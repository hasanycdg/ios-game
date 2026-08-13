import RegiereDeutschlandCore
import SwiftUI

/// Volk-Tab: Zufriedenheit der Bevölkerungsgruppen.
struct PeopleTab: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                moodHeader

                if let happiest = viewModel.happiestGroup, let unhappiest = viewModel.unhappiestGroup {
                    HStack(spacing: 12) {
                        highlightCard(title: "Stärkster Rückhalt", group: happiest, positive: true)
                        highlightCard(title: "Größter Unmut", group: unhappiest, positive: false)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Bevölkerungsgruppen", systemImage: "person.3.fill",
                                  accessory: "nach Anteil")
                    VStack(spacing: 10) {
                        ForEach(viewModel.populationGroupsBySize) { group in
                            GroupRow(group: group)
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }

    private var moodHeader: some View {
        let weighted = viewModel.weightedPopulationApproval
        return HStack(spacing: 16) {
            ApprovalRing(value: weighted, size: 96, caption: "Volk")
            VStack(alignment: .leading, spacing: 8) {
                Text("Stimmung im Land")
                    .font(.headline)
                    .foregroundStyle(GameTheme.primaryText)
                Text("Die Bevölkerung ist im Schnitt \(NationMood.moodWord(forApproval: weighted)).")
                    .font(.caption)
                    .foregroundStyle(GameTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Gewichtet nach Bevölkerungsanteil.")
                    .font(.caption2)
                    .foregroundStyle(GameTheme.tertiaryText)
            }
            Spacer(minLength: 0)
        }
        .gameCard(padding: 18)
    }

    private func highlightCard(title: String, group: PopulationGroup, positive: Bool) -> some View {
        let color = positive ? GameTheme.green : GameTheme.red
        return VStack(alignment: .leading, spacing: 6) {
            Image(systemName: positive ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                .font(.footnote.weight(.bold))
                .foregroundStyle(color)
            Text(title)
                .font(.caption2.weight(.bold))
                .tracking(0.4)
                .foregroundStyle(GameTheme.tertiaryText)
            Text(group.name)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(GameTheme.primaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(group.approval) %")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .gameCard(padding: 14, tint: color)
    }
}

/// Zeile für eine Bevölkerungsgruppe.
private struct GroupRow: View {
    let group: PopulationGroup

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: NationMood.moodEmoji(forApproval: group.approval))
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(GameTheme.statusColor(for: group.approval))
                    .frame(width: 24)
                Text(group.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(GameTheme.primaryText)
                Spacer(minLength: 0)
                Text("\(Int((group.populationShare * 100).rounded())) %")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(GameTheme.tertiaryText)
                Text("\(group.approval)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.statusColor(for: group.approval))
                    .monospacedDigit()
                    .frame(width: 30, alignment: .trailing)
            }
            ValueBar(value: group.approval, height: 7)
        }
        .gameCard(padding: 14)
    }
}
