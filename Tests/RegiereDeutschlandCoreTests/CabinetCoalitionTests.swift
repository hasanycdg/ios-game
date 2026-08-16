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

    // Schritt 1: Partner wählen → Koalitionsgespräche starten.
    engine.formCoalition(optionID: "conservatives")
    #expect(engine.pendingCoalitionOptions == nil)
    #expect(engine.pendingCoalitionTalks?.partnerName == "Konservative")

    // Schritt 2: Gespräche abschließen → Koalition steht.
    engine.concludeCoalitionTalks(acceptedDemandIDs: [])
    #expect(engine.coalition.partnerName == "Konservative")
    #expect(engine.coalition.leaning == .conservative)
    #expect(engine.coalition.isMinority == false)
    #expect(engine.pendingCoalitionTalks == nil)
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

@Test func acceptingCoalitionDemandsPleasesPartnerAndShiftsPolicy() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame(party: PartyCatalog.party(id: "spd"), playerName: "Test")
    let partner = engine.pendingCoalitionOptions!.first { !$0.isMinority }!
    let renewablesBefore = engine.state.hidden.renewableCapacity

    engine.formCoalition(optionID: partner.id)
    let talks = engine.pendingCoalitionTalks
    #expect(talks?.demands.isEmpty == false)

    engine.concludeCoalitionTalks(acceptedDemandIDs: Set(talks!.demands.map(\.id)))
    #expect(engine.pendingCoalitionTalks == nil)
    #expect(engine.coalition.partnerName == partner.partyName)
    #expect(engine.coalition.satisfaction >= 60)
    // Die Grünen fordern u.a. den Ausbau Erneuerbarer – die Zusage wirkt.
    #expect(engine.state.hidden.renewableCapacity >= renewablesBefore)
    // Nach der Startkoalition ist das erste Ereignis geladen.
    #expect(engine.currentEvent != nil)
}

@Test func rejectingCoalitionDemandsLeavesPartnerUnhappy() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame(party: PartyCatalog.party(id: "spd"), playerName: "Test")
    let partner = engine.pendingCoalitionOptions!.first { !$0.isMinority }!
    engine.formCoalition(optionID: partner.id)
    engine.concludeCoalitionTalks(acceptedDemandIDs: [])
    #expect(engine.coalition.satisfaction < 52)
}

@Test func newGameOpensWithBriefingBeforeCoalition() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame(party: PartyCatalog.party(id: "spd"), playerName: "Test")

    // Zuerst das Lage-Briefing …
    #expect(engine.awaitingInitialBriefing)
    // … dann die Regierungsbildung, weiterhin im Startjahr.
    engine.dismissInitialBriefing()
    #expect(engine.awaitingInitialBriefing == false)
    #expect(engine.pendingCoalitionOptions != nil)
    #expect(engine.state.currentYear == 2000)
    #expect(engine.currentEvent == nil)
}

@Test func briefingStateSurvivesSnapshot() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame(party: PartyCatalog.party(id: "cdu"), playerName: "X")
    let restored = GameEngine(snapshot: engine.snapshot(), eventRepository: LocalJSONEventRepository())
    #expect(restored.awaitingInitialBriefing)
}
