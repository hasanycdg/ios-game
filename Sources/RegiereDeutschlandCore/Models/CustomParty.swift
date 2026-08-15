import Foundation

/// Eine Ideologie, die der Spieler beim Gründen einer eigenen Partei wählt.
/// Legt Spektrum, Ausrichtung, Start-Profil und die möglichen Partner fest.
public struct PartyIdeology: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let tagline: String
    public let icon: String
    public let spectrum: Double
    public let leaning: PoliticalLeaning
    public let visibleModifiers: [GameEffect]
    public let hiddenModifiers: [HiddenEffect]
    public let startingCapital: Int
    public let costReduction: Int
    public let naturalPartnerIDs: [String]

    public init(
        id: String,
        title: String,
        tagline: String,
        icon: String,
        spectrum: Double,
        leaning: PoliticalLeaning,
        visibleModifiers: [GameEffect] = [],
        hiddenModifiers: [HiddenEffect] = [],
        startingCapital: Int = 7,
        costReduction: Int = 0,
        naturalPartnerIDs: [String]
    ) {
        self.id = id
        self.title = title
        self.tagline = tagline
        self.icon = icon
        self.spectrum = spectrum
        self.leaning = leaning
        self.visibleModifiers = visibleModifiers
        self.hiddenModifiers = hiddenModifiers
        self.startingCapital = startingCapital
        self.costReduction = costReduction
        self.naturalPartnerIDs = naturalPartnerIDs
    }
}

public enum IdeologyCatalog {
    public static let all: [PartyIdeology] = [
        PartyIdeology(
            id: "socialdemocratic",
            title: "Sozialdemokratisch",
            tagline: "Sozialer Ausgleich und ein starker Sozialstaat.",
            icon: "figure.2.arms.open",
            spectrum: 0.35, leaning: .left,
            visibleModifiers: [GameEffect(metric: .livingStandard, change: 3), GameEffect(metric: .society, change: 2), GameEffect(metric: .budget, change: -2)],
            hiddenModifiers: [HiddenEffect(metric: .welfareStrength, change: 5), HiddenEffect(metric: .labourMarketFlexibility, change: -2)],
            startingCapital: 7,
            naturalPartnerIDs: ["spd", "gruene", "linke"]
        ),
        PartyIdeology(
            id: "ecological",
            title: "Ökologisch",
            tagline: "Klimaschutz und Nachhaltigkeit an erster Stelle.",
            icon: "leaf.fill",
            spectrum: 0.28, leaning: .left,
            visibleModifiers: [GameEffect(metric: .society, change: 2), GameEffect(metric: .energy, change: 2), GameEffect(metric: .economy, change: -2)],
            hiddenModifiers: [HiddenEffect(metric: .renewableCapacity, change: 8), HiddenEffect(metric: .nuclearCapacity, change: -4), HiddenEffect(metric: .polarization, change: 3)],
            startingCapital: 6,
            naturalPartnerIDs: ["gruene", "spd", "fdp"]
        ),
        PartyIdeology(
            id: "liberal",
            title: "Wirtschaftsliberal",
            tagline: "Freie Märkte, weniger Staat, solide Finanzen.",
            icon: "chart.line.uptrend.xyaxis",
            spectrum: 0.62, leaning: .liberal,
            visibleModifiers: [GameEffect(metric: .economy, change: 4), GameEffect(metric: .budget, change: 2), GameEffect(metric: .livingStandard, change: -2)],
            hiddenModifiers: [HiddenEffect(metric: .labourMarketFlexibility, change: 7), HiddenEffect(metric: .fiscalSpace, change: 4), HiddenEffect(metric: .welfareStrength, change: -3)],
            startingCapital: 6, costReduction: 1,
            naturalPartnerIDs: ["fdp", "cdu", "spd"]
        ),
        PartyIdeology(
            id: "conservative",
            title: "Konservativ",
            tagline: "Wirtschaftskraft, Ordnung und innere Sicherheit.",
            icon: "shield.lefthalf.filled",
            spectrum: 0.70, leaning: .conservative,
            visibleModifiers: [GameEffect(metric: .economy, change: 3), GameEffect(metric: .security, change: 3), GameEffect(metric: .society, change: -2)],
            hiddenModifiers: [HiddenEffect(metric: .defenceReadiness, change: 4), HiddenEffect(metric: .fiscalSpace, change: 3)],
            startingCapital: 7,
            naturalPartnerIDs: ["cdu", "fdp"]
        ),
        PartyIdeology(
            id: "progressive",
            title: "Progressiv & modern",
            tagline: "Fortschritt, Digitalisierung und pragmatische Mitte.",
            icon: "sparkles",
            spectrum: 0.50, leaning: .liberal,
            visibleModifiers: [GameEffect(metric: .society, change: 2), GameEffect(metric: .economy, change: 1), GameEffect(metric: .trust, change: 2)],
            hiddenModifiers: [HiddenEffect(metric: .digitalization, change: 6)],
            startingCapital: 7,
            naturalPartnerIDs: ["spd", "fdp", "gruene"]
        ),
        PartyIdeology(
            id: "populist",
            title: "Populistisch",
            tagline: "Gegen das Establishment – laute Töne, viel Mobilisierung.",
            icon: "megaphone.fill",
            spectrum: 0.85, leaning: .conservative,
            visibleModifiers: [GameEffect(metric: .trust, change: 3), GameEffect(metric: .society, change: -2)],
            hiddenModifiers: [HiddenEffect(metric: .polarization, change: 8), HiddenEffect(metric: .integrationCapacity, change: -3)],
            startingCapital: 8,
            naturalPartnerIDs: ["cdu", "fdp"]
        )
    ]

