import Foundation

public enum GameOverReason: String, Codable, Sendable {
    case lostElection
    case reachedFinalYear
}

public struct GameOverSummary: Codable, Equatable, Sendable {
    public let reason: GameOverReason
    public let message: String
    public let startYear: Int
    public let endYear: Int
    public let keyDecisionTitles: [String]
    public let finalStats: VisibleMetrics
    public let defeatReasons: [String]
    public let governingStyle: String

    public init(
        reason: GameOverReason,
        message: String,
        startYear: Int,
        endYear: Int,
        keyDecisionTitles: [String],
        finalStats: VisibleMetrics,
        defeatReasons: [String],
        governingStyle: String
    ) {
        self.reason = reason
        self.message = message
        self.startYear = startYear
        self.endYear = endYear
        self.keyDecisionTitles = keyDecisionTitles
        self.finalStats = finalStats
        self.defeatReasons = defeatReasons
        self.governingStyle = governingStyle
    }
}
