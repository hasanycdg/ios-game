import RegiereDeutschlandCore
import SwiftUI

struct EventPanel: View {
    let event: GameEvent
    let onChoose: (DecisionOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.title2.bold())
                Text(event.headline)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(event.description)
                    .font(.body)
            }

            Text(event.historicalContext.summary)
                .font(.callout)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(event.options) { option in
                    Button {
                        onChoose(option)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(option.title)
                                .font(.headline)
                            Text(option.advisoryNote)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityHint(option.advisoryNote)
                }
            }
        }
        .strategyPanel()
    }
}