    public static var `default`: PartyIdeology { all[0] }

    public static func ideology(id: String) -> PartyIdeology {
        all.first { $0.id == id } ?? `default`
    }
}

/// Ein wählbares Ziel beim Gründen einer eigenen Partei. Die gewählten Ziele
/// werden zur Agenda der Partei – und wirken schon zum Start als Programm.
public enum CustomGoalCatalog {
    public static let all: [AgendaItem] = [
        AgendaItem(id: "goal-sozialstaat", title: "Sozialstaat ausbauen",
                   summary: "Höhere Sozialleistungen und mehr Absicherung.", demand: "",
                   visibleEffects: [GameEffect(metric: .livingStandard, change: 2)],
                   hiddenEffects: [HiddenEffect(metric: .welfareStrength, change: 4)]),
        AgendaItem(id: "goal-klima", title: "Klima schützen",
                   summary: "Erneuerbare ausbauen, Emissionen senken.", demand: "",
                   visibleEffects: [GameEffect(metric: .energy, change: 2)],
                   hiddenEffects: [HiddenEffect(metric: .renewableCapacity, change: 5)]),
        AgendaItem(id: "goal-wirtschaft", title: "Wirtschaft ankurbeln",
                   summary: "Wachstum, Investitionen, mehr Jobs.", demand: "",
                   visibleEffects: [GameEffect(metric: .economy, change: 3)],
                   hiddenEffects: [HiddenEffect(metric: .labourMarketFlexibility, change: 3)]),
        AgendaItem(id: "goal-sicherheit", title: "Sicherheit stärken",
                   summary: "Mehr Personal und Befugnisse für die Sicherheit.", demand: "",
                   visibleEffects: [GameEffect(metric: .security, change: 3)],
                   hiddenEffects: [HiddenEffect(metric: .defenceReadiness, change: 3)]),
        AgendaItem(id: "goal-haushalt", title: "Solide Finanzen",
                   summary: "Schulden abbauen, sparsam wirtschaften.", demand: "",
                   visibleEffects: [GameEffect(metric: .budget, change: 3)],
                   hiddenEffects: [HiddenEffect(metric: .fiscalSpace, change: 4)]),
        AgendaItem(id: "goal-digital", title: "Digitalisierung vorantreiben",
                   summary: "Schnelles Netz und digitale Verwaltung.", demand: "",
                   visibleEffects: [GameEffect(metric: .economy, change: 1)],
                   hiddenEffects: [HiddenEffect(metric: .digitalization, change: 6)]),
        AgendaItem(id: "goal-bildung", title: "In Bildung investieren",
                   summary: "Bessere Schulen, gleiche Chancen.", demand: "",
                   visibleEffects: [GameEffect(metric: .society, change: 2), GameEffect(metric: .budget, change: -1)]),
        AgendaItem(id: "goal-steuern", title: "Steuern senken",
                   summary: "Bürger und Wirtschaft entlasten.", demand: "",
                   visibleEffects: [GameEffect(metric: .economy, change: 2), GameEffect(metric: .budget, change: -2)],
                   hiddenEffects: [HiddenEffect(metric: .fiscalSpace, change: -2)]),
        AgendaItem(id: "goal-umverteilung", title: "Reichtum umverteilen",
                   summary: "Starke Schultern tragen mehr.", demand: "",
                   visibleEffects: [GameEffect(metric: .livingStandard, change: 2), GameEffect(metric: .economy, change: -1)],
                   hiddenEffects: [HiddenEffect(metric: .welfareStrength, change: 4)]),
        AgendaItem(id: "goal-europa", title: "Europa stärken",
                   summary: "Enge Zusammenarbeit in der EU.", demand: "",
                   visibleEffects: [GameEffect(metric: .internationalRelations, change: 3)],
                   hiddenEffects: [HiddenEffect(metric: .euRelations, change: 5)]),
        AgendaItem(id: "goal-buergerrechte", title: "Bürgerrechte schützen",
                   summary: "Freiheit, Datenschutz und Teilhabe.", demand: "",
                   visibleEffects: [GameEffect(metric: .trust, change: 3), GameEffect(metric: .society, change: 1)],
                   hiddenEffects: [HiddenEffect(metric: .polarization, change: -3)]),
        AgendaItem(id: "goal-infrastruktur", title: "Infrastruktur erneuern",
                   summary: "Straßen, Schienen und Netze modernisieren.", demand: "",
                   visibleEffects: [GameEffect(metric: .economy, change: 1)],
                   hiddenEffects: [HiddenEffect(metric: .infrastructureQuality, change: 5)])
    ]

