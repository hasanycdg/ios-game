import Foundation
import Testing
@testable import RegiereDeutschlandCore

private let europeanCountries: [GameCountry] = [.unitedKingdom, .france]

@discardableResult
private func play(_ engine: GameEngine, choice: Int = 1, maxSteps: Int = 3000) throws -> Int {
    var steps = 0
    while engine.state.gameOverSummary == nil && steps < maxSteps {
        steps += 1
        if engine.awaitingInitialBriefing { engine.dismissInitialBriefing() }
        else if let options = engine.pendingCoalitionOptions { engine.formCoalition(optionID: options[0].id) }
        else if let talks = engine.pendingCoalitionTalks { engine.concludeCoalitionTalks(acceptedDemandIDs: Set(talks.demands.map(\.id))) }
        else if engine.state.pendingElectionResult != nil { engine.continueAfterElection() }
        else if engine.pendingCampaign { engine.runCampaign(focus: CampaignFocusCatalog.all[0]) }
        else if let encounter = engine.pendingEncounter { engine.resolveEncounter(optionID: encounter.options[1].id) }
        else if let event = engine.currentEvent { try engine.choose(option: event.options[min(choice, event.options.count - 1)]); engine.advanceGame() }
        else { engine.advanceGame() }
    }
    return steps
}

@Test(arguments: europeanCountries)
func europeanCatalogHasFourValidDecisionsEveryYear(country: GameCountry) throws {
    let events = EuropeanEventRepository(country: country).loadEvents().filter { !$0.id.hasPrefix("future-") }
    #expect(events.count == 108)
    for year in 2000...2026 {
        #expect(events.filter { $0.year == year }.count == 4, "\(country) \(year)")
    }
    #expect(Set(events.map(\.id)).count == events.count)
    for event in events {
        #expect(event.id.hasPrefix(country == .france ? "fr-" : "uk-"))
        #expect(event.options.count == 3)
        #expect(Set(event.options.map(\.id)).count == 3)
        #expect(!event.title.isEmpty && event.historicalReality?.isEmpty == false)
    }
    // Never loads German or US content.
    let all = EuropeanEventRepository(country: country).loadEvents()
    #expect(!all.contains { $0.id.hasPrefix("us-") || $0.id.contains("-us-") || $0.id.hasPrefix("future-scenario-2") })
}

@Test(arguments: europeanCountries)
func everyEuropeanTextHasAGermanTranslationAndStaysEnglishInEnglish(country: GameCountry) throws {
    for event in EuropeanEventRepository(country: country).loadEvents() {
        var texts = [event.title, event.description, event.historicalContext.summary]
        texts += event.options.flatMap { [$0.title, $0.description, $0.advisoryNote] }
        texts += event.options.flatMap { $0.delayedEffects.compactMap(\.note) }
        for text in texts where !text.isEmpty {
            let german = GameTextLocalization.translate(text, country: country, language: .german)
            #expect(german != text, "Missing German: \(text)")
            #expect(GameTextLocalization.translate(text, country: country, language: .english) == text)
        }
    }
    for party in country.playableParties {
        #expect(GameTextLocalization.translate(party.tagline, country: country, language: .german) != party.tagline)
        for item in party.agenda {
            for text in [item.title, item.summary, item.demand] {
                #expect(GameTextLocalization.translate(text, country: country, language: .german) != text, "\(text)")
            }
        }
    }
}

@Test func europeanTerminologyReplacesGermanInstitutions() {
    #expect(GameTextLocalization.translate("Nächste Bundestagswahl: 2005", country: .unitedKingdom, language: .english) == "Next general election: 2005")
    #expect(GameTextLocalization.translate("Nächste Bundestagswahl: 2007", country: .france, language: .german) == "Nächste Präsidentschaftswahl: 2007")
    #expect(GameTextLocalization.translate("Bundestag", country: .unitedKingdom, language: .german) == "Unterhaus")
    #expect(GameTextLocalization.translate("DEUTSCHLAND", country: .france, language: .english) == "FRANCE")
    #expect(GameTextLocalization.translate("Stichwahl: 54.2 % gegen Front Patriote", country: .france, language: .english) == "Run-off: 54.2% against Front Patriote")
    #expect(GameTextLocalization.translate("Sitze: 412 von 650 (Mehrheit ab 326)", country: .unitedKingdom, language: .english) == "Seats: 412 of 650 (majority: 326)")
    // Germany and the US are unaffected.
    #expect(GameTextLocalization.translate("Bundestag", country: .germany, language: .german) == "Bundestag")
    #expect(GameTextLocalization.translate("Bundestag", country: .unitedStates, language: .german) == "Kongress")
}

