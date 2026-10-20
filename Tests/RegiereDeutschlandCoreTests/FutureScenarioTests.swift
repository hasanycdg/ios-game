import Foundation
import Testing
@testable import RegiereDeutschlandCore

private let scenarioRepository = LocalJSONEventRepository(resourceNames: ["Future2050Scenarios"])

private func scenarioEngine(year: Int, flags: Set<String> = [], seed: UInt64 = 0,
                            repository: any EventRepository = scenarioRepository) -> GameEngine {
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = year
    state.yearProgress = YearProgress(year: year)
    state.historicalFlags = flags.union(["content_future_2050", "content_2005_2026"])
    return GameEngine(
        snapshot: GameSessionSnapshot(state: state, currentEventID: nil, lastDecisionResult: nil,
                                      randomSeed: String(seed), finalYear: 2050),
        eventRepository: repository
    )
}

@Test func scenarioBranchesLoadWithThreeDecisionsAndStayBehindTheAddon() {
    let events = scenarioRepository.loadEvents()
    #expect(events.count == 227)
    #expect(Set(events.map(\.id)).count == events.count)
    #expect(Set(events.flatMap { $0.options.map(\.id) }).count > 600)
    for event in events {
        #expect(event.options.count == 3)
        #expect((2026...2050).contains(event.year))
        #expect(event.scenarioStep.map { (0..<8).contains($0) } == true)
        var state = scenarioEngine(year: event.year).state
        state.historicalFlags.formUnion(event.conditions.flatMap(\.requiredFlags))
        state.historicalFlags.subtract(event.conditions.flatMap(\.blockedByFlags))
        #expect(event.isAvailable(in: state), "Unerreichbares Szenario: \(event.id)")
        state.historicalFlags.remove("content_future_2050")
        #expect(!event.isAvailable(in: state), "Add-on ohne Kauf erreichbar: \(event.id)")
        #expect(FutureScenario.chapter(in: state) == nil)
    }
}

@Test(arguments: [UInt64(1), 42, 777, 987654])
func seededFutureYearsAlwaysStartWithTheirStoryDecision(seed: UInt64) {
    let repository = LocalJSONEventRepository()
    for year in 2027...2050 {
        let engine = scenarioEngine(year: year, seed: seed, repository: repository)
        engine.advanceGame()
        #expect(engine.currentEvent.map { FutureScenario.isStoryEvent($0.id) } == true,
                "Szenario fehlt bei Seed \(seed), Jahr \(year)")
    }
}

@Test func historical2026FinishesBeforeThePurchasedFutureBegins() {
    let engine = scenarioEngine(year: 2026, seed: 42, repository: LocalJSONEventRepository())
    engine.advanceGame()
    #expect(engine.currentEvent?.id.hasPrefix("future-") == false)
    let queue = engine.state.eventQueue.pendingEventIDs
    guard let storyIndex = queue.firstIndex(where: FutureScenario.isStoryEvent) else {
        Issue.record("Zukunftseinstieg fehlt")
        return
    }
    #expect(queue.prefix(storyIndex).allSatisfy { !$0.hasPrefix("future-") })
    #expect(queue.dropFirst(storyIndex + 1).allSatisfy { $0.hasPrefix("future-") })
}

@Test func futurePurchaseResumesThe2026FinaleWithoutResettingTheCountry() throws {
    let repository = LocalJSONEventRepository()
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2026
    state.visible.budget = 37
    state.historicalFlags.insert("energy_2000_renewables_priority")
    state.yearProgress = YearProgress(year: 2026, completedEventIDs: Set(
        repository.events(for: 2026).filter { !$0.id.hasPrefix("future-") }.map(\.id)
    ))
    state.gameOverSummary = GameOverSummary(reason: .reachedFinalYear, message: "Finale 2026",
        startYear: 2000, endYear: 2026, keyDecisionTitles: [], finalStats: state.visible,
        defeatReasons: [], governingStyle: "Test")
    let engine = GameEngine(snapshot: GameSessionSnapshot(state: state, currentEventID: nil,
        lastDecisionResult: nil, finalYear: 2026), eventRepository: repository)

    engine.extendCampaign(to: 2050)

    #expect(engine.state.currentYear == 2026)
    #expect(engine.state.visible.budget == 37)
    #expect(engine.state.historicalFlags.contains("energy_2000_renewables_priority"))
    #expect(engine.currentEvent?.id == "future-scenario-2026-doctrine")
    #expect(engine.state.gameOverSummary == nil)
    #expect(engine.finalYear == 2050)
    try engine.choose(option: "scenario-dialogue")
    #expect(engine.state.historicalFlags.contains("scenario_dialogue"))
}