    public static func goal(id: String) -> AgendaItem? {
        all.first { $0.id == id }
    }
}

/// Baut aus den Spieler-Entscheidungen (Name, Ideologie, Ziele) eine spielbare
/// eigene Partei. Ideologie prägt das Start-Profil, die gewählten Ziele werden
/// zur Agenda – und wirken schon zum Start als Programm.
public enum CustomPartyFactory {
    public static let partyID = "custom"

    public static func make(name rawName: String, shortName rawShort: String, ideologyID: String, goalIDs: [String]) -> PlayerParty {
        let ideology = IdeologyCatalog.ideology(id: ideologyID)
        let name = normalizedName(rawName)
        let short = normalizedShort(rawShort, fallback: name)
        let goals = goalIDs.compactMap { CustomGoalCatalog.goal(id: $0) }

        // Die Ziele fließen als Gründungsprogramm ins Start-Profil ein.
        let visible = ideology.visibleModifiers + goals.flatMap(\.visibleEffects)
        let hidden = ideology.hiddenModifiers + goals.flatMap(\.hiddenEffects)

        let profile = KanzlerPersona(
            id: partyID,
            title: name,
            tagline: ideology.title,
            icon: ideology.icon,
            visibleModifiers: visible,
            hiddenModifiers: hidden,
            startingCapital: ideology.startingCapital,
            costReduction: ideology.costReduction,
            coalitionLeaning: ideology.leaning,
            coalitionSatisfaction: 60,
            coalitionPartnerName: "der Koalitionspartner"
        )

        return PlayerParty(
            id: partyID,
            name: name,
            fullName: name,
            shortName: short,
            tagline: ideology.title,
            spectrum: ideology.spectrum,
            leaning: ideology.leaning,
            baseSupport: 27,
            profile: profile,
            naturalPartnerIDs: ideology.naturalPartnerIDs,
            agenda: goals,
            isCustom: true
        )
    }

    private static func normalizedName(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Neue Partei" : String(trimmed.prefix(28))
    }

    private static func normalizedShort(_ raw: String, fallback: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if !trimmed.isEmpty { return String(trimmed.prefix(4)) }
        // Kürzel aus dem Namen ableiten (Anfangsbuchstaben der Wörter).
        let initials = fallback.split(separator: " ").compactMap { $0.first }.map(String.init).joined()
        return String((initials.isEmpty ? fallback : initials).prefix(4)).uppercased()
    }
}
