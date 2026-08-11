import RegiereDeutschlandCore
import SwiftUI

struct GameOverPanel: View {
    let summary: GameOverSummary
    let onNewGame: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(summary.message)
                .font(.title2.bold())

            Text("\(summary.startYear)-\(summary.endYear)")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(summary.governingStyle)
                .font(.headline)

            Text("Score \(summary.score)")
                .font(.title3.bold())
                .foregroundStyle(GameTheme.gold)

            VStack(alignment: .leading, spacing: 6) {
                Text("Endbericht")
                    .font(.headline)
                Text("Gewonnene Wahlen: \(summary.wonElectionCount)")
                Text("Groesster Erfolg: \(summary.biggestSuccess)")
                Text("Groesste Schwachstelle: \(summary.biggestMistake)")
                Text("Butterfly Effect: \(summary.biggestButterflyEffect)")
                Text("Abweichung: \(summary.strongestHistoricalDeviation)")
            }
            .font(.callout)
            .foregroundStyle(.secondary)

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

            Button(action: onNewGame) {
                Text("Neues Spiel")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .strategyPanel()
    }
}
