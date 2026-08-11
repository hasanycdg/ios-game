import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func startNewGameSelectsFirstEvent() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())

    engine.startNewGame()

    #expect(engine.state.currentYear == 2000)
    #expect(engine.currentEvent?.id == "energy-policy-2000")
    #expect(engine.availableEvents().count == 1)
}

@Test func choosingRenewablesAppliesImmediateAndHiddenEffects() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    let result = try engine.choose(option: "promote-renewables")

    #expect(result.optionTitle == "Erneuerbare Energien stark foerdern")
    #expect(engine.state.visible.energy == 61)
    #expect(engine.state.visible.budget == 43)
    #expect(engine.state.hidden.renewableCapacity == 32)
    #expect(engine.state.hidden.russianEnergyDependency == 31)
    #expect(engine.state.governmentApproval == 58)
    #expect(engine.state.historicalFlags.contains("energy_2000_renewables_priority"))
    #expect(engine.state.scheduledEffects.count == 1)
    #expect(engine.state.decisionMemory.count == 1)
    #expect(engine.state.decisions.count == 1)
}

@Test func choosingOptionClampsValuesToValidRange() throws {
    let event = GameEvent(
        id: "stress-test",
        year: 2000,
        title: "Stress Test",
        category: .energy,
        headline: "Grenzwerte pruefen",
        description: "Test",
        historicalContext: HistoricalContext(summary: "Test"),
        options: [
            DecisionOption(
                id: "extreme",
                title: "Extrem",
                description: "Test",
                advisoryNote: "Test",
                immediateEffects: [
                    GameEffect(metric: .energy, change: 500),
                    GameEffect(metric: .budget, change: -500)
                ],
                hiddenEffects: [
                    HiddenEffect(metric: .renewableCapacity, change: 500)
                ],
                approvalEffect: 500
            )
        ]
    )
    let engine = GameEngine(eventRepository: InMemoryEventRepository(events: [event]))
    engine.startNewGame()

    try engine.choose(option: "extreme")

    #expect(engine.state.visible.energy == 100)
    #expect(engine.state.visible.budget == 0)
    #expect(engine.state.hidden.renewableCapacity == 100)
    #expect((0...100).contains(engine.state.governmentApproval))
}

@Test func advanceGameMovesToNextYearAndSelectsNextAvailableEvent() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    try engine.choose(option: "keep-energy-mix")
    engine.advanceGame()

    #expect(engine.state.currentYear == 2001)
    #expect(engine.currentEvent?.id == "labour-market-2001")
}

@Test func multipleEventsInOneYearAreQueued() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    try engine.choose(option: "keep-energy-mix")
    engine.advanceGame()
    #expect(engine.currentEvent?.id == "labour-market-2001")

    try engine.choose(option: "training-investment")
    engine.advanceGame()
    #expect(engine.state.currentYear == 2001)
    #expect(engine.currentEvent?.id == "security-2001")
}

@Test func year2002HasFloodEventBefore2003() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    try engine.choose(option: "keep-energy-mix")
    engine.advanceGame()
    try engine.choose(option: "training-investment")
    engine.advanceGame()
    try engine.choose(option: "balanced-security")
    engine.advanceGame()

    #expect(engine.state.currentYear == 2002)
    #expect(engine.currentEvent?.id == "floods-2002")

    try engine.choose(option: "fast-relief")
    engine.advanceGame()

    #expect(engine.state.currentYear == 2003)
    #expect(engine.currentEvent?.id == "digital-administration-2003")
}

@Test func delayedEffectsCanUnlockHistoricalEchoes() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    try engine.choose(option: "promote-renewables")
    engine.advanceGame()
    try engine.choose(option: "training-investment")
    engine.advanceGame()
    try engine.choose(option: "balanced-security")
    engine.advanceGame()
    try engine.choose(option: "fast-relief")
    engine.advanceGame()

    #expect(engine.state.currentYear == 2003)
    #expect(engine.state.historicalFlags.contains("energy_2000_renewables_echo_due"))
    #expect(engine.state.hidden.renewableCapacity >= 38)
    #expect(engine.currentEvent?.id == "renewables-echo-2003")
}

