import Foundation

/// Eine echte deutsche Partei, die der Spieler als Regierungspartei wählen kann.
/// Ersetzt die früheren „Kanzler-Typen": jede Partei bringt ihr eigenes
/// Start-Profil (Werte-Modifikatoren, Kapital) und ihre natürlichen
/// Koalitionspartner mit.
public struct PlayerParty: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String            // z.B. "SPD"
    public let fullName: String        // z.B. "Sozialdemokratische Partei"
    public let shortName: String       // Kürzel im Balken (z.B. "SPD")
    public let tagline: String
    public let spectrum: Double         // 0 = links, 1 = rechts
    public let leaning: PoliticalLeaning
    public let baseSupport: Double      // realer Ausgangswert um 2000 (%)
    public let profile: KanzlerPersona  // Start-Profil für die Engine-Mechanik
    public let naturalPartnerIDs: [String]

    public init(
        id: String,
        name: String,
        fullName: String,
        shortName: String,
        tagline: String,
        spectrum: Double,
        leaning: PoliticalLeaning,
        baseSupport: Double,
        profile: KanzlerPersona,
        naturalPartnerIDs: [String]
    ) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.shortName = shortName
        self.tagline = tagline
        self.spectrum = spectrum
        self.leaning = leaning
        self.baseSupport = baseSupport
        self.profile = profile
        self.naturalPartnerIDs = naturalPartnerIDs
    }
}

/// Referenz-Eintrag für eine Partei in der Umfrage-Landschaft (auch nicht
/// spielbare wie Linke/AfD).
public struct PartyReference: Sendable {
    public let id: String
    public let name: String
    public let shortName: String
    public let spectrum: Double
    public let leaning: PoliticalLeaning
    public let baseSupport: Double
    public let isPlayable: Bool

    public init(id: String, name: String, shortName: String, spectrum: Double, leaning: PoliticalLeaning, baseSupport: Double, isPlayable: Bool) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.spectrum = spectrum
        self.leaning = leaning
        self.baseSupport = baseSupport
        self.isPlayable = isPlayable
    }
}

public enum PartyCatalog {

    // MARK: Spielbare Parteien

