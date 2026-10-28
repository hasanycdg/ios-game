import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func germanyRemainsTheDefaultAndLegacySnapshotsStayGerman() throws {
    let engine = GameEngine()
    engine.startNewGame()
    #expect(engine.country == .germany)
    #expect(engine.currentEvent?.id == "energy-policy-2000")
    let data = try JSONEncoder().encode(engine.snapshot())
    var object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    object.removeValue(forKey: "country")
    let legacy = try JSONDecoder().decode(GameSessionSnapshot.self, from: JSONSerialization.data(withJSONObject: object))
    #expect(legacy.country == .germany)
    let resumed = GameEngine(snapshot: legacy)
    #expect(resumed.country == .germany)
    #expect(resumed.currentEvent?.id == engine.currentEvent?.id)
    #expect(resumed.state == engine.state)
}

@Test func countrySavesResultsAndAchievementsAreIndependent() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let german = GamePersistence(baseDirectory: directory)
    let american = GamePersistence(baseDirectory: directory, country: .unitedStates)
    let de = GameEngine(); de.startNewGame()
    let us = GameEngine(country: .unitedStates); us.startNewGame()
    try german.saveSnapshot(de.snapshot())
    try american.saveSnapshot(us.snapshot())
    try german.unlockAchievements(["reach-2026"])
    try american.unlockAchievements(["score-800"])
    try american.appendRunResult(RunResult(startYear: 2000, endYear: 2004, endReason: .lostElection, score: 123, governingStyle: "Test"))
    #expect(german.loadSnapshot()?.country == .germany)
    #expect(american.loadSnapshot()?.country == .unitedStates)
    #expect(german.loadUnlockedAchievements() == ["reach-2026"])
    #expect(american.loadUnlockedAchievements() == ["score-800"])
    #expect(german.loadRunResults().isEmpty)
    #expect(american.loadRunResults().count == 1)
    try american.deleteSnapshot()
    #expect(german.hasSaveGame)
    #expect(!american.hasSaveGame)
    #expect(FileManager.default.fileExists(atPath: directory.appendingPathComponent("savegame.json").path))
}

@Test func usCatalogIsSeparateCompleteAndHasValidChoices() {
    let us = USEventRepository().loadEvents()
    let germanIDs = Set(LocalJSONEventRepository().loadEvents().map(\.id))
    #expect(us.count == 383)
    #expect(Set(us.map(\.id)).count == us.count)
    #expect(us.allSatisfy { !germanIDs.contains($0.id) && $0.options.count == 3 })
    for year in 2000...2026 {
        #expect(us.filter { $0.year == year && !$0.id.hasPrefix("future-") }.count == 4)
    }
    for year in 2026...2050 {
        #expect(us.filter { $0.year == year && FutureScenario.isStoryEvent($0.id) }.count == 8)
        #expect(us.filter { $0.year == year && $0.id.hasPrefix("future-us-extra-") }.count == 3)
    }
    #expect(us.allSatisfy { !$0.description.contains("Deutschland") })
    #expect(us.allSatisfy { !$0.options.flatMap(\.delayedEffects).isEmpty })
    #expect(USNewsRepository().loadNews().count == 383)
}

