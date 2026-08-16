import Foundation

public enum DiplomaticPartner: String, Codable, CaseIterable, Sendable {
    case eu, usa, russia, china

    public var title: String {
        switch self {
        case .eu: "Europäische Union"
        case .usa: "USA"
        case .russia: "Russland"
        case .china: "China"
        }
    }

    public var icon: String {
        switch self {
        case .eu: "eurosign.circle.fill"
        case .usa: "flag.fill"
        case .russia: "snowflake"
        case .china: "yensign.circle.fill"
        }
    }
}

/// Aktive Beziehungen zu den wichtigsten außenpolitischen Partnern (0–100).
public struct DiplomaticState: Codable, Equatable, Sendable {
    public var relations: [String: Int]

    public init(relations: [String: Int]) { self.relations = relations }

    public func relation(_ partner: DiplomaticPartner) -> Int {
        min(100, max(0, relations[partner.rawValue] ?? 50))
    }

    public static func standard(from hidden: HiddenMetrics) -> DiplomaticState {
        DiplomaticState(relations: [
            DiplomaticPartner.eu.rawValue: hidden.euRelations,
            DiplomaticPartner.usa.rawValue: hidden.usRelations,
            DiplomaticPartner.russia.rawValue: hidden.russiaRelations,
            DiplomaticPartner.china.rawValue: 55
        ])
    }

    public static func label(for relation: Int) -> String {
        switch relation {
        case 72...: "eng verbündet"
        case 56..<72: "freundschaftlich"
        case 42..<56: "kühl"
        case 26..<42: "angespannt"
        default: "feindselig"
        }
    }
}

public struct DiplomaticAction: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let cost: Int
    public let relationDelta: Int
    public let visible: [GameEffect]
    public let hidden: [HiddenEffect]

    public init(id: String, title: String, detail: String, cost: Int, relationDelta: Int,
                visible: [GameEffect] = [], hidden: [HiddenEffect] = []) {
        self.id = id
        self.title = title
        self.detail = detail
        self.cost = cost
        self.relationDelta = relationDelta
        self.visible = visible
        self.hidden = hidden
    }
}

public enum DiplomaticActionCatalog {
    public static func actions(for partner: DiplomaticPartner) -> [DiplomaticAction] {
        switch partner {
        case .eu:
            return [
                DiplomaticAction(id: "eu-summit", title: "EU-Gipfel", detail: "Enger Schulterschluss in Brüssel.",
                                 cost: 2, relationDelta: 8,
                                 visible: [GameEffect(metric: .internationalRelations, change: 2)],
                                 hidden: [HiddenEffect(metric: .euRelations, change: 4)]),
                DiplomaticAction(id: "eu-integration", title: "Integration vertiefen", detail: "Mehr Europa – nicht allen gefällt das.",
                                 cost: 3, relationDelta: 10,
                                 visible: [GameEffect(metric: .internationalRelations, change: 2), GameEffect(metric: .society, change: -1)],
                                 hidden: [HiddenEffect(metric: .euRelations, change: 6), HiddenEffect(metric: .polarization, change: 3)])
            ]
        case .usa:
            return [
                DiplomaticAction(id: "us-visit", title: "Staatsbesuch in Washington", detail: "Transatlantische Nähe demonstrieren.",
                                 cost: 2, relationDelta: 8,
                                 visible: [GameEffect(metric: .security, change: 2), GameEffect(metric: .internationalRelations, change: 1)],
                                 hidden: [HiddenEffect(metric: .usRelations, change: 4)]),
                DiplomaticAction(id: "us-trade", title: "Handelsabkommen", detail: "Zugang zum US-Markt sichern.",
                                 cost: 2, relationDelta: 6,
                                 visible: [GameEffect(metric: .economy, change: 3)],
                                 hidden: [HiddenEffect(metric: .usRelations, change: 3)])
            ]
        case .russia:
            return [
                DiplomaticAction(id: "ru-energy", title: "Energiepartnerschaft ausbauen", detail: "Billiges Gas – aber wachsende Abhängigkeit.",
                                 cost: 2, relationDelta: 8,
                                 visible: [GameEffect(metric: .energy, change: 3)],
                                 hidden: [HiddenEffect(metric: .russiaRelations, change: 5), HiddenEffect(metric: .russianEnergyDependency, change: 8)]),
                DiplomaticAction(id: "ru-sanctions", title: "Sanktionen verhängen", detail: "Klare Kante – zum Preis der Wirtschaft.",
                                 cost: 2, relationDelta: -12,
                                 visible: [GameEffect(metric: .security, change: 2), GameEffect(metric: .economy, change: -3)],
                                 hidden: [HiddenEffect(metric: .russiaRelations, change: -8), HiddenEffect(metric: .euRelations, change: 3), HiddenEffect(metric: .usRelations, change: 3)])
            ]
        case .china:
            return [
                DiplomaticAction(id: "cn-trade", title: "Handelsoffensive", detail: "Riesiger Absatzmarkt, heikle Abhängigkeit.",
                                 cost: 2, relationDelta: 8,
                                 visible: [GameEffect(metric: .economy, change: 3), GameEffect(metric: .budget, change: 2)]),
                DiplomaticAction(id: "cn-humanrights", title: "Menschenrechte ansprechen", detail: "Haltung zeigen – Peking reagiert verstimmt.",
                                 cost: 1, relationDelta: -8,
                                 visible: [GameEffect(metric: .society, change: 2), GameEffect(metric: .trust, change: 2), GameEffect(metric: .economy, change: -2)])
            ]
        }
    }
}
