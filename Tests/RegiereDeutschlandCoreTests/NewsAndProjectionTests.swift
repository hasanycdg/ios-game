import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func worldNewsCoversEveryYearThrough2026() {
    let repository = LocalJSONNewsRepository()
    let all = repository.loadNews()
    #expect(all.count >= 60)
    for year in 2000...2026 {
        #expect(!repository.news(for: year).isEmpty, "Kein News-Eintrag fuer \(year)")
    }
}

@Test func worldNewsContainsKnownHistoricalHeadline() {
    let repository = LocalJSONNewsRepository()
    let news2011 = repository.news(for: 2011)
    #expect(news2011.contains { $0.headline.contains("Fukushima") })
}

@Test func dynamicNewsReactsToDecisions() throws {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()
    try engine.choose(option: "promote-renewables")

    let news = DynamicNewsFactory.make(for: engine.state)
    #expect(news.contains { $0.scope == .domestic })
    #expect(news.contains { $0.headline.contains("Kabinettsbeschluss") })
}

@Test func electionProjectionStaysInPlausibleRange() {
    let engine = GameEngine(eventRepository: LocalJSONEventRepository())
    engine.startNewGame()
    let electionEngine = ElectionEngine()

    let projection = electionEngine.project(in: engine.state)
    #expect(projection.governingShare >= 24 && projection.governingShare <= 52)
    #expect(projection.oppositionShare >= 25 && projection.oppositionShare <= 55)
    #expect(projection.nextElectionYear == 2005)
}

@Test func projectionMatchesConductedElectionShares() {
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2005
    let electionEngine = ElectionEngine()

    let projection = electionEngine.project(in: state)
    let result = electionEngine.conductElection(in: state)

    #expect(projection.governingShare == result.governingPartyShare)
    #expect(projection.oppositionShare == result.oppositionShare)
    #expect(projection.wouldWin == result.didWin)
}
