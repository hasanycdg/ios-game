import Foundation

public struct DecisionResult: Codable, Equatable, Sendable {
    public let year: Int
    public let eventTitle: String
    public let optionTitle: String
    public let visibleEffects: [GameEffect]
    public let approvalEffect: Int
    public let resultText: String

    public init(
        year: Int,
        eventTitle: String,
        optionTitle: String,
        visibleEffects: [GameEffect],
        approvalEffect: Int,
        resultText: String
    ) {
        self.year = year
        self.eventTitle = eventTitle
        self.optionTitle = optionTitle
        self.visibleEffects = visibleEffects
        self.approvalEffect = approvalEffect
        self.resultText = resultText
    }
}

public enum GameEngineError: Error, Equatable {
    case noActiveEvent
    case optionNotFound(String)
}

public final class GameEngine {
    private let eventRepository: EventRepository
    private let finalYear: Int

    public private(set) var state: GameState
    public private(set) var currentEvent: GameEvent?
    public private(set) var lastDecisionResult: DecisionResult?

    public init(
        eventRepository: EventRepository = LocalJSONEventRepository(),
        initialState: GameState = GameStateFactory.initialGermany2000(),
        finalYear: Int = 2026
    ) {
        self.eventRepository = eventRepository
        self.state = initialState
        self.finalYear = finalYear
        self.currentEvent = nil
        self.lastDecisionResult = nil
    }

    public func startNewGame() {
        state = GameStateFactory.initialGermany2000()
        lastDecisionResult = nil
        currentEvent = nextEventForCurrentYear()
    }

    public func availableEvents() -> [GameEvent] {
        eventRepository
            .events(for: state.currentYear)
            .filter { event in
                !state.decisions.contains { $0.eventID == event.id }
            }
            .filter { $0.isAvailable(in: state) }
    }

    @discardableResult
    public func choose(option optionID: String) throws -> DecisionResult {
        guard let event = currentEvent ?? nextEventForCurrentYear() else {
            throw GameEngineError.noActiveEvent
        }

        guard let option = event.options.first(where: { $0.id == optionID }) else {
            throw GameEngineError.optionNotFound(optionID)
        }

        for effect in option.immediateEffects {
            state.apply(effect)
        }

        for effect in option.hiddenEffects {
            state.apply(effect)
        }

        state.applyApprovalChange(option.approvalEffect)
        state.historicalFlags.formUnion(option.flagsToSet)
        state.decisions.append(
            DecisionRecord(
                year: state.currentYear,
                eventID: event.id,
                optionID: option.id,
                optionTitle: option.title
            )
        )

        if !option.delayedEffects.isEmpty {
            state.activeLongTermEffects.append(
                ActiveLongTermEffect(
                    sourceEventID: event.id,
                    sourceOptionID: option.id,
                    startedYear: state.currentYear,
                    note: "Verzoegerte Effekte sind fuer spaetere Spielschritte vorgemerkt."
                )
            )
        }

        state.clampAll()

        let result = DecisionResult(
            year: state.currentYear,
            eventTitle: event.title,
            optionTitle: option.title,
            visibleEffects: option.immediateEffects,
            approvalEffect: option.approvalEffect,
            resultText: option.description
        )
        lastDecisionResult = result
        currentEvent = nil
        return result
    }

    public func choose(option: DecisionOption) throws -> DecisionResult {
        try choose(option: option.id)
    }

    public func advanceGame() {
        lastDecisionResult = nil

        if let nextEvent = nextEventForCurrentYear() {
            currentEvent = nextEvent
            return
        }

        guard state.currentYear < finalYear else {
            currentEvent = nil
            return
        }

        state.currentYear += 1
        currentEvent = nextEventForCurrentYear()
    }

    private func nextEventForCurrentYear() -> GameEvent? {
        availableEvents().first
    }
}
