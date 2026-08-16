import SwiftUI

/// Zentrales Design-System für "Regiere Deutschland".
/// Dunkles, hochwertiges Strategie-Game-Look: Anthrazit, Gold, Rot – mit
/// dezentem Schwarz-Rot-Gold-Akzent. Reine Präsentation, keine Game-Logik.
enum GameTheme {

    // MARK: - Flächen & Hintergründe

    static let background = LinearGradient(
        colors: [
            Color(red: 0.055, green: 0.060, blue: 0.075),
            Color(red: 0.030, green: 0.032, blue: 0.045)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Warmer, tiefer Verlauf für dramatische Momente (Wahlabend, Game Over).
    static let dramaticBackground = LinearGradient(
        colors: [
            Color(red: 0.10, green: 0.055, blue: 0.055),
            Color(red: 0.028, green: 0.028, blue: 0.038)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surface = Color(red: 0.115, green: 0.125, blue: 0.150)
    static let surfaceElevated = Color(red: 0.150, green: 0.162, blue: 0.190)
    static let surfaceSunken = Color(red: 0.075, green: 0.082, blue: 0.100)

    static let hairline = Color.white.opacity(0.08)
    static let hairlineStrong = Color.white.opacity(0.14)

    // MARK: - Text

    static let primaryText = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let secondaryText = Color(red: 0.68, green: 0.70, blue: 0.76)
    static let tertiaryText = Color(red: 0.48, green: 0.50, blue: 0.56)

    // MARK: - Akzente

    static let gold = Color(red: 0.86, green: 0.69, blue: 0.32)
    static let goldBright = Color(red: 0.96, green: 0.82, blue: 0.42)
    static let red = Color(red: 0.85, green: 0.26, blue: 0.24)
    static let green = Color(red: 0.38, green: 0.78, blue: 0.48)
    static let amber = Color(red: 0.95, green: 0.66, blue: 0.26)
    static let blue = Color(red: 0.37, green: 0.62, blue: 0.92)
    static let teal = Color(red: 0.30, green: 0.74, blue: 0.72)
    static let purple = Color(red: 0.62, green: 0.52, blue: 0.90)
    static let pink = Color(red: 0.90, green: 0.44, blue: 0.55)

    // MARK: - Deutschland-Flagge (dezenter Akzent)

    static let flagBlack = Color(red: 0.08, green: 0.08, blue: 0.09)
    static let flagRed = Color(red: 0.79, green: 0.16, blue: 0.14)
    static let flagGold = Color(red: 0.96, green: 0.80, blue: 0.20)

    static let goldGradient = LinearGradient(
        colors: [goldBright, gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Farbcodierung von Werten (0–100)

    /// Ampel-Farbe für einen Kennwert.
    static func statusColor(for value: Int) -> Color {
        switch value {
        case 67...:   return green
        case 50..<67: return gold
        case 34..<50: return amber
        default:      return red
        }
    }

    /// Qualitatives Label für einen Kennwert.
    static func statusLabel(for value: Int) -> String {
        switch value {
        case 82...:   return "Exzellent"
        case 67..<82: return "Stark"
        case 50..<67: return "Solide"
        case 40..<50: return "Wackelig"
        case 28..<40: return "Kritisch"
        default:      return "Alarm"
        }
    }
}

// MARK: - Karten-Container

struct PanelCardModifier: ViewModifier {
    var padding: CGFloat = 16
    var tint: Color? = nil

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(GameTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(tint?.opacity(0.35) ?? GameTheme.hairline, lineWidth: 1)
            )
    }
}

extension View {
    /// Standard-Karte im Design-System.
    func gameCard(padding: CGFloat = 16, tint: Color? = nil) -> some View {
        modifier(PanelCardModifier(padding: padding, tint: tint))
    }

    /// Rückwärtskompatibler Alias.
    func strategyPanel() -> some View {
        modifier(PanelCardModifier())
    }
}

// MARK: - Button-Stile

/// Große, goldene Primär-Aktion.
struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.05))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(GameTheme.goldGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: GameTheme.gold.opacity(configuration.isPressed ? 0.0 : 0.35), radius: 12, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Dezente Sekundär-Aktion (umrandet).
struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(GameTheme.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(GameTheme.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(GameTheme.hairlineStrong, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Interaktive Entscheidungs-Karte mit Press-Feedback.
struct OptionCardButtonStyle: ButtonStyle {
    var accent: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(configuration.isPressed ? GameTheme.surfaceElevated : GameTheme.surfaceSunken)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(accent)
                    .frame(width: 4)
                    .padding(.vertical, 12)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(configuration.isPressed ? accent.opacity(0.6) : GameTheme.hairline, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.75), value: configuration.isPressed)
    }
}
