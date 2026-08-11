import RegiereDeutschlandCore
import SwiftUI

struct DecisionResultView: View {
    let result: DecisionResult
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Entscheidung umgesetzt")
                .font(.title2.bold())

            Text(result.optionTitle)
                .font(.headline)

            Text(result.resultText)
                .font(.body)
                .foregroundStyle(.secondary)

            if !result.visibleEffects.isEmpty || result.approvalEffect != 0 {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(result.visibleEffects, id: \.metric) { effect in
                        Text("\(displayName(for: effect.metric)): \(signed(effect.change))")
                    }

                    if result.approvalEffect != 0 {
                        Text("Zustimmung: \(signed(result.approvalEffect))")
                    }
                }
                .font(.callout.weight(.medium))
            }

            Button(action: onContinue) {
                Text("Fortfahren")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func signed(_ value: Int) -> String {
        value > 0 ? "+\(value)" : "\(value)"
    }

    private func displayName(for metric: VisibleMetric) -> String {
        switch metric {
        case .economy: "Wirtschaft"
        case .budget: "Haushalt"
        case .livingStandard: "Lebensstandard"
        case .society: "Gesellschaft"
        case .security: "Sicherheit"
        case .energy: "Energie"
        case .internationalRelations: "International"
        case .trust: "Vertrauen"
        }
    }
}
