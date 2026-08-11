import Foundation

public struct ReleaseReadinessReport: Codable, Equatable, Sendable {
    public let hasEventsForEveryYear: Bool
    public let missingYears: [Int]
    public let initialStateIsCodable: Bool
    public let allInitialValuesAreInRange: Bool

    public init(
        hasEventsForEveryYear: Bool,
        missingYears: [Int],
        initialStateIsCodable: Bool,
        allInitialValuesAreInRange: Bool
    ) {
        self.hasEventsForEveryYear = hasEventsForEveryYear
        self.missingYears = missingYears
        self.initialStateIsCodable = initialStateIsCodable
        self.allInitialValuesAreInRange = allInitialValuesAreInRange
    }

    public var isReadyForPrototypeRelease: Bool {
        hasEventsForEveryYear && initialStateIsCodable && allInitialValuesAreInRange
    }
}

public struct ReleaseReadinessChecker: Sendable {
    private let eventRepository: EventRepository

    public init(eventRepository: EventRepository = LocalJSONEventRepository()) {
        self.eventRepository = eventRepository
    }

    public func check(yearRange: ClosedRange<Int> = 2000...2026) -> ReleaseReadinessReport {
        let missingYears = yearRange.filter { eventRepository.events(for: $0).isEmpty }
        let state = GameStateFactory.initialGermany2000()
        let visibleValues = VisibleMetric.allCases.map { state.visible.value(for: $0) }
        let hiddenValues = HiddenMetric.allCases.map { state.hidden.value(for: $0) }
        let allValues = visibleValues + hiddenValues + [state.governmentApproval]

        let initialStateIsCodable: Bool
        do {
            let data = try JSONEncoder().encode(state)
            _ = try JSONDecoder().decode(GameState.self, from: data)
            initialStateIsCodable = true
        } catch {
            initialStateIsCodable = false
        }

        return ReleaseReadinessReport(
            hasEventsForEveryYear: missingYears.isEmpty,
            missingYears: missingYears,
            initialStateIsCodable: initialStateIsCodable,
            allInitialValuesAreInRange: allValues.allSatisfy { (0...100).contains($0) }
        )
    }
}
