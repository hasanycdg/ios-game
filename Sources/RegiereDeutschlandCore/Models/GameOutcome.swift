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
    public let score: Int
    public let wonElectionCount: Int
    public let biggestSuccess: String
    public let biggestMistake: String
    public let biggestButterflyEffect: String
    public let strongestHistoricalDeviation: String

    public init(
        reason: GameOverReason,
        message: String,
        startYear: Int,
        endYear: Int,
        keyDecisionTitles: [String],
        finalStats: VisibleMetrics,
        defeatReasons: [String],
        governingStyle: String,
        score: Int = 0,
        wonElectionCount: Int = 0,
        biggestSuccess: String = "Noch nicht bewertet",
        biggestMistake: String = "Noch nicht bewertet",
        biggestButterflyEffect: String = "Noch nicht bewertet",
        strongestHistoricalDeviation: String = "Noch nicht bewertet"
    ) {
        self.reason = reason
        self.message = message
        self.startYear = startYear
        self.endYear = endYear
        self.keyDecisionTitles = keyDecisionTitles
        self.finalStats = finalStats
        self.defeatReasons = defeatReasons
        self.governingStyle = governingStyle
        self.score = score
        self.wonElectionCount = wonElectionCount
        self.biggestSuccess = biggestSuccess
        self.biggestMistake = biggestMistake
        self.biggestButterflyEffect = biggestButterflyEffect
        self.strongestHistoricalDeviation = strongestHistoricalDeviation
    }
}
