import Foundation

/// Display language is independent of the campaign and its saved game.
public enum GameLanguage: String, CaseIterable, Codable, Sendable {
    case german
    case english

    public var localeIdentifier: String {
        switch self {
        case .german: "de_DE"
        case .english: "en_US"
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

    private static let germanyEnglish: Catalog = {
        var entries = USLocalization.catalog
        entries.merge(load("GermanyEnglishOverrides")) { _, replacement in replacement }
        entries.merge(load("GermanyEventsEnglish.draft")) { _, replacement in replacement }
        entries.merge(load("WorldNewsEnglish")) { _, replacement in replacement }
        return Catalog(entries)
    }()

    private static let usGerman: Catalog = {
        var entries = load("USEventsGerman.draft")
        entries.merge(load("USGeneratedGerman")) { _, replacement in replacement }
        entries.merge(load("USGermanOverrides")) { _, replacement in replacement }
        return Catalog(entries)
    }()

    public static func translate(_ source: String, country: GameCountry, language: GameLanguage) -> String {
        switch (country, language) {
        case (.germany, .german): source
        case (.germany, .english): germanyEnglish.translate(source)
        case (.unitedStates, .german): usGerman.translate(source)
        case (.unitedStates, .english): USLocalization.translate(source)
        }
    }
}
