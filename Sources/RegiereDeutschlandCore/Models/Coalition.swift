import Foundation

/// Politische Ausrichtung des Koalitionspartners – bestimmt, worauf er
/// empfindlich reagiert.
public enum PoliticalLeaning: String, Codable, Sendable, CaseIterable {
    case left        // sozial-ökologisch
    case liberal     // wirtschaftsliberal
    case conservative // sicherheits- und wirtschaftskonservativ

    public var displayName: String {
        switch self {
        case .left: "sozial-ökologisch"
        case .liberal: "wirtschaftsliberal"
        case .conservative: "konservativ"
        }
    }
}

/// Zustand des Koalitionspartners. Sinkt die Zufriedenheit zu tief,
/// platzt die Koalition und es kommt zur Neuwahl.
public struct CoalitionState: Codable, Equatable, Sendable {
    public var partnerName: String
    public var leaning: PoliticalLeaning
    public var satisfaction: Int      // 0–100
    public var reactionDamping: Double // 1.0 = normal, <1 = gelassener Partner
    public var isMinority: Bool

    /// Unterhalb dieses Wertes bricht die Koalition.
    public static let breakingPoint = 8

    public init(partnerName: String, leaning: PoliticalLeaning, satisfaction: Int, reactionDamping: Double = 1.0, isMinority: Bool = false) {
        self.partnerName = partnerName
        self.leaning = leaning
        self.satisfaction = VisibleMetrics.clamped(satisfaction)
        self.reactionDamping = reactionDamping
        self.isMinority = isMinority
    }

    private enum CodingKeys: String, CodingKey {
        case partnerName, leaning, satisfaction, reactionDamping, isMinority
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        partnerName = try container.decode(String.self, forKey: .partnerName)
        leaning = try container.decode(PoliticalLeaning.self, forKey: .leaning)
        satisfaction = try container.decode(Int.self, forKey: .satisfaction)
        reactionDamping = try container.decodeIfPresent(Double.self, forKey: .reactionDamping) ?? 1.0
        isMinority = try container.decodeIfPresent(Bool.self, forKey: .isMinority) ?? false
    }

    public static func standard() -> CoalitionState {
        CoalitionState(partnerName: "Der Juniorpartner", leaning: .liberal, satisfaction: 62)
    }

    public var isBroken: Bool { satisfaction <= Self.breakingPoint }

    public var moodLabel: String {
        switch satisfaction {
        case 70...: return "loyal"
        case 50..<70: return "zufrieden"
        case 30..<50: return "unruhig"
        case (Self.breakingPoint + 1)..<30: return "aufbegehrend"
        default: return "vor dem Bruch"
        }
    }
}

/// Berechnet, wie der Koalitionspartner auf eine Entscheidung reagiert.
public enum CoalitionDynamics {
    /// Reaktion (Delta der Zufriedenheit) auf eine gewählte Option.
    public static func reaction(to option: DecisionOption, leaning: PoliticalLeaning, damping: Double) -> Int {
        var score = 0.0
        for effect in option.immediateEffects {
            score += Double(effect.change) * visibleWeight(effect.metric, leaning)
        }
        for effect in option.hiddenEffects {
            score += Double(effect.change) * hiddenWeight(effect.metric, leaning)
        }
        let raw = (score * 0.16 * damping)
        return min(6, max(-6, Int(raw.rounded())))
    }

    private static func visibleWeight(_ metric: VisibleMetric, _ leaning: PoliticalLeaning) -> Double {
        switch leaning {
        case .left:
            switch metric {
            case .livingStandard: 1.0
            case .society: 1.0
            case .trust: 0.5
            case .economy: 0.3
            case .security: -0.5
            case .budget: -0.3
            default: 0
            }
        case .liberal:
            switch metric {
            case .economy: 1.0
            case .budget: 0.8
            case .trust: 0.3
            case .society: -0.2
            default: 0
            }
        case .conservative:
            switch metric {
            case .security: 1.0
            case .economy: 0.6
            case .budget: 0.5
            case .society: -0.2
            default: 0
            }
        }
    }

    private static func hiddenWeight(_ metric: HiddenMetric, _ leaning: PoliticalLeaning) -> Double {
        switch leaning {
        case .left:
            switch metric {
            case .welfareStrength: 1.0
            case .renewableCapacity: 0.7
            case .nuclearCapacity: -0.7
            case .labourMarketFlexibility: -0.6
            case .defenceReadiness: -0.4
            default: 0
            }
        case .liberal:
            switch metric {
            case .labourMarketFlexibility: 1.0
            case .fiscalSpace: 0.8
            case .digitalization: 0.6
            case .welfareStrength: -0.4
            case .russianEnergyDependency: -0.3
            default: 0
            }
        case .conservative:
            switch metric {
            case .defenceReadiness: 1.0
            case .nuclearCapacity: 0.5
            case .infrastructureQuality: 0.3
            case .polarization: -0.4
            case .welfareStrength: -0.3
            default: 0
            }
        }
    }
}
