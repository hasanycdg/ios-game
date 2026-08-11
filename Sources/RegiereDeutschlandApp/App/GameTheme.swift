import SwiftUI

enum GameTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.05, blue: 0.055),
            Color(red: 0.11, green: 0.10, blue: 0.09)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let panel = Color(red: 0.14, green: 0.14, blue: 0.145)
    static let panelStroke = Color(red: 0.78, green: 0.63, blue: 0.28).opacity(0.35)
    static let primaryText = Color(red: 0.96, green: 0.95, blue: 0.91)
    static let secondaryText = Color(red: 0.72, green: 0.71, blue: 0.68)
    static let gold = Color(red: 0.82, green: 0.65, blue: 0.28)
    static let red = Color(red: 0.72, green: 0.16, blue: 0.14)
}

struct StrategyPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(GameTheme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(GameTheme.panelStroke, lineWidth: 1)
            )
    }
}

extension View {
    func strategyPanel() -> some View {
        modifier(StrategyPanelModifier())
    }
}
