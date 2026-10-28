import Foundation

/// English presentation of shared mechanics. Historical US content lives in its
/// own repositories. Templates preserve interpolated values and support nested
/// model labels without changing identifiers, SF Symbols, or player input.
public enum USLocalization {
    public static let catalog: [String: String] = {
        guard let url = Bundle.module.url(forResource: "USEnglish", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let result = try? JSONDecoder().decode([String: String].self, from: data) else { return [:] }
        return result
    }()

    private struct Template: @unchecked Sendable {
        let regex: NSRegularExpression
        let translation: String
        let captures: Int
    }

    private static let templates: [Template] = catalog.compactMap { key, value in
        guard key.contains("{0}") else { return nil }
        var pattern = NSRegularExpression.escapedPattern(for: key)
        var count = 0
        while key.contains("{\(count)}") {
            pattern = pattern.replacingOccurrences(of: NSRegularExpression.escapedPattern(for: "{\(count)}"), with: "(.+?)")
            count += 1
        }
        guard let regex = try? NSRegularExpression(pattern: "^" + pattern + "$", options: [.dotMatchesLineSeparators]) else { return nil }
        return Template(regex: regex, translation: value, captures: count)
    }.sorted { $0.regex.pattern.count > $1.regex.pattern.count }

    public static func translate(_ source: String) -> String { translate(source, depth: 0) }

    private static func translate(_ source: String, depth: Int) -> String {
        if let exact = catalog[source] { return exact }
        guard depth < 4 else { return source }
        let range = NSRange(source.startIndex..., in: source)
        for template in templates {
            guard let match = template.regex.firstMatch(in: source, range: range) else { continue }
            var result = template.translation
            // Reverse order prevents a captured value containing a placeholder
            // from being substituted a second time.
            for index in (0..<template.captures).reversed() {
                guard let capture = Range(match.range(at: index + 1), in: source) else { continue }
                result = result.replacingOccurrences(of: "{\(index)}", with: translate(String(source[capture]), depth: depth + 1))
            }
            return result
        }
        return source
    }
}
