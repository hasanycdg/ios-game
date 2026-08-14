import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func cabinetStartsWithAllMinistries() {
    let cabinet = Cabinet.standard()
    for ministry in Ministry.allCases {
        #expect((0...100).contains(cabinet.minister(ministry).competence))
    }
}

@Test func reshufflingAMinisterCostsCapital() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()
    let capitalBefore = engine.politicalCapital
    let ok = engine.reshuffleMinister(.economy)
    #expect(ok)
    #expect(engine.politicalCapital == capitalBefore - 2)
}

@Test func formingACoalitionSetsThePartner() {
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2005
    let options = [
        CoalitionOption(id: "conservatives", partyName: "Konservative", leaning: .conservative,
                        combinedShare: 58, formsMajority: true, isMinority: false),
        CoalitionOption(id: "none", partyName: "Minderheitsregierung", leaning: .liberal,
                        combinedShare: 40, formsMajority: false, isMinority: true)
    ]
    let snapshot = GameSessionSnapshot(state: state, currentEventID: nil, lastDecisionResult: nil,
                                       pendingCoalitionOptions: options)
    let engine = GameEngine(snapshot: snapshot, eventRepository: LocalJSONEventRepository())
    #expect(engine.pendingCoalitionOptions?.count == 2)

    engine.formCoalition(optionID: "conservatives")
    #expect(engine.coalition.partnerName == "Konservative")
    #expect(engine.coalition.leaning == .conservative)
    #expect(engine.coalition.isMinority == false)
    #expect(engine.pendingCoalitionOptions == nil)
}

@Test func minorityGovernmentIsMarkedAndCannotBreak() {
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2005
    let options = [CoalitionOption(id: "none", partyName: "Minderheitsregierung", leaning: .liberal,
                                   combinedShare: 40, formsMajority: false, isMinority: true)]
    let snapshot = GameSessionSnapshot(state: state, currentEventID: nil, lastDecisionResult: nil,
                                       pendingCoalitionOptions: options)
    let engine = GameEngine(snapshot: snapshot, eventRepository: LocalJSONEventRepository())
    engine.formCoalition(optionID: "none")
    #expect(engine.coalition.isMinority)
    #expect(engine.coalition.partnerName == "Minderheitsregierung")
}
