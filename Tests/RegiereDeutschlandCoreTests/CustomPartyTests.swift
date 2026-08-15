import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func customPartyBuildsFromChoices() {
    let party = CustomPartyFactory.make(
        name: "Zukunft", shortName: "",
        ideologyID: "ecological", goalIDs: ["goal-klima", "goal-digital"]
    )
    #expect(party.id == "custom")
    #expect(party.name == "Zukunft")
    #expect(party.isCustom)
    #expect(party.leaning == .left)
    #expect(party.agenda.count == 2)
    #expect(party.shortName == "Z")   // Kürzel aus Anfangsbuchstaben abgeleitet
    // Ökologisch + Klima-Ziel schlagen sich im Start-Profil nieder.
    #expect(party.profile.hiddenModifiers.contains { $0.metric == .renewableCapacity })
    // Natürliche Partner richten sich nach der Ausrichtung.
    #expect(party.naturalPartnerIDs.contains("gruene"))
}

@Test func startingWithCustomPartyAppliesItsProgram() {
    let party = CustomPartyFactory.make(
        name: "Grünzukunft", shortName: "GZ",
        ideologyID: "ecological", goalIDs: ["goal-klima"]
    )
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame(party: party, playerName: "Test")

    // Ökologie + Klimaziel heben die Erneuerbaren-Kapazität über den Basiswert (16).
    #expect(engine.state.hidden.renewableCapacity > 16)
    #expect(engine.playerParty.isCustom)
    // Auch die eigene Partei startet mit Koalitionsbildung.
    #expect(engine.pendingCoalitionOptions != nil)
}

@Test func customPartySurvivesSnapshotRoundTrip() {
    let party = CustomPartyFactory.make(
        name: "Testpartei", shortName: "TP",
        ideologyID: "liberal", goalIDs: ["goal-haushalt", "goal-digital"]
    )
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame(party: party, playerName: "Chef")

    let snapshot = engine.snapshot()
    let restored = GameEngine(snapshot: snapshot, eventRepository: LocalJSONEventRepository())

    #expect(restored.playerParty.id == "custom")
    #expect(restored.playerParty.name == "Testpartei")
    #expect(restored.playerParty.isCustom)
    #expect(restored.playerParty.agenda.count == 2)
    #expect(restored.playerParty.shortName == "TP")
    #expect(restored.playerName == "Chef")
}
