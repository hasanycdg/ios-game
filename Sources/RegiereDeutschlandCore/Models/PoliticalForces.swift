import Foundation

// MARK: - Interessengruppen

public enum InterestGroupID: String, Codable, CaseIterable, Sendable {
    case unions, business, environment, social, security

    public var title: String {
        switch self {
        case .unions: "Gewerkschaften"
        case .business: "Wirtschaftsverbände"
        case .environment: "Umweltverbände"
        case .social: "Sozialverbände"
        case .security: "Sicherheitslobby"
        }
    }

    public var icon: String {
        switch self {
        case .unions: "person.3.fill"
        case .business: "briefcase.fill"
        case .environment: "leaf.fill"
        case .social: "heart.fill"
        case .security: "shield.lefthalf.filled"
        }
    }
}

public struct InterestGroup: Codable, Equatable, Identifiable, Sendable {
    public let id: InterestGroupID
    public var satisfaction: Int
    public let power: Int   // 1–3

    public init(id: InterestGroupID, satisfaction: Int, power: Int) {
        self.id = id
        self.satisfaction = VisibleMetrics.clamped(satisfaction)
        self.power = power
    }

    public var moodLabel: String {
        switch satisfaction {
        case 60...: "kooperativ"
        case 40..<60: "abwartend"
        case 22..<40: "verärgert"
        default: "kampfbereit"
        }
    }
}

public enum InterestGroupsFactory {
    public static func standard() -> [InterestGroup] {
        [
            InterestGroup(id: .unions, satisfaction: 55, power: 3),
            InterestGroup(id: .business, satisfaction: 55, power: 3),
            InterestGroup(id: .environment, satisfaction: 50, power: 2),
            InterestGroup(id: .social, satisfaction: 55, power: 2),
            InterestGroup(id: .security, satisfaction: 55, power: 2)
        ]
    }

    /// Zielzufriedenheit aus Politikfeldern und Lage.
    public static func target(_ id: InterestGroupID, policies: PolicyState, state: GameState) -> Int {
        let v = state.visible
        func lvl(_ p: PolicyID) -> Int { policies.level(p) - 2 }
        let value: Int
        switch id {
        case .unions:
            value = 50 + lvl(.welfare) * 8 + lvl(.taxes) * 3 + (v.livingStandard - 50) / 4
        case .business:
            value = 50 - lvl(.taxes) * 8 - lvl(.welfare) * 4 + (v.economy - 50) / 3
        case .environment:
            value = 50 + lvl(.environment) * 10 + (v.energy - 50) / 5
        case .social:
            value = 50 + lvl(.welfare) * 8 + (v.livingStandard - 50) / 5 + (v.society - 50) / 5
        case .security:
            value = 50 + lvl(.defense) * 8 + (v.security - 50) / 5
        }
        return VisibleMetrics.clamped(value)
    }

    /// Wirkung einer Protest-/Streik-Aktion, wenn eine mächtige Gruppe kippt.
    public static func action(_ id: InterestGroupID) -> (note: String, visible: [GameEffect], hidden: [HiddenEffect], approval: Int) {
        switch id {
        case .unions:
            return ("Die Gewerkschaften rufen zum Generalstreik – die Wirtschaft steht still.",
                    [GameEffect(metric: .economy, change: -6)], [], -6)
        case .business:
            return ("Wirtschaftsverbände drohen mit Standortverlagerung und Investitionsstopp.",
                    [GameEffect(metric: .economy, change: -5), GameEffect(metric: .budget, change: -3)], [], -3)
        case .environment:
            return ("Umweltverbände mobilisieren Großproteste im ganzen Land.",
                    [GameEffect(metric: .society, change: -4)], [HiddenEffect(metric: .polarization, change: 6)], -4)
        case .social:
            return ("Sozialverbände prangern soziale Kälte an – Empörung macht sich breit.",
                    [GameEffect(metric: .society, change: -5), GameEffect(metric: .livingStandard, change: -2)], [], -5)
        case .security:
            return ("Die Sicherheitslobby warnt öffentlich vor einer Gefährdung der Sicherheit.",
                    [GameEffect(metric: .security, change: -4)], [], -3)
        }
    }
}

// MARK: - Partei-Flügel

public struct PartyWings: Codable, Equatable, Sendable {
    public var progressive: Int
    public var traditional: Int
    public var leadershipBacking: Int

    public init(progressive: Int, traditional: Int, leadershipBacking: Int) {
        self.progressive = VisibleMetrics.clamped(progressive)
        self.traditional = VisibleMetrics.clamped(traditional)
        self.leadershipBacking = VisibleMetrics.clamped(leadershipBacking)
    }

    public static func standard() -> PartyWings {
        PartyWings(progressive: 58, traditional: 58, leadershipBacking: 60)
    }

    /// Ab hier stürzt die eigene Partei die Führung.
    public static let ousterPoint = 10

    public var backingLabel: String {
        switch leadershipBacking {
        case 55...: "gefestigt"
        case 35..<55: "wackelig"
        case 20..<35: "brüchig"
        default: "vor dem Sturz"
        }
    }
}

public enum PartyWingsDynamics {
    public static func progressiveTarget(policies: PolicyState) -> Int {
        func lvl(_ p: PolicyID) -> Int { policies.level(p) - 2 }
        return VisibleMetrics.clamped(50 + lvl(.welfare) * 5 + lvl(.environment) * 5 + lvl(.immigration) * 4 - lvl(.defense) * 3)
    }

    public static func traditionalTarget(policies: PolicyState) -> Int {
        func lvl(_ p: PolicyID) -> Int { policies.level(p) - 2 }
        return VisibleMetrics.clamped(50 - lvl(.welfare) * 4 - lvl(.immigration) * 4 + lvl(.defense) * 5 - lvl(.taxes) * 3)
    }
}
