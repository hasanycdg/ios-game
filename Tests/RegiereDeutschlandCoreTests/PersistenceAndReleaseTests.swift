import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func futureCampaignTargetSurvivesSavingAndResuming() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository(), finalYear: 2050)
    engine.startNewGame()

    let resumed = GameEngine(snapshot: engine.snapshot(), eventRepository: LocalJSONEventRepository())
    #expect(resumed.finalYear == 2050)
}

@Test func purchasedCampaignContinuesTheSameCompletedRun() {
    let repository = LocalJSONEventRepository()
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2004
    state.yearProgress = YearProgress(year: 2004, completedEventIDs: Set(repository.events(for: 2004).map(\.id)))
    state.gameOverSummary = GameOverSummary(
        reason: .reachedFinalYear,
        message: "Bis 2004 gespielt.",
        startYear: 2000,
        endYear: 2004,
        keyDecisionTitles: [],
        finalStats: state.visible,
        defeatReasons: [],
        governingStyle: "Test"
    )
    let snapshot = GameSessionSnapshot(state: state, currentEventID: nil, lastDecisionResult: nil, finalYear: 2004)
    let engine = GameEngine(snapshot: snapshot, eventRepository: repository)

    engine.extendCampaign(to: 2026)

    #expect(engine.finalYear == 2026)
    #expect(engine.state.currentYear == 2005)
    #expect(engine.state.gameOverSummary == nil)
    #expect(engine.state.historicalFlags.contains("content_2005_2026"))
}

@Test(arguments: [2004, 2026])
func completePurchasePreservesTheRunAndOpensTheNextPlayableEvent(checkpoint: Int) throws {
    let repository = LocalJSONEventRepository()
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = checkpoint
    state.historicalFlags.insert("existing_campaign_progress")
    state.yearProgress = YearProgress(year: checkpoint, completedEventIDs: Set(
        repository.events(for: checkpoint).filter { !$0.id.hasPrefix("future-") }.map(\.id)
    ))
    state.gameOverSummary = GameOverSummary(reason: .reachedFinalYear, message: "Kampagnenende",
        startYear: 2000, endYear: checkpoint, keyDecisionTitles: [], finalStats: state.visible,
        defeatReasons: [], governingStyle: "Test")
    let snapshot = GameSessionSnapshot(state: state, currentEventID: nil, lastDecisionResult: nil,
        playerName: "Bestehende Amtszeit", finalYear: checkpoint)
    let engine = GameEngine(snapshot: snapshot, eventRepository: repository)
    let access = CampaignAccess(activeEntitlements: [CampaignAccess.mainEntitlementID, CampaignAccess.futureEntitlementID])

    engine.extendCampaign(to: try #require(access.continuationFinalYear(after: checkpoint)))

    #expect(engine.finalYear == 2050)
    #expect(engine.state.gameOverSummary == nil)
    #expect(engine.state.historicalFlags.contains("existing_campaign_progress"))
    #expect(engine.playerName == "Bestehende Amtszeit")
    let nextEvent = try #require(engine.currentEvent)
    #expect(nextEvent.year == (checkpoint == 2004 ? 2005 : 2026))
    if checkpoint == 2026 {
        #expect(nextEvent.id.hasPrefix("future-"))
        #expect(nextEvent.scenarioStep == 0)
    }
    let resumed = GameEngine(snapshot: engine.snapshot(), eventRepository: repository)
    #expect(resumed.finalYear == 2050)
    #expect(resumed.currentEvent?.id == nextEvent.id)
}

@Test func persistenceRoundTripsSnapshotAndRunResults() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    let persistence = GamePersistence(baseDirectory: directory)
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()
    try engine.choose(option: "promote-renewables")

    try persistence.saveSnapshot(engine.snapshot())
    let snapshot = persistence.loadSnapshot()

    #expect(persistence.hasSaveGame)
    #expect(snapshot?.schemaVersion == 1)
    #expect(snapshot?.state.decisions.count == 1)
    #expect(snapshot?.lastDecisionResult?.historicalReality != nil)

    let result = RunResult(startYear: 2000, endYear: 2005, endReason: .lostElection, score: 430, governingStyle: "Test")
    try persistence.appendRunResult(result)

    #expect(persistence.loadRunResults().first?.score == 430)

    try persistence.deleteSnapshot()
    #expect(persistence.hasSaveGame == false)
}

@Test func engineCanResumeFromSnapshot() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()
    try engine.choose(option: "promote-renewables")

    let resumed = GameEngine(snapshot: engine.snapshot(), eventRepository: LocalJSONEventRepository())

    #expect(resumed.state.decisions.count == 1)
    #expect(resumed.lastDecisionResult?.optionTitle == "Erneuerbare Energien stark fördern")
}

@Test func decisionResultContainsHistoricalCompareData() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    let result = try engine.choose(option: "promote-renewables")

    #expect(result.historicalReality?.isEmpty == false)
    #expect(result.didChooseHistoricalPath)
}

#if DEBUG
@Test func balanceSimulatorRunsDeveloperStrategies() {
    let summary = GameBalanceSimulator(eventRepository: LocalJSONEventRepository()).runAllStrategies()

    #expect(summary.runs.count == BalanceStrategy.allCases.count)
    #expect(summary.runs.allSatisfy { $0.decisionCount > 0 })
    // Der historische Pfad muss die volle Distanz bis 2026 schaffen – fängt ein
    // erneutes Hängen des Simulators (z.B. bei Wahlkampf/Koalition) ab.
    #expect(summary.runs.contains { $0.strategy == .historicalPath && $0.didReachFinalYear })
    // Nicht jede Strategie gewinnt: ein konträrer Kurs scheitert an einer Wahl.
    #expect(summary.runs.contains { $0.didLoseElection })
}
#endif

@Test func releaseReadinessCheckerPassesForPrototypeContent() {
    let report = ReleaseReadinessChecker(eventRepository: LocalJSONEventRepository()).check()

    #expect(report.isReadyForPrototypeRelease)
    #expect(report.missingYears.isEmpty)
}
