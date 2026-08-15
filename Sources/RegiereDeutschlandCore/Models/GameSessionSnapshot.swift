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
    public let playerPartyID: String?
    public let playerPartyData: PlayerParty?
    public let playerName: String?
    public let awaitingInitialCoalition: Bool?
    public let pendingCampaign: Bool?
    public let corruption: Int?
    public let pendingEncounter: PoliticalEncounter?
    public let cabinet: Cabinet?
    public let pendingCoalitionOptions: [CoalitionOption]?
    public let pendingCoalitionTalks: CoalitionNegotiation?
    public let policies: PolicyState?
    public let debt: Int?
    public let interestGroups: [InterestGroup]?
    public let partyWings: PartyWings?
    public let hasBundesratMajority: Bool?
    public let diplomacy: DiplomaticState?

    public init(
        schemaVersion: Int = 1,
        state: GameState,
        currentEventID: String?,
        lastDecisionResult: DecisionResult?,
        annualHistory: [AnnualRecord] = [],
        politicalCapital: Int? = nil,
        coalition: CoalitionState? = nil,
        personaID: String? = nil,
        playerPartyID: String? = nil,
        playerPartyData: PlayerParty? = nil,
        playerName: String? = nil,
        awaitingInitialCoalition: Bool? = nil,
        pendingCampaign: Bool? = nil,
        corruption: Int? = nil,
        pendingEncounter: PoliticalEncounter? = nil,
        cabinet: Cabinet? = nil,
        pendingCoalitionOptions: [CoalitionOption]? = nil,
        pendingCoalitionTalks: CoalitionNegotiation? = nil,
        policies: PolicyState? = nil,
        debt: Int? = nil,
        interestGroups: [InterestGroup]? = nil,
        partyWings: PartyWings? = nil,
        hasBundesratMajority: Bool? = nil,
        diplomacy: DiplomaticState? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.state = state
        self.currentEventID = currentEventID
        self.lastDecisionResult = lastDecisionResult
        self.annualHistory = annualHistory
        self.politicalCapital = politicalCapital
        self.coalition = coalition
        self.personaID = personaID
        self.playerPartyID = playerPartyID
        self.playerPartyData = playerPartyData
        self.playerName = playerName
        self.awaitingInitialCoalition = awaitingInitialCoalition
        self.pendingCampaign = pendingCampaign
        self.corruption = corruption
        self.pendingEncounter = pendingEncounter
        self.cabinet = cabinet
        self.pendingCoalitionOptions = pendingCoalitionOptions
        self.pendingCoalitionTalks = pendingCoalitionTalks
        self.policies = policies
        self.debt = debt
        self.interestGroups = interestGroups
        self.partyWings = partyWings
        self.hasBundesratMajority = hasBundesratMajority
        self.diplomacy = diplomacy
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
        case playerPartyID
        case playerPartyData
        case playerName
        case awaitingInitialCoalition
        case pendingCampaign
        case corruption
        case pendingEncounter
        case cabinet
        case pendingCoalitionOptions
        case pendingCoalitionTalks
        case policies
        case debt
        case interestGroups
        case partyWings
        case hasBundesratMajority
        case diplomacy
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
        playerPartyID = try container.decodeIfPresent(String.self, forKey: .playerPartyID)
        playerPartyData = try container.decodeIfPresent(PlayerParty.self, forKey: .playerPartyData)
        playerName = try container.decodeIfPresent(String.self, forKey: .playerName)
        awaitingInitialCoalition = try container.decodeIfPresent(Bool.self, forKey: .awaitingInitialCoalition)
        pendingCampaign = try container.decodeIfPresent(Bool.self, forKey: .pendingCampaign)
        corruption = try container.decodeIfPresent(Int.self, forKey: .corruption)
        pendingEncounter = try container.decodeIfPresent(PoliticalEncounter.self, forKey: .pendingEncounter)
        cabinet = try container.decodeIfPresent(Cabinet.self, forKey: .cabinet)
        pendingCoalitionOptions = try container.decodeIfPresent([CoalitionOption].self, forKey: .pendingCoalitionOptions)
        pendingCoalitionTalks = try container.decodeIfPresent(CoalitionNegotiation.self, forKey: .pendingCoalitionTalks)
        policies = try container.decodeIfPresent(PolicyState.self, forKey: .policies)
        debt = try container.decodeIfPresent(Int.self, forKey: .debt)
        interestGroups = try container.decodeIfPresent([InterestGroup].self, forKey: .interestGroups)
        partyWings = try container.decodeIfPresent(PartyWings.self, forKey: .partyWings)
        hasBundesratMajority = try container.decodeIfPresent(Bool.self, forKey: .hasBundesratMajority)
        diplomacy = try container.decodeIfPresent(DiplomaticState.self, forKey: .diplomacy)
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
