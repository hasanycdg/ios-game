import Foundation

public protocol EventRepository: Sendable {
    func loadEvents() -> [GameEvent]
    func events(for year: Int) -> [GameEvent]
}

public struct LocalJSONEventRepository: EventRepository {
    private let storedEvents: [GameEvent]

    public init(resourceNames: [String] = ["Events2000", "Events2001", "Events2002", "Events2003", "Events2004", "Events2005", "Events2006To2026", "EventsExtra", "EventsEarly", "EventsExtra2", "Future2050Scenarios", "Future2050", "Future2050Extra"]) {
        self.init(bundle: .module, resourceNames: resourceNames)
    }

    public init(
        bundle: Bundle,
        resourceNames: [String]
    ) {
        // Die langen Entscheidungsketten fragen den Katalog mehrfach pro Zug
        // ab. Gebündelte JSON-Dateien dafür nur einmal pro Repository dekodieren.
        storedEvents = resourceNames.flatMap { name -> [GameEvent] in
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

    public func loadEvents() -> [GameEvent] {
        storedEvents
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
