import Foundation

/// Schwierigkeitsgrad. Beeinflusst politisches Kapital und die Wahlmarge.
public enum Difficulty: String, Codable, CaseIterable, Sendable {
    case leicht
    case normal
    case schwer

    public var title: String {
        switch self {
        case .leicht: "Leicht"
        case .normal: "Normal"
        case .schwer: "Schwer"
        }
    }

    public var subtitle: String {
        switch self {
        case .leicht: "Mehr Kapital, gnädigere Wahlen – zum Reinkommen."
        case .normal: "Ausgewogen. Die Standard-Erfahrung."
        case .schwer: "Weniger Kapital, härtere Wahlen. Für Profis."
        }
    }

    public var icon: String {
        switch self {
        case .leicht: "leaf.fill"
        case .normal: "flag.fill"
        case .schwer: "flame.fill"
        }
    }

    /// Extra politisches Kapital zu Spielbeginn.
    public var startingCapitalBonus: Int {
        switch self {
        case .leicht: 2
        case .normal: 0
        case .schwer: -1
        }
    }

    /// Extra politisches Kapital pro Jahr.
    public var capitalIncomeBonus: Int {
        switch self {
        case .leicht: 1
        case .normal: 0
        case .schwer: -1
        }
    }

    /// Zu-/Abschlag auf den eigenen Stimmenanteil bei Wahlen und in der Prognose.
    public var electionShareBonus: Double {
        switch self {
        case .leicht: 4
        case .normal: 0
        case .schwer: -4
        }
    }
}
