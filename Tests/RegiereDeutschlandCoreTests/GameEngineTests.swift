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
    #expect(engine.state.governmentApproval == 55)
    #expect(engine.state.historicalFlags.contains("energy_2000_renewables_priority"))
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
    #expect(engine.state.governmentApproval == 100)
}

@Test func advanceGameMovesToNextYearWhenNoEventIsLeft() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()

    try engine.choose(option: "keep-energy-mix")
    engine.advanceGame()

    #expect(engine.state.currentYear == 2001)
    #expect(engine.currentEvent == nil)
}
