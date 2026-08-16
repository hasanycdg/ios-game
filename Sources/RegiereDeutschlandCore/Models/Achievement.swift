import Foundation

/// Ein freischaltbarer Erfolg. Wird am Spielende ausgewertet.
public struct Achievement: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let icon: String

    public init(id: String, title: String, detail: String, icon: String) {
        self.id = id
        self.title = title
        self.detail = detail
        self.icon = icon
    }
}

public enum AchievementCatalog {
    public static let all: [Achievement] = [
        Achievement(id: "reach-2026", title: "Staatsmann", detail: "Erreiche das Jahr 2026.", icon: "flag.checkered"),
        Achievement(id: "score-800", title: "Hohe Kunst", detail: "Beende ein Spiel mit mindestens 800 Punkten.", icon: "star.fill"),
        Achievement(id: "score-1200", title: "Legende", detail: "Beende ein Spiel mit mindestens 1200 Punkten.", icon: "crown.fill"),
        Achievement(id: "elections-3", title: "Dauerregent", detail: "Gewinne mindestens drei Wahlen in einem Run.", icon: "checkmark.seal.fill"),
        Achievement(id: "elections-5", title: "Ewiger Kanzler", detail: "Gewinne fünf Wahlen in einem Run.", icon: "rosette"),
        Achievement(id: "modernizer", title: "Vordenker", detail: "Regiere als Modernisierer mit europäischem Kurs.", icon: "bolt.fill"),
        Achievement(id: "stability", title: "Stabilitätsanker", detail: "Regiere im Stabilitätskurs bis zum Ende.", icon: "shield.lefthalf.filled"),
        Achievement(id: "landslide", title: "Erdrutschsieg", detail: "Erreiche einen Regierungsindex von 75 oder mehr.", icon: "chart.line.uptrend.xyaxis")
    ]

    public static func achievement(id: String) -> Achievement? {
        all.first { $0.id == id }
    }

    /// Ermittelt die durch dieses Spielende erfüllten Erfolgs-IDs.
    public static func satisfiedIDs(summary: GameOverSummary) -> [String] {
        var ids: [String] = []
        if summary.reason == .reachedFinalYear { ids.append("reach-2026") }
        if summary.score >= 800 { ids.append("score-800") }
        if summary.score >= 1200 { ids.append("score-1200") }
        if summary.wonElectionCount >= 3 { ids.append("elections-3") }
        if summary.wonElectionCount >= 5 { ids.append("elections-5") }
        if summary.governingStyle.contains("Modernisierer") { ids.append("modernizer") }
        if summary.governingStyle.contains("Stabilit") { ids.append("stability") }

        let index = VisibleMetric.allCases.map { summary.finalStats.value(for: $0) }.reduce(0, +) / VisibleMetric.allCases.count
        if index >= 75 { ids.append("landslide") }

        return ids
    }
}
