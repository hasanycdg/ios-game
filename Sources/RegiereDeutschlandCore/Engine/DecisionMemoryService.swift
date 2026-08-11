import Foundation

public struct DecisionMemoryService: Sendable {
    public init() {}

    public func recordDecision(
        event: GameEvent,
        option: DecisionOption,
        in state: inout GameState
    ) {
        let hasMeaningfulImpact = option.publicMemoryImpact.immediateApproval != 0 ||
            !option.publicMemoryImpact.groupEffects.isEmpty ||
            !option.publicMemoryImpact.reactivationTags.isEmpty

        guard hasMeaningfulImpact else { return }

        state.decisionMemory.append(
            DecisionMemoryRecord(
                sourceEventID: event.id,
                sourceOptionID: option.id,
                optionTitle: option.title,
                year: state.currentYear,
                impact: option.publicMemoryImpact
            )
        )
    }

    public func decayMemory(in state: inout GameState) {
        for index in state.decisionMemory.indices {
            let age = max(0, state.currentYear - state.decisionMemory[index].year)
            state.decisionMemory[index].currentWeight = memoryWeight(forAge: age)
        }
    }

    @discardableResult
    public func reactivateMemory(tags: [String], in state: inout GameState) -> [TriggeredHistoricalEcho] {
        guard !tags.isEmpty else { return [] }
        let tagSet = Set(tags)
        var echoes: [TriggeredHistoricalEcho] = []

        for index in state.decisionMemory.indices {
            let memoryTags = Set(state.decisionMemory[index].impact.reactivationTags)
            guard !memoryTags.isDisjoint(with: tagSet) else { continue }

            state.decisionMemory[index].currentWeight = max(state.decisionMemory[index].currentWeight, 0.65)
            state.decisionMemory[index].lastReactivatedYear = state.currentYear

            echoes.append(
                TriggeredHistoricalEcho(
                    year: state.currentYear,
                    sourceEventID: state.decisionMemory[index].sourceEventID,
                    sourceOptionID: state.decisionMemory[index].sourceOptionID,
                    note: "Eine Entscheidung aus dem Jahr \(state.decisionMemory[index].year) wirkt bis heute nach: \(state.decisionMemory[index].optionTitle)."
                )
            )
        }

        state.triggeredHistoricalEchoes.append(contentsOf: echoes)
        return echoes
    }

    public func memoryWeight(forAge age: Int) -> Double {
        switch age {
        case 0...1: 1.0
        case 2: 0.75
        case 3: 0.55
        case 4: 0.40
        default: 0.25
        }
    }
}
