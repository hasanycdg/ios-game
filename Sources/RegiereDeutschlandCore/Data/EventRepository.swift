import Foundation

public protocol EventRepository: Sendable {
    func loadEvents() -> [GameEvent]
    func events(for year: Int) -> [GameEvent]
}

public struct LocalJSONEventRepository: EventRepository {
    private let bundle: Bundle
    private let resourceNames: [String]

    public init(resourceNames: [String] = ["Events2000", "Events2001", "Events2002", "Events2003", "Events2004", "Events2005", "Events2006To2026", "EventsExtra", "EventsEarly", "EventsExtra2"]) {
        self.init(bundle: .module, resourceNames: resourceNames)
    }

    public init(
        bundle: Bundle,
        resourceNames: [String]
    ) {
        self.bundle = bundle
        self.resourceNames = resourceNames
    }

    public func loadEvents() -> [GameEvent] {
        resourceNames.flatMap { name -> [GameEvent] in
            guard let url = bundle.url(forResource: name, withExtension: "json") else {
                return []
            }

            do {
                let data = try Data(contentsOf: url)
                return Self.decodeEvents(from: data)
            } catch {
                return []
            }
        }
    }

    public func events(for year: Int) -> [GameEvent] {
        loadEvents().filter { $0.year == year }
    }

    public static func decodeEvents(from data: Data) -> [GameEvent] {
        do {
            return try JSONDecoder().decode([GameEvent].self, from: data)
        } catch {
            return []
        }
    }
}

public struct InMemoryEventRepository: EventRepository {
    private let storedEvents: [GameEvent]

    public init(events: [GameEvent]) {
        self.storedEvents = events
    }

    public func loadEvents() -> [GameEvent] {
        storedEvents
    }

    public func events(for year: Int) -> [GameEvent] {
        storedEvents.filter { $0.year == year }
    }
}
