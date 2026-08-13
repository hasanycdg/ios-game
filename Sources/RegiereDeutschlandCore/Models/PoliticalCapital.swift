import Foundation

/// Leitet die Kosten einer Entscheidung an politischem Kapital ab –
/// größere Eingriffe kosten mehr. Bewusst 1–4 "Kapital-Chips".
public enum DecisionCost {
    public static let maximum = 4

    public static func cost(of option: DecisionOption) -> Int {
        let visibleMagnitude = option.immediateEffects.reduce(0) { $0 + abs($1.change) }
        let approvalMagnitude = abs(option.approvalEffect)
        let magnitude = visibleMagnitude + approvalMagnitude / 2
        let scaled = Int((Double(magnitude) / 9.0).rounded())
        return min(maximum, max(1, scaled))
    }
}
