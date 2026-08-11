import RegiereDeutschlandCore
import SwiftUI

struct GameScreen: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(mode: GameViewModel.StartMode = .newGame) {
        _viewModel = StateObject(wrappedValue: GameViewModel(mode: mode))
    }

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
                    GameOverPanel(summary: summary) {
                        viewModel.startNewGame()
                    }
                case .noEvent:
                    NoEventPanel(year: viewModel.state.currentYear) {
                        viewModel.continueWithoutEvent()
                    }
                }

                #if DEBUG
                DebugPanel(viewModel: viewModel)
                #endif
            }
            .padding(20)
        }
        .background(GameTheme.background.ignoresSafeArea())
        .foregroundStyle(GameTheme.primaryText)
        .navigationTitle("Regierung")
        .inlineNavigationTitle()
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                viewModel.saveNow()
            }
        }
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

#if DEBUG
private struct DebugPanel: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Button("Jahr +1") { viewModel.debugJumpForwardOneYear() }
                    Button("Wirtschaft +5") { viewModel.debugBoostEconomy() }
                    Button("Vertrauen -5") { viewModel.debugReduceTrust() }
                }
                .buttonStyle(.bordered)

                Button("Erstes Event dieses Jahres triggern") {
                    viewModel.debugTriggerCurrentYearFirstEvent()
                }
                .buttonStyle(.bordered)

                hiddenMetricGrid

                Button("Balancing-Simulation ausfuehren") {
                    viewModel.debugRunBalanceSimulation()
                }
                .buttonStyle(.borderedProminent)

                if !viewModel.balanceSummaryText.isEmpty {
                    Text(viewModel.balanceSummaryText)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)
        } label: {
            Label("Debug", systemImage: "hammer")
                .font(.headline)
        }
        .strategyPanel()
    }

    private var hiddenMetricGrid: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Versteckte Werte")
                .font(.headline)
            Text("Erneuerbare \(viewModel.state.hidden.renewableCapacity) | Atom \(viewModel.state.hidden.nuclearCapacity) | Russland-Energie \(viewModel.state.hidden.russianEnergyDependency)")
            Text("Digitalisierung \(viewModel.state.hidden.digitalization) | Infrastruktur \(viewModel.state.hidden.infrastructureQuality) | Polarisierung \(viewModel.state.hidden.polarization)")
            Text("Fiskalspielraum \(viewModel.state.hidden.fiscalSpace) | Verteidigung \(viewModel.state.hidden.defenceReadiness)")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
    }
}
#endif

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
        .strategyPanel()
    }
}
