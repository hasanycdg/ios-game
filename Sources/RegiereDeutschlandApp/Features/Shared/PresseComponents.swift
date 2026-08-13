import RegiereDeutschlandCore
import SwiftUI

// MARK: - Nachrichten-Karte

struct NewsCard: View {
    let item: NewsItem

    var body: some View {
        let scope = NewsPresentation.style(for: item.scope)
        let category = CategoryPresentation.style(for: item.category)

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(scope.label)
                    .font(.system(size: 9.5, weight: .heavy))
                    .tracking(0.6)
                    .foregroundStyle(scope.color)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(scope.color.opacity(0.16)))
                Image(systemName: category.icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(category.color)
                Spacer(minLength: 0)
                if let source = item.source {
                    Text(source)
                        .font(.caption2)
                        .foregroundStyle(GameTheme.tertiaryText)
                }
            }

            Text(item.headline)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(GameTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            if !item.summary.isEmpty {
                Text(item.summary)
                    .font(.footnote)
                    .foregroundStyle(GameTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(GameTheme.surface)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(category.color)
                .frame(width: 3)
                .padding(.vertical, 10)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(GameTheme.hairline, lineWidth: 1)
        )
    }
}

// MARK: - Politisches Kapital

struct CapitalBadge: View {
    let value: Int
    let maximum: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "hexagon.fill")
                .font(.caption2)
                .foregroundStyle(GameTheme.gold)
            Text("Kapital")
                .font(.caption.weight(.semibold))
                .foregroundStyle(GameTheme.secondaryText)
                .lineLimit(1)
                .fixedSize()
            Text("\(value)/\(maximum)")
                .font(.caption.weight(.bold))
                .foregroundStyle(GameTheme.gold)
                .monospacedDigit()
                .lineLimit(1)
                .fixedSize()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(GameTheme.gold.opacity(0.14)))
        .accessibilityLabel("Politisches Kapital: \(value) von \(maximum)")
    }
}

// MARK: - Koalition

struct CoalitionCard: View {
    let coalition: CoalitionState

    private var color: Color { GameTheme.statusColor(for: coalition.satisfaction) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(GameTheme.gold)
                Text("KOALITION")
                    .font(.caption.weight(.bold)).tracking(1.2)
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer(minLength: 0)
                Text(coalition.moodLabel)
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(color)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(color.opacity(0.16)))
            }

            HStack(spacing: 6) {
                Text(coalition.partnerName)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(GameTheme.primaryText)
                Text("· \(coalition.leaning.displayName)")
                    .font(.caption)
                    .foregroundStyle(GameTheme.tertiaryText)
                Spacer(minLength: 0)
                Text("\(coalition.satisfaction)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .monospacedDigit()
            }

            ValueBar(value: coalition.satisfaction, height: 7)

            if coalition.satisfaction < 30 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.caption2)
                    Text("Der Partner droht mit dem Koalitionsbruch – dann kommt es zur Neuwahl.")
                        .font(.caption2.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(GameTheme.red)
            }
        }
        .gameCard(padding: 16, tint: coalition.satisfaction < 30 ? GameTheme.red : nil)
    }
}

// MARK: - Wahlbarometer ("Sonntagsfrage")

struct ElectionBarometer: View {
    let projection: ElectionProjection
    let currentYear: Int

    private var accent: Color { projection.wouldWin ? GameTheme.green : GameTheme.red }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(GameTheme.gold)
                Text("SONNTAGSFRAGE")
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer(minLength: 0)
                HStack(spacing: 4) {
                    Image(systemName: projection.wouldWin ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.caption2.weight(.bold))
                    Text(projection.wouldWin ? "Vorn" : "Hinten")
                        .font(.caption2.weight(.heavy))
                }
                .foregroundStyle(accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(accent.opacity(0.16)))
            }

            Text(projection.wouldWin ? "Bei einer Wahl heute bliebe deine Regierung im Amt." : "Bei einer Wahl heute würdest du abgewählt.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(GameTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                shareRow(title: "Deine Partei", value: projection.governingShare, color: GameTheme.gold, emphasised: true)
                shareRow(title: "Stärkste Opposition", value: projection.oppositionShare, color: GameTheme.secondaryText, emphasised: false)
            }

            Divider().overlay(GameTheme.hairline)

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundStyle(GameTheme.tertiaryText)
                Text(nextElectionText)
                    .font(.caption)
                    .foregroundStyle(GameTheme.secondaryText)
            }
        }
        .gameCard(padding: 16, tint: accent)
    }

    private var nextElectionText: String {
        guard let next = projection.nextElectionYear else {
            return "Keine weitere Bundestagswahl vorgesehen."
        }
        if next == currentYear {
            return "Wahljahr – die Bundestagswahl steht an!"
        }
        let years = next - currentYear
        return "Nächste Bundestagswahl: \(String(next)) (in \(years) \(years == 1 ? "Jahr" : "Jahren"))."
    }

    private func shareRow(title: String, value: Double, color: Color, emphasised: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer()
                Text(String(format: "%.1f %%", value))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(emphasised ? GameTheme.primaryText : GameTheme.secondaryText)
                    .monospacedDigit()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(GameTheme.surfaceSunken)
                    Capsule()
                        .fill(color)
                        .frame(width: max(6, geo.size.width * CGFloat(min(value, 60) / 60)))
                }
            }
            .frame(height: 9)
        }
    }
}