@Test func theBaseCampaignNeverOffersTheScenarioEvenIn2026() {
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2026
    let engine = GameEngine(initialState: state, finalYear: 2026)
    #expect(!engine.availableEvents().contains { FutureScenario.isStoryEvent($0.id) })
    #expect(FutureScenario.chapter(in: engine.state) == nil)
}

#if DEBUG
@Test func debugScenarioFixtureStartsAtTheAddonWithoutHistoricalChoices() {
    let engine = GameEngine()
    engine.debugStartFutureCampaign(party: PartyCatalog.party(id: "spd"), playerName: "Zukunftstest", seed: 777)
    #expect(engine.finalYear == 2050)
    #expect(engine.state.currentYear == 2026)
    #expect(engine.currentEvent?.id == "future-scenario-2026-doctrine")
    #expect(engine.state.historicalFlags.contains("content_future_2050"))
    #expect(engine.state.historicalFlags.contains("debug_future_preview"))
    #expect(engine.state.decisions.isEmpty)
    #expect(!engine.awaitingInitialBriefing)
    #expect(!engine.awaitingInitialCoalition)
    #expect(engine.pendingCoalitionOptions == nil)
    #expect(engine.annualHistory.count == 1)
    #expect(engine.annualHistory.first?.year == 2026)
    #expect(engine.playerName == "Zukunftstest")
}

@Test func futureScenarioFixtureSavesAndResumesIndependentlyOfTheRegularCampaign() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let regular = GamePersistence(baseDirectory: directory)
    let regularEngine = GameEngine(finalYear: 2026)
    regularEngine.startNewGame()
    let original = regularEngine.snapshot()
    try regular.saveSnapshot(original)

    let preview = GamePersistence(baseDirectory: directory.appendingPathComponent("ScenarioFixture"))
    let previewEngine = GameEngine()
    previewEngine.debugStartFutureCampaign(seed: 777)
    try previewEngine.choose(option: "scenario-dialogue")
    previewEngine.advanceGame()
    try preview.saveSnapshot(previewEngine.snapshot())

    #expect(regular.loadSnapshot() == original)
    let restored = GameEngine(snapshot: try #require(preview.loadSnapshot()))
    #expect(restored.finalYear == 2050)
    #expect(restored.state.decisions.count == 1)
    #expect(restored.currentEvent?.scenarioStep == 1)
    #expect(restored.state.historicalFlags.contains("debug_future_preview"))

    previewEngine.debugStartFutureCampaign(seed: 42)
    #expect(previewEngine.state.currentYear == 2026)
    #expect(previewEngine.state.decisions.isEmpty)
    #expect(previewEngine.state.scheduledEffects.isEmpty)
    #expect(previewEngine.currentEvent?.id == "future-scenario-2026-doctrine")
}

@Test(arguments: [false, true])
func summitDecisionChangesTheCrisisAndReconstructionBranches(war: Bool) throws {
    let engine = scenarioEngine(year: 2031)
    engine.advanceGame()
    try engine.choose(option: war ? "scenario-summit-ultimatum" : "scenario-summit-accord")
    engine.debugJumpToYear(2032)
    #expect(engine.currentEvent?.id == (war ? "future-scenario-2032-confrontation" : "future-scenario-2032-accord"))
    try engine.choose(option: war ? "scenario-confrontation-war" : "scenario-accord-treaty")

    // Durch einen echten JSON-Speichervorgang müssen Verzweigung und Folgen erhalten bleiben.
    let data = try JSONEncoder().encode(engine.snapshot())
    let restored = GameEngine(snapshot: try JSONDecoder().decode(GameSessionSnapshot.self, from: data),
                              eventRepository: scenarioRepository)
    #expect(restored.state.historicalFlags == engine.state.historicalFlags)
    #expect(restored.state.scheduledEffects == engine.state.scheduledEffects)
    #expect(restored.state.decisions == engine.state.decisions)

    for (year, suffix) in [(2033, war ? "war-relief" : "peace-dividend"),
                           (2034, war ? "armistice" : "peace-security"),
                           (2035, war ? "rebuild-war" : "rebuild-peace")] {
        restored.debugJumpToYear(year)
        #expect(restored.currentEvent?.id == "future-scenario-\(year)-\(suffix)")
        let event = try #require(restored.currentEvent)
        try restored.choose(option: event.options[0].id)
    }
    #expect(restored.state.historicalFlags.contains("scenario_world_war") == war)
    #expect(restored.state.historicalFlags.contains("scenario_war_avoided") == !war)
    #expect(restored.state.historicalFlags.contains("scenario_war_damage") == war)
}

