import Foundation

public protocol NewsRepository: Sendable {
    func loadNews() -> [NewsItem]
    func news(for year: Int) -> [NewsItem]
}

/// Lädt die historischen Welt-/Deutschland-Schlagzeilen aus einer lokalen
/// JSON-Datei. Crash-sicher: ungültige Daten ergeben eine leere Liste.
public struct LocalJSONNewsRepository: NewsRepository {
    private let bundle: Bundle
    private let resourceNames: [String]

    public init(resourceNames: [String] = ["WorldNews"]) {
        self.init(bundle: .module, resourceNames: resourceNames)
    }

    public init(bundle: Bundle, resourceNames: [String]) {
        self.bundle = bundle
        self.resourceNames = resourceNames
    }

    public func loadNews() -> [NewsItem] {
        resourceNames.flatMap { name -> [NewsItem] in
            guard let url = bundle.url(forResource: name, withExtension: "json") else {
                return []
            }
            do {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode([NewsItem].self, from: data)
            } catch {
                return []
            }
        }
    }

    public func news(for year: Int) -> [NewsItem] {
        loadNews().filter { $0.year == year }
    }
}

public struct InMemoryNewsRepository: NewsRepository {
    private let stored: [NewsItem]

    public init(news: [NewsItem]) {
        self.stored = news
    }

    public func loadNews() -> [NewsItem] { stored }

    public func news(for year: Int) -> [NewsItem] {
        stored.filter { $0.year == year }
    }
}
