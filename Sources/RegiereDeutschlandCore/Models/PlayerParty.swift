import Foundation

/// Eine echte deutsche Partei, die der Spieler als Regierungspartei wählen kann.
/// Ersetzt die früheren „Kanzler-Typen": jede Partei bringt ihr eigenes
/// Start-Profil (Werte-Modifikatoren, Kapital) und ihre natürlichen
/// Koalitionspartner mit.
public struct PlayerParty: Identifiable, Equatable, Codable, Sendable {
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
    /// Die Vorhaben (Agenda) der Partei – bei eigenen Parteien vom Spieler gewählt.
    public let agenda: [AgendaItem]
    /// True, wenn der Spieler diese Partei selbst gegründet hat.
    public let isCustom: Bool

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
        naturalPartnerIDs: [String],
        agenda: [AgendaItem] = [],
        isCustom: Bool = false
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
        self.agenda = agenda
        self.isCustom = isCustom
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, fullName, shortName, tagline, spectrum, leaning
        case baseSupport, profile, naturalPartnerIDs, agenda, isCustom
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        fullName = try c.decode(String.self, forKey: .fullName)
        shortName = try c.decode(String.self, forKey: .shortName)
        tagline = try c.decodeIfPresent(String.self, forKey: .tagline) ?? ""
        spectrum = try c.decode(Double.self, forKey: .spectrum)
        leaning = try c.decode(PoliticalLeaning.self, forKey: .leaning)
        baseSupport = try c.decode(Double.self, forKey: .baseSupport)
        profile = try c.decode(KanzlerPersona.self, forKey: .profile)
        naturalPartnerIDs = try c.decodeIfPresent([String].self, forKey: .naturalPartnerIDs) ?? []
        agenda = try c.decodeIfPresent([AgendaItem].self, forKey: .agenda) ?? []
        isCustom = try c.decodeIfPresent(Bool.self, forKey: .isCustom) ?? false
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
            name: "SDP",
            fullName: "Sozialdemokratische Partei",
            shortName: "SDP",
            tagline: "Soziale Gerechtigkeit und ein starker Sozialstaat.",
            spectrum: 0.36,
            leaning: .left,
            baseSupport: 40,
            profile: KanzlerPersona(
                id: "spd",
                title: "SDP",
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
                coalitionPartnerName: "Grün-Alternative"
            ),
            naturalPartnerIDs: ["gruene", "fdp", "linke"],
            agenda: PartyAgendaCatalog.agenda(for: "spd")
        ),
        PlayerParty(
            id: "cdu",
            name: "CDV/CSV",
            fullName: "Christlich-Demokratische Volkspartei",
            shortName: "CDV",
            tagline: "Wirtschaftskraft, innere Sicherheit, solide Kasse.",
            spectrum: 0.66,
            leaning: .conservative,
            baseSupport: 37,
            profile: KanzlerPersona(
                id: "cdu",
                title: "CDV/CSV",
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
                coalitionPartnerName: "FDV"
            ),
            naturalPartnerIDs: ["fdp", "gruene", "spd"],
            agenda: PartyAgendaCatalog.agenda(for: "cdu")
        ),
        PlayerParty(
            id: "gruene",
            name: "Grün-Alternative",
            fullName: "Grüne Alternative",
            shortName: "GAL",
            tagline: "Klima, Ökologie und gesellschaftlicher Fortschritt.",
            spectrum: 0.24,
            leaning: .left,
            baseSupport: 8,
            profile: KanzlerPersona(
                id: "gruene",
                title: "Grün-Alternative",
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
                coalitionPartnerName: "SDP"
            ),
            naturalPartnerIDs: ["spd", "cdu", "fdp"],
            agenda: PartyAgendaCatalog.agenda(for: "gruene")
        ),
        PlayerParty(
            id: "fdp",
            name: "FDV",
            fullName: "Freie Demokratische Volkspartei",
            shortName: "FDV",
            tagline: "Freie Wirtschaft, weniger Staat, solide Finanzen.",
            spectrum: 0.62,
            leaning: .liberal,
            baseSupport: 7,
            profile: KanzlerPersona(
                id: "fdp",
                title: "FDV",
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
                coalitionPartnerName: "CDV/CSV"
            ),
            naturalPartnerIDs: ["cdu", "spd", "gruene"],
            agenda: PartyAgendaCatalog.agenda(for: "fdp")
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
        PartyReference(id: "spd", name: "SDP", shortName: "SDP", spectrum: 0.36, leaning: .left, baseSupport: 40, isPlayable: true),
        PartyReference(id: "cdu", name: "CDV/CSV", shortName: "CDV", spectrum: 0.66, leaning: .conservative, baseSupport: 37, isPlayable: true),
        PartyReference(id: "gruene", name: "Grün-Alternative", shortName: "GAL", spectrum: 0.24, leaning: .left, baseSupport: 8, isPlayable: true),
        PartyReference(id: "fdp", name: "FDV", shortName: "FDV", spectrum: 0.62, leaning: .liberal, baseSupport: 7, isPlayable: true),
        PartyReference(id: "linke", name: "Linksbündnis", shortName: "LNK", spectrum: 0.12, leaning: .left, baseSupport: 5, isPlayable: false),
        PartyReference(id: "afd", name: "AfP", shortName: "AfP", spectrum: 0.92, leaning: .conservative, baseSupport: 1, isPlayable: false)
    ]

    public static func reference(id: String) -> PartyReference? {
        landscape.first { $0.id == id }
    }

    public static func leaning(for partyID: String) -> PoliticalLeaning {
        reference(id: partyID)?.leaning ?? .liberal
    }
}
