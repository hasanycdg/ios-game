import RegiereDeutschlandCore
import SwiftUI

struct StatGrid: View {
    let state: GameState

    private var stats: [(String, Int)] {
        [
            ("Wirtschaft", state.visible.economy),
            ("Haushalt", state.visible.budget),
            ("Lebensstandard", state.visible.livingStandard),
            ("Gesellschaft", state.visible.society),
            ("Sicherheit", state.visible.security),
            ("Energie", state.visible.energy),
            ("International", state.visible.internationalRelations),
            ("Vertrauen", state.visible.trust)
        ]
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 12)], spacing: 12) {
            ForEach(stats, id: \.0) { title, value in
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ProgressView(value: Double(value), total: 100)
                    Text("\(value)")
                        .font(.headline)
                }
                .padding(12)
                .background(GameTheme.panel.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(GameTheme.panelStroke, lineWidth: 1)
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(title): \(value) von 100")
            }
        }
    }
}
