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
    public let reasons: [String]

    public init(
        id: UUID = UUID(),
        year: Int,
        governingPartyShare: Double,
        oppositionShare: Double,
        didWin: Bool,
        reasons: [String] = []
    ) {
        self.id = id
        self.year = year
        self.governingPartyShare = governingPartyShare
        self.oppositionShare = oppositionShare
        self.didWin = didWin
        self.reasons = reasons
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
    public var shortTermMomentum: Int
    public var visible: VisibleMetrics
    public var hidden: HiddenMetrics
    public var yearProgress: YearProgress
    public var eventQueue: EventQueue
    public var decisions: [DecisionRecord]
    public var electionResults: [ElectionResult]
    public var activeLongTermEffects: [ActiveLongTermEffect]
    public var scheduledEffects: [ScheduledEffect]
    public var triggeredHistoricalEchoes: [TriggeredHistoricalEcho]
    public var historicalFlags: Set<String>
    public var populationGroups: [PopulationGroup]
    public var decisionMemory: [DecisionMemoryRecord]
    public var pendingElectionResult: ElectionResult?
    public var gameOverSummary: GameOverSummary?

    public init(
        currentYear: Int,
        governmentApproval: Int,
        visible: VisibleMetrics,
        hidden: HiddenMetrics,
        shortTermMomentum: Int = 0,
        yearProgress: YearProgress? = nil,
        eventQueue: EventQueue? = nil,
        decisions: [DecisionRecord] = [],
        electionResults: [ElectionResult] = [],
        activeLongTermEffects: [ActiveLongTermEffect] = [],
        scheduledEffects: [ScheduledEffect] = [],
        triggeredHistoricalEchoes: [TriggeredHistoricalEcho] = [],
        historicalFlags: Set<String> = [],
        populationGroups: [PopulationGroup] = PopulationGroupsFactory.initialGermany2000(),
        decisionMemory: [DecisionMemoryRecord] = [],
        pendingElectionResult: ElectionResult? = nil,
        gameOverSummary: GameOverSummary? = nil
    ) {
        self.currentYear = currentYear
        self.governmentApproval = VisibleMetrics.clamped(governmentApproval)
        self.shortTermMomentum = shortTermMomentum
        self.visible = visible
        self.hidden = hidden
        self.yearProgress = yearProgress ?? YearProgress(year: currentYear)
        self.eventQueue = eventQueue ?? EventQueue(year: currentYear)
        self.decisions = decisions
        self.electionResults = electionResults
        self.activeLongTermEffects = activeLongTermEffects
        self.scheduledEffects = scheduledEffects
        self.triggeredHistoricalEchoes = triggeredHistoricalEchoes
        self.historicalFlags = historicalFlags
        self.populationGroups = populationGroups
        self.decisionMemory = decisionMemory
        self.pendingElectionResult = pendingElectionResult
        self.gameOverSummary = gameOverSummary
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
        shortTermMomentum = VisibleMetrics.clamped(shortTermMomentum + change + 50) - 50
    }

    public mutating func applyPopulationEffects(_ effects: [PopulationApprovalEffect]) {
        for effect in effects {
            guard let index = populationGroups.firstIndex(where: { $0.id == effect.group }) else {
                continue
            }
            populationGroups[index].approval = VisibleMetrics.clamped(populationGroups[index].approval + effect.change)
        }
    }

    public mutating func clampAll() {
        governmentApproval = VisibleMetrics.clamped(governmentApproval)
        shortTermMomentum = min(50, max(-50, shortTermMomentum))
        visible.clampAll()
        hidden.clampAll()
        for index in populationGroups.indices {
            populationGroups[index].approval = VisibleMetrics.clamped(populationGroups[index].approval)
        }
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

/// Ausgangslage Deutschlands im Jahr 2000 als 0–100-Index, an der realen Lage
/// kalibriert: Dotcom-Wachstum bei ~9,6 % Arbeitslosigkeit (Wirtschaft mittel),
/// durch UMTS-Erlöse fast ausgeglichener Haushalt, Atomkonsens 2000, EU-Motor
/// unter Schröder/Fischer – aber durch die CDU-Spendenaffäre erschüttertes
/// Vertrauen in die Politik.
private enum InitialGermany2000 {
    static let currentYear = 2000
    static let governmentApproval = 54

    static let visible = VisibleMetrics(
        economy: 54,            // Dotcom-Boom, aber hohe Arbeitslosigkeit
        budget: 53,             // UMTS-Erlöse, Eichel-Konsolidierung
        livingStandard: 62,     // hoher Wohlstand, Ost-West-Gefälle
        society: 58,            // stabil, aber Integrationsdebatte
        security: 68,           // vor dem 11. September, hohe innere Sicherheit
        energy: 52,             // Atomausstiegs-Konsens, fossil geprägt
        internationalRelations: 66, // EU-Motor, transatlantisch stabil
        trust: 44               // CDU-Spendenaffäre, Politikverdrossenheit
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
