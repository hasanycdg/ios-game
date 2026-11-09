import Foundation

/// Display language is independent of the campaign and its saved game.
public enum GameLanguage: String, CaseIterable, Codable, Sendable {
    case german
    case english
    case french

    public var localeIdentifier: String {
        switch self {
        case .german: "de_DE"
        case .english: "en_US"
        case .french: "fr_FR"
        }
    }
}

/// Localizes presentation text without changing event identifiers or saves.
public enum GameTextLocalization {
    private struct Template: @unchecked Sendable {
        let regex: NSRegularExpression
        let translation: String
        let count: Int
    }

    private struct Catalog: Sendable {
        let entries: [String: String]
        let templates: [Template]

        init(_ entries: [String: String]) {
            self.entries = entries
            self.templates = entries.compactMap { key, value in
                guard key.contains("{0}") else { return nil }
                var pattern = NSRegularExpression.escapedPattern(for: key)
                var count = 0
                while key.contains("{\(count)}") {
                    pattern = pattern.replacingOccurrences(
                        of: NSRegularExpression.escapedPattern(for: "{\(count)}"), with: "(.+?)")
                    count += 1
                }
                guard let regex = try? NSRegularExpression(pattern: "^" + pattern + "$", options: [.dotMatchesLineSeparators]) else { return nil }
                return Template(regex: regex, translation: value, count: count)
            }.sorted { $0.regex.pattern.count > $1.regex.pattern.count }
        }

        func translate(_ source: String, depth: Int = 0) -> String {
            if let exact = entries[source] { return exact }
            guard depth < 4 else { return source }
            let range = NSRange(source.startIndex..., in: source)
            for template in templates {
                guard let match = template.regex.firstMatch(in: source, range: range) else { continue }
                var result = template.translation
                for index in (0..<template.count).reversed() {
                    guard let capture = Range(match.range(at: index + 1), in: source) else { continue }
                    result = result.replacingOccurrences(of: "{\(index)}", with: translate(String(source[capture]), depth: depth + 1))
                }
                return result
            }
            return source
        }
    }

    private static func load(_ name: String) -> [String: String] {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode([String: String].self, from: data) else { return [:] }
        return catalog
    }

    /// German mechanics in parliamentary English (shared by Germany, the UK and France).
    private static let parliamentaryEnglishEntries: [String: String] = {
        var entries = USLocalization.catalog
        entries.merge(load("GermanyEnglishOverrides")) { _, replacement in replacement }
        return entries
    }()

    private static let germanyEnglish: Catalog = {
        var entries = parliamentaryEnglishEntries
        entries.merge(load("GermanyEventsEnglish.draft")) { _, replacement in replacement }
        entries.merge(load("WorldNewsEnglish")) { _, replacement in replacement }
        return Catalog(entries)
    }()

    /// UK/France in English: event content is English source; German mechanics
    /// are translated with the parliamentary catalog plus country terminology.
    private static func europeanEnglish(_ prefix: String) -> Catalog {
        var entries = parliamentaryEnglishEntries
        entries.merge(load("EuropeanCommonEnglish")) { _, replacement in replacement }
        entries.merge(load(prefix + "English")) { _, replacement in replacement }
        return Catalog(entries)
    }

    /// UK/France in German: English content is translated; German mechanics keep
    /// their source text except for country terminology (Unterhaus, Präsident …).
    private static func europeanGerman(_ prefix: String) -> Catalog {
        var entries = load("EuropeanCommonGerman")
        entries.merge(load(prefix + "German")) { _, replacement in replacement }
        entries.merge(load(prefix + "GermanOverrides")) { _, replacement in replacement }
        return Catalog(entries)
    }

    private static let ukEnglish = europeanEnglish("UK")
    private static let ukGerman = europeanGerman("UK")
    private static let frEnglish = europeanEnglish("FR")
    private static let frGerman = europeanGerman("FR")

    private static let usGerman: Catalog = {
        var entries = load("USEventsGerman.draft")
        entries.merge(load("USGeneratedGerman")) { _, replacement in replacement }
        entries.merge(load("USGermanOverrides")) { _, replacement in replacement }
        return Catalog(entries)
    }()

    /// French is translated from each country's English rendering, so one
    /// catalog (English → French) serves every campaign and its templates.
    private static let french: Catalog = {
        var entries = load("French")
        entries.merge(load("FrenchFuture")) { _, replacement in replacement }
        return Catalog(entries)
    }()

    /// French for an English source text (used by screens with English copy).
    public static func frenchFromEnglish(_ english: String) -> String {
        french.translate(english)
    }

    public static func translate(_ source: String, country: GameCountry, language: GameLanguage) -> String {
        if language == .french {
            return french.translate(translate(source, country: country, language: .english))
        }
        return switch (country, language) {
        case (.germany, .german): source
        case (.germany, .english): germanyEnglish.translate(source)
        case (.unitedStates, .german): usGerman.translate(source)
        case (.unitedStates, .english): USLocalization.translate(source)
        case (.unitedKingdom, .german): ukGerman.translate(source)
        case (.unitedKingdom, .english): ukEnglish.translate(source)
        case (.france, .german): frGerman.translate(source)
        case (.france, .english): frEnglish.translate(source)
        case (_, .french): source // handled above
        }
    }
}
