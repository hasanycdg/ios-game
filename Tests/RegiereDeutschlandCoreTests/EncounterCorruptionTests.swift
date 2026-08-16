import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func lobbyOfferOffersAcceptDeclineExpose() {
    let encounter = LobbyFactory.make(state: GameStateFactory.initialGermany2000(), year: 2002)
    #expect(encounter.kind == .lobby)
    #expect(encounter.options.contains { $0.id == "accept" })
    #expect(encounter.options.contains { $0.id == "expose" })
    let accept = encounter.options.first { $0.id == "accept" }!
    #expect(accept.corruptionEffect > 0)
    #expect(accept.capitalReward > 0)
}

@Test func resolvingLobbyAcceptRaisesCorruptionAndCapital() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()
    // Begegnung von Hand setzen und annehmen.
    let encounter = LobbyFactory.make(state: engine.state, year: 2002)
    let capitalBefore = engine.politicalCapital
    // Über einen Snapshot mit vorgemerkter Begegnung einspielen.
    let snapshot = GameSessionSnapshot(
        state: engine.state, currentEventID: nil, lastDecisionResult: nil,
        politicalCapital: capitalBefore, coalition: engine.coalition,
        personaID: engine.persona.id, pendingEncounter: encounter
    )
    let resumed = GameEngine(snapshot: snapshot, eventRepository: LocalJSONEventRepository())
    #expect(resumed.pendingEncounter != nil)

    resumed.resolveEncounter(optionID: "accept")
    #expect(resumed.corruption >= 20)
    #expect(resumed.politicalCapital >= capitalBefore)
    #expect(resumed.pendingEncounter == nil)
}

@Test func interviewReflectsTheWeakestMetric() {
    var state = GameStateFactory.initialGermany2000()
    state.visible.economy = 20
    // Jahr 2002: kein Führungs-Interview (nur alle 3 Jahre), daher spiegelt es
    // den schwächsten Wert – hier die Wirtschaft.
    let interview = InterviewFactory.make(state: state, year: 2002)
    #expect(interview.kind == .interview)
    #expect(interview.prompt.contains("Wirtschaft"))
    #expect(interview.options.count == 3)
}

@Test func interviewsVaryWithTheSituation() {
    // Angespannte Koalition und Höhenflug erzeugen andere Interviews als die
    // reine Schwachstellen-Frage.
    var tenseCoalition = GameStateFactory.initialGermany2000()
    tenseCoalition.visible.economy = 20
    let rift = InterviewFactory.make(
        state: tenseCoalition, year: 2004,
        coalition: CoalitionState(partnerName: "Grüne", leaning: .left, satisfaction: 20)
    )
    #expect(rift.title == "Krisengespräch")

    var strong = GameStateFactory.initialGermany2000()
    strong.governmentApproval = 80
    let highApproval = InterviewFactory.make(state: strong, year: 2004)
    #expect(highApproval.title == "Das große Interview")
    #expect(rift.prompt != highApproval.prompt)
}