@Test(arguments: europeanCountries)
func seatAllocationIsCompleteAndFavoursTheLeader(country: GameCountry) {
    let landscape = PartyLandscapeFactory.makeFromBaseSupport(playerParty: country.defaultParty, country: country)
    #expect(landscape.parties.reduce(0) { $0 + $1.seats } == country.parliamentSeats)
    let leader = landscape.parties.max { $0.support < $1.support }!
    #expect(Double(leader.seats) / Double(country.parliamentSeats) * 100 > leader.support)
}

@Test func europeanElectionCalendarsFollowHistory() {
    #expect(ElectionEngine(country: .unitedKingdom).electionYears.filter { $0 <= 2026 }.sorted() == [2001, 2005, 2010, 2015, 2017, 2019, 2024])
    #expect(ElectionEngine(country: .france).electionYears.filter { $0 <= 2026 }.sorted() == [2002, 2007, 2012, 2017, 2022])
}

@Test func aLargeUKPartyCanGovernAloneAndASmallOneNeedsPartners() throws {
    let labour = GameEngine(country: .unitedKingdom)
    labour.startNewGame(party: GameCountry.unitedKingdom.party(id: "uk_labour"), playerName: "PM")
    let options = try #require(labour.pendingCoalitionOptions)
    #expect(options.first?.id == GameEngine.singlePartyMajorityID)
    labour.dismissInitialBriefing()
    labour.formCoalition(optionID: GameEngine.singlePartyMajorityID)
    #expect(labour.coalition.partnerName == GameEngine.singlePartyMajorityName)
    #expect(!labour.coalition.isMinority)
    #expect(labour.currentEvent?.id.hasPrefix("uk-2000-") == true)

    let greens = GameEngine(country: .unitedKingdom)
    greens.startNewGame(party: GameCountry.unitedKingdom.party(id: "uk_green"), playerName: "PM")
    let greenOptions = try #require(greens.pendingCoalitionOptions)
    #expect(!greenOptions.contains { $0.id == GameEngine.singlePartyMajorityID })
    #expect(greenOptions.contains { $0.id == "uk_labour" && $0.formsMajority })
}

@Test(arguments: europeanCountries)
func europeanFutureHasTheSameStoryStructureAsGermanyAndTheUS(country: GameCountry) throws {
    let code = country == .france ? "fr" : "uk"
    let future = EuropeanEventRepository(country: country).loadEvents().filter { $0.id.hasPrefix("future-") }
    let story = future.filter { FutureScenario.isStoryEvent($0.id) }
    #expect(story.count == FutureScenario.totalDecisionCount)
    #expect(future.count - story.count == 75)
    for year in 2026...2050 {
        #expect(story.filter { $0.year == year }.compactMap(\.scenarioStep).sorted() == Array(1...8))
    }
    #expect(story.allSatisfy { $0.id.hasPrefix("future-scenario-\(code)-") })
    let crisis = try #require(story.first { $0.year == 2030 && $0.scenarioStep == 2 })
    #expect(crisis.options[0].flagsToSet.contains("scenario_world_war"))
    #expect(crisis.options[1].flagsToSet.contains("scenario_war_avoided"))
    let settlement = try #require(story.first { $0.year == 2050 && $0.scenarioStep == 8 })
    #expect(settlement.options[2].flagsToSet.contains("\(code)-world-order-2"))
}

@Test(arguments: europeanCountries)
func futureContentStaysLockedWithoutTheExpansion(country: GameCountry) {
    let engine = GameEngine(country: country, finalYear: 2026)
    engine.startNewGame()
    engine.debugJumpToYear(2026)
    #expect(!engine.availableEvents().contains { $0.id.hasPrefix("future-") })
    #expect(GameEngine(country: country, finalYear: 2050).finalYear == 2050)
}

