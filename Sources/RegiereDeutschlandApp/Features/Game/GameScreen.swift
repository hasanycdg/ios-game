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
                case .noEvent:
                    ContentUnavailableView(
                        "Keine Ereignisse",
                        systemImage: "calendar",
                        description: Text("Fuer das Jahr \(viewModel.state.currentYear) ist noch kein Event hinterlegt.")
                    )
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