@Test func lastMinuteDiplomacyCanStillPreventWarAfterAnUltimatum() throws {
    let engine = scenarioEngine(year: 2031)
    engine.advanceGame()
    try engine.choose(option: "scenario-summit-ultimatum")
    engine.debugJumpToYear(2032)
    try engine.choose(option: "scenario-confrontation-mediate")
    engine.debugJumpToYear(2033)
    #expect(engine.currentEvent?.id == "future-scenario-2033-peace-dividend")
    #expect(!engine.state.historicalFlags.contains("scenario_world_war"))
}

@Test func reconstructionInvestmentsChangeLaterDecisionEffects() throws {
    let invested = scenarioEngine(year: 2035)
    invested.advanceGame()
    try invested.choose(option: "scenario-rebuild-public")
    invested.debugJumpToYear(2039)
    #expect(invested.state.historicalFlags.contains("scenario_rebuild_dividend"))
    let supported = try invested.choose(option: "scenario-regions-equalize")

    let austerity = scenarioEngine(year: 2039)
    austerity.advanceGame()
    let unsupported = try austerity.choose(option: "scenario-regions-equalize")
    #expect(supported.visibleEffects.filter { $0.metric == .budget }.reduce(0) { $0 + $1.change } == -1)
    #expect(unsupported.visibleEffects.filter { $0.metric == .budget }.reduce(0) { $0 + $1.change } == -3)
}

@Test(arguments: ["cooperate", "blocs", "isolate"])
func theChosenWorldOrderDeterminesThe2050Finale(order: String) throws {
    let engine = scenarioEngine(year: 2043)
    engine.advanceGame()
    try engine.choose(option: "scenario-charter-\(order)")
    engine.debugJumpToYear(2050)
    let suffix = order == "cooperate" ? "cooperation" : (order == "blocs" ? "blocs" : "isolation")
    for _ in 0..<7 {
        let detail = try #require(engine.currentEvent)
        try engine.choose(option: detail.options[0].id)
        engine.advanceGame()
    }
    #expect(engine.currentEvent?.id == "future-scenario-2050-final-\(suffix)")
    try engine.choose(option: "scenario-final-review")
    engine.advanceGame()
    #expect(engine.state.gameOverSummary?.reason == .reachedFinalYear)
    #expect(engine.state.historicalFlags.contains("scenario_ending_accountable"))
}

@Test(arguments: [false, true])
func completeScenarioRoutesOfferEightSequentialDecisionsEveryYear(war: Bool) throws {
    let engine = scenarioEngine(year: 2026, seed: 777)
    for year in 2026...2050 {
        engine.debugJumpToYear(year)
        for step in 0..<8 {
            let event = try #require(engine.currentEvent)
            #expect(event.scenarioStep == step, "Falsche Reihenfolge in \(year)")
            #expect(engine.availableEvents().filter { $0.scenarioStep == step }.count == 1,
                    "Widersprüchliche Zweige in \(year), Schritt \(step)")
            let choice: String
            if year == 2031, step == 0, war { choice = "scenario-summit-ultimatum" }
            else if year == 2032, step == 0, war { choice = "scenario-confrontation-war" }
            else { choice = event.options[0].id }
            try engine.choose(option: choice)
            if step < 7 { engine.advanceGame() }
        }
        #expect(FutureScenario.completedDecisions(in: engine.state) == 8)
    }
    #expect(engine.state.decisions.count == 200)
    #expect(engine.state.historicalFlags.contains("scenario_ending_open"))
    #expect(engine.state.historicalFlags.contains("scenario_world_war") == war)
    engine.advanceGame()
    #expect(engine.state.gameOverSummary?.endYear == 2050)
}

@Test(arguments: [UInt64(0), 42, 777])
func longStoryChainsDoNotSkipTheThreeExistingFutureEvents(seed: UInt64) throws {
    let repository = LocalJSONEventRepository()
    for year in 2027...2050 {
        let engine = scenarioEngine(year: year, flags: ["scenario_deescalation_2031"],
                                    seed: seed, repository: repository)
        engine.advanceGame()
        var ids = Set<String>()
        for position in 0..<11 {
            let event = try #require(engine.currentEvent, "Ereignis \(position + 1) fehlt in \(year)")
            #expect(ids.insert(event.id).inserted, "Ereignis doppelt gespielt: \(event.id)")
            #expect(FutureScenario.isStoryEvent(event.id) == (position < 8))
            try engine.choose(option: event.options[0].id)
            if position < 10 { engine.advanceGame() }
        }
        #expect(engine.state.currentYear == year)
        #expect(engine.availableEvents().isEmpty)
        #expect(engine.state.decisions.count == 11)
    }
}

