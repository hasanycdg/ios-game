import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func localJSONRepositoryLoadsEnergyPolicyEvent() {
    let repository = LocalJSONEventRepository()

    let events = repository.events(for: 2000)
    let event = events.first

    #expect(events.count == 1)
    #expect(event?.id == "energy-policy-2000")
    #expect(event?.title == "Energiepolitik 2000")
}

@Test func eventOptionsDecodeCorrectly() {
    let event = LocalJSONEventRepository().events(for: 2000).first

    #expect(event?.options.count == 3)
    #expect(event?.options.map(\.id) == [
        "promote-renewables",
        "keep-energy-mix",
        "strengthen-nuclear"
    ])
    #expect(event?.options.first?.immediateEffects.isEmpty == false)
    #expect(event?.options.first?.hiddenEffects.isEmpty == false)
}

@Test func invalidJSONDataReturnsEmptyEventsInsteadOfCrashing() {
    let invalidData = Data("{ not valid json".utf8)

    let events = LocalJSONEventRepository.decodeEvents(from: invalidData)

    #expect(events.isEmpty)
}
