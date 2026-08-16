import RegiereDeutschlandCore
import SwiftUI

/// Kompakte, teilbare Ergebnis-Karte. Wird per ImageRenderer zu einem Bild.
struct ShareCardView: View {
    let summary: GameOverSummary

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                FlagRibbon(height: 5).frame(width: 64)
                Spacer(minLength: 0)
                Text("REGIERE DEUTSCHLAND")
                    .font(.system(size: 10, weight: .bold)).tracking(1.4)
                    .foregroundStyle(GameTheme.secondaryText)
            }

            VStack(spacing: 4) {
                Text("MEIN DEUTSCHLAND")
                    .font(.caption.weight(.bold)).tracking(2)
                    .foregroundStyle(GameTheme.gold)
                Text(verbatim: "\(summary.startYear)–\(summary.endYear)")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(GameTheme.primaryText)
            }

            VStack(spacing: 2) {
                Text("\(summary.score)")
                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                    .foregroundStyle(GameTheme.gold).monospacedDigit()
                Text("PUNKTE")
                    .font(.caption2.weight(.bold)).tracking(2.5)
                    .foregroundStyle(GameTheme.secondaryText)
            }

            Text(summary.governingStyle)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.05))
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(Capsule().fill(GameTheme.goldGradient))
                .multilineTextAlignment(.center)

            VStack(spacing: 7) {
                ForEach(VisibleMetric.allCases, id: \.self) { metric in
                    let style = MetricPresentation.style(for: metric)
                    let value = summary.finalStats.value(for: metric)
                    HStack(spacing: 8) {
                        Image(systemName: style.icon).font(.caption2)
                            .foregroundStyle(GameTheme.secondaryText).frame(width: 16)
                        Text(style.label).font(.caption2).foregroundStyle(GameTheme.primaryText)
                            .frame(width: 92, alignment: .leading)
                        ValueBar(value: value, height: 6)
                        Text("\(value)").font(.caption2.weight(.bold))
                            .foregroundStyle(GameTheme.statusColor(for: value)).monospacedDigit()
                            .frame(width: 22, alignment: .trailing)
                    }
                }
            }

            Text("Deutschland 2000–2026, aber diesmal entscheidest DU.")
                .font(.system(size: 10))
                .foregroundStyle(GameTheme.tertiaryText)
        }
        .padding(24)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(GameTheme.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(GameTheme.gold.opacity(0.3), lineWidth: 1)
        )
    }
}
