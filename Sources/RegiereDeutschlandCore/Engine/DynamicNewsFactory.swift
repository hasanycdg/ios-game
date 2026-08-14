import Foundation

/// Erzeugt reaktive Schlagzeilen aus dem aktuellen Spielzustand – die Presse
/// kommentiert die Politik des Spielers. Rein deterministisch und testbar.
public enum DynamicNewsFactory {

    public static func make(for state: GameState, corruption: Int = 0) -> [NewsItem] {
        var items: [NewsItem] = []
        let year = state.currentYear

        // Korruptions-Gerüchte als Vorboten eines möglichen Skandals
        if corruption >= 20 {
            items.append(
                NewsItem(
                    id: "dyn-corruption-\(year)-\(corruption)",
                    year: year,
                    scope: .domestic,
                    category: .society,
                    headline: "Gerüchte über dubiose Zahlungen",
                    summary: "In der Hauptstadt wird über vertrauliche Geldflüsse rund um die Regierung getuschelt.",
                    source: "Recherche"
                )
            )
        }

        // Kabinettsbeschlüsse dieses Jahres
        for decision in state.decisions where decision.year == year {
            items.append(
                NewsItem(
                    id: "dyn-decision-\(decision.id.uuidString)",
                    year: year,
                    scope: .domestic,
                    category: .society,
                    headline: "Kabinettsbeschluss: \(decision.optionTitle)",
                    summary: "Die Regierung hat sich festgelegt. Kommentatoren streiten über die Folgen.",
                    source: "Hauptstadtbüro"
                )
            )
        }

        // Historische Echos dieses Jahres
        for echo in state.triggeredHistoricalEchoes where echo.year == year {
            items.append(
                NewsItem(
                    id: "dyn-echo-\(echo.id.uuidString)",
                    year: year,
                    scope: .domestic,
                    category: .historicalEcho,
                    headline: "Echo der Geschichte",
                    summary: echo.note,
                    source: "Analyse"
                )
            )
        }

        // Stimmungslage aus Zustimmung und Momentum
        if let mood = moodHeadline(for: state) {
            items.append(mood)
        }

        // Warnungen aus kritischen Werten (max. zwei)
        let critical = VisibleMetric.allCases
            .map { ($0, state.visible.value(for: $0)) }
            .filter { $0.1 < 36 }
            .sorted { $0.1 < $1.1 }
            .prefix(2)
        for (metric, value) in critical {
            items.append(alarmHeadline(for: metric, value: value, year: year))
        }

        // Lob bei einem herausragenden Wert
        if let (metric, value) = VisibleMetric.allCases
            .map({ ($0, state.visible.value(for: $0)) })
            .filter({ $0.1 >= 82 })
            .max(by: { $0.1 < $1.1 }) {
            items.append(praiseHeadline(for: metric, value: value, year: year))
        }

        return items
    }

    private static func moodHeadline(for state: GameState) -> NewsItem? {
        let approval = state.governmentApproval
        let momentum = state.shortTermMomentum
        let (headline, summary, category): (String, String, EventCategory)

        if approval >= 62 {
            (headline, summary, category) = ("Regierung mit starkem Rückhalt", "Aktuelle Umfragen sehen die Regierung klar vorn.", .society)
        } else if approval <= 38 {
            (headline, summary, category) = ("Zustimmung im Keller", "Die Opposition wittert Morgenluft, in der Koalition wächst die Nervosität.", .society)
        } else if momentum >= 8 {
            (headline, summary, category) = ("Aufwind für die Regierung", "Die jüngsten Entscheidungen kommen an – die Stimmung dreht.", .society)
        } else if momentum <= -8 {
            (headline, summary, category) = ("Regierung unter Druck", "Mehrere Entscheidungen sorgen für Gegenwind in der Bevölkerung.", .society)
        } else {
            return nil
        }

        return NewsItem(
            id: "dyn-mood-\(state.currentYear)-\(approval)-\(momentum)",
            year: state.currentYear,
            scope: .domestic,
            category: category,
            headline: headline,
            summary: summary,
            source: "Sonntagstrend"
        )
    }

    private static func alarmHeadline(for metric: VisibleMetric, value: Int, year: Int) -> NewsItem {
        let (headline, summary, category): (String, String, EventCategory)
        switch metric {
        case .economy:
            (headline, summary, category) = ("Konjunktursorgen wachsen", "Ökonomen warnen vor einer Abschwächung der Wirtschaft.", .economy)
        case .budget:
            (headline, summary, category) = ("Haushaltsloch belastet den Bund", "Der Finanzminister ringt um die Deckung der Ausgaben.", .budget)
        case .livingStandard:
            (headline, summary, category) = ("Kaufkraft unter Druck", "Viele Menschen spüren die steigenden Kosten im Alltag.", .welfare)
        case .society:
            (headline, summary, category) = ("Gesellschaft driftet auseinander", "Beobachter warnen vor wachsenden Spannungen im Land.", .society)
        case .security:
            (headline, summary, category) = ("Sorge um die Sicherheit", "Debatten über innere und äußere Sicherheit nehmen zu.", .security)
        case .energy:
            (headline, summary, category) = ("Energieversorgung wackelt", "Steigende Preise und Versorgungsfragen dominieren die Debatte.", .energy)
        case .internationalRelations:
            (headline, summary, category) = ("Deutschland verliert an Einfluss", "Partner zeigen sich irritiert über den außenpolitischen Kurs.", .foreignPolicy)
        case .trust:
            (headline, summary, category) = ("Vertrauenskrise in der Politik", "Das Vertrauen in die Regierung erreicht einen Tiefstand.", .society)
        }
        return NewsItem(
            id: "dyn-alarm-\(year)-\(metric.rawValue)",
            year: year,
            scope: .domestic,
            category: category,
            headline: headline,
            summary: summary,
            source: "Brennpunkt"
        )
    }

    private static func praiseHeadline(for metric: VisibleMetric, value: Int, year: Int) -> NewsItem {
        let name: String
        let category: EventCategory
        switch metric {
        case .economy: name = "Die Wirtschaft brummt"; category = .economy
        case .budget: name = "Solide Staatsfinanzen loben Ökonomen"; category = .budget
        case .livingStandard: name = "Wohlstand auf Höchststand"; category = .welfare
        case .society: name = "Gesellschaftlicher Zusammenhalt stark wie selten"; category = .society
        case .security: name = "Deutschland gilt als besonders sicher"; category = .security
        case .energy: name = "Energieversorgung auf stabilem Kurs"; category = .energy
        case .internationalRelations: name = "Deutschland als geschätzter Partner"; category = .foreignPolicy
        case .trust: name = "Hohes Vertrauen in die Regierung"; category = .society
        }
        return NewsItem(
            id: "dyn-praise-\(year)-\(metric.rawValue)",
            year: year,
            scope: .domestic,
            category: category,
            headline: name,
            summary: "International und im Inland findet der Kurs Anerkennung.",
            source: "Wirtschaftsteil"
        )
    }
}
