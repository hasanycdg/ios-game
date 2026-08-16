import Foundation
import Testing
@testable import RegiereDeutschlandCore

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
    #expect(summary.runs.allSatisfy { $0.reachedYear >= 2005 })
}
#endif

@Test func releaseReadinessCheckerPassesForPrototypeContent() {
    let report = ReleaseReadinessChecker(eventRepository: LocalJSONEventRepository()).check()

    #expect(report.isReadyForPrototypeRelease)
    #expect(report.missingYears.isEmpty)
}
