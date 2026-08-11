import RegiereDeutschlandCore
import SwiftUI

struct ElectionResultPanel: View {
    let election: ElectionResult
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bundestagswahl \(election.year)")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 10) {
                resultRow(title: "Eigene Partei", value: election.governingPartyShare)
                resultRow(title: "Wichtigste Opposition", value: election.oppositionShare)
            }

            Text(election.didWin ? "Die Regierung bleibt im Amt." : "Deine Regierung wurde abgewaehlt.")
                .font(.headline)
                .foregroundStyle(election.didWin ? .green : .red)

            if !election.reasons.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(election.reasons, id: \.self) { reason in
                        Text("- \(reason)")
                    }
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }

            Button(action: onContinue) {
                Text(election.didWin ? "Weiterregieren" : "Auswertung ansehen")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .strategyPanel()
    }

    private func resultRow(title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: "%.1f %%", value))
                    .fontWeight(.semibold)
            }
            ProgressView(value: value, total: 60)
        }
    }
}
