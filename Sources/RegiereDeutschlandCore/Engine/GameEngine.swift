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
    private let annualSimulation: AnnualSimulation
    private let approvalEngine: ApprovalEngine
    private let memoryService: DecisionMemoryService
    private let electionEngine: ElectionEngine

    public private(set) var state: GameState
    public private(set) var currentEvent: GameEvent?
    public private(set) var lastDecisionResult: DecisionResult?

    public init(
        eventRepository: EventRepository = LocalJSONEventRepository(),
        initialState: GameState = GameStateFactory.initialGermany2000(),
        finalYear: Int = 2026,
        annualSimulation: AnnualSimulation = AnnualSimulation(),
        approvalEngine: ApprovalEngine = ApprovalEngine(),
        memoryService: DecisionMemoryService = DecisionMemoryService(),
        electionEngine: ElectionEngine = ElectionEngine()
    ) {
        self.eventRepository = eventRepository
        self.state = initialState
        self.finalYear = finalYear
        self.annualSimulation = annualSimulation
        self.approvalEngine = approvalEngine
        self.memoryService = memoryService
        self.electionEngine = electionEngine
        self.currentEvent = nil
        self.lastDecisionResult = nil
    }

    public func startNewGame() {
        state = GameStateFactory.initialGermany2000()
        lastDecisionResult = nil
        prepareCurrentYear()
        currentEvent = nextQueuedEvent()
    }

    public func availableEvents() -> [GameEvent] {
        eventRepository
            .events(for: state.currentYear)
            .filter { event in
                !state.yearProgress.completedEventIDs.contains(event.id)
            }
            .filter { $0.isAvailable(in: state) }
    }

    @discardableResult
    public func choose(option optionID: String) throws -> DecisionResult {
        guard let event = currentEvent ?? nextQueuedEvent() else {
            throw GameEngineError.noActiveEvent
        }

        guard let option = event.options.first(where: { $0.id == optionID }) else {
            throw GameEngineError.optionNotFound(optionID)
        }

        var visibleEffects = option.immediateEffects
        var hiddenEffects = option.hiddenEffects
        var approvalEffect = option.approvalEffect
        var flagsToSet = option.flagsToSet

        memoryService.reactivateMemory(tags: event.memoryReactivationTags, in: &state)

        for modifier in option.conditionalModifiers where modifier.isSatisfied(by: state) {
            visibleEffects.append(contentsOf: modifier.immediateEffects)
            hiddenEffects.append(contentsOf: modifier.hiddenEffects)
            approvalEffect += modifier.approvalEffect
            flagsToSet.append(contentsOf: modifier.memoryReactivationTags.map { "reactivated_\($0)" })
            memoryService.reactivateMemory(tags: modifier.memoryReactivationTags, in: &state)
        }

        for effect in visibleEffects {
            state.apply(effect)
        }

        for effect in hiddenEffects {
            state.apply(effect)
        }

        approvalEngine.applyDecisionImpact(option.publicMemoryImpact, optionApprovalEffect: approvalEffect, to: &state)
        state.historicalFlags.formUnion(flagsToSet)
        state.yearProgress.completedEventIDs.insert(event.id)
        state.decisions.append(
            DecisionRecord(
                year: state.currentYear,
                eventID: event.id,
                optionID: option.id,
                optionTitle: option.title
            )
        )
        memoryService.recordDecision(event: event, option: option, in: &state)

        for delayedEffect in option.delayedEffects {
            state.scheduledEffects.append(
                ScheduledEffect(
                    sourceEventID: event.id,
                    sourceOptionID: option.id,
                    dueYear: state.currentYear + delayedEffect.delayInYears,
                    immediateEffects: delayedEffect.immediateEffects,
                    hiddenEffects: delayedEffect.hiddenEffects,
                    approvalEffect: delayedEffect.approvalEffect,
                    flagsToSet: delayedEffect.flagsToSet,
                    note: delayedEffect.note
                )
            )
        }

        if !option.delayedEffects.isEmpty || !option.conditionalModifiers.isEmpty {
            state.activeLongTermEffects.append(
                ActiveLongTermEffect(
                    sourceEventID: event.id,
                    sourceOptionID: option.id,
                    startedYear: state.currentYear,
                    note: "Langfristige Effekte sind fuer spaetere Jahre vorgemerkt."
                )
            )
        }

        state.clampAll()

        let result = DecisionResult(
            year: state.currentYear,
            eventTitle: event.title,
            optionTitle: option.title,
            visibleEffects: visibleEffects,
            approvalEffect: approvalEffect,
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
        guard state.gameOverSummary == nil else { return }
        guard state.pendingElectionResult == nil else { return }

        if let nextEvent = nextQueuedEvent() {
            currentEvent = nextEvent
            return
        }

        annualSimulation.applyEndOfYearDevelopment(to: &state)

        if electionEngine.shouldHoldElection(in: state) {
            let election = electionEngine.conductElection(in: state)
            state.pendingElectionResult = election
            state.electionResults.append(election)
            state.yearProgress.isElectionResolved = true

            if !election.didWin {
                state.gameOverSummary = electionEngine.makeGameOverSummary(for: state, electionResult: election)
            }

            currentEvent = nil
            return
        }

        guard state.currentYear < finalYear else {
            state.gameOverSummary = makeFinalYearSummary()
            currentEvent = nil
            return
        }

        enterYear(state.currentYear + 1)
        currentEvent = nextQueuedEvent()
    }

    public func continueAfterElection() {
        guard let election = state.pendingElectionResult else { return }
        state.pendingElectionResult = nil
        guard election.didWin, state.gameOverSummary == nil else {
            currentEvent = nil
            return
        }

        if state.currentYear >= finalYear {
            state.gameOverSummary = makeFinalYearSummary()
            currentEvent = nil
            return
        }

        enterYear(state.currentYear + 1)
        currentEvent = nextQueuedEvent()
    }

    private func prepareCurrentYear() {
        state.yearProgress = YearProgress(year: state.currentYear)
        applyScheduledEffectsDueThisYear()
        rebuildEventQueue()
    }

    private func enterYear(_ year: Int) {
        state.currentYear = year
        prepareCurrentYear()
    }

    private func rebuildEventQueue() {
        let pendingIDs = availableEvents().map(\.id)
        state.eventQueue = EventQueue(year: state.currentYear, pendingEventIDs: pendingIDs)
    }

    private func nextQueuedEvent() -> GameEvent? {
        if state.eventQueue.year != state.currentYear || state.eventQueue.isEmpty {
            rebuildEventQueue()
        }

        while let eventID = state.eventQueue.popNext() {
            guard let event = event(withID: eventID), event.isAvailable(in: state) else {
                continue
            }
            return event
        }

        return nil
    }

    private func event(withID eventID: String) -> GameEvent? {
        eventRepository.events(for: state.currentYear).first { $0.id == eventID }
    }

    private func applyScheduledEffectsDueThisYear() {
        let dueEffects = state.scheduledEffects.filter { $0.dueYear <= state.currentYear }
        guard !dueEffects.isEmpty else { return }

        for scheduledEffect in dueEffects {
            for effect in scheduledEffect.immediateEffects {
                state.apply(effect)
            }
            for effect in scheduledEffect.hiddenEffects {
                state.apply(effect)
            }
            if scheduledEffect.approvalEffect != 0 {
                approvalEngine.applyDecisionImpact(
                    PublicMemoryImpact(immediateApproval: scheduledEffect.approvalEffect),
                    optionApprovalEffect: 0,
                    to: &state
                )
            }
            state.historicalFlags.formUnion(scheduledEffect.flagsToSet)

            if let note = scheduledEffect.note {
                state.triggeredHistoricalEchoes.append(
                    TriggeredHistoricalEcho(
                        year: state.currentYear,
                        sourceEventID: scheduledEffect.sourceEventID,
                        sourceOptionID: scheduledEffect.sourceOptionID,
                        note: note
                    )
                )
            }
        }

        let dueIDs = Set(dueEffects.map(\.id))
        state.scheduledEffects.removeAll { dueIDs.contains($0.id) }
        state.clampAll()
    }

    private func makeFinalYearSummary() -> GameOverSummary {
        GameOverSummary(
            reason: .reachedFinalYear,
            message: "Dein Deutschland 2026 ist erreicht.",
            startYear: 2000,
            endYear: state.currentYear,
            keyDecisionTitles: state.decisions.suffix(5).map(\.optionTitle),
            finalStats: state.visible,
            defeatReasons: [],
            governingStyle: electionEngine.governingStyle(for: state)
        )
    }
}
