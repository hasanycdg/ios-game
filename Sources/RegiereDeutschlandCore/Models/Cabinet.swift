import Foundation

/// Ein Ressort im Kabinett.
public enum Ministry: String, Codable, CaseIterable, Sendable {
    case economy, budget, security, foreign, social, energy

    public var title: String {
        switch self {
        case .economy: "Wirtschaft"
        case .budget: "Finanzen"
        case .security: "Inneres"
        case .foreign: "Äußeres"
        case .social: "Soziales"
        case .energy: "Energie"
        }
    }

    public var icon: String {
        switch self {
        case .economy: "chart.line.uptrend.xyaxis"
        case .budget: "banknote"
        case .security: "shield.lefthalf.filled"
        case .foreign: "globe.europe.africa.fill"
        case .social: "heart.fill"
        case .energy: "bolt.fill"
        }
    }

    public func departmentTitle(in country: GameCountry, year: Int = 2000) -> String {
        guard country == .unitedStates else { return "Ministerium für \(title)" }
        switch self {
        case .economy: return "Department of Commerce"
        case .budget: return "Department of the Treasury"
        case .security: return year >= 2003 ? "Department of Homeland Security" : "Department of Justice"
        case .foreign: return "Department of State"
        case .social: return "Department of Health and Human Services"
        case .energy: return "Department of Energy"
        }
    }

    /// Der Kennwert, auf den ein starkes/schwaches Ressort einzahlt.
    public var metric: VisibleMetric {
        switch self {
        case .economy: .economy
        case .budget: .budget
        case .security: .security
        case .foreign: .internationalRelations
        case .social: .livingStandard
        case .energy: .energy
        }
    }
}

public struct Minister: Codable, Equatable, Sendable {
    public let name: String
    public let competence: Int   // 0–100

    public init(name: String, competence: Int) {
        self.name = name
        self.competence = VisibleMetrics.clamped(competence)
    }

    public var ratingLabel: String {
        switch competence {
        case 75...: "hochkompetent"
        case 60..<75: "solide"
        case 45..<60: "durchwachsen"
        default: "überfordert"
        }
    }
}

/// Das Kabinett – ein Minister je Ressort.
public struct Cabinet: Codable, Equatable, Sendable {
    public var ministers: [String: Minister]

    public init(ministers: [String: Minister]) {
        self.ministers = ministers
    }

    public func minister(_ ministry: Ministry) -> Minister {
        ministers[ministry.rawValue] ?? Minister(name: "N. N.", competence: 50)
    }

    public static func standard(country: GameCountry = .germany) -> Cabinet {
        var ministers: [String: Minister] = [:]
        for (index, ministry) in Ministry.allCases.enumerated() {
            ministers[ministry.rawValue] = MinisterPool.make(seed: 100 + index * 7, country: country)
        }
        return Cabinet(ministers: ministers)
    }
}

public enum MinisterPool {
    static let names = [
        "Dr. Weber", "Frau Schneider", "Herr Fischer", "Dr. Wagner", "Frau Becker",
        "Herr Hoffmann", "Dr. Schäfer", "Frau Koch", "Herr Bauer", "Dr. Richter",
        "Frau Klein", "Herr Wolf", "Dr. Neumann", "Frau Braun", "Herr Krüger", "Dr. Hartmann"
    ]

    public static func make(seed: Int, country: GameCountry = .germany) -> Minister {
        let pool = country == .germany ? names : ["Jordan Williams", "Dr. Taylor Brooks", "Casey Johnson", "Dr. Avery Davis", "Morgan Reed", "Jamie Thompson", "Dr. Riley Chen", "Sam Rodriguez", "Alex Carter", "Dr. Cameron Patel", "Drew Jackson", "Quinn Mitchell", "Dr. Reese Anderson", "Parker Lewis", "Dakota Wilson", "Dr. Sidney Clark"]
        let name = pool[abs(seed) % pool.count]
        let competence = 45 + (abs(seed &* 31 &+ 7) % 41)
        return Minister(name: name, competence: competence)
    }
}
