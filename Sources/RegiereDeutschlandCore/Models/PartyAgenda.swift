import Foundation

/// Ein Vorhaben, das eine Partei durchsetzen will. Wird in Koalitionsgesprächen
/// zur Forderung: Erfüllt der Kanzler sie, ist der Partner zufriedener – aber
/// die Zusage kostet oft an anderer Stelle.
public struct AgendaItem: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String        // "Atomausstieg beschleunigen"
    public let summary: String      // kurz, was die Partei will
    public let demand: String       // wie die Partei es im Gespräch fordert
    public let visibleEffects: [GameEffect]   // Zugeständnis, falls gewährt
    public let hiddenEffects: [HiddenEffect]
    public let satisfactionReward: Int        // Zufriedenheit des Partners, falls gewährt

    public init(
        id: String,
        title: String,
        summary: String,
        demand: String,
        visibleEffects: [GameEffect] = [],
        hiddenEffects: [HiddenEffect] = [],
        satisfactionReward: Int = 10
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.demand = demand
        self.visibleEffects = visibleEffects
        self.hiddenEffects = hiddenEffects
        self.satisfactionReward = satisfactionReward
    }
}

/// Die Agenda (Vorhaben) jeder Partei. Nach Priorität sortiert – die ersten
/// Punkte werden in Koalitionsgesprächen zu Forderungen.
public enum PartyAgendaCatalog {

    public static func agenda(for partyID: String) -> [AgendaItem] {
        switch partyID {
        case "spd":     return spd
        case "cdu":     return cdu
        case "gruene":  return gruene
        case "fdp":     return fdp
        case "linke":   return linke
        default:        return []
        }
    }

    /// Die stärksten Forderungen einer Partei für Koalitionsverhandlungen.
    public static func topDemands(for partyID: String, count: Int = 2) -> [AgendaItem] {
        Array(agenda(for: partyID).prefix(count))
    }

    // MARK: SPD

    private static let spd: [AgendaItem] = [
        AgendaItem(
            id: "spd-sozialstaat",
            title: "Sozialstaat stärken",
            summary: "Höhere Sozialleistungen und mehr Absicherung.",
            demand: "Wir bestehen auf einem starken Sozialstaat – höhere Leistungen für die Menschen.",
            visibleEffects: [GameEffect(metric: .livingStandard, change: 3), GameEffect(metric: .budget, change: -3)],
            hiddenEffects: [HiddenEffect(metric: .welfareStrength, change: 5)],
            satisfactionReward: 12
        ),
        AgendaItem(
            id: "spd-loehne",
            title: "Löhne und Arbeitnehmerrechte",
            summary: "Bessere Löhne, mehr Schutz für Beschäftigte.",
            demand: "Faire Löhne und starke Arbeitnehmerrechte sind für uns nicht verhandelbar.",
            visibleEffects: [GameEffect(metric: .society, change: 2)],
            hiddenEffects: [HiddenEffect(metric: .labourMarketFlexibility, change: -4), HiddenEffect(metric: .welfareStrength, change: 2)],
            satisfactionReward: 10
        ),
        AgendaItem(
            id: "spd-bildung",
            title: "In Bildung investieren",
            summary: "Mehr Geld für Schulen und Chancengleichheit.",
            demand: "Wir wollen kräftig in Bildung investieren – für gleiche Chancen.",
            visibleEffects: [GameEffect(metric: .society, change: 2), GameEffect(metric: .budget, change: -2)],
            hiddenEffects: [HiddenEffect(metric: .digitalization, change: 2)],
            satisfactionReward: 8
        )
    ]

    // MARK: CDU/CSU

    private static let cdu: [AgendaItem] = [
        AgendaItem(
            id: "cdu-steuern",
            title: "Steuern und Abgaben senken",
            summary: "Entlastung für Wirtschaft und Mittelstand.",
            demand: "Wir erwarten spürbare Entlastungen – niedrigere Steuern für Wirtschaft und Bürger.",
            visibleEffects: [GameEffect(metric: .economy, change: 3), GameEffect(metric: .budget, change: -2)],
            hiddenEffects: [HiddenEffect(metric: .fiscalSpace, change: -3), HiddenEffect(metric: .labourMarketFlexibility, change: 3)],
            satisfactionReward: 12
        ),
        AgendaItem(
            id: "cdu-sicherheit",
            title: "Innere Sicherheit stärken",
            summary: "Mehr Befugnisse und Personal für die Sicherheit.",
            demand: "Innere Sicherheit hat für uns oberste Priorität – dafür braucht es mehr Mittel.",
            visibleEffects: [GameEffect(metric: .security, change: 4), GameEffect(metric: .budget, change: -2)],
            hiddenEffects: [HiddenEffect(metric: .defenceReadiness, change: 3), HiddenEffect(metric: .polarization, change: 2)],
            satisfactionReward: 10
        ),
        AgendaItem(
            id: "cdu-wirtschaft",
            title: "Wirtschaft entfesseln",
            summary: "Weniger Bürokratie, mehr Wettbewerb.",
            demand: "Die Wirtschaft muss atmen können – weg mit überflüssiger Bürokratie.",
            visibleEffects: [GameEffect(metric: .economy, change: 3)],
            hiddenEffects: [HiddenEffect(metric: .labourMarketFlexibility, change: 4), HiddenEffect(metric: .welfareStrength, change: -2)],
            satisfactionReward: 9
        )
    ]

