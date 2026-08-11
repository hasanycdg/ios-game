import Foundation
import RegiereDeutschlandCore

@MainActor
final class GameViewModel: ObservableObject {
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

    private let engine: GameEngine

    init(engine: GameEngine = GameEngine()) {
        self.engine = engine
        self.engine.startNewGame()
        self.state = engine.state
        self.currentEvent = engine.currentEvent
        self.phase = Self.phase(for: engine)
    }

    func choose(_ option: DecisionOption) {
        do {
            let result = try engine.choose(option: option)
            syncFromEngine()
            phase = .result(result)
        } catch {
            syncFromEngine()
            phase = Self.phase(for: engine)
        }
    }

    func continueAfterResult() {
        engine.advanceGame()
        syncFromEngine()
        phase = Self.phase(for: engine)
    }

    func continueAfterElection() {
        engine.continueAfterElection()
        syncFromEngine()
        phase = Self.phase(for: engine)
    }

    func continueWithoutEvent() {
        engine.advanceGame()
        syncFromEngine()
        phase = Self.phase(for: engine)
    }

    private func syncFromEngine() {
        state = engine.state
        currentEvent = engine.currentEvent
    }

    private static func phase(for engine: GameEngine) -> Phase {
        if let summary = engine.state.gameOverSummary {
            return .gameOver(summary)
        }

        if let election = engine.state.pendingElectionResult {
            return .election(election)
        }

        return engine.currentEvent == nil ? .noEvent : .event
    }
}
