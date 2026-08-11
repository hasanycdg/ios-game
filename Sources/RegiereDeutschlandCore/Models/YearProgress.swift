import Foundation

public struct YearProgress: Codable, Equatable, Sendable {
    public var year: Int
    public var completedEventIDs: Set<String>
    public var isAnnualSimulationApplied: Bool
    public var isElectionResolved: Bool

    public init(
        year: Int,
        completedEventIDs: Set<String> = [],
        isAnnualSimulationApplied: Bool = false,
        isElectionResolved: Bool = false
    ) {
        self.year = year
        self.completedEventIDs = completedEventIDs
        self.isAnnualSimulationApplied = isAnnualSimulationApplied
        self.isElectionResolved = isElectionResolved
    }
}

public struct EventQueue: Codable, Equatable, Sendable {
    public var year: Int
    public var pendingEventIDs: [String]

    public init(year: Int, pendingEventIDs: [String] = []) {
        self.year = year
        self.pendingEventIDs = pendingEventIDs
    }

    public var isEmpty: Bool {
        pendingEventIDs.isEmpty
    }

    public mutating func popNext() -> String? {
        guard !pendingEventIDs.isEmpty else { return nil }
        return pendingEventIDs.removeFirst()
    }
}
