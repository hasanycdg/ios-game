import Foundation
import RegiereDeutschlandCore

@MainActor
final class GameViewModel: ObservableObject {
    enum StartMode {
        case newGame
        case resume
    }

    enum Phase: Equatable {
        case event
        case result(DecisionResult)
        case election(ElectionResult)
        case gameOver(GameOverSummary)
        case noEvent
    }

    @Published private(set) var state: GameState
    @Published private(set) var currentEvent: GameEvent?
    @Published private(set) var phase: Phase
    #if DEBUG
    @Published private(set) var balanceSummaryText: String = ""
    #endif

    private let engine: GameEngine
    private let persistence: GamePersistence
    private var didStoreRunResult = false

    init(mode: StartMode = .newGame, persistence: GamePersistence = GamePersistence()) {
        self.persistence = persistence
        switch mode {
        case .newGame:
            self.engine = GameEngine()
            self.engine.startNewGame()
        case .resume:
            if let snapshot = persistence.loadSnapshot() {
                self.engine = GameEngine(snapshot: snapshot)
            } else {
                self.engine = GameEngine()
                self.engine.startNewGame()
            }
        }
        self.state = engine.state
        self.currentEvent = engine.currentEvent
        self.phase = Self.phase(for: engine)
        autosave()
    }

    func choose(_ option: DecisionOption) {
        do {
            let result = try engine.choose(option: option)
            syncFromEngine()
            phase = .result(result)
            autosave()
        } catch {
            syncFromEngine()
            phase = Self.phase(for: engine)
            autosave()
        }
    }

    func continueAfterResult() {
        engine.advanceGame()
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func continueAfterElection() {
        engine.continueAfterElection()
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func continueWithoutEvent() {
        engine.advanceGame()
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func startNewGame() {
        didStoreRunResult = false
        engine.startNewGame()
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func saveNow() {
        autosave()
    }

    private func syncFromEngine() {
        state = engine.state
        currentEvent = engine.currentEvent
    }

    private func autosave() {
        if let summary = engine.state.gameOverSummary {
            storeRunResultIfNeeded(summary)
            try? persistence.deleteSnapshot()
        } else {
            try? persistence.saveSnapshot(engine.snapshot())
        }
    }

    private func storeRunResultIfNeeded(_ summary: GameOverSummary) {
        guard !didStoreRunResult else { return }
        didStoreRunResult = true
        try? persistence.appendRunResult(
            RunResult(
                startYear: summary.startYear,
                endYear: summary.endYear,
                endReason: summary.reason,
                score: summary.score,
                governingStyle: summary.governingStyle
            )
        )
    }

    private static func phase(for engine: GameEngine) -> Phase {
        if let summary = engine.state.gameOverSummary {
            return .gameOver(summary)
        }

        if let election = engine.state.pendingElectionResult {
            return .election(election)
        }

        if let result = engine.lastDecisionResult {
            return .result(result)
        }

        return engine.currentEvent == nil ? .noEvent : .event
    }
}

#if DEBUG
extension GameViewModel {
    func debugJumpForwardOneYear() {
        engine.debugJumpToYear(state.currentYear + 1)
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func debugBoostEconomy() {
        engine.debugAdjustVisibleMetric(.economy, by: 5)
        syncFromEngine()
        autosave()
    }

    func debugReduceTrust() {
        engine.debugAdjustVisibleMetric(.trust, by: -5)
        syncFromEngine()
        autosave()
    }

    func debugTriggerCurrentYearFirstEvent() {
        if let eventID = LocalJSONEventRepository().events(for: state.currentYear).first?.id {
            engine.debugTriggerEvent(id: eventID)
            syncFromEngine()
            phase = Self.phase(for: engine)
            autosave()
        }
    }

    func debugRunBalanceSimulation() {
        let summary = GameBalanceSimulator().runAllStrategies()
        balanceSummaryText = summary.runs
            .map { report in
                "\(report.strategy.rawValue): Jahr \(report.reachedYear), Score \(report.score), Approval \(report.finalApproval)"
            }
            .joined(separator: "\n")
    }
}
#endif
