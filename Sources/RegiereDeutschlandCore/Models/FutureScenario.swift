import Foundation

/// Die drei aufeinander aufbauenden Kapitel des separat gekauften Zukunftspakets.
/// Der Verlauf selbst liegt wie alle Entscheidungen und Folgen im Spielstand.
public enum FutureScenario: String, CaseIterable, Identifiable, Sendable {
    public static let decisionsPerYear = 8
    public static let totalDecisionCount = 25 * decisionsPerYear

    case escalation
    case reconstruction
    case worldOrder

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .escalation: "Der Weg zum dritten Weltkrieg"
        case .reconstruction: "Wiederaufbau und was danach kommt"
        case .worldOrder: "Die neue Weltordnung"
        }
    }

    public var years: ClosedRange<Int> {
        switch self {
        case .escalation: 2026...2034
        case .reconstruction: 2035...2042
        case .worldOrder: 2043...2050
        }
    }

    public var decisionCount: Int { years.count * Self.decisionsPerYear }

    public static func completedDecisions(in state: GameState) -> Int {
        state.decisions.filter { $0.year == state.currentYear && isStoryEvent($0.eventID) }.count
    }

    public var summary: String {
        switch self {
        case .escalation: "Bündnisse, Krisen und Diplomatie: Verhindere den Krieg oder trage die Folgen der Eskalation."
        case .reconstruction: "Gestalte Wiederaufbau, Versorgung und Versöhnung – oder erneuere das Land nach einem verhinderten Krieg."
        case .worldOrder: "Entscheide über internationale Regeln, Machtblöcke und das Vermächtnis deiner Amtszeit."
        }
    }

    public static func chapter(in state: GameState) -> FutureScenario? {
        guard state.historicalFlags.contains("content_future_2050") else { return nil }
        return allCases.first { $0.years.contains(state.currentYear) }
    }

    /// Diese Ereignisse bilden die Handlung und dürfen nicht zufällig entfallen.
    public static func isStoryEvent(_ eventID: String) -> Bool {
        eventID.hasPrefix("future-scenario-")
    }
}
