import RegiereDeutschlandCore
import SwiftUI

/// Chronik-Tab: Timeline der bisherigen Amtszeit.
struct ChronicleTab: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                summaryHeader

                let items = viewModel.timeline
                if items.isEmpty {
                    EmptyStateView(
                        icon: "book.pages",
                        title: "Deine Amtszeit beginnt",
                        message: "Noch keine Entscheidungen getroffen. Deine Geschichte wird hier festgehalten."
                    )
                    .gameCard()
                } else {
                    SectionHeader(title: "Verlauf", systemImage: "list.bullet.rectangle")
                    VStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            TimelineRow(item: item, isLast: index == items.count - 1)
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }

    private var summaryHeader: some View {
        HStack(spacing: 12) {
            summaryTile(value: "\(viewModel.state.decisions.count)", label: "Entscheidungen", icon: "checkmark.circle.fill", color: GameTheme.gold)
            summaryTile(value: "\(viewModel.wonElectionsCount)", label: "Wahlsiege", icon: "checkmark.seal.fill", color: GameTheme.green)
            summaryTile(value: "\(viewModel.state.triggeredHistoricalEchoes.count)", label: "Echos", icon: "clock.arrow.circlepath", color: GameTheme.purple)
        }
    }

    private func summaryTile(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.footnote.weight(.bold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(GameTheme.primaryText)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(GameTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .gameCard(padding: 14)
    }
}

/// Eine Zeile der Timeline mit vertikaler Schiene.
private struct TimelineRow: View {
    let item: TimelineItem
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(item.color.opacity(0.18))
                        .frame(width: 32, height: 32)
                    Image(systemName: item.icon)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(item.color)
                }
                if !isLast {
                    Rectangle()
                        .fill(GameTheme.hairlineStrong)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(GameTheme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 8)
                    Text(String(item.year))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(item.color)
                        .monospacedDigit()
                }
                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(GameTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(GameTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(GameTheme.hairline, lineWidth: 1)
            )
            .padding(.bottom, isLast ? 0 : 12)
        }
    }
}