@Test func usCampaignRestoresItsCountryPartyEventsAndElectionCalendar() throws {
    let engine = GameEngine(country: .unitedStates)
    engine.startNewGame(party: USPartyCatalog.playable[1], playerName: "Taylor 🇺🇸", seed: 42)
    #expect(engine.awaitingInitialBriefing)
    #expect(engine.pendingCoalitionOptions?.allSatisfy { !$0.partyName.contains("SDP") } == true)
    engine.dismissInitialBriefing()
    engine.formCoalition(optionID: try #require(engine.pendingCoalitionOptions?.first?.id))
    engine.concludeCoalitionTalks(acceptedDemandIDs: Set(engine.pendingCoalitionTalks?.demands.map(\.id) ?? []))
    let current = try #require(engine.currentEvent)
    #expect(current.id.hasPrefix("us-2000-"))
    let snapshot = try JSONDecoder().decode(GameSessionSnapshot.self, from: JSONEncoder().encode(engine.snapshot()))
    let restored = GameEngine(snapshot: snapshot)
    #expect(restored.country == .unitedStates)
    #expect(restored.playerName == "Taylor 🇺🇸")
    #expect(restored.playerParty.id == "republican")
    #expect(restored.persona.id == restored.playerParty.profile.id)
    #expect(restored.currentEvent?.id == current.id)
    #expect(restored.state == engine.state)
    #expect(ElectionEngine(country: .unitedStates).nextElectionYear(onOrAfter: 2000) == 2004)
    #expect(ElectionEngine().nextElectionYear(onOrAfter: 2000) == 2005)
}

@Test func electoralAllocationsAlwaysTotal538AndHaveTheRightCensusChanges() {
    for year in [2000, 2004, 2008, 2012, 2020, 2024, 2050] {
        let allocation = USElectoralCollege.allocations(for: year)
        #expect(allocation.count == 51)
        #expect(allocation.values.reduce(0, +) == 538, "Wrong electoral total in \(year)")
    }
    #expect(USElectoralCollege.allocations(for: 2000)["FL"] == 25)
    #expect(USElectoralCollege.allocations(for: 2024)["FL"] == 30)
    #expect(USElectoralCollege.allocations(for: 2012)["CA"] == 55)
    #expect(USElectoralCollege.allocations(for: 2024)["CA"] == 54)
}

@Test func usElectionResultsAndProjectionAgreeAndStoreElectoralVotes() {
    let calendar = ElectionEngine(country: .unitedStates)
    var state = GameCountry.unitedStates.initialState()
    state.currentYear = 2004
    let result = calendar.conductElection(in: state)
    #expect(calendar.project(in: state).wouldWin == result.didWin)
    #expect(result.electoralVotes != nil)
    #expect(result.didWin == ((result.electoralVotes ?? 0) >= 270))
    #expect(abs(result.governingPartyShare + result.oppositionShare - 96) < 0.01)
    #expect(ElectionEngine().conductElection(in: state).electoralVotes == nil)
}

@Test func usDiplomacyDoesNotTargetTheUnitedStates() {
    let engine = GameEngine(country: .unitedStates)
    engine.startNewGame()
    #expect(!engine.country.diplomaticPartners.contains(.usa))
    #expect(engine.country.diplomaticPartners.contains(.canada))
    #expect(!engine.takeDiplomaticAction(.usa, actionID: "us-visit"))
    #expect(engine.takeDiplomaticAction(.canada, actionID: "us-ca-summit"))
    #expect(engine.cabinet.ministers.values.allSatisfy { !$0.name.contains("Frau ") && !$0.name.contains("Herr ") })
}

@Test func englishTemplatesTranslateInterpolatedMechanics() {
    #expect(USLocalization.translate("Nächste Bundestagswahl: 2004") == "Next presidential election: 2004")
    #expect(USLocalization.translate("Politisches Kapital: 7 von 10") == "Political capital: 7 of 10")
    #expect(USLocalization.translate("Diplomatische Krise mit Russland: Das Verhältnis ist zerrüttet.") == "Diplomatic crisis with Russia: relations have broken down.")
    #expect(USLocalization.translate("Ein großer Energiekonzern") == "A major energy company")
    #expect(USLocalization.translate("Your player-written name 🇺🇸") == "Your player-written name 🇺🇸")
    #expect(!USLocalization.catalog.isEmpty)
}

@Test func usFiscalDecisionsAndCrisisShocksHaveConsistentEffects() throws {
    let repository = USEventRepository()
    let tax = try #require(repository.events(for: 2017).first { $0.id == "us-2017-tax-reform-and-federal-revenue" })
    #expect(tax.options[2].immediateEffects.filter { $0.metric == .budget }.reduce(0) { $0 + $1.change } < 0)
    #expect(tax.options[2].immediateEffects.filter { $0.metric == .economy }.reduce(0) { $0 + $1.change } > 0)
    let crash = try #require(repository.events(for: 2008).first { $0.id == "us-2008-lehman-and-the-financial-panic" })
    #expect(crash.options.allSatisfy { $0.immediateEffects.filter { $0.metric == .economy }.reduce(0) { $0 + $1.change } < 0 })
    let pandemic = try #require(repository.events(for: 2020).first { $0.id == "us-2020-covid-19" })
    #expect(pandemic.options.allSatisfy { $0.immediateEffects.contains { $0.metric == .economy && $0.change < 0 } })
    let protection = try #require(crash.options[1].conditionalModifiers.first { $0.conditions.contains { $0.requiredFlags.contains("us_mortgage_oversight") } })
    var state = GameCountry.unitedStates.initialState()
    #expect(!protection.isSatisfied(by: state))
    state.historicalFlags.insert("us_mortgage_oversight")
    #expect(protection.isSatisfied(by: state))
    #expect(protection.immediateEffects.contains { $0.metric == .economy && $0.change > 0 })
}

@Test func usCongressionalRevoltDoesNotCallAnEarlyPresidentialElection() {
    var state = GameCountry.unitedStates.initialState()
    state.currentYear = 2001
    state.yearProgress = YearProgress(year: 2001)
    let engine = GameEngine(snapshot: GameSessionSnapshot(country: .unitedStates, state: state,
        currentEventID: nil, lastDecisionResult: nil,
        coalition: CoalitionState(partnerName: "Congressional caucus", leaning: .left, satisfaction: 0),
        playerPartyID: "democratic"))
    engine.advanceGame()
    #expect(engine.state.pendingElectionResult == nil)
    #expect(engine.state.electionResults.isEmpty)
    #expect(engine.currentEvent?.year == 2001)
    #expect(engine.coalition.satisfaction == 35)
}

@Test func usCrisisChoicesChangeTheReconstructionBranch() throws {
    func response(war: Bool) throws -> (GameEngine, DecisionResult) {
        let engine = GameEngine(country: .unitedStates, finalYear: 2050)
        engine.startNewGame()
        engine.debugTriggerEvent(id: "future-scenario-us-2030-2")
        let crisis = try #require(engine.currentEvent)
        try engine.choose(option: crisis.options[war ? 0 : 1])
        #expect(engine.state.historicalFlags.contains(war ? "scenario_world_war" : "scenario_war_avoided"))
        engine.debugJumpToYear(2035)
        let event = try #require(engine.currentEvent)
        return (engine, try engine.choose(option: event.options[1]))
    }
    let (war, warResult) = try response(war: true)
    let (peace, peaceResult) = try response(war: false)
    #expect(warResult.visibleEffects.first { $0.metric == .budget }?.change == -2)
    #expect(peaceResult.visibleEffects.first { $0.metric == .budget }?.change == -1)
    #expect(war.state.historicalFlags.contains("scenario_world_war"))
    #expect(peace.state.historicalFlags.contains("scenario_war_avoided"))
    #expect(Set(warResult.visibleEffects.map(\.metric)).count == warResult.visibleEffects.count)
}

@Test func aSaveCannotBeWrittenIntoTheWrongCountrySlot() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let engine = GameEngine(country: .unitedStates)
    engine.startNewGame()
    #expect(throws: GamePersistence.PersistenceError.self) {
        try GamePersistence(baseDirectory: directory).saveSnapshot(engine.snapshot())
    }
    #expect(!FileManager.default.fileExists(atPath: directory.appendingPathComponent("savegame.json").path))
}