@Test(arguments: europeanCountries, ["war", "peace"])
func aEuropeanCampaignCanBePlayedFrom2000Through2050(country: GameCountry, path: String) throws {
    let engine = GameEngine(country: country, finalYear: 2050)
    engine.startNewGame(party: country.defaultParty, playerName: "Player", difficulty: .leicht, seed: 42)
    var steps = 0
    while engine.state.gameOverSummary == nil && steps < 6000 {
        steps += 1
        if engine.awaitingInitialBriefing { engine.dismissInitialBriefing() }
        else if let options = engine.pendingCoalitionOptions { engine.formCoalition(optionID: options[0].id) }
        else if let talks = engine.pendingCoalitionTalks { engine.concludeCoalitionTalks(acceptedDemandIDs: Set(talks.demands.map(\.id))) }
        else if engine.state.pendingElectionResult != nil { engine.continueAfterElection() }
        else if engine.pendingCampaign { engine.runCampaign(focus: CampaignFocusCatalog.all[0]) }
        else if let encounter = engine.pendingEncounter { engine.resolveEncounter(optionID: encounter.options[1].id) }
        else if let event = engine.currentEvent {
            let isCrisis = event.year == 2030 && event.scenarioStep == 2
            try engine.choose(option: event.options[isCrisis && path == "war" ? 0 : 1])
            engine.advanceGame()
        }
        else { engine.advanceGame() }
    }
    #expect(steps < 6000)
    let summary = try #require(engine.state.gameOverSummary)
    #expect(summary.reason == .reachedFinalYear)
    #expect(engine.state.currentYear == 2050)
    #expect(engine.state.decisions.filter { FutureScenario.isStoryEvent($0.eventID) }.count == 200)
    #expect(engine.state.historicalFlags.contains(path == "war" ? "scenario_world_war" : "scenario_war_avoided"))
    #expect(summary.message.hasPrefix("Dein Vermächtnis 2050:"))
    let english = GameTextLocalization.translate(summary.message, country: country, language: .english)
    #expect(english.hasPrefix("Your legacy in 2050:"))
    #expect(GameTextLocalization.translate(summary.message, country: country, language: .french).hasPrefix("Ton héritage en 2050"))
    let elections = engine.state.electionResults.map(\.year).filter { $0 > 2026 }
    #expect(elections == (country == .france ? [2027, 2032, 2037, 2042, 2047] : [2029, 2034, 2039, 2044, 2049]))
}

@Test(arguments: europeanCountries)
func buyingTheExpansionContinuesTheSameEuropeanCampaign(country: GameCountry) throws {
    let repository = EuropeanEventRepository(country: country)
    var state = country.initialState()
    state.currentYear = 2026
    state.yearProgress = YearProgress(year: 2026, completedEventIDs: Set(repository.events(for: 2026).filter { !$0.id.hasPrefix("future-") }.map(\.id)), isElectionResolved: true)
    state.gameOverSummary = GameOverSummary(reason: .reachedFinalYear, message: "Complete", startYear: 2000, endYear: 2026, keyDecisionTitles: [], finalStats: state.visible, defeatReasons: [], governingStyle: "Test")
    let engine = GameEngine(snapshot: GameSessionSnapshot(country: country, state: state, currentEventID: nil, lastDecisionResult: nil, playerPartyID: country.defaultParty.id, playerName: "Existing run", finalYear: 2026))
    engine.extendCampaign(to: 2050)
    #expect(engine.state.gameOverSummary == nil)
    #expect(engine.playerName == "Existing run")
    #expect(engine.currentEvent?.id.hasPrefix("future-scenario-\(country == .france ? "fr" : "uk")-2026-") == true)
}

