import Foundation

public enum CampaignAlignment: String, Sendable {
    case strong   // starkes Thema
    case solid
    case risky    // riskant
}

/// Ein Wahlkampf-Schwerpunkt. Passt er zu einer Stärke der Regierung, bringt er
/// Stimmen – passt er zu einer Schwäche, kostet er welche.
public struct CampaignFocus: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let icon: String
    public let primary: VisibleMetric

    public init(id: String, title: String, detail: String, icon: String, primary: VisibleMetric) {
        self.id = id
        self.title = title
        self.detail = detail
        self.icon = icon
        self.primary = primary
    }

    /// Bonus (in Prozentpunkten) auf das eigene Ergebnis: bis +5, bis -2.
    public func bonus(for state: GameState) -> Double {
        let value = state.visible.value(for: primary)
        return min(5.0, max(-2.0, Double(value - 50) * 0.14))
    }

    public func alignment(for state: GameState) -> CampaignAlignment {
        switch state.visible.value(for: primary) {
        case 60...: return .strong
        case 45..<60: return .solid
        default: return .risky
        }
    }
}

public enum CampaignFocusCatalog {
    public static let all: [CampaignFocus] = [
        CampaignFocus(id: "economy", title: "Wirtschaftskompetenz",
                      detail: "Arbeitsplätze, Wachstum, Aufschwung.",
                      icon: "chart.line.uptrend.xyaxis", primary: .economy),
        CampaignFocus(id: "welfare", title: "Soziale Sicherheit",
                      detail: "Kaufkraft, Gerechtigkeit, Zusammenhalt.",
                      icon: "heart.fill", primary: .livingStandard),
        CampaignFocus(id: "security", title: "Sicherheit & Ordnung",
                      detail: "Innere und äußere Sicherheit.",
                      icon: "shield.lefthalf.filled", primary: .security),
        CampaignFocus(id: "trust", title: "Vertrauen & Erneuerung",
                      detail: "Glaubwürdigkeit und ein frischer Kurs.",
                      icon: "hand.raised.fill", primary: .trust)
    ]
}
