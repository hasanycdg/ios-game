import Foundation

/// Momentaufnahme der sichtbaren Lage am Ende eines Spieljahres.
/// Wird von der Engine geführt und im Snapshot mitgespeichert – der
/// eigentliche `GameState` bleibt davon unberührt.
public struct AnnualRecord: Codable, Equatable, Identifiable, Sendable {
    public var id: Int { year }
    public let year: Int
    public let visible: VisibleMetrics
    public let approval: Int

    public init(year: Int, visible: VisibleMetrics, approval: Int) {
        self.year = year
        self.visible = visible
        self.approval = approval
    }

    /// Durchschnitt der acht sichtbaren Werte für dieses Jahr.
    public var governanceIndex: Int {
        let sum = visible.economy + visible.budget + visible.livingStandard + visible.society
            + visible.security + visible.energy + visible.internationalRelations + visible.trust
        return Int((Double(sum) / 8.0).rounded())
    }
}