@Test(arguments: [GameCountry.unitedKingdom, .france], [UInt64(0), 42, 777])
func aEuropeanCampaignRunsToAValidEnding(country: GameCountry, seed: UInt64) throws {
    for party in country.playableParties {
        let engine = GameEngine(country: country, finalYear: 2026)
        engine.startNewGame(party: party, playerName: "Player", difficulty: .leicht, seed: seed)
        let steps = try play(engine)
        #expect(steps < 3000)
        let summary = try #require(engine.state.gameOverSummary)
        #expect(engine.state.currentYear <= 2026)
        if summary.reason == .reachedFinalYear { #expect(engine.state.currentYear == 2026) }
        // Every decision belongs to this country's catalog or its mechanics.
        #expect(!engine.state.decisions.contains { $0.eventID.hasPrefix("us-") || $0.eventID.hasPrefix("future-") })
    }
}

@Test(arguments: europeanCountries)
func aCompromisingGovernmentCanReach2026(country: GameCountry) throws {
    var reached = false
    for seed in [UInt64(1), 2, 3, 4, 5, 6, 7, 8] where !reached {
        let engine = GameEngine(country: country, finalYear: 2026)
        engine.startNewGame(party: country.defaultParty, playerName: "Player", difficulty: .leicht, seed: seed)
        try play(engine)
        reached = engine.state.gameOverSummary?.reason == .reachedFinalYear
        if reached {
            let years = engine.state.electionResults.map(\.year)
            #expect(years.contains(country == .france ? 2022 : 2024))
        }
    }
    #expect(reached)
}

@Test(arguments: europeanCountries)
func europeanSavesAreSeparateAndResumable(country: GameCountry) throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let persistence = GamePersistence(baseDirectory: directory, country: country)
    let engine = GameEngine(country: country)
    engine.startNewGame(party: country.playableParties[1], playerName: "Saved", seed: 9)
    engine.dismissInitialBriefing()
    if let option = engine.pendingCoalitionOptions?.first { engine.formCoalition(optionID: option.id) }
    if engine.pendingCoalitionTalks != nil { engine.concludeCoalitionTalks(acceptedDemandIDs: []) }
    try persistence.saveSnapshot(engine.snapshot())
    #expect(GamePersistence(baseDirectory: directory, country: .germany).loadSnapshot() == nil)
    #expect(GamePersistence(baseDirectory: directory, country: .unitedStates).loadSnapshot() == nil)
    let restored = GameEngine(snapshot: try #require(persistence.loadSnapshot()))
    #expect(restored.country == country)
    #expect(restored.playerParty.id == country.playableParties[1].id)
    #expect(restored.persona.id == country.playableParties[1].id)
    #expect(restored.currentEvent?.id == engine.currentEvent?.id)
    #expect(restored.finalYear == 2026)
}

@Test func frenchPresidentIsNotOustedByTheirParty() throws {
    var state = GameCountry.france.initialState()
    state.governmentApproval = 5
    let engine = GameEngine(snapshot: GameSessionSnapshot(country: .france, state: state, currentEventID: nil, lastDecisionResult: nil, playerPartyID: "fr_socialist", playerName: "P", partyWings: PartyWings(progressive: 0, traditional: 0, leadershipBacking: 0), finalYear: 2026))
    engine.advanceGame()
    #expect(engine.state.gameOverSummary?.message != "Deine eigene Partei hat dich gestürzt.")
}

// MARK: - French for every campaign

private func eventRepository(for country: GameCountry) -> EventRepository {
    switch country {
    case .germany: LocalJSONEventRepository()
    case .unitedStates: USEventRepository()
    case .unitedKingdom, .france: EuropeanEventRepository(country: country)
    }
}

@Test(arguments: GameCountry.allCases)
func everyEventIsAvailableInFrench(country: GameCountry) throws {
    var missing: [String] = []
    for event in eventRepository(for: country).loadEvents() {
        var texts = [event.title, event.description]
        texts += event.options.flatMap { [$0.title, $0.description] }
        for text in texts where !text.isEmpty {
            let english = GameTextLocalization.translate(text, country: country, language: .english)
            let french = GameTextLocalization.translate(text, country: country, language: .french)
            // Proper names stay as they are in French.
            let names: Set<String> = ["Fridays for Future", "Hinkley Point C"]
            if french == english && english.split(separator: " ").count > 2 && !names.contains(english) { missing.append(english) }
        }
    }
    #expect(missing.isEmpty, "\(country): \(missing.count) untranslated, e.g. \(missing.prefix(3))")
}

@Test func frenchUsesEachCountrysTerminology() {
    #expect(GameTextLocalization.translate("Bundestag", country: .germany, language: .french) == "Bundestag")
    #expect(GameTextLocalization.translate("Bundestag", country: .unitedKingdom, language: .french) != "House of Commons")
    #expect(GameTextLocalization.translate("Nächste Bundestagswahl: 2005", country: .unitedKingdom, language: .french).contains("2005"))
    #expect(GameLanguage.french.localeIdentifier == "fr_FR")
}
