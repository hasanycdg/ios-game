import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func interestGroupsStartWithFiveActors() {
    let groups = InterestGroupsFactory.standard()
    #expect(groups.count == 5)
    #expect(groups.contains { $0.id == .unions })
    #expect(groups.allSatisfy { (1...3).contains($0.power) })
}

@Test func highTaxesAngerBusinessAndPleaseUnions() {
    let state = GameStateFactory.initialGermany2000()
    var lowTax = PolicyState.standard()
    lowTax.levels[PolicyID.taxes.rawValue] = 0
    var highTax = PolicyState.standard()
    highTax.levels[PolicyID.taxes.rawValue] = 4

    let businessLow = InterestGroupsFactory.target(.business, policies: lowTax, state: state)
    let businessHigh = InterestGroupsFactory.target(.business, policies: highTax, state: state)
    #expect(businessLow > businessHigh)

    var lowWelfare = PolicyState.standard(); lowWelfare.levels[PolicyID.welfare.rawValue] = 0
    var highWelfare = PolicyState.standard(); highWelfare.levels[PolicyID.welfare.rawValue] = 4
    let unionsLow = InterestGroupsFactory.target(.unions, policies: lowWelfare, state: state)
    let unionsHigh = InterestGroupsFactory.target(.unions, policies: highWelfare, state: state)
    #expect(unionsHigh > unionsLow)
}

@Test func partyWingsRespondToCourse() {
    var green = PolicyState.standard()
    green.levels[PolicyID.environment.rawValue] = 4
    green.levels[PolicyID.welfare.rawValue] = 4
    var hawkish = PolicyState.standard()
    hawkish.levels[PolicyID.defense.rawValue] = 4
    hawkish.levels[PolicyID.welfare.rawValue] = 0

    #expect(PartyWingsDynamics.progressiveTarget(policies: green) > PartyWingsDynamics.progressiveTarget(policies: hawkish))
    #expect(PartyWingsDynamics.traditionalTarget(policies: hawkish) > PartyWingsDynamics.traditionalTarget(policies: green))
}

@Test func losingBundesratRaisesTheVoteThreshold() {
    // Ein Zustand, in dem eine ausrichtungsneutrale Änderung ohne Bundesrat scheitert,
    // mit Bundesrat aber durchgeht.
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2006
    let coalition = CoalitionState(partnerName: "Der liberale Partner", leaning: .liberal, satisfaction: 40)

    let withMajority = GameEngine(
        snapshot: GameSessionSnapshot(state: state, currentEventID: nil, lastDecisionResult: nil,
                                      politicalCapital: 8, coalition: coalition, hasBundesratMajority: true),
        eventRepository: LocalJSONEventRepository())
    // Bildung ist für liberale Partner neutral (leaningPreference 0) → Score 40 >= 45? nein.
    // Daher testen wir mit einer für den Partner positiven Änderung (Steuern senken).
    #expect(withMajority.attemptPolicyChange(.taxes, to: 1) == .passed)

    let withoutMajority = GameEngine(
        snapshot: GameSessionSnapshot(state: state, currentEventID: nil, lastDecisionResult: nil,
                                      politicalCapital: 8, coalition: coalition, hasBundesratMajority: false),
        eventRepository: LocalJSONEventRepository())
    // Gleiche Änderung, aber höhere Hürde ohne Bundesrat: Score 40+8=48 >= 45+7=52? nein → abgelehnt.
    #expect(withoutMajority.attemptPolicyChange(.taxes, to: 1) == .rejected)
}