@Test func conditionalModifierChangesLaterDecisionEffects() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    try engine.choose(option: "promote-renewables")
    engine.advanceGame()
    try engine.choose(option: "training-investment")
    engine.advanceGame()
    try engine.choose(option: "balanced-security")
    engine.advanceGame()
    try engine.choose(option: "fast-relief")
    engine.advanceGame()
    try engine.choose(option: "own-the-course")
    engine.advanceGame()
    try engine.choose(option: "federal-platforms")
    engine.advanceGame()
    try engine.choose(option: "soft-reform")
    engine.advanceGame()
    try engine.choose(option: "accelerate-transition")

    #expect(engine.state.historicalFlags.contains("reactivated_renewables"))
    #expect(engine.state.visible.energy >= 68)
    #expect(engine.state.triggeredHistoricalEchoes.isEmpty == false)
}

@Test func decisionMemoryDecaysAndCanReactivate() {
    var state = GameStateFactory.initialGermany2000()
    let service = DecisionMemoryService()
    let impact = PublicMemoryImpact(immediateApproval: -4, reactivationTags: ["energy_strategy"])
    state.decisionMemory = [
        DecisionMemoryRecord(
            sourceEventID: "event",
            sourceOptionID: "option",
            optionTitle: "Option",
            year: 2000,
            impact: impact
        )
    ]
    state.currentYear = 2005

    service.decayMemory(in: &state)
    #expect(state.decisionMemory.first?.currentWeight == 0.25)

    let echoes = service.reactivateMemory(tags: ["energy_strategy"], in: &state)
    #expect(echoes.count == 1)
    #expect(state.decisionMemory.first?.currentWeight == 0.65)
}

@Test func approvalEngineUsesPopulationGroupsAndNationalCondition() {
    var state = GameStateFactory.initialGermany2000()
    let engine = ApprovalEngine()

    engine.applyDecisionImpact(
        PublicMemoryImpact(
            immediateApproval: 0,
            groupEffects: [
                PopulationApprovalEffect(group: .youngAdults, change: 10),
                PopulationApprovalEffect(group: .entrepreneurs, change: -5)
            ]
        ),
        optionApprovalEffect: 0,
        to: &state
    )

    #expect(state.populationGroups.first { $0.id == .youngAdults }?.approval == 58)
    #expect(state.populationGroups.first { $0.id == .entrepreneurs }?.approval == 44)
    #expect((0...100).contains(state.governmentApproval))
}

@Test func electionCanEndTheRun() {
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2005
    state.yearProgress = YearProgress(year: 2005)
    state.visible = VisibleMetrics(
        economy: 32,
        budget: 35,
        livingStandard: 34,
        society: 36,
        security: 50,
        energy: 42,
        internationalRelations: 45,
        trust: 28
    )
    state.governmentApproval = 30

    let electionEngine = ElectionEngine(electionYears: [2005])
    let result = electionEngine.conductElection(in: state)
    let summary = electionEngine.makeGameOverSummary(for: state, electionResult: result)

    #expect(result.didWin == false)
    #expect(summary.reason == .lostElection)
    #expect(summary.message == "Deine Regierung wurde abgewaehlt.")
}

@Test func playablePrototypeCanReachThe2005Election() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    try engine.choose(option: "promote-renewables")
    engine.advanceGame()
    try engine.choose(option: "training-investment")
    engine.advanceGame()
    try engine.choose(option: "balanced-security")
    engine.advanceGame()
    try engine.choose(option: "fast-relief")
    engine.advanceGame()
    try engine.choose(option: "own-the-course")
    engine.advanceGame()
    try engine.choose(option: "federal-platforms")
    engine.advanceGame()
    try engine.choose(option: "soft-reform")
    engine.advanceGame()
    try engine.choose(option: "accelerate-transition")
    engine.advanceGame()

    #expect(engine.state.currentYear == 2005)
    #expect(engine.state.pendingElectionResult?.year == 2005)
    #expect(engine.state.electionResults.count == 1)
}