    // MARK: Grüne

    private static let gruene: [AgendaItem] = [
        AgendaItem(
            id: "gruene-erneuerbare",
            title: "Erneuerbare massiv ausbauen",
            summary: "Schneller Umstieg auf Wind und Sonne.",
            demand: "Ohne einen klaren Ausbaupfad für Erneuerbare gibt es keine Koalition mit uns.",
            visibleEffects: [GameEffect(metric: .energy, change: 2), GameEffect(metric: .budget, change: -2)],
            hiddenEffects: [HiddenEffect(metric: .renewableCapacity, change: 6), HiddenEffect(metric: .russianEnergyDependency, change: -2)],
            satisfactionReward: 13
        ),
        AgendaItem(
            id: "gruene-atomausstieg",
            title: "Atomausstieg beschleunigen",
            summary: "Kernkraftwerke früher abschalten.",
            demand: "Wir wollen einen verbindlichen, schnellen Atomausstieg.",
            visibleEffects: [GameEffect(metric: .energy, change: -1)],
            hiddenEffects: [HiddenEffect(metric: .nuclearCapacity, change: -6), HiddenEffect(metric: .renewableCapacity, change: 2)],
            satisfactionReward: 11
        ),
        AgendaItem(
            id: "gruene-klima",
            title: "Klima- und Umweltschutz",
            summary: "Strengere Klimaziele und Umweltauflagen.",
            demand: "Ehrgeiziger Klimaschutz muss im Koalitionsvertrag verankert sein.",
            visibleEffects: [GameEffect(metric: .society, change: 2), GameEffect(metric: .economy, change: -2)],
            hiddenEffects: [HiddenEffect(metric: .polarization, change: 2)],
            satisfactionReward: 9
        )
    ]

    // MARK: FDP

    private static let fdp: [AgendaItem] = [
        AgendaItem(
            id: "fdp-haushalt",
            title: "Haushalt konsolidieren",
            summary: "Schulden abbauen, solide Finanzen.",
            demand: "Solide Finanzen sind unsere Bedingung – keine neuen Schuldenberge.",
            visibleEffects: [GameEffect(metric: .budget, change: 3), GameEffect(metric: .livingStandard, change: -2)],
            hiddenEffects: [HiddenEffect(metric: .fiscalSpace, change: 5), HiddenEffect(metric: .welfareStrength, change: -3)],
            satisfactionReward: 12
        ),
        AgendaItem(
            id: "fdp-arbeitsmarkt",
            title: "Arbeitsmarkt flexibilisieren",
            summary: "Weniger Regeln, mehr Eigenverantwortung.",
            demand: "Ein flexiblerer Arbeitsmarkt ist für uns zentral.",
            visibleEffects: [GameEffect(metric: .economy, change: 3)],
            hiddenEffects: [HiddenEffect(metric: .labourMarketFlexibility, change: 6), HiddenEffect(metric: .welfareStrength, change: -3)],
            satisfactionReward: 10
        ),
        AgendaItem(
            id: "fdp-digital",
            title: "Digitalisierung vorantreiben",
            summary: "Schnelles Netz und digitale Verwaltung.",
            demand: "Wir wollen einen echten Digitalisierungsschub für Staat und Wirtschaft.",
            visibleEffects: [GameEffect(metric: .economy, change: 2), GameEffect(metric: .budget, change: -2)],
            hiddenEffects: [HiddenEffect(metric: .digitalization, change: 6)],
            satisfactionReward: 9
        )
    ]

    // MARK: Linke

    private static let linke: [AgendaItem] = [
        AgendaItem(
            id: "linke-umverteilung",
            title: "Reichtum umverteilen",
            summary: "Höhere Steuern für Reiche, mehr für Arme.",
            demand: "Wir fordern echte Umverteilung – die Starken müssen mehr tragen.",
            visibleEffects: [GameEffect(metric: .livingStandard, change: 3), GameEffect(metric: .economy, change: -2)],
            hiddenEffects: [HiddenEffect(metric: .welfareStrength, change: 6), HiddenEffect(metric: .fiscalSpace, change: 2)],
            satisfactionReward: 12
        ),
        AgendaItem(
            id: "linke-abruestung",
            title: "Abrüstung und Frieden",
            summary: "Weniger Militärausgaben, mehr Diplomatie.",
            demand: "Weniger Geld fürs Militär, mehr für die Menschen – das ist unsere Bedingung.",
            visibleEffects: [GameEffect(metric: .budget, change: 2)],
            hiddenEffects: [HiddenEffect(metric: .defenceReadiness, change: -5)],
            satisfactionReward: 9
        )
    ]
}
