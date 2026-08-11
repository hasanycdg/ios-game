import Foundation

public enum EventCategory: String, Codable, CaseIterable, Sendable {
    case economy
    case budget
    case society
    case security
    case energy
    case foreignPolicy
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
    public let flagsToSet: [String]
    public let note: String?

    public init(
        delayInYears: Int,
        immediateEffects: [GameEffect] = [],
        hiddenEffects: [HiddenEffect] = [],
        flagsToSet: [String] = [],
        note: String? = nil
    ) {
        self.delayInYears = delayInYears
        self.immediateEffects = immediateEffects
        self.hiddenEffects = hiddenEffects
        self.flagsToSet = flagsToSet
        self.note = note
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
    public let flagsToSet: [String]

    public init(
        id: String,
        title: String,
        description: String,
        advisoryNote: String,
        immediateEffects: [GameEffect] = [],
        hiddenEffects: [HiddenEffect] = [],
        approvalEffect: Int = 0,
        delayedEffects: [DelayedEffect] = [],
        flagsToSet: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.advisoryNote = advisoryNote
        self.immediateEffects = immediateEffects
        self.hiddenEffects = hiddenEffects
        self.approvalEffect = approvalEffect
        self.delayedEffects = delayedEffects
        self.flagsToSet = flagsToSet
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
        followUpEvents: [String] = []
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
    }

    public func isAvailable(in state: GameState) -> Bool {
        year == state.currentYear && conditions.allSatisfy { $0.isSatisfied(by: state) }
    }
}