    public static let playable: [PlayerParty] = [
        PlayerParty(
            id: "spd",
            name: "SPD",
            fullName: "Sozialdemokratische Partei",
            shortName: "SPD",
            tagline: "Soziale Gerechtigkeit und ein starker Sozialstaat.",
            spectrum: 0.36,
            leaning: .left,
            baseSupport: 40,
            profile: KanzlerPersona(
                id: "spd",
                title: "SPD",
                tagline: "Soziale Gerechtigkeit und ein starker Sozialstaat.",
                icon: "figure.2.arms.open",
                visibleModifiers: [
                    GameEffect(metric: .livingStandard, change: 3),
                    GameEffect(metric: .society, change: 2),
                    GameEffect(metric: .budget, change: -2)
                ],
                hiddenModifiers: [
                    HiddenEffect(metric: .welfareStrength, change: 6),
                    HiddenEffect(metric: .labourMarketFlexibility, change: -3)
                ],
                startingCapital: 7,
                coalitionLeaning: .left,
                coalitionSatisfaction: 62,
                coalitionPartnerName: "Grüne"
            ),
            naturalPartnerIDs: ["gruene", "fdp", "linke"]
        ),
        PlayerParty(
            id: "cdu",
            name: "CDU/CSU",
            fullName: "Christlich Demokratische Union",
            shortName: "CDU",
            tagline: "Wirtschaftskraft, innere Sicherheit, solide Kasse.",
            spectrum: 0.66,
            leaning: .conservative,
            baseSupport: 37,
            profile: KanzlerPersona(
                id: "cdu",
                title: "CDU/CSU",
                tagline: "Wirtschaftskraft, innere Sicherheit, solide Kasse.",
                icon: "building.columns.fill",
                visibleModifiers: [
                    GameEffect(metric: .economy, change: 3),
                    GameEffect(metric: .security, change: 3),
                    GameEffect(metric: .society, change: -2)
                ],
                hiddenModifiers: [
                    HiddenEffect(metric: .fiscalSpace, change: 5),
                    HiddenEffect(metric: .defenceReadiness, change: 4),
                    HiddenEffect(metric: .welfareStrength, change: -2)
                ],
                startingCapital: 7,
                coalitionLeaning: .liberal,
                coalitionSatisfaction: 64,
                coalitionPartnerName: "FDP"
            ),
            naturalPartnerIDs: ["fdp", "gruene", "spd"]
        ),
        PlayerParty(
            id: "gruene",
            name: "Grüne",
            fullName: "Bündnis 90/Die Grünen",
            shortName: "GRÜ",
            tagline: "Klima, Ökologie und gesellschaftlicher Fortschritt.",
            spectrum: 0.24,
            leaning: .left,
            baseSupport: 8,
            profile: KanzlerPersona(
                id: "gruene",
                title: "Grüne",
                tagline: "Klima, Ökologie und gesellschaftlicher Fortschritt.",
                icon: "leaf.fill",
                visibleModifiers: [
                    GameEffect(metric: .society, change: 3),
                    GameEffect(metric: .energy, change: 2),
                    GameEffect(metric: .economy, change: -2)
                ],
                hiddenModifiers: [
                    HiddenEffect(metric: .renewableCapacity, change: 12),
                    HiddenEffect(metric: .nuclearCapacity, change: -6),
                    HiddenEffect(metric: .russianEnergyDependency, change: -3),
                    HiddenEffect(metric: .polarization, change: 5)
                ],
                startingCapital: 6,
                capitalIncomeBonus: 1,
                coalitionLeaning: .left,
                coalitionSatisfaction: 60,
                coalitionPartnerName: "SPD"
            ),
            naturalPartnerIDs: ["spd", "cdu", "fdp"]
        ),
        PlayerParty(
            id: "fdp",
            name: "FDP",
            fullName: "Freie Demokratische Partei",
            shortName: "FDP",
            tagline: "Freie Wirtschaft, weniger Staat, solide Finanzen.",
            spectrum: 0.62,
            leaning: .liberal,
            baseSupport: 7,
            profile: KanzlerPersona(
                id: "fdp",
                title: "FDP",
                tagline: "Freie Wirtschaft, weniger Staat, solide Finanzen.",
                icon: "chart.line.uptrend.xyaxis",
                visibleModifiers: [
                    GameEffect(metric: .economy, change: 4),
                    GameEffect(metric: .budget, change: 3),
                    GameEffect(metric: .livingStandard, change: -2)
                ],
                hiddenModifiers: [
                    HiddenEffect(metric: .labourMarketFlexibility, change: 9),
                    HiddenEffect(metric: .fiscalSpace, change: 6),
                    HiddenEffect(metric: .digitalization, change: 4),
                    HiddenEffect(metric: .welfareStrength, change: -5)
                ],
                startingCapital: 6,
                costReduction: 1,
                coalitionLeaning: .conservative,
                coalitionSatisfaction: 64,
                coalitionPartnerName: "CDU/CSU"
            ),
            naturalPartnerIDs: ["cdu", "spd", "gruene"]
        )
    ]

    public static var `default`: PlayerParty { playable[0] }

    public static func party(id: String) -> PlayerParty {
        playable.first { $0.id == id } ?? `default`
    }

    public static let defaultChancellorName = "Alex Bund"

    // MARK: Gesamte Parteienlandschaft (inkl. nicht spielbarer)

    /// Alle Parteien der Umfrage-Landschaft mit ihren realen Ausgangswerten.
    public static let landscape: [PartyReference] = [
        PartyReference(id: "spd", name: "SPD", shortName: "SPD", spectrum: 0.36, leaning: .left, baseSupport: 40, isPlayable: true),
        PartyReference(id: "cdu", name: "CDU/CSU", shortName: "CDU", spectrum: 0.66, leaning: .conservative, baseSupport: 37, isPlayable: true),
        PartyReference(id: "gruene", name: "Grüne", shortName: "GRÜ", spectrum: 0.24, leaning: .left, baseSupport: 8, isPlayable: true),
        PartyReference(id: "fdp", name: "FDP", shortName: "FDP", spectrum: 0.62, leaning: .liberal, baseSupport: 7, isPlayable: true),
        PartyReference(id: "linke", name: "Die Linke", shortName: "LNK", spectrum: 0.12, leaning: .left, baseSupport: 5, isPlayable: false),
        PartyReference(id: "afd", name: "AfD", shortName: "AfD", spectrum: 0.92, leaning: .conservative, baseSupport: 1, isPlayable: false)
    ]

    public static func reference(id: String) -> PartyReference? {
        landscape.first { $0.id == id }
    }

    public static func leaning(for partyID: String) -> PoliticalLeaning {
        reference(id: partyID)?.leaning ?? .liberal
    }
}
