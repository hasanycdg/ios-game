import Foundation

/// Ein dauerhaftes Politikfeld, das der Spieler einstellt und pflegt.
public enum PolicyID: String, Codable, CaseIterable, Sendable {
    case taxes, welfare, defense, education, environment, immigration

    public var title: String {
        switch self {
        case .taxes: "Steuern"
        case .welfare: "Sozialausgaben"
        case .defense: "Verteidigung"
        case .education: "Bildung"
        case .environment: "Umweltschutz"
        case .immigration: "Zuwanderung"
        }
    }

    public var icon: String {
        switch self {
        case .taxes: "percent"
        case .welfare: "heart.fill"
        case .defense: "shield.lefthalf.filled"
        case .education: "graduationcap.fill"
        case .environment: "leaf.fill"
        case .immigration: "figure.walk.arrival"
        }
    }

    /// Steuern bringen Einnahmen, alle anderen Felder kosten.
    public var isRevenue: Bool { self == .taxes }
}

/// Der aktuelle Stand aller Politikfelder (Stufe 0–4 je Feld).
public struct PolicyState: Codable, Equatable, Sendable {
    public var levels: [String: Int]

    public init(levels: [String: Int]) { self.levels = levels }

    public func level(_ policy: PolicyID) -> Int {
        min(PolicyEngine.maxLevel, max(0, levels[policy.rawValue] ?? 2))
    }

    public static func standard() -> PolicyState {
        PolicyState(levels: Dictionary(uniqueKeysWithValues: PolicyID.allCases.map { ($0.rawValue, 2) }))
    }
}

public enum PolicyVoteResult: Equatable, Sendable {
    case passed      // im Parlament angenommen
    case rejected    // durchgefallen
    case noCapital   // nicht genug politisches Kapital
    case unchanged
}

public struct BudgetSummary: Equatable, Sendable {
    public let income: Int
    public let spending: Int
    public let debt: Int
    public var deficit: Int { spending - income }
    public init(income: Int, spending: Int, debt: Int) {
        self.income = income
        self.spending = spending
        self.debt = debt
    }
}

public enum PolicyEngine {
    public static let maxLevel = 4

    public static func label(_ policy: PolicyID, level: Int) -> String {
        let scale: [String]
        switch policy {
        case .taxes: scale = ["sehr niedrig", "niedrig", "mittel", "hoch", "sehr hoch"]
        case .immigration: scale = ["sehr restriktiv", "restriktiv", "moderat", "offen", "sehr offen"]
        default: scale = ["minimal", "niedrig", "mittel", "hoch", "sehr hoch"]
        }
        return scale[min(scale.count - 1, max(0, level))]
    }

    /// Fiskalischer Betrag: Einnahmen (Steuern) bzw. Ausgaben (sonst).
    public static func fiscal(_ policy: PolicyID, level: Int) -> Int {
        if policy.isRevenue {
            return [10, 20, 30, 42, 54][clamp(level)]
        }
        return [0, 3, 6, 10, 15][clamp(level)]
    }

    /// Jährliche (kleine) Wirkung auf sichtbare Werte.
    public static func annualVisible(_ policy: PolicyID, level: Int) -> [GameEffect] {
        let d = level - 2
        switch policy {
        case .taxes:
            return [GameEffect(metric: .economy, change: -d), GameEffect(metric: .livingStandard, change: -(d / 2))]
        case .welfare:
            return [GameEffect(metric: .livingStandard, change: d), GameEffect(metric: .society, change: d / 2)]
        case .defense:
            return [GameEffect(metric: .security, change: d)]
        case .education:
            return [GameEffect(metric: .economy, change: d / 2)]
        case .environment:
            return [GameEffect(metric: .energy, change: d / 2)]
        case .immigration:
            return [GameEffect(metric: .economy, change: d / 2), GameEffect(metric: .society, change: -(d / 2))]
        }
    }

    public static func annualHidden(_ policy: PolicyID, level: Int) -> [HiddenEffect] {
        let d = level - 2
        switch policy {
        case .taxes: return [HiddenEffect(metric: .fiscalSpace, change: d)]
        case .welfare: return [HiddenEffect(metric: .welfareStrength, change: d)]
        case .defense: return [HiddenEffect(metric: .defenceReadiness, change: d)]
        case .education: return [HiddenEffect(metric: .digitalization, change: d)]
        case .environment: return [HiddenEffect(metric: .renewableCapacity, change: d)]
        case .immigration: return [HiddenEffect(metric: .polarization, change: d / 2)]
        }
    }

    /// +1 wenn die Ausrichtung eine höhere Stufe bevorzugt, -1 wenn niedrigere.
    public static func leaningPreference(_ policy: PolicyID, _ leaning: PoliticalLeaning) -> Int {
        switch (policy, leaning) {
        case (.welfare, .left), (.taxes, .left), (.environment, .left),
             (.education, .left), (.education, .liberal), (.immigration, .left), (.immigration, .liberal),
             (.defense, .conservative):
            return 1
        case (.welfare, .liberal), (.welfare, .conservative), (.taxes, .liberal), (.taxes, .conservative),
             (.environment, .liberal), (.environment, .conservative), (.defense, .left), (.immigration, .conservative):
            return -1
        default:
            return 0
        }
    }

    /// Unmittelbare Reaktion von Bevölkerungsgruppen auf eine Änderung.
    public static func groupReaction(_ policy: PolicyID, delta: Int) -> [PopulationApprovalEffect] {
        let s = delta > 0 ? 1 : -1
        switch policy {
        case .taxes:
            return [.init(group: .entrepreneurs, change: -3 * s), .init(group: .workers, change: -1 * s), .init(group: .lowIncomeAndUnemployed, change: 1 * s)]
        case .welfare:
            return [.init(group: .lowIncomeAndUnemployed, change: 3 * s), .init(group: .retirees, change: 2 * s), .init(group: .entrepreneurs, change: -2 * s)]
        case .defense:
            return [.init(group: .publicSector, change: 1 * s), .init(group: .youngAdults, change: -1 * s)]
        case .education:
            return [.init(group: .families, change: 2 * s), .init(group: .youngAdults, change: 2 * s)]
        case .environment:
            return [.init(group: .youngAdults, change: 2 * s), .init(group: .entrepreneurs, change: -2 * s)]
        case .immigration:
            return [.init(group: .entrepreneurs, change: 2 * s), .init(group: .lowIncomeAndUnemployed, change: -1 * s)]
        }
    }

    private static func clamp(_ level: Int) -> Int { min(maxLevel, max(0, level)) }
}