@Test func anEarlierProtectionDecisionChangesTheLaterWarConsequences() throws {
    let prepared = scenarioEngine(year: 2032,
        flags: ["scenario_detail_2030_01_a", "scenario_detail_2031_03_a"])
    prepared.advanceGame()
    let protected = try prepared.choose(option: "scenario-confrontation-war")
    let unprepared = scenarioEngine(year: 2032)
    unprepared.advanceGame()
    let exposed = try unprepared.choose(option: "scenario-confrontation-war")
    let protectedSecurity = protected.visibleEffects.filter { $0.metric == .security }.reduce(0) { $0 + $1.change }
    let exposedSecurity = exposed.visibleEffects.filter { $0.metric == .security }.reduce(0) { $0 + $1.change }
    #expect(protectedSecurity == exposedSecurity + 2)
    #expect(prepared.state.historicalFlags.contains("scenario_world_war"))
}

@Test func savingBetweenStoryStepsResumesAtTheNextDecisionWithoutRepeating() throws {
    let engine = scenarioEngine(year: 2035, flags: ["scenario_world_war"], seed: 777)
    engine.advanceGame()
    for _ in 0..<4 {
        let event = try #require(engine.currentEvent)
        try engine.choose(option: event.options[0].id)
        engine.advanceGame()
    }
    let data = try JSONEncoder().encode(engine.snapshot())
    let restored = GameEngine(snapshot: try JSONDecoder().decode(GameSessionSnapshot.self, from: data),
                              eventRepository: scenarioRepository)
    #expect(restored.currentEvent?.scenarioStep == 4)
    #expect(FutureScenario.completedDecisions(in: restored.state) == 4)
    for step in 4..<8 {
        let event = try #require(restored.currentEvent)
        #expect(event.scenarioStep == step)
        #expect(!restored.state.yearProgress.completedEventIDs.contains(event.id))
        try restored.choose(option: event.options[0].id)
        if step < 7 { restored.advanceGame() }
    }
    #expect(restored.state.decisions.count == 8)
    #expect(restored.state.scheduledEffects.isEmpty == false)
}

@Test(arguments: [false, true])
func theExpandedFutureCanBePlayedThroughWithNormalYearAndElectionProgression(war: Bool) throws {
    let engine = scenarioEngine(year: 2026, seed: 777, repository: LocalJSONEventRepository())
    engine.advanceGame()
    for _ in 0..<1500 {
        if engine.state.gameOverSummary != nil { break }
        if engine.pendingCampaign {
            engine.runCampaign(focus: CampaignFocusCatalog.all[0])
        } else if engine.state.pendingElectionResult != nil {
            engine.continueAfterElection()
        } else if let talks = engine.pendingCoalitionTalks {
            engine.concludeCoalitionTalks(acceptedDemandIDs: Set(talks.demands.map(\.id)))
        } else if let options = engine.pendingCoalitionOptions {
            engine.formCoalition(optionID: options[0].id)
        } else if let encounter = engine.pendingEncounter {
            let response = encounter.options.first { $0.corruptionEffect <= 0 } ?? encounter.options[0]
            engine.resolveEncounter(optionID: response.id)
        } else if let event = engine.currentEvent {
            let optionID: String
            if war && event.id == "future-scenario-2031-summit" { optionID = "scenario-summit-ultimatum" }
            else if war && event.id == "future-scenario-2032-confrontation" { optionID = "scenario-confrontation-war" }
            else { optionID = event.options[0].id }
            let option = try #require(event.options.first { $0.id == optionID })
            #expect(engine.canAfford(option, among: event.options))
            try engine.choose(option: optionID)
            engine.advanceGame()
        } else {
            engine.advanceGame()
        }
    }
    #expect(engine.state.gameOverSummary?.reason == .reachedFinalYear)
    #expect(engine.state.currentYear == 2050)
    #expect(engine.state.decisions.filter { FutureScenario.isStoryEvent($0.eventID) }.count == 200)
    #expect(engine.state.decisions.filter { $0.eventID.hasPrefix("future-") }.count == 275)
}
#endif
