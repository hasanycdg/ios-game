import RegiereDeutschlandCore
import SwiftUI

struct DecisionResultView: View {
    let result: DecisionResult
    let onContinue: () -> Void

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

            // Was geschah wirklich?
            if let historicalReality = result.historicalReality {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.badge.checkmark").font(.caption)
                        Text(result.didChooseHistoricalPath ? "Du bist dem historischen Pfad gefolgt" : "Was geschah wirklich?")
                            .font(.caption.weight(.bold))
                            .tracking(0.4)
                    }
                    .foregroundStyle(GameTheme.purple)
                    Text(historicalReality)
                        .font(.footnote)
                        .foregroundStyle(GameTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
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

            Button(action: onContinue) {
                Label("Fortfahren", systemImage: "arrow.right")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
        .gameCard(padding: 18)
    }
}