@Test func englishCatalogPreservesAllInterpolationPlaceholders() throws {
    let regex = try NSRegularExpression(pattern: #"\{\d+\}"#)
    func placeholders(_ value: String) -> Set<String> {
        Set(regex.matches(in: value, range: NSRange(value.startIndex..., in: value)).compactMap {
            Range($0.range, in: value).map { String(value[$0]) }
        })
    }
    for (source, english) in USLocalization.catalog {
        #expect(placeholders(source) == placeholders(english), "Placeholder mismatch: \(source)")
    }
}

@Test(arguments: [UInt64(0), 42, 777])
func usFutureStoryHasEightOrderedStepsAndSurvivesResuming(seed: UInt64) throws {
    let engine = GameEngine(country: .unitedStates, finalYear: 2050)
    engine.startNewGame(party: USPartyCatalog.playable[0], playerName: "Alex", seed: seed)
    engine.debugJumpToYear(2027)
    for step in 1...8 {
        let event = try #require(engine.currentEvent)
        #expect(event.scenarioStep == step)
        try engine.choose(option: event.options[1])
        engine.advanceGame()
        let restored = GameEngine(snapshot: engine.snapshot())
        #expect(restored.country == .unitedStates)
        #expect(restored.currentEvent?.id == engine.currentEvent?.id)
    }
    #expect(engine.currentEvent?.id.hasPrefix("future-us-extra-") == true)
}

@Test(arguments: [2004, 2026])
func usExpansionContinuesTheSameCampaignAtEachPurchaseBoundary(checkpoint: Int) throws {
    let repository = USEventRepository()
    var state = GameCountry.unitedStates.initialState()
    state.currentYear = checkpoint
    state.yearProgress = YearProgress(year: checkpoint, completedEventIDs: Set(repository.events(for: checkpoint).filter { !$0.id.hasPrefix("future-") }.map(\.id)), isElectionResolved: true)
    state.gameOverSummary = GameOverSummary(reason: .reachedFinalYear, message: "Complete", startYear: 2000, endYear: checkpoint, keyDecisionTitles: [], finalStats: state.visible, defeatReasons: [], governingStyle: "Test")
    let engine = GameEngine(snapshot: GameSessionSnapshot(country: .unitedStates, state: state, currentEventID: nil, lastDecisionResult: nil, playerPartyID: "democratic", playerName: "Existing run", finalYear: checkpoint))
    engine.extendCampaign(to: 2050)
    #expect(engine.state.gameOverSummary == nil)
    #expect(engine.country == .unitedStates)
    #expect(engine.playerName == "Existing run")
    #expect(engine.currentEvent?.year == (checkpoint == 2004 ? 2005 : 2026))
    #expect(engine.currentEvent?.id.hasPrefix(checkpoint == 2004 ? "us-" : "future-scenario-us-") == true)
}

@Test(arguments: ["democratic", "republican", "libertarian", "green_us"])
func aUSCampaignCanBePlayedFrom2000Through2050(partyID: String) throws {
    let engine = GameEngine(country: .unitedStates, finalYear: 2050)
    engine.startNewGame(party: GameCountry.unitedStates.party(id: partyID), playerName: "Player", difficulty: .normal, seed: 42)
    var steps = 0
    while engine.state.gameOverSummary == nil && steps < 2000 {
        steps += 1
        if engine.awaitingInitialBriefing { engine.dismissInitialBriefing() }
        else if let options = engine.pendingCoalitionOptions { engine.formCoalition(optionID: options[0].id) }
        else if let talks = engine.pendingCoalitionTalks { engine.concludeCoalitionTalks(acceptedDemandIDs: Set(talks.demands.map(\.id))) }
        else if engine.state.pendingElectionResult != nil { engine.continueAfterElection() }
        else if engine.pendingCampaign { engine.runCampaign(focus: CampaignFocusCatalog.all[0]) }
        else if let encounter = engine.pendingEncounter { engine.resolveEncounter(optionID: encounter.options[1].id) }
        else if let event = engine.currentEvent { try engine.choose(option: event.options[1]); engine.advanceGame() }
        else { engine.advanceGame() }
    }
    #expect(steps < 2000)
    #expect(engine.state.currentYear == 2050)
    #expect(engine.state.gameOverSummary?.reason == .reachedFinalYear)
    #expect(engine.state.electionResults.map(\.year) == Array(stride(from: 2004, through: 2048, by: 4)))
    #expect(engine.state.electionResults.allSatisfy { $0.electoralVotes != nil })
    #expect(engine.state.decisions.filter { FutureScenario.isStoryEvent($0.eventID) }.count == 200)
    #expect(engine.state.triggeredHistoricalEchoes.contains { $0.sourceEventID == "us-midterms" && $0.year == 2002 })
}

@Test func automaticCampaignOfferRespectsOwnershipAndFrequency() {
    let now = 2_000_000.0
    let recent = now - CampaignOfferSchedule.interval + 1
    #expect(!CampaignOfferSchedule.shouldPresent(hasFutureCampaign: true, lastPresented: 0, now: now, afterOnboarding: true))
    #expect(CampaignOfferSchedule.shouldPresent(hasFutureCampaign: false, lastPresented: recent, now: now, afterOnboarding: true))
    #expect(!CampaignOfferSchedule.shouldPresent(hasFutureCampaign: false, lastPresented: recent, now: now, afterOnboarding: false))
    #expect(CampaignOfferSchedule.shouldPresent(hasFutureCampaign: false, lastPresented: now - CampaignOfferSchedule.interval, now: now, afterOnboarding: false))
    #expect(CampaignOfferSchedule.shouldPresent(hasFutureCampaign: false, lastPresented: 0, now: now, afterOnboarding: false))
}
