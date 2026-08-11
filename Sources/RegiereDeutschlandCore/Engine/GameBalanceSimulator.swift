import Foundation

#if DEBUG
public enum BalanceStrategy: String, Codable, CaseIterable, Sendable {
    case firstOption
    case lastOption
    case historicalPath
}

public struct SimulationRunReport: Codable, Equatable, Sendable {
    public let strategy: BalanceStrategy
    public let reachedYear: Int
    public let didReachFinalYear: Bool
    public let didLoseElection: Bool
    public let finalApproval: Int
    public let score: Int
    public let decisionCount: Int

    public init(
        strategy: BalanceStrategy,
        reachedYear: Int,
        didReachFinalYear: Bool,
        didLoseElection: Bool,
        finalApproval: Int,
        score: Int,
        decisionCount: Int
    ) {
        self.strategy = strategy
        self.reachedYear = reachedYear
        self.didReachFinalYear = didReachFinalYear
        self.didLoseElection = didLoseElection
        self.finalApproval = finalApproval
        self.score = score
        self.decisionCount = decisionCount
    }
}

public struct BalanceSimulationSummary: Codable, Equatable, Sendable {
    public let runs: [SimulationRunReport]

    public init(runs: [SimulationRunReport]) {
        self.runs = runs
    }

    public var finalYearReachRate: Double {
        guard !runs.isEmpty else { return 0 }
        let reached = runs.filter(\.didReachFinalYear).count
        return Double(reached) / Double(runs.count)
    }
}

public struct GameBalanceSimulator: Sendable {
    private let eventRepository: EventRepository

    public init(eventRepository: EventRepository = LocalJSONEventRepository()) {
        self.eventRepository = eventRepository
    }

    public func runAllStrategies() -> BalanceSimulationSummary {
        BalanceSimulationSummary(runs: BalanceStrategy.allCases.map { run(strategy: $0) })
    }

    public func run(strategy: BalanceStrategy) -> SimulationRunReport {
        let engine = GameEngine(eventRepository: eventRepository)
        engine.startNewGame()

        var iterations = 0
        while engine.state.gameOverSummary == nil && iterations < 300 {
            iterations += 1

            if engine.state.pendingElectionResult != nil {
                engine.continueAfterElection()
                continue
            }

            if let event = engine.currentEvent {
                let option = optionToChoose(for: event, strategy: strategy)
                _ = try? engine.choose(option: option.id)
                engine.advanceGame()
                continue
            }

            engine.advanceGame()
        }

        let summary = engine.state.gameOverSummary
        return SimulationRunReport(
            strategy: strategy,
            reachedYear: engine.state.currentYear,
            didReachFinalYear: summary?.reason == .reachedFinalYear,
            didLoseElection: summary?.reason == .lostElection,
            finalApproval: engine.state.governmentApproval,
            score: summary?.score ?? 0,
            decisionCount: engine.state.decisions.count
        )
    }

    private func optionToChoose(for event: GameEvent, strategy: BalanceStrategy) -> DecisionOption {
        switch strategy {
        case .firstOption:
            return event.options.first!
        case .lastOption:
            return event.options.last!
        case .historicalPath:
            if let historicalOptionID = event.historicalOptionID,
               let option = event.options.first(where: { $0.id == historicalOptionID }) {
                return option
            }
            return event.options.first!
        }
    }
}
#endif
