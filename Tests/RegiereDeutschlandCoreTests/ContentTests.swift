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
