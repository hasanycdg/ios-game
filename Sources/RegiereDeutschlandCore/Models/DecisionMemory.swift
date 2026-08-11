import Foundation

public struct PublicMemoryImpact: Codable, Equatable, Sendable {
    public let immediateApproval: Int
    public let groupEffects: [PopulationApprovalEffect]
    public let reactivationTags: [String]

    public init(
        immediateApproval: Int = 0,
        groupEffects: [PopulationApprovalEffect] = [],
        reactivationTags: [String] = []
    ) {
        self.immediateApproval = immediateApproval
        self.groupEffects = groupEffects
        self.reactivationTags = reactivationTags
    }
}

public struct DecisionMemoryRecord: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let sourceEventID: String
    public let sourceOptionID: String
    public let optionTitle: String
    public let year: Int
    public let impact: PublicMemoryImpact
    public var currentWeight: Double
    public var lastReactivatedYear: Int?

    public init(
        id: UUID = UUID(),
        sourceEventID: String,
        sourceOptionID: String,
        optionTitle: String,
        year: Int,
        impact: PublicMemoryImpact,
        currentWeight: Double = 1.0,
        lastReactivatedYear: Int? = nil
    ) {
        self.id = id
        self.sourceEventID = sourceEventID
        self.sourceOptionID = sourceOptionID
        self.optionTitle = optionTitle
        self.year = year
        self.impact = impact
        self.currentWeight = currentWeight
        self.lastReactivatedYear = lastReactivatedYear
    }
}
