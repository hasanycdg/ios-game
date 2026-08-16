import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func difficultyChangesStartingCapital() {
    let easy = GameEngine(eventRepository: LocalJSONEventRepository())
    easy.startNewGame(party: PartyCatalog.party(id: "spd"), playerName: "X", difficulty: .leicht)
    let hard = GameEngine(eventRepository: LocalJSONEventRepository())
    hard.startNewGame(party: PartyCatalog.party(id: "spd"), playerName: "X", difficulty: .schwer)

    #expect(easy.politicalCapital > hard.politicalCapital)
    #expect(easy.difficulty == .leicht)
    #expect(hard.difficulty == .schwer)
}

@Test func difficultyShiftsElectionShare() {
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2005
    let engine = ElectionEngine()
    let easy = engine.project(in: state, shareBonus: Difficulty.leicht.electionShareBonus)
    let hard = engine.project(in: state, shareBonus: Difficulty.schwer.electionShareBonus)
    #expect(easy.governingShare > hard.governingShare)
}

@Test func difficultySurvivesSnapshot() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame(party: PartyCatalog.party(id: "cdu"), playerName: "Y", difficulty: .schwer)
    let restored = GameEngine(snapshot: engine.snapshot(), eventRepository: LocalJSONEventRepository())
    #expect(restored.difficulty == .schwer)
}
