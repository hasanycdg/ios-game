import RegiereDeutschlandCore
import SwiftUI

struct GameOverPanel: View {
    let summary: GameOverSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(summary.message)
                .font(.title2.bold())

            Text("\(summary.startYear)-\(summary.endYear)")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(summary.governingStyle)
                .font(.headline)

            if !summary.defeatReasons.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hauptgruende")
                        .font(.headline)
                    ForEach(summary.defeatReasons, id: \.self) { reason in
                        Text("- \(reason)")
                    }
                }
                .foregroundStyle(.secondary)
            }

            if !summary.keyDecisionTitles.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Wichtigste Entscheidungen")
                        .font(.headline)
                    ForEach(summary.keyDecisionTitles, id: \.self) { title in
                        Text("- \(title)")
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
