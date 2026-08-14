import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func diplomacyIsSeededFromHiddenRelations() {
    let state = GameStateFactory.initialGermany2000()
    let diplomacy = DiplomaticState.standard(from: state.hidden)
    #expect(diplomacy.relation(.eu) == state.hidden.euRelations)
    #expect(diplomacy.relation(.usa) == state.hidden.usRelations)
    #expect(diplomacy.relation(.russia) == state.hidden.russiaRelations)
}

@Test func energyDealWithRussiaRaisesRelationAndDependency() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()
    let relationBefore = engine.diplomacy.relation(.russia)
    let dependencyBefore = engine.state.hidden.russianEnergyDependency
    let capitalBefore = engine.politicalCapital

    let ok = engine.takeDiplomaticAction(.russia, actionID: "ru-energy")
    #expect(ok)
    #expect(engine.diplomacy.relation(.russia) > relationBefore)
    #expect(engine.state.hidden.russianEnergyDependency > dependencyBefore)
    #expect(engine.politicalCapital == capitalBefore - 2)
}

@Test func sanctionsCoolTheRelationButPleaseTheWest() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()
    let russiaBefore = engine.diplomacy.relation(.russia)
    let euBefore = engine.state.hidden.euRelations

    engine.takeDiplomaticAction(.russia, actionID: "ru-sanctions")
    #expect(engine.diplomacy.relation(.russia) < russiaBefore)
    #expect(engine.state.hidden.euRelations >= euBefore)
}

@Test func diplomaticActionNeedsCapital() {
    let snapshot = GameSessionSnapshot(state: GameStateFactory.initialGermany2000(),
                                       currentEventID: nil, lastDecisionResult: nil, politicalCapital: 0)
    let engine = GameEngine(snapshot: snapshot, eventRepository: LocalJSONEventRepository())
    #expect(engine.takeDiplomaticAction(.eu, actionID: "eu-summit") == false)
}
