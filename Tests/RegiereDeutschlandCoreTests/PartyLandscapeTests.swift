import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func partyLandscapeSumsToAboutHundred() {
    let state = GameStateFactory.initialGermany2000()
    let landscape = PartyLandscapeFactory.make(state: state, governingShare: 40, coalition: .standard())

    let total = landscape.parties.reduce(0) { $0 + $1.support }
    #expect(abs(total - 100) < 1.0)
    #expect(landscape.parties.contains { $0.role == .governing })
    #expect(landscape.strongestOpposition != nil)
    #expect(landscape.parties.first?.support ?? 0 >= landscape.parties.last?.support ?? 0)
}

@Test func polarizationStrengthensTheFarRight() {
    var calm = GameStateFactory.initialGermany2000()
    calm.hidden.polarization = 10
    var tense = GameStateFactory.initialGermany2000()
    tense.hidden.polarization = 80
    tense.visible.trust = 30
    tense.visible.security = 35

    let calmRight = PartyLandscapeFactory.make(state: calm, governingShare: 40, coalition: .standard())
        .parties.first { $0.id == "farright" }?.support ?? 0
    let tenseRight = PartyLandscapeFactory.make(state: tense, governingShare: 40, coalition: .standard())
        .parties.first { $0.id == "farright" }?.support ?? 0

    #expect(tenseRight > calmRight)
}
