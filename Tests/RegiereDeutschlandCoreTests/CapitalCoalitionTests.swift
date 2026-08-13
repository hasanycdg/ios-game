import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func decisionCostStaysWithinOneToFour() {
    let cheap = DecisionOption(id: "c", title: "", description: "", advisoryNote: "",
                               immediateEffects: [GameEffect(metric: .economy, change: 1)])
    let expensive = DecisionOption(id: "e", title: "", description: "", advisoryNote: "",
                                   immediateEffects: [
                                       GameEffect(metric: .economy, change: 12),
                                       GameEffect(metric: .budget, change: -12),
                                       GameEffect(metric: .society, change: 9)
                                   ], approvalEffect: 8)
    #expect(DecisionCost.cost(of: cheap) == 1)
    #expect(DecisionCost.cost(of: expensive) == DecisionCost.maximum)
}

@Test func personaShapesStartingConditions() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    let sparkommissar = PersonaCatalog.persona(id: "sparkommissar")
    engine.startNewGame(persona: sparkommissar)

    #expect(engine.politicalCapital == sparkommissar.startingCapital)
    #expect(engine.coalition.leaning == .liberal)
    // Budget-Modifier hebt den Startwert gegenüber der Basis an.
    #expect(engine.state.visible.budget > GameStateFactory.initialGermany2000().visible.budget)
}

@Test func choosingSpendsPoliticalCapital() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()
    let before = engine.politicalCapital
    try engine.choose(option: "promote-renewables")
    #expect(engine.politicalCapital < before)
    #expect(engine.politicalCapital >= 0)
}

@Test func coalitionPartnerReactsAlongItsLeaning() {
    let welfareBoost = DecisionOption(id: "w", title: "", description: "", advisoryNote: "",
                                      hiddenEffects: [HiddenEffect(metric: .welfareStrength, change: 12)])
    let nuclearBoost = DecisionOption(id: "n", title: "", description: "", advisoryNote: "",
                                      hiddenEffects: [HiddenEffect(metric: .nuclearCapacity, change: 12)])

    let up = CoalitionDynamics.reaction(to: welfareBoost, leaning: .left, damping: 1.0)
    let down = CoalitionDynamics.reaction(to: nuclearBoost, leaning: .left, damping: 1.0)
    #expect(up > 0)
    #expect(down < 0)
}

@Test func achievementsAreDerivedFromEndSummary() {
    let summary = GameOverSummary(
        reason: .reachedFinalYear,
        message: "",
        startYear: 2000,
        endYear: 2026,
        keyDecisionTitles: [],
        finalStats: VisibleMetrics(economy: 80, budget: 80, livingStandard: 80, society: 80,
                                   security: 80, energy: 80, internationalRelations: 80, trust: 80),
        defeatReasons: [],
        governingStyle: "Ausgleichender Regierungsstil",
        score: 1300,
        wonElectionCount: 5
    )
    let ids = Set(AchievementCatalog.satisfiedIDs(summary: summary))
    #expect(ids.contains("reach-2026"))
    #expect(ids.contains("score-1200"))
    #expect(ids.contains("elections-5"))
    #expect(ids.contains("landslide"))
}
