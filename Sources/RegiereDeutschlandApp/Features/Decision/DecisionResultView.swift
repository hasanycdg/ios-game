import RegiereDeutschlandCore
import SwiftUI

struct DecisionResultView: View {
    let result: DecisionResult
    let onContinue: () -> Void

    @State private var showBackground = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(GameTheme.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Entscheidung umgesetzt")
                        .font(.headline)
                        .foregroundStyle(GameTheme.primaryText)
                    Text(result.optionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(GameTheme.gold)
                }
            }

            Text(result.resultText)
                .font(.callout)
                .foregroundStyle(GameTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            // Auswirkungen
            if !result.visibleEffects.isEmpty || result.approvalEffect != 0 {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "Direkte Auswirkungen", systemImage: "chart.bar.fill")
                    VStack(spacing: 8) {
                        ForEach(result.visibleEffects, id: \.metric) { effect in
                            let style = MetricPresentation.style(for: effect.metric)
                            DeltaRow(label: style.label, icon: style.icon, change: effect.change)
                        }
                        if result.approvalEffect != 0 {
                            DeltaRow(label: "Zustimmung", icon: "person.2.fill", change: result.approvalEffect)
                        }
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(GameTheme.surfaceSunken)
                )
            }

            // Dein Weg vs. die Realität
            if result.historicalReality != nil || result.historicalBackground != nil {
                historyComparison
            }

            Button(action: onContinue) {
                Label("Fortfahren", systemImage: "arrow.right")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
        .gameCard(padding: 18)
    }

    // MARK: Dein Weg vs. die Realität

    private var historyComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "clock.badge.checkmark").font(.caption)
                Text("Dein Weg & die Geschichte")
                    .font(.caption.weight(.bold))
                    .tracking(0.4)
                Spacer(minLength: 0)
                if result.didChooseHistoricalPath {
                    Text("historisch")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(GameTheme.gold)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(GameTheme.gold.opacity(0.15)))
                }
            }
            .foregroundStyle(GameTheme.purple)

            // Deine Entscheidung
            comparisonRow(
                marker: "person.fill",
                markerColor: GameTheme.gold,
                title: "Deine Entscheidung",
                text: result.optionTitle
            )

            // Was wirklich geschah
            if let historicalReality = result.historicalReality {
                comparisonRow(
                    marker: "building.columns.fill",
                    markerColor: GameTheme.secondaryText,
                    title: "In Wirklichkeit",
                    text: historicalReality
                )
            }

            // Hintergrund (aufklappbar)
            if let background = result.historicalBackground {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        showBackground.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.closed.fill").font(.caption2)
                        Text(showBackground ? "Hintergrund ausblenden" : "Historischer Hintergrund")
                            .font(.caption.weight(.semibold))
                        Image(systemName: showBackground ? "chevron.up" : "chevron.down")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(GameTheme.purple)
                }
                .buttonStyle(.plain)

                if showBackground {
                    Text(background)
                        .font(.footnote)
                        .foregroundStyle(GameTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(GameTheme.surfaceSunken)
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(GameTheme.purple.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(GameTheme.purple.opacity(0.3), lineWidth: 1)
        )
    }

    private func comparisonRow(marker: String, markerColor: Color, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: marker)
                .font(.caption.weight(.bold))
                .foregroundStyle(markerColor)
                .frame(width: 26, height: 26)
                .background(Circle().fill(markerColor.opacity(0.15)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(GameTheme.tertiaryText)
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(GameTheme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}
