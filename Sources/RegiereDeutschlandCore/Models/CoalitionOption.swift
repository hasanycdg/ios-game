import Foundation

/// Eine mögliche Regierungskoalition nach einer gewonnenen Wahl.
public struct CoalitionOption: Codable, Equatable, Identifiable, Sendable {
    public let id: String            // Partei-ID oder "none" (Minderheit)
    public let partyName: String
    public let leaning: PoliticalLeaning
    public let combinedShare: Double // eigenes Lager + Partner
    public let formsMajority: Bool
    public let isMinority: Bool

    public init(id: String, partyName: String, leaning: PoliticalLeaning, combinedShare: Double, formsMajority: Bool, isMinority: Bool) {
        self.id = id
        self.partyName = partyName
        self.leaning = leaning
        self.combinedShare = combinedShare
        self.formsMajority = formsMajority
        self.isMinority = isMinority
    }
}
