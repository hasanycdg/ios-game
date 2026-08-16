import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func campaignBonusHelpsGoverningShare() {
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2005
    let engine = ElectionEngine()

    let base = engine.conductElection(in: state)
    let boosted = engine.conductElection(in: state, campaignBonus: 4)

    #expect(boosted.governingPartyShare >= base.governingPartyShare)
}

@Test func campaignFocusReflectsAlignment() {
    let focus = CampaignFocusCatalog.all.first { $0.primary == .economy }!

    var strong = GameStateFactory.initialGermany2000()
    strong.visible.economy = 90
    var weak = GameStateFactory.initialGermany2000()
    weak.visible.economy = 20

    let strongBonus = focus.bonus(for: strong)
    let weakBonus = focus.bonus(for: weak)

    #expect(strongBonus > weakBonus)
    #expect(strongBonus <= 5.0)
    #expect(weakBonus >= -2.0)
    #expect(focus.alignment(for: strong) == .strong)
    #expect(focus.alignment(for: weak) == .risky)
}

@Test func projectionIsUnaffectedByCampaignBonus() {
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2005
    let engine = ElectionEngine()

    // Die Prognose spiegelt die Lage ohne Wahlkampf-Bonus wider.
    let projection = engine.project(in: state)
    let plainElection = engine.conductElection(in: state)
    #expect(projection.governingShare == plainElection.governingPartyShare)
}
