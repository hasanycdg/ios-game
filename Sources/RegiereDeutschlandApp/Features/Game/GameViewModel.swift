import Foundation
import RegiereDeutschlandCore

@MainActor
final class GameViewModel: ObservableObject {
    enum Phase: Equatable {
        case event
        case result(DecisionResult)
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
        self.phase = engine.currentEvent == nil ? .noEvent : .event
    }

    func choose(_ option: DecisionOption) {
        do {
            let result = try engine.choose(option: option)
            syncFromEngine()
            phase = .result(result)
        } catch {
            syncFromEngine()
            phase = .noEvent
        }
    }

    func continueAfterResult() {
        engine.advanceGame()
        syncFromEngine()
        phase = currentEvent == nil ? .noEvent : .event
    }

    private func syncFromEngine() {
        state = engine.state
        currentEvent = engine.currentEvent
    }
}
