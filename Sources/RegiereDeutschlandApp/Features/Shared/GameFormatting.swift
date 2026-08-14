import RegiereDeutschlandCore
import SwiftUI

/// Präsentations-Metadaten für die sichtbaren Kennwerte.
struct MetricStyle {
    let label: String
    let icon: String
    let blurb: String
}

enum MetricPresentation {
    static func style(for metric: VisibleMetric) -> MetricStyle {
        switch metric {
        case .economy:
            MetricStyle(label: "Wirtschaft", icon: "chart.line.uptrend.xyaxis", blurb: "Wachstum, Arbeitsmarkt und Konjunktur.")
        case .budget:
            MetricStyle(label: "Haushalt", icon: "banknote", blurb: "Staatsfinanzen und Verschuldung.")
        case .livingStandard:
            MetricStyle(label: "Lebensstandard", icon: "house", blurb: "Kaufkraft und Alltag der Menschen.")
        case .society:
            MetricStyle(label: "Gesellschaft", icon: "person.3", blurb: "Zusammenhalt und sozialer Frieden.")
        case .security:
            MetricStyle(label: "Sicherheit", icon: "shield.lefthalf.filled", blurb: "Innere und äußere Sicherheit.")
        case .energy:
            MetricStyle(label: "Energie", icon: "bolt.fill", blurb: "Versorgung, Preise und Unabhängigkeit.")
        case .internationalRelations:
            MetricStyle(label: "International", icon: "globe.europe.africa.fill", blurb: "Ansehen und Bündnisse Deutschlands.")
        case .trust:
            MetricStyle(label: "Vertrauen", icon: "hand.raised.fill", blurb: "Glaubwürdigkeit der Regierung.")
        }
    }

    /// Thematische Gruppierung für die Ressort-Übersicht.
    static let groups: [(title: String, metrics: [VisibleMetric])] = [
        ("Wirtschaft & Finanzen", [.economy, .budget]),
        ("Gesellschaft", [.livingStandard, .society, .trust]),
        ("Sicherheit & Energie", [.security, .energy]),
        ("Außenpolitik", [.internationalRelations])
    ]
}

/// Präsentations-Metadaten für Ereignis-Kategorien.
struct CategoryStyle {
    let label: String
    let icon: String
    let color: Color
}

enum CategoryPresentation {
    static func style(for category: EventCategory) -> CategoryStyle {
        switch category {
        case .economy:
            CategoryStyle(label: "Wirtschaft", icon: "chart.line.uptrend.xyaxis", color: GameTheme.green)
        case .budget:
            CategoryStyle(label: "Haushalt", icon: "banknote", color: GameTheme.gold)
        case .society:
            CategoryStyle(label: "Gesellschaft", icon: "person.3", color: GameTheme.blue)
        case .security:
            CategoryStyle(label: "Sicherheit", icon: "shield.lefthalf.filled", color: GameTheme.red)
        case .energy:
            CategoryStyle(label: "Energie", icon: "bolt.fill", color: GameTheme.amber)
        case .foreignPolicy:
            CategoryStyle(label: "Außenpolitik", icon: "globe.europe.africa.fill", color: GameTheme.teal)
        case .digitalization:
            CategoryStyle(label: "Digitalisierung", icon: "network", color: GameTheme.teal)
        case .welfare:
            CategoryStyle(label: "Soziales", icon: "heart.fill", color: GameTheme.pink)
        case .election:
            CategoryStyle(label: "Wahl", icon: "checkmark.seal.fill", color: GameTheme.gold)
        case .historicalEcho:
            CategoryStyle(label: "Echo der Geschichte", icon: "clock.arrow.circlepath", color: GameTheme.purple)
        }
    }
}

/// Abgeleitete, rein präsentationsbezogene Auswertungen des Spielzustands.
enum NationMood {
    /// Gesamtstimmung als kurzes Schlagwort + Farbe, abgeleitet aus Zustimmung
    /// und der allgemeinen Lage.
    static func headline(for state: GameState) -> (word: String, color: Color) {
        let approval = state.governmentApproval
        let condition = (state.visible.economy + state.visible.society + state.visible.trust) / 3
        let score = (approval * 2 + condition) / 3
        switch score {
        case 66...:   return ("Aufbruch", GameTheme.green)
        case 54..<66: return ("Stabil", GameTheme.gold)
        case 44..<54: return ("Angespannt", GameTheme.amber)
        case 34..<44: return ("Unruhe", GameTheme.amber)
        default:      return ("Krise", GameTheme.red)
        }
    }

    /// Gewichtete Zufriedenheit der Bevölkerung (nach Bevölkerungsanteil).
    static func weightedApproval(for groups: [PopulationGroup]) -> Int {
        guard !groups.isEmpty else { return 0 }
        let totalShare = groups.reduce(0.0) { $0 + $1.populationShare }
        guard totalShare > 0 else { return 0 }
        let weighted = groups.reduce(0.0) { $0 + Double($1.approval) * $1.populationShare }
        return Int((weighted / totalShare).rounded())
    }

    static func moodWord(forApproval value: Int) -> String {
        switch value {
        case 62...:   return "begeistert"
        case 54..<62: return "zufrieden"
        case 46..<54: return "gespalten"
        case 38..<46: return "unzufrieden"
        default:      return "empört"
        }
    }

    static func moodEmoji(forApproval value: Int) -> String {
        switch value {
        case 62...:   return "face.smiling"
        case 46..<62: return "face.dashed"
        default:      return "exclamationmark.bubble"
        }
    }
}

func signedString(_ value: Int) -> String {
    value > 0 ? "+\(value)" : "\(value)"
}

// MARK: - Presse

struct NewsScopeStyle {
    let label: String
    let color: Color
}

enum PartyPresentation {
    static func leader(for id: String) -> String {
        switch id {
        case "cdu":    "Dr. Berger"
        case "spd":    "Frau Vogt"
        case "gruene": "Frau Sommer"
        case "fdp":    "Herr Lang"
        case "linke":  "Herr Albrecht"
        case "afd":    "Herr Stein"
        default:       "die Opposition"
        }
    }

    static func color(for id: String) -> Color {
        switch id {
        case "spd":    GameTheme.red
        case "cdu":    Color(red: 0.78, green: 0.80, blue: 0.85) // Schwarz/Neutral, auf Dunkel hell
        case "gruene": GameTheme.green
        case "fdp":    GameTheme.amber                            // Gelb
        case "linke":  GameTheme.purple
        case "afd":    GameTheme.blue
        default:       GameTheme.secondaryText
        }
    }
}

enum NewsPresentation {
    static func style(for scope: NewsScope) -> NewsScopeStyle {
        switch scope {
        case .world:    NewsScopeStyle(label: "WELT", color: GameTheme.blue)
        case .germany:  NewsScopeStyle(label: "DEUTSCHLAND", color: GameTheme.gold)
        case .domestic: NewsScopeStyle(label: "DEINE POLITIK", color: GameTheme.red)
        }
    }
}
