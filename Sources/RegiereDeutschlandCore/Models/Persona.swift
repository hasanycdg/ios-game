import Foundation

/// Ein Kanzler-Archetyp: verändert Startwerte, politisches Kapital und den
/// Koalitionspartner. Gibt jedem Run einen eigenen Charakter.
public struct KanzlerPersona: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let tagline: String
    public let icon: String
    public let visibleModifiers: [GameEffect]
    public let hiddenModifiers: [HiddenEffect]
    public let startingCapital: Int
    public let capitalIncomeBonus: Int
    public let costReduction: Int
    public let coalitionLeaning: PoliticalLeaning
    public let coalitionSatisfaction: Int
    public let coalitionDamping: Double
    public let coalitionPartnerName: String

    public init(
        id: String,
        title: String,
        tagline: String,
        icon: String,
        visibleModifiers: [GameEffect] = [],
        hiddenModifiers: [HiddenEffect] = [],
        startingCapital: Int,
        capitalIncomeBonus: Int = 0,
        costReduction: Int = 0,
        coalitionLeaning: PoliticalLeaning,
        coalitionSatisfaction: Int,
        coalitionDamping: Double = 1.0,
        coalitionPartnerName: String
    ) {
        self.id = id
        self.title = title
        self.tagline = tagline
        self.icon = icon
        self.visibleModifiers = visibleModifiers
        self.hiddenModifiers = hiddenModifiers
        self.startingCapital = startingCapital
        self.capitalIncomeBonus = capitalIncomeBonus
        self.costReduction = costReduction
        self.coalitionLeaning = coalitionLeaning
        self.coalitionSatisfaction = coalitionSatisfaction
        self.coalitionDamping = coalitionDamping
        self.coalitionPartnerName = coalitionPartnerName
    }

    public func makeCoalition() -> CoalitionState {
        CoalitionState(
            partnerName: coalitionPartnerName,
            leaning: coalitionLeaning,
            satisfaction: coalitionSatisfaction,
            reactionDamping: coalitionDamping
        )
    }
}

public enum PersonaCatalog {
    public static let all: [KanzlerPersona] = [
        KanzlerPersona(
            id: "pragmatiker",
            title: "Der Pragmatiker",
            tagline: "Kein Profil, keine Schwäche – solide von allem. Der leichte Einstieg.",
            icon: "circle.grid.cross.fill",
            startingCapital: 7,
            coalitionLeaning: .liberal,
            coalitionSatisfaction: 66,
            coalitionPartnerName: "Der liberale Partner"
        ),
        KanzlerPersona(
            id: "reformerin",
            title: "Die Reformerin",
            tagline: "Aufbruch und Moderne – aber ihr Kurs polarisiert.",
            icon: "bolt.fill",
            visibleModifiers: [GameEffect(metric: .economy, change: 4), GameEffect(metric: .society, change: -2)],
            hiddenModifiers: [
                HiddenEffect(metric: .digitalization, change: 8),
                HiddenEffect(metric: .renewableCapacity, change: 6),
                HiddenEffect(metric: .polarization, change: 6)
            ],
            startingCapital: 6,
            capitalIncomeBonus: 1,
            coalitionLeaning: .left,
            coalitionSatisfaction: 60,
            coalitionPartnerName: "Der soziale Flügel"
        ),
        KanzlerPersona(
            id: "sparkommissar",
            title: "Der Sparkommissar",
            tagline: "Solide Kasse – jede Entscheidung kostet weniger, doch der Sozialstaat leidet.",
            icon: "banknote.fill",
            visibleModifiers: [GameEffect(metric: .budget, change: 6), GameEffect(metric: .livingStandard, change: -2)],
            hiddenModifiers: [
                HiddenEffect(metric: .fiscalSpace, change: 10),
                HiddenEffect(metric: .welfareStrength, change: -4)
            ],
            startingCapital: 7,
            costReduction: 1,
            coalitionLeaning: .liberal,
            coalitionSatisfaction: 64,
            coalitionPartnerName: "Der liberale Partner"
        ),
        KanzlerPersona(
            id: "brueckenbauerin",
            title: "Die Brückenbauerin",
            tagline: "Ausgleich und Vertrauen – ihre Koalition hält auch Stürme aus.",
            icon: "hand.raised.fill",
            visibleModifiers: [GameEffect(metric: .society, change: 3), GameEffect(metric: .trust, change: 4)],
            hiddenModifiers: [HiddenEffect(metric: .euRelations, change: 6)],
            startingCapital: 6,
            coalitionLeaning: .liberal,
            coalitionSatisfaction: 78,
            coalitionDamping: 0.5,
            coalitionPartnerName: "Der verlässliche Partner"
        )
    ]

    public static var `default`: KanzlerPersona { all[0] }

    public static func persona(id: String) -> KanzlerPersona {
        all.first { $0.id == id } ?? `default`
    }
}
