import Foundation
import Testing
@testable import RegiereDeutschlandCore

/// Spielt den historischen/ersten Pfad bis zu einem Zieljahr, robust gegenüber
/// zusätzlichen Events. `firstChoice` erzwingt die erste Entscheidung.
private func play(_ engine: GameEngine, firstChoice: String? = nil, untilYear year: Int, maxSteps: Int = 400) {
    var didFirst = false
    var steps = 0
    while engine.state.currentYear < year && engine.state.gameOverSummary == nil && steps < maxSteps {
        steps += 1
        if engine.pendingCampaign {
            engine.runCampaign(focus: CampaignFocusCatalog.all[0])
        } else if let options = engine.pendingCoalitionOptions {
            engine.formCoalition(optionID: options[0].id)
        } else if let encounter = engine.pendingEncounter {
            engine.resolveEncounter(optionID: encounter.options[0].id)
        } else if let event = engine.currentEvent {
            var choice = event.options[0].id
            if !didFirst, let first = firstChoice, event.options.contains(where: { $0.id == first }) {
                choice = first
                didFirst = true
            } else if let historical = event.historicalOptionID, event.options.contains(where: { $0.id == historical }) {
                choice = historical
            }
            try? engine.choose(option: choice)
            engine.advanceGame()
        } else {
            engine.advanceGame()
        }
    }
}

@Test func startNewGameSelectsFirstEvent() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())

    engine.startNewGame()

    #expect(engine.state.currentYear == 2000)
    #expect(engine.currentEvent?.id == "energy-policy-2000")
    #expect(engine.availableEvents().count >= 1)
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

@Test func advanceGameMovesToNextYearAndSelectsNextAvailableEvent() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    // Alle Events aus 2000 abarbeiten führt sicher ins Folgejahr mit einem Event.
    play(engine, untilYear: 2001, maxSteps: 20)
    #expect(engine.state.currentYear >= 2001)
    #expect(engine.currentEvent != nil)
}

@Test func multipleEventsInOneYearAreQueued() {
    // Mehrere Events pro Jahr sind vorhanden und werden zu Jahresbeginn eingereiht.
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()
    #expect(engine.availableEvents().count >= 2)
    #expect(LocalJSONEventRepository().events(for: 2001).count >= 2)
}

@Test func year2002HasFloodEventBefore2003() {
    let repository = LocalJSONEventRepository()
    #expect(repository.events(for: 2002).contains { $0.id == "floods-2002" })
    #expect(repository.events(for: 2003).contains { $0.id == "digital-administration-2003" })
}

@Test func delayedEffectsCanUnlockHistoricalEchoes() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    // Erste Entscheidung: Erneuerbare fördern (setzt einen verzögerten Effekt).
    try engine.choose(option: "promote-renewables")
    engine.advanceGame()
    play(engine, untilYear: 2004)

    // Der verzögerte Effekt aus 2000 ist inzwischen ausgelöst.
    #expect(engine.state.historicalFlags.contains("energy_2000_renewables_echo_due"))
    #expect(engine.state.hidden.renewableCapacity >= 30)
    #expect(engine.state.triggeredHistoricalEchoes.isEmpty == false)
}

@Test func conditionalModifierChangesLaterDecisionEffects() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    try engine.choose(option: "promote-renewables")
    engine.advanceGame()
    play(engine, untilYear: 2005)

    // Der frühe Erneuerbaren-Kurs wirkt nach: hohe Kapazität und ausgelöste Echos.
    #expect(engine.state.hidden.renewableCapacity >= 34)
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

@Test func playablePrototypeCanReachThe2005Election() {
    // Inhalts-robust: spielt den historischen/ersten Pfad, bis eine Wahl fällt.
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    var steps = 0
    while engine.state.electionResults.isEmpty && engine.state.gameOverSummary == nil && steps < 600 {
        steps += 1
        if engine.pendingCampaign {
            engine.runCampaign(focus: CampaignFocusCatalog.all[0])
        } else if let options = engine.pendingCoalitionOptions {
            engine.formCoalition(optionID: options[0].id)
        } else if engine.pendingEncounter != nil {
            engine.resolveEncounter(optionID: engine.pendingEncounter!.options[0].id)
        } else if let event = engine.currentEvent {
            let historical = event.historicalOptionID.flatMap { id in event.options.first { $0.id == id }?.id }
            try? engine.choose(option: historical ?? event.options[0].id)
            engine.advanceGame()
        } else {
            engine.advanceGame()
        }
    }

    #expect(engine.state.currentYear >= 2005)
    #expect(engine.state.electionResults.contains { $0.year == 2005 })
}
