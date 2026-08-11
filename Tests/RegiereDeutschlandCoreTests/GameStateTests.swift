import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func initialStateUsesGermanyIn2000Defaults() {
    let state = GameStateFactory.initialGermany2000()

    #expect(state.currentYear == 2000)
    #expect(state.governmentApproval == 52)
    #expect(state.visible.economy == 58)
    #expect(state.hidden.renewableCapacity == 16)
    #expect(state.decisions.isEmpty)
    #expect(state.electionResults.isEmpty)
    #expect(state.activeLongTermEffects.isEmpty)
    #expect(state.historicalFlags.isEmpty)
}

@Test func initialStateValuesAreInValidRange() {
    let state = GameStateFactory.initialGermany2000()

    let visibleValues = VisibleMetric.allCases.map { state.visible.value(for: $0) }
    let hiddenValues = HiddenMetric.allCases.map { state.hidden.value(for: $0) }
    let allValues = visibleValues + hiddenValues + [state.governmentApproval]

    #expect(allValues.allSatisfy { (0...100).contains($0) })
}

@Test func gameStateCodableRoundTripPreservesState() throws {
    var state = GameStateFactory.initialGermany2000()
    state.decisions.append(
        DecisionRecord(
            year: 2000,
            eventID: "energy-policy-2000",
            optionID: "promote-renewables",
            optionTitle: "Erneuerbare Energien stark foerdern"
        )
    )
    state.historicalFlags.insert("energy_2000_renewables_priority")

    let data = try JSONEncoder().encode(state)
    let decoded = try JSONDecoder().decode(GameState.self, from: data)

    #expect(decoded == state)
}
