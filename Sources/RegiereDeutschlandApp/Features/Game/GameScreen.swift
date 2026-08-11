import RegiereDeutschlandCore
import SwiftUI

struct GameScreen: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                StatGrid(state: viewModel.state)

                switch viewModel.phase {
                case .event:
                    if let event = viewModel.currentEvent {
                        EventPanel(event: event) { option in
                            viewModel.choose(option)
                        }
                    }
                case .result(let result):
                    DecisionResultView(result: result) {
                        viewModel.continueAfterResult()
                    }
                case .election(let election):
                    ElectionResultPanel(election: election) {
                        viewModel.continueAfterElection()
                    }
                case .gameOver(let summary):
                    GameOverPanel(summary: summary)
                case .noEvent:
                    NoEventPanel(year: viewModel.state.currentYear) {
                        viewModel.continueWithoutEvent()
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Regierung")
        .inlineNavigationTitle()
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Jahr")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.state.currentYear)")
                    .font(.title.bold())
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Zustimmung")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.state.governmentApproval)")
                    .font(.title2.bold())
            }
        }
    }
}

private struct NoEventPanel: View {
    let year: Int
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Keine Ereignisse", systemImage: "calendar")
                .font(.title3.bold())
            Text("Fuer das Jahr \(year) ist noch kein Event hinterlegt.")
                .foregroundStyle(.secondary)
            Button(action: onContinue) {
                Text("Jahr abschliessen")
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
}
