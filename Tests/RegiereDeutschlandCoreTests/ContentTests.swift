import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func expandedContentLoadsAndIsWellFormed() {
    let events = LocalJSONEventRepository().loadEvents()
    #expect(events.count >= 60)
    for event in events {
        #expect(!event.headline.isEmpty)
        #expect(event.options.count >= 2, "\(event.id) hat zu wenige Optionen")
        #expect(event.options.allSatisfy { !$0.title.isEmpty })
    }
}

@Test func everyRequiredFlagIsProducedSomewhere() {
    let events = LocalJSONEventRepository().loadEvents()
    var producedFlags = Set<String>()
    for event in events {
        for option in event.options {
            producedFlags.formUnion(option.flagsToSet)
            for delayed in option.delayedEffects { producedFlags.formUnion(delayed.flagsToSet) }
        }
    }
    for event in events {
        for condition in event.conditions {
            for flag in condition.requiredFlags {
                #expect(producedFlags.contains(flag), "Kette gebrochen: '\(flag)' (\(event.id)) wird nie gesetzt")
            }
        }
    }
}

@Test func digitalChainPayoffRequiresTheEarlyInvestment() {
    let events = LocalJSONEventRepository().loadEvents()
    let payoff = events.first { $0.id == "x-digital-2016" }
    #expect(payoff?.conditions.first?.requiredFlags.contains("x_digital_push") == true)

    let origin = events.first { $0.id == "x-digital-2007" }
    let investOption = origin?.options.first { $0.id == "dig-invest" }
    #expect(investOption?.flagsToSet.contains("x_digital_push") == true)
    #expect(investOption?.delayedEffects.isEmpty == false)
}

@Test func futureCampaignHasAPlayableDecisionForEveryYearThrough2050() {
    let events = LocalJSONEventRepository().loadEvents()

    #expect(events.filter { $0.id.hasPrefix("future-") }.count >= 75)

    for year in 2026...2050 {
        #expect(events.contains { $0.year == year && $0.id.hasPrefix("future-") }, "Zukunftsjahr \(year) fehlt")
    }

    let grid = events.first { $0.id == "future-grid-2026" }
    #expect(grid?.options.contains { $0.flagsToSet.contains("future_grid_fast") } == true)

    let heat = events.first { $0.id == "future-energy-2045" }
    #expect(heat?.options.contains { option in
        option.conditionalModifiers.contains { modifier in
            modifier.conditions.contains { $0.requiredFlags.contains("future_grid_dividend") }
        }
    } == true)
}

@Test func futureEventsNeedTheFutureCampaignLicense() {
    let event = LocalJSONEventRepository().loadEvents().first { $0.id == "future-grid-2026" }
    var state = GameStateFactory.initialGermany2000()
    state.currentYear = 2026

    #expect(event?.isAvailable(in: state) == false)
    state.historicalFlags.insert("content_future_2050")
    #expect(event?.isAvailable(in: state) == true)
}
