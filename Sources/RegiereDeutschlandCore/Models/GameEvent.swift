import Foundation

public enum EventCategory: String, Codable, CaseIterable, Sendable {
    case economy
    case budget
    case society
    case security
    case energy
    case foreignPolicy
    case digitalization
    case welfare
    case election
    case historicalEcho
}

public struct GameEffect: Codable, Equatable, Sendable {
    public let metric: VisibleMetric
    public let change: Int

    public init(metric: VisibleMetric, change: Int) {
        self.metric = metric
        self.change = change
    }
}

public struct HiddenEffect: Codable, Equatable, Sendable {
    public let metric: HiddenMetric
    public let change: Int

    public init(metric: HiddenMetric, change: Int) {
        self.metric = metric
        self.change = change
    }
}

public struct DelayedEffect: Codable, Equatable, Sendable {
    public let delayInYears: Int
    public let immediateEffects: [GameEffect]
    public let hiddenEffects: [HiddenEffect]
    public let approvalEffect: Int
    public let flagsToSet: [String]
    public let note: String?

    public init(
        delayInYears: Int,
        immediateEffects: [GameEffect] = [],
        hiddenEffects: [HiddenEffect] = [],
        approvalEffect: Int = 0,
        flagsToSet: [String] = [],
        note: String? = nil
    ) {
        self.delayInYears = delayInYears
        self.immediateEffects = immediateEffects
        self.hiddenEffects = hiddenEffects
        self.approvalEffect = approvalEffect
        self.flagsToSet = flagsToSet
        self.note = note
    }
}

public struct ConditionalModifier: Codable, Equatable, Sendable {
    public let conditions: [EventCondition]
    public let immediateEffects: [GameEffect]
    public let hiddenEffects: [HiddenEffect]
    public let approvalEffect: Int
    public let memoryReactivationTags: [String]
    public let note: String?

    public init(
        conditions: [EventCondition] = [],
        immediateEffects: [GameEffect] = [],
        hiddenEffects: [HiddenEffect] = [],
        approvalEffect: Int = 0,
        memoryReactivationTags: [String] = [],
        note: String? = nil
    ) {
        self.conditions = conditions
        self.immediateEffects = immediateEffects
        self.hiddenEffects = hiddenEffects
        self.approvalEffect = approvalEffect
        self.memoryReactivationTags = memoryReactivationTags
        self.note = note
    }

    public func isSatisfied(by state: GameState) -> Bool {
        conditions.allSatisfy { $0.isSatisfied(by: state) }
    }
}

public struct MetricCondition<Metric: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
    public let metric: Metric
    public let minimum: Int?
    public let maximum: Int?

    public init(metric: Metric, minimum: Int? = nil, maximum: Int? = nil) {
        self.metric = metric
        self.minimum = minimum
        self.maximum = maximum
    }
}

public struct EventCondition: Codable, Equatable, Sendable {
    public let requiredFlags: [String]
    public let blockedByFlags: [String]
    public let visibleMetrics: [MetricCondition<VisibleMetric>]
    public let hiddenMetrics: [MetricCondition<HiddenMetric>]

    public init(
        requiredFlags: [String] = [],
        blockedByFlags: [String] = [],
        visibleMetrics: [MetricCondition<VisibleMetric>] = [],
        hiddenMetrics: [MetricCondition<HiddenMetric>] = []
    ) {
        self.requiredFlags = requiredFlags
        self.blockedByFlags = blockedByFlags
        self.visibleMetrics = visibleMetrics
        self.hiddenMetrics = hiddenMetrics
    }

    public func isSatisfied(by state: GameState) -> Bool {
        let flags = state.historicalFlags
        guard requiredFlags.allSatisfy(flags.contains) else { return false }
        guard blockedByFlags.allSatisfy({ !flags.contains($0) }) else { return false }

        for condition in visibleMetrics {
            let value = state.visible.value(for: condition.metric)
            if let minimum = condition.minimum, value < minimum { return false }
            if let maximum = condition.maximum, value > maximum { return false }
        }

        for condition in hiddenMetrics {
            let value = state.hidden.value(for: condition.metric)
            if let minimum = condition.minimum, value < minimum { return false }
            if let maximum = condition.maximum, value > maximum { return false }
        }

        return true
    }
}

public struct HistoricalContext: Codable, Equatable, Sendable {
    public let summary: String
    public let sourceNote: String?

    public init(summary: String, sourceNote: String? = nil) {
        self.summary = summary
        self.sourceNote = sourceNote
    }
}

