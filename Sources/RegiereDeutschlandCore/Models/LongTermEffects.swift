import Foundation

public struct ScheduledEffect: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let sourceEventID: String
    public let sourceOptionID: String
    public let dueYear: Int
    public let immediateEffects: [GameEffect]
    public let hiddenEffects: [HiddenEffect]
    public let approvalEffect: Int
    public let flagsToSet: [String]
    public let note: String?

    public init(
        id: UUID = UUID(),
        sourceEventID: String,
        sourceOptionID: String,
        dueYear: Int,
        immediateEffects: [GameEffect] = [],
        hiddenEffects: [HiddenEffect] = [],
        approvalEffect: Int = 0,
        flagsToSet: [String] = [],
        note: String? = nil
    ) {
        self.id = id
        self.sourceEventID = sourceEventID
        self.sourceOptionID = sourceOptionID
        self.dueYear = dueYear
        self.immediateEffects = immediateEffects
        self.hiddenEffects = hiddenEffects
        self.approvalEffect = approvalEffect
        self.flagsToSet = flagsToSet
        self.note = note
    }
}

public struct TriggeredHistoricalEcho: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let year: Int
    public let sourceEventID: String
    public let sourceOptionID: String
    public let note: String

    public init(
        id: UUID = UUID(),
        year: Int,
        sourceEventID: String,
        sourceOptionID: String,
        note: String
    ) {
        self.id = id
        self.year = year
        self.sourceEventID = sourceEventID
        self.sourceOptionID = sourceOptionID
        self.note = note
    }
}
