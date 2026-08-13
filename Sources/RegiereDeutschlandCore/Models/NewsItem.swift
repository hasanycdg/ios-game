import Foundation

/// Herkunft einer Nachricht.
public enum NewsScope: String, Codable, Sendable {
    case world      // Weltgeschehen
    case germany    // Deutschland
    case domestic   // Reaktion auf die eigene Politik (dynamisch erzeugt)
}

/// Eine Schlagzeile im Presse-Feed. Historische Meldungen sind redaktioneller,
/// statischer Content; dynamische Meldungen entstehen aus dem Spielverlauf.
public struct NewsItem: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let year: Int
    public let scope: NewsScope
    public let category: EventCategory
    public let headline: String
    public let summary: String
    public let source: String?

    public init(
        id: String,
        year: Int,
        scope: NewsScope,
        category: EventCategory,
        headline: String,
        summary: String,
        source: String? = nil
    ) {
        self.id = id
        self.year = year
        self.scope = scope
        self.category = category
        self.headline = headline
        self.summary = summary
        self.source = source
    }

    private enum CodingKeys: String, CodingKey {
        case id, year, scope, category, headline, summary, source
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        year = try container.decode(Int.self, forKey: .year)
        scope = try container.decodeIfPresent(NewsScope.self, forKey: .scope) ?? .world
        category = try container.decodeIfPresent(EventCategory.self, forKey: .category) ?? .society
        headline = try container.decode(String.self, forKey: .headline)
        summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
        source = try container.decodeIfPresent(String.self, forKey: .source)
    }
}