public struct DecisionOption: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let advisoryNote: String
    public let immediateEffects: [GameEffect]
    public let hiddenEffects: [HiddenEffect]
    public let approvalEffect: Int
    public let delayedEffects: [DelayedEffect]
    public let conditionalModifiers: [ConditionalModifier]
    public let flagsToSet: [String]
    public let publicMemoryImpact: PublicMemoryImpact

    public init(
        id: String,
        title: String,
        description: String,
        advisoryNote: String,
        immediateEffects: [GameEffect] = [],
        hiddenEffects: [HiddenEffect] = [],
        approvalEffect: Int = 0,
        delayedEffects: [DelayedEffect] = [],
        conditionalModifiers: [ConditionalModifier] = [],
        flagsToSet: [String] = [],
        publicMemoryImpact: PublicMemoryImpact = PublicMemoryImpact()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.advisoryNote = advisoryNote
        self.immediateEffects = immediateEffects
        self.hiddenEffects = hiddenEffects
        self.approvalEffect = approvalEffect
        self.delayedEffects = delayedEffects
        self.conditionalModifiers = conditionalModifiers
        self.flagsToSet = flagsToSet
        self.publicMemoryImpact = publicMemoryImpact
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case advisoryNote
        case immediateEffects
        case hiddenEffects
        case approvalEffect
        case delayedEffects
        case conditionalModifiers
        case flagsToSet
        case publicMemoryImpact
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        advisoryNote = try container.decode(String.self, forKey: .advisoryNote)
        immediateEffects = try container.decodeIfPresent([GameEffect].self, forKey: .immediateEffects) ?? []
        hiddenEffects = try container.decodeIfPresent([HiddenEffect].self, forKey: .hiddenEffects) ?? []
        approvalEffect = try container.decodeIfPresent(Int.self, forKey: .approvalEffect) ?? 0
        delayedEffects = try container.decodeIfPresent([DelayedEffect].self, forKey: .delayedEffects) ?? []
        conditionalModifiers = try container.decodeIfPresent([ConditionalModifier].self, forKey: .conditionalModifiers) ?? []
        flagsToSet = try container.decodeIfPresent([String].self, forKey: .flagsToSet) ?? []
        publicMemoryImpact = try container.decodeIfPresent(PublicMemoryImpact.self, forKey: .publicMemoryImpact) ?? PublicMemoryImpact()
    }
}

public struct GameEvent: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let year: Int
    public let title: String
    public let category: EventCategory
    public let headline: String
    public let description: String
    public let historicalContext: HistoricalContext
    public let options: [DecisionOption]
    public let conditions: [EventCondition]
    public let followUpEvents: [String]
    public let memoryReactivationTags: [String]
    public let historicalReality: String?
    public let historicalOptionID: String?

    public init(
        id: String,
        year: Int,
        title: String,
        category: EventCategory,
        headline: String,
        description: String,
        historicalContext: HistoricalContext,
        options: [DecisionOption],
        conditions: [EventCondition] = [],
        followUpEvents: [String] = [],
        memoryReactivationTags: [String] = [],
        historicalReality: String? = nil,
        historicalOptionID: String? = nil
    ) {
        self.id = id
        self.year = year
        self.title = title
        self.category = category
        self.headline = headline
        self.description = description
        self.historicalContext = historicalContext
        self.options = options
        self.conditions = conditions
        self.followUpEvents = followUpEvents
        self.memoryReactivationTags = memoryReactivationTags
        self.historicalReality = historicalReality
        self.historicalOptionID = historicalOptionID
    }

    public func isAvailable(in state: GameState) -> Bool {
        year == state.currentYear && conditions.allSatisfy { $0.isSatisfied(by: state) }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case year
        case title
        case category
        case headline
        case description
        case historicalContext
        case options
        case conditions
        case followUpEvents
        case memoryReactivationTags
        case historicalReality
        case historicalOptionID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        year = try container.decode(Int.self, forKey: .year)
        title = try container.decode(String.self, forKey: .title)
        category = try container.decode(EventCategory.self, forKey: .category)
        headline = try container.decode(String.self, forKey: .headline)
        description = try container.decode(String.self, forKey: .description)
        historicalContext = try container.decode(HistoricalContext.self, forKey: .historicalContext)
        options = try container.decode([DecisionOption].self, forKey: .options)
        conditions = try container.decodeIfPresent([EventCondition].self, forKey: .conditions) ?? []
        followUpEvents = try container.decodeIfPresent([String].self, forKey: .followUpEvents) ?? []
        memoryReactivationTags = try container.decodeIfPresent([String].self, forKey: .memoryReactivationTags) ?? []
        historicalReality = try container.decodeIfPresent(String.self, forKey: .historicalReality)
        historicalOptionID = try container.decodeIfPresent(String.self, forKey: .historicalOptionID)
    }
}
