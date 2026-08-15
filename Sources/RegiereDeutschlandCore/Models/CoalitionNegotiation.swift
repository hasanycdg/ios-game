import Foundation

/// Laufendes Koalitionsgespräch: Der gewählte Partner legt seine Forderungen
/// auf den Tisch, der Kanzler sagt sie zu oder lehnt sie ab.
public struct CoalitionNegotiation: Codable, Equatable, Sendable {
    public let partnerID: String
    public let partnerName: String
    public let leaning: PoliticalLeaning
    public let combinedShare: Double
    public let formsMajority: Bool
    public let isInitial: Bool          // Amtsantritt vs. nach einer Wahl
    public let demands: [AgendaItem]

    public init(
        partnerID: String,
        partnerName: String,
        leaning: PoliticalLeaning,
        combinedShare: Double,
        formsMajority: Bool,
        isInitial: Bool,
        demands: [AgendaItem]
    ) {
        self.partnerID = partnerID
        self.partnerName = partnerName
        self.leaning = leaning
        self.combinedShare = combinedShare
        self.formsMajority = formsMajority
        self.isInitial = isInitial
        self.demands = demands
    }
}
