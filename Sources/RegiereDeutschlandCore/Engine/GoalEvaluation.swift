import Foundation

/// Erfüllungsgrad eines Partei-Ziels, gemessen an der treibenden Kennzahl.
public enum GoalStatus: String, Codable, Sendable {
    case fulfilled   // erfüllt
    case partial     // teilweise
    case missed      // verfehlt

    public var label: String {
        switch self {
        case .fulfilled: "erfüllt"
        case .partial:   "teilweise"
        case .missed:    "verfehlt"
        }
    }
}

public struct GoalProgress: Identifiable, Sendable {
    public let goal: AgendaItem
    public let percent: Int          // 0–100
    public let status: GoalStatus
    public let metricLabel: String   // treibende Kennzahl (für die Anzeige)
    public let metricValue: Int

    public var id: String { goal.id }

    public init(goal: AgendaItem, percent: Int, status: GoalStatus, metricLabel: String, metricValue: Int) {
        self.goal = goal
        self.percent = percent
        self.status = status
        self.metricLabel = metricLabel
        self.metricValue = metricValue
    }
}

/// Bewertet, wie weit eine Partei ihr Programm (ihre Agenda) umgesetzt hat.
/// Jedes Ziel wird an seiner stärksten Kennzahl gemessen: Will das Ziel den
/// Wert heben, zählt der Endstand direkt; will es ihn senken, der Gegenwert.
public enum GoalEvaluator {

    public static func evaluate(agenda: [AgendaItem], state: GameState) -> [GoalProgress] {
        agenda.map { progress(for: $0, state: state) }
    }

    /// Anzahl der vollständig erreichten Ziele.
    public static func fulfilledCount(_ progress: [GoalProgress]) -> Int {
        progress.filter { $0.status == .fulfilled }.count
    }

    private static func progress(for goal: AgendaItem, state: GameState) -> GoalProgress {
        // Treibende Kennzahl = größter Effekt (Betrag), positive bevorzugt.
        var best: (label: String, value: Int, positive: Bool, magnitude: Int)?

        func consider(_ label: String, _ value: Int, _ change: Int) {
            let mag = abs(change)
            if best == nil || mag > best!.magnitude || (mag == best!.magnitude && change > 0 && !best!.positive) {
                best = (label, value, change > 0, mag)
            }
        }

        for e in goal.visibleEffects {
            consider(Self.label(for: e.metric), state.visible.value(for: e.metric), e.change)
        }
        for e in goal.hiddenEffects {
            consider(Self.label(for: e.metric), state.hidden.value(for: e.metric), e.change)
        }

        guard let b = best else {
            return GoalProgress(goal: goal, percent: 50, status: .partial, metricLabel: "—", metricValue: 50)
        }

        // Will das Ziel den Wert senken, ist der Erfolg der Gegenwert.
        let score = b.positive ? b.value : (100 - b.value)
        let status: GoalStatus = score >= 60 ? .fulfilled : (score >= 45 ? .partial : .missed)
        return GoalProgress(goal: goal, percent: score, status: status, metricLabel: b.label, metricValue: b.value)
    }

    // MARK: Kennzahl-Bezeichnungen

    static func label(for metric: VisibleMetric) -> String {
        switch metric {
        case .economy: "Wirtschaft"
        case .budget: "Haushalt"
        case .livingStandard: "Lebensstandard"
        case .society: "Gesellschaft"
        case .security: "Sicherheit"
        case .energy: "Energie"
        case .internationalRelations: "International"
        case .trust: "Vertrauen"
        }
    }

    static func label(for metric: HiddenMetric) -> String {
        switch metric {
        case .renewableCapacity: "Erneuerbare"
        case .nuclearCapacity: "Kernkraft"
        case .russianEnergyDependency: "Energie-Abhängigkeit"
        case .defenceReadiness: "Verteidigung"
        case .digitalization: "Digitalisierung"
        case .infrastructureQuality: "Infrastruktur"
        case .integrationCapacity: "Integration"
        case .labourMarketFlexibility: "Arbeitsmarkt"
        case .welfareStrength: "Sozialstaat"
        case .healthcareResilience: "Gesundheit"
        case .euRelations: "EU-Beziehungen"
        case .usRelations: "US-Beziehungen"
        case .russiaRelations: "Russland-Beziehungen"
        case .polarization: "Spaltung"
        case .fiscalSpace: "Finanzspielraum"
        }
    }
}
