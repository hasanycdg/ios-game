import RegiereDeutschlandCore
import SwiftUI

// MARK: - Nachrichten-Karte

struct NewsCard: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let item: NewsItem

    var body: some View {
        let scope = NewsPresentation.style(for: item.scope)
        let category = CategoryPresentation.style(for: item.category)

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(L(scope.label))
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
                    Text(L(source))
                        .font(.caption2)
                        .foregroundStyle(GameTheme.tertiaryText)
                }
            }

            Text(L(item.headline))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(GameTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            if !item.summary.isEmpty {
                Text(L(item.summary))
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

struct CapitalBadge: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let value: Int
    let maximum: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "hexagon.fill")
                .font(.caption2)
                .foregroundStyle(GameTheme.gold)
            Text(L("Kapital"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(GameTheme.secondaryText)
                .lineLimit(1)
                .fixedSize()
            Text(L("\(L(value))/\(L(maximum))"))
                .font(.caption.weight(.bold))
                .foregroundStyle(GameTheme.gold)
                .monospacedDigit()
                .lineLimit(1)
                .fixedSize()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(GameTheme.gold.opacity(0.14)))
        .accessibilityLabel(L("Politisches Kapital: \(L(value)) von \(L(maximum))"))
    }
}

// MARK: - Koalition

struct CoalitionCard: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let coalition: CoalitionState

    private var color: Color { GameTheme.statusColor(for: coalition.satisfaction) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(GameTheme.gold)
                Text(L("KOALITION"))
                    .font(.caption.weight(.bold)).tracking(1.2)
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer(minLength: 0)
                Text(L(coalition.moodLabel))
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(color)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(color.opacity(0.16)))
            }

            HStack(spacing: 6) {
                Text(L(coalition.partnerName))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(GameTheme.primaryText)
                Text(L("· \(L(coalition.leaning.displayName))"))
                    .font(.caption)
                    .foregroundStyle(GameTheme.tertiaryText)
                Spacer(minLength: 0)
                Text(L("\(L(coalition.satisfaction))"))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .monospacedDigit()
            }

            ValueBar(value: coalition.satisfaction, height: 7)

            if coalition.satisfaction < 30 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.caption2)
                    Text(L("Der Partner droht mit dem Koalitionsbruch – dann kommt es zur Neuwahl."))
                        .font(.caption2.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(GameTheme.red)
            }
        }
        .gameCard(padding: 16, tint: coalition.satisfaction < 30 ? GameTheme.red : nil)
    }
}

// MARK: - Sitzverteilung im Bundestag

struct SeatDistributionBar: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let election: ElectionResult

    private let totalSeats = 630
    private var gov: Double { election.governingPartyShare }
    private var opp: Double { election.oppositionShare }
    private var rest: Double { max(0, 100 - gov - opp) }

    private func seats(_ share: Double) -> Int { Int((share / 100 * Double(totalSeats)).rounded()) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: L("Sitzverteilung im Bundestag"), systemImage: "building.columns.fill",
                          accessory: L("\(L(totalSeats)) Sitze"))

            GeometryReader { geo in
                HStack(spacing: 2) {
                    segment(width: geo.size.width * CGFloat(gov / 100), color: GameTheme.gold)
                    segment(width: geo.size.width * CGFloat(opp / 100), color: GameTheme.blue)
                    segment(width: geo.size.width * CGFloat(rest / 100), color: GameTheme.tertiaryText)
                }
            }
            .frame(height: 14)
            .clipShape(Capsule())

            VStack(spacing: 8) {
                legendRow(name: L("Deine Koalition"), share: gov, color: GameTheme.gold)
                legendRow(name: L("Opposition"), share: opp, color: GameTheme.blue)
                legendRow(name: L("Weitere Parteien"), share: rest, color: GameTheme.tertiaryText)
            }
        }
        .gameCard(padding: 16)
    }

    private func segment(width: CGFloat, color: Color) -> some View {
        Rectangle().fill(color).frame(width: max(0, width))
    }

    private func legendRow(name: String, share: Double, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 9, height: 9)
            Text(L(name)).font(.caption).foregroundStyle(GameTheme.secondaryText)
            Spacer(minLength: 0)
            Text(L("\(L(seats(share))) Sitze"))
                .font(.caption.weight(.semibold)).foregroundStyle(GameTheme.primaryText).monospacedDigit()
            Text(L(String(format: L("%.1f %%"), share)))
                .font(.caption2).foregroundStyle(GameTheme.tertiaryText).monospacedDigit()
                .frame(width: 48, alignment: .trailing)
        }
    }
}

