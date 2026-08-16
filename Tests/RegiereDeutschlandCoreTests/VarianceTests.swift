import Foundation
import Testing
@testable import RegiereDeutschlandCore

/// Spielt einen Durchlauf und sammelt die Reihenfolge der Ereignis-IDs.
private func eventSequence(seed: UInt64, maxEvents: Int = 14) -> [String] {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame(party: PartyCatalog.party(id: "spd"), playerName: "X", seed: seed)

    var ids: [String] = []
    var steps = 0
    while ids.count < maxEvents, engine.state.gameOverSummary == nil, steps < 400 {
        steps += 1
        if engine.awaitingInitialBriefing { engine.dismissInitialBriefing(); continue }
        if let opts = engine.pendingCoalitionOptions { engine.formCoalition(optionID: opts.first!.id); continue }
        if let talks = engine.pendingCoalitionTalks { engine.concludeCoalitionTalks(acceptedDemandIDs: Set(talks.demands.map(\.id))); continue }
        if engine.pendingCampaign { engine.runCampaign(focus: CampaignFocusCatalog.all[0]); continue }
        if engine.state.pendingElectionResult != nil { engine.continueAfterElection(); continue }
        if let enc = engine.pendingEncounter { engine.resolveEncounter(optionID: enc.options.first!.id); continue }
        if let event = engine.currentEvent {
            ids.append(event.id)
            try? engine.choose(option: event.options.first!.id)
            engine.advanceGame()
            continue
        }
        engine.advanceGame()
    }
    return ids
}

@Test func differentSeedsProduceDifferentRuns() {
    let a = eventSequence(seed: 1234)
    let b = eventSequence(seed: 987654)
    #expect(!a.isEmpty)
    #expect(a != b)   // andere Seeds -> anderer Verlauf (Reihenfolge/Auswahl)
}

@Test func sameSeedIsReproducible() {
    #expect(eventSequence(seed: 42) == eventSequence(seed: 42))
}

@Test func seededRunSurvivesSnapshot() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame(party: PartyCatalog.party(id: "spd"), playerName: "X", seed: 777)
    let restored = GameEngine(snapshot: engine.snapshot(), eventRepository: LocalJSONEventRepository())
    #expect(restored.randomSeed == 777)
}
