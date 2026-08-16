import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func goalEvaluatorScoresByDrivingMetric() {
    var state = GameStateFactory.initialGermany2000()
    state.hidden.renewableCapacity = 80
    let klima = CustomGoalCatalog.goal(id: "goal-klima")!   // treibend: renewableCapacity
    let prog = GoalEvaluator.evaluate(agenda: [klima], state: state)
    #expect(prog.count == 1)
    #expect(prog[0].metricLabel == "Erneuerbare")
    #expect(prog[0].percent == 80)
    #expect(prog[0].status == .fulfilled)
}

@Test func goalEvaluatorHandlesLoweringGoals() {
    var state = GameStateFactory.initialGermany2000()
    state.hidden.nuclearCapacity = 20   // Ziel will Kernkraft senken -> Erfolg = 100-20
    let atom = PartyAgendaCatalog.agenda(for: "gruene").first { $0.id == "gruene-atomausstieg" }!
    let prog = GoalEvaluator.evaluate(agenda: [atom], state: state)[0]
    #expect(prog.metricLabel == "Kernkraft")
    #expect(prog.percent == 80)
    #expect(prog.status == .fulfilled)
}

@Test func goalEvaluatorMarksMissedGoals() {
    var state = GameStateFactory.initialGermany2000()
    state.hidden.welfareStrength = 30
    let soz = CustomGoalCatalog.goal(id: "goal-sozialstaat")!  // treibend: welfareStrength
    let prog = GoalEvaluator.evaluate(agenda: [soz], state: state)[0]
    #expect(prog.status == .missed)
    #expect(GoalEvaluator.fulfilledCount([prog]) == 0)
}