// MARK: - Schattenkonto (Korruption)

struct ShadowFundsCard: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let corruption: Int

    private var risk: (label: String, color: Color) {
        switch corruption {
        case 45...:   (L("hoch"), GameTheme.red)
        case 25..<45: (L("erhöht"), GameTheme.amber)
        default:      (L("gering"), GameTheme.gold)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "eye.slash.fill")
                    .font(.footnote.weight(.bold)).foregroundStyle(GameTheme.red)
                Text(L("SCHATTENKONTO"))
                    .font(.caption.weight(.bold)).tracking(1.2)
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer(minLength: 0)
                HStack(spacing: 4) {
                    Text(L("Skandalrisiko"))
                        .font(.caption2).foregroundStyle(GameTheme.tertiaryText)
                    Text(L(risk.label))
                        .font(.caption2.weight(.heavy)).foregroundStyle(risk.color)
                }
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(risk.color.opacity(0.16)))
            }
            ValueBar(value: corruption, height: 7, color: GameTheme.red)
            Text(L("Verdeckte Zuwendungen verschaffen dir Spielraum – doch je größer das Schattenkonto, desto eher fliegt der Skandal auf."))
                .font(.caption2)
                .foregroundStyle(GameTheme.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .gameCard(padding: 16, tint: GameTheme.red)
    }
}

// MARK: - Wahlbarometer ("Sonntagsfrage")

struct ElectionBarometer: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let projection: ElectionProjection
    let currentYear: Int

    private var accent: Color { projection.wouldWin ? GameTheme.green : GameTheme.red }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(GameTheme.gold)
                Text(L("SONNTAGSFRAGE"))
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer(minLength: 0)
                HStack(spacing: 4) {
                    Image(systemName: projection.wouldWin ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.caption2.weight(.bold))
                    Text(L(projection.wouldWin ? L("Vorn") : L("Hinten")))
                        .font(.caption2.weight(.heavy))
                }
                .foregroundStyle(accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(accent.opacity(0.16)))
            }

            Text(L(projection.wouldWin ? L("Bei einer Wahl heute bliebe deine Regierung im Amt.") : L("Bei einer Wahl heute würdest du abgewählt.")))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(GameTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                shareRow(title: L("Deine Partei"), value: projection.governingShare, color: GameTheme.gold, emphasised: true)
                shareRow(title: L("Stärkste Opposition"), value: projection.oppositionShare, color: GameTheme.secondaryText, emphasised: false)
            }

            Divider().overlay(GameTheme.hairline)

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundStyle(GameTheme.tertiaryText)
                Text(L(nextElectionText))
                    .font(.caption)
                    .foregroundStyle(GameTheme.secondaryText)
            }
        }
        .gameCard(padding: 16, tint: accent)
    }

    private var nextElectionText: String {
        guard let next = projection.nextElectionYear else {
            return L("Keine weitere Bundestagswahl vorgesehen.")
        }
        if next == currentYear {
            return L("Wahljahr – die Bundestagswahl steht an!")
        }
        let years = next - currentYear
        return L("Nächste Bundestagswahl: \(L(String(next))) (in \(L(years)) \(L(years == 1 ? L("Jahr") : L("Jahren")))).")
    }

    private func shareRow(title: String, value: Double, color: Color, emphasised: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(L(title))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer()
                Text(L(String(format: L("%.1f %%"), value)))
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
