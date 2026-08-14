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
    let interview = InterviewFactory.make(state: state, year: 2001)
    #expect(interview.kind == .interview)
    #expect(interview.prompt.contains("Wirtschaft"))
    #expect(interview.options.count == 3)
}
