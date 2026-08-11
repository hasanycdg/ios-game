import Foundation

public struct DecisionRecord: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let year: Int
    public let eventID: String
    public let optionID: String
    public let optionTitle: String

    public init(
        id: UUID = UUID(),
        year: Int,
        eventID: String,
        optionID: String,
        optionTitle: String
    ) {
        self.id = id
        self.year = year
        self.eventID = eventID
        self.optionID = optionID
        self.optionTitle = optionTitle
    }
}

public struct ElectionResult: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let year: Int
    public let governingPartyShare: Double
    public let oppositionShare: Double
    public let didWin: Bool

    public init(
        id: UUID = UUID(),
        year: Int,
        governingPartyShare: Double,
        oppositionShare: Double,
        didWin: Bool
    ) {
        self.id = id
        self.year = year
        self.governingPartyShare = governingPartyShare
        self.oppositionShare = oppositionShare
        self.didWin = didWin
    }
}

public struct ActiveLongTermEffect: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let sourceEventID: String
    public let sourceOptionID: String
    public let startedYear: Int
    public let note: String

    public init(
        id: UUID = UUID(),
        sourceEventID: String,
        sourceOptionID: String,
        startedYear: Int,
        note: String
    ) {
        self.id = id
        self.sourceEventID = sourceEventID
        self.sourceOptionID = sourceOptionID
        self.startedYear = startedYear
        self.note = note
    }
}

public struct GameState: Codable, Equatable, Sendable {
    public var currentYear: Int
    public var governmentApproval: Int
    public var visible: VisibleMetrics
    public var hidden: HiddenMetrics
    public var decisions: [DecisionRecord]
    public var electionResults: [ElectionResult]
    public var activeLongTermEffects: [ActiveLongTermEffect]
    public var historicalFlags: Set<String>

    public init(
        currentYear: Int,
        governmentApproval: Int,
        visible: VisibleMetrics,
        hidden: HiddenMetrics,
        decisions: [DecisionRecord] = [],
        electionResults: [ElectionResult] = [],
        activeLongTermEffects: [ActiveLongTermEffect] = [],
        historicalFlags: Set<String> = []
    ) {
        self.currentYear = currentYear
        self.governmentApproval = VisibleMetrics.clamped(governmentApproval)
        self.visible = visible
        self.hidden = hidden
        self.decisions = decisions
        self.electionResults = electionResults
        self.activeLongTermEffects = activeLongTermEffects
        self.historicalFlags = historicalFlags
        clampAll()
    }

    public mutating func apply(_ effect: GameEffect) {
        visible.apply(effect.change, to: effect.metric)
    }

    public mutating func apply(_ effect: HiddenEffect) {
        hidden.apply(effect.change, to: effect.metric)
    }

    public mutating func applyApprovalChange(_ change: Int) {
        governmentApproval = VisibleMetrics.clamped(governmentApproval + change)
    }

    public mutating func clampAll() {
        governmentApproval = VisibleMetrics.clamped(governmentApproval)
        visible.clampAll()
        hidden.clampAll()
    }
}

public enum GameStateFactory {
    public static func initialGermany2000() -> GameState {
        GameState(
            currentYear: InitialGermany2000.currentYear,
            governmentApproval: InitialGermany2000.governmentApproval,
            visible: InitialGermany2000.visible,
            hidden: InitialGermany2000.hidden
        )
    }
}

private enum InitialGermany2000 {
    static let currentYear = 2000
    static let governmentApproval = 52

    static let visible = VisibleMetrics(
        economy: 58,
        budget: 48,
        livingStandard: 64,
        society: 61,
        security: 70,
        energy: 55,
        internationalRelations: 68,
        trust: 50
    )

    static let hidden = HiddenMetrics(
        renewableCapacity: 16,
        nuclearCapacity: 42,
        russianEnergyDependency: 36,
        defenceReadiness: 62,
        digitalization: 24,
        infrastructureQuality: 67,
        integrationCapacity: 58,
        labourMarketFlexibility: 43,
        welfareStrength: 66,
        healthcareResilience: 68,
        euRelations: 72,
        usRelations: 66,
        russiaRelations: 54,
        polarization: 31,
        fiscalSpace: 46
    )
}
