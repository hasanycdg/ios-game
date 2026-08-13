import Foundation

public struct GameSessionSnapshot: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let state: GameState
    public let currentEventID: String?
    public let lastDecisionResult: DecisionResult?
    public let annualHistory: [AnnualRecord]
    public let politicalCapital: Int?
    public let coalition: CoalitionState?
    public let personaID: String?

    public init(
        schemaVersion: Int = 1,
        state: GameState,
        currentEventID: String?,
        lastDecisionResult: DecisionResult?,
        annualHistory: [AnnualRecord] = [],
        politicalCapital: Int? = nil,
        coalition: CoalitionState? = nil,
        personaID: String? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.state = state
        self.currentEventID = currentEventID
        self.lastDecisionResult = lastDecisionResult
        self.annualHistory = annualHistory
        self.politicalCapital = politicalCapital
        self.coalition = coalition
        self.personaID = personaID
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case state
        case currentEventID
        case lastDecisionResult
        case annualHistory
        case politicalCapital
        case coalition
        case personaID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 1
        state = try container.decode(GameState.self, forKey: .state)
        currentEventID = try container.decodeIfPresent(String.self, forKey: .currentEventID)
        lastDecisionResult = try container.decodeIfPresent(DecisionResult.self, forKey: .lastDecisionResult)
        annualHistory = try container.decodeIfPresent([AnnualRecord].self, forKey: .annualHistory) ?? []
        politicalCapital = try container.decodeIfPresent(Int.self, forKey: .politicalCapital)
        coalition = try container.decodeIfPresent(CoalitionState.self, forKey: .coalition)
        personaID = try container.decodeIfPresent(String.self, forKey: .personaID)
    }
}

public struct RunResult: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let startYear: Int
    public let endYear: Int
    public let endReason: GameOverReason
    public let score: Int
    public let governingStyle: String
    public let completedAt: Date

    public init(
        id: UUID = UUID(),
        startYear: Int,
        endYear: Int,
        endReason: GameOverReason,
        score: Int,
        governingStyle: String,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.startYear = startYear
        self.endYear = endYear
        self.endReason = endReason
        self.score = score
        self.governingStyle = governingStyle
        self.completedAt = completedAt
    }
}
