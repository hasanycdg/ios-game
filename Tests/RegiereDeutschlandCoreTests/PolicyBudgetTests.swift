import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func defaultBudgetIsBalanced() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()
    let budget = engine.budgetSummary()
    #expect(budget.income == 30)
    #expect(budget.spending == 30)
    #expect(budget.deficit == 0)
}

@Test func alignedPolicyChangePassesAndCostsCapital() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame(persona: PersonaCatalog.persona(id: "reformerin")) // linke Koalition
    let capitalBefore = engine.politicalCapital

    let result = engine.attemptPolicyChange(.welfare, to: 3) // linke Partner mögen mehr Sozialstaat
    #expect(result == .passed)
    #expect(engine.policies.level(.welfare) == 3)
    #expect(engine.politicalCapital == capitalBefore - 1)
}

@Test func conflictingChangeFailsWhenPartnerIsUnhappy() {
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2006
    let coalition = CoalitionState(partnerName: "Der liberale Partner", leaning: .liberal, satisfaction: 20)
    let snapshot = GameSessionSnapshot(state: state, currentEventID: nil, lastDecisionResult: nil,
                                       politicalCapital: 8, coalition: coalition)
    let engine = GameEngine(snapshot: snapshot, eventRepository: LocalJSONEventRepository())

    // Sozialausgaben hoch widerspricht dem liberalen Partner; bei niedriger Zufriedenheit fällt es durch.
    let result = engine.attemptPolicyChange(.welfare, to: 4)
    #expect(result == .rejected)
    #expect(engine.policies.level(.welfare) == 2) // unverändert
}

@Test func policyChangeNeedsCapital() {
    var state = GameStateFactory.initialGermany2000()
    let snapshot = GameSessionSnapshot(state: state, currentEventID: nil, lastDecisionResult: nil,
                                       politicalCapital: 0)
    let engine = GameEngine(snapshot: snapshot, eventRepository: LocalJSONEventRepository())
    let result = engine.attemptPolicyChange(.defense, to: 4)
    #expect(result == .noCapital)
}
