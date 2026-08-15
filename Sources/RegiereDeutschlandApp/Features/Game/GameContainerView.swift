import RegiereDeutschlandCore
import SwiftUI

/// Container des laufenden Spiels: TabView mit geteiltem ViewModel plus
/// Vollbild-Overlays für Wahlabend und Game Over.
struct GameContainerView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0

    init(mode: GameViewModel.StartMode = .newGame,
         party: PlayerParty = PartyCatalog.default,
         playerName: String = PartyCatalog.defaultChancellorName) {
        _viewModel = StateObject(wrappedValue: GameViewModel(mode: mode, party: party, playerName: playerName))
    }

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()

            TabView(selection: $selectedTab) {
                SituationTab(viewModel: viewModel)
                    .tag(0)
                    .tabItem { Label("Lage", systemImage: "flag.fill") }

                PresseTab(viewModel: viewModel)
                    .tag(1)
                    .tabItem { Label("Presse", systemImage: "newspaper.fill") }

                DepartmentsTab(viewModel: viewModel)
                    .tag(2)
                    .tabItem { Label("Ressorts", systemImage: "chart.bar.fill") }

                PolitikTab(viewModel: viewModel)
                    .tag(3)
                    .tabItem { Label("Politik", systemImage: "building.columns.fill") }

                DiplomacyTab(viewModel: viewModel)
                    .tag(4)
                    .tabItem { Label("Welt", systemImage: "globe.europe.africa.fill") }
            }
            .tint(GameTheme.gold)

            overlay
        }
        .background(GameTheme.background.ignoresSafeArea())
        .foregroundStyle(GameTheme.primaryText)
        .navigationTitle("Regieren")
        .inlineNavigationTitle()
        .toolbar { toolbarContent }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active { viewModel.saveNow() }
        }
    }

    // MARK: Overlays (Wahlabend / Game Over)

    @ViewBuilder
    private var overlay: some View {
        switch viewModel.phase {
        case .encounter:
            if let encounter = viewModel.pendingEncounter {
                EncounterView(encounter: encounter) { optionID in
                    withAnimation(.easeInOut) { viewModel.resolveEncounter(optionID) }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        case .campaign:
            CampaignView(year: viewModel.state.currentYear, state: viewModel.state) { focus in
                withAnimation(.easeInOut) { viewModel.runCampaign(focus) }
            }
            .transition(.opacity)
            .zIndex(1)
        case .coalitionTalks:
            if let options = viewModel.pendingCoalitionOptions {
                CoalitionTalksView(
                    year: viewModel.state.currentYear,
                    options: options,
                    isInitial: viewModel.isFormingInitialGovernment,
                    playerPartyName: viewModel.playerParty.name
                ) { optionID in
                    withAnimation(.easeInOut) { viewModel.formCoalition(optionID) }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        case .briefing:
            SituationBriefingView(
                year: viewModel.state.currentYear,
                playerName: viewModel.playerName,
                party: viewModel.playerParty,
                state: viewModel.state,
                governanceIndex: viewModel.governanceIndex,
                nationMood: viewModel.nationMood,
                nextElectionYear: viewModel.electionProjection.nextElectionYear
            ) {
                withAnimation(.easeInOut) { viewModel.dismissBriefing() }
            }
            .transition(.opacity)
            .zIndex(1)
        case .coalitionNegotiation:
            if let talks = viewModel.pendingCoalitionTalks {
                CoalitionNegotiationView(negotiation: talks) { acceptedIDs in
                    withAnimation(.easeInOut) { viewModel.concludeCoalitionTalks(accepted: acceptedIDs) }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        case .election(let election):
            ElectionResultPanel(election: election, parties: viewModel.partyLandscape.parties) {
                withAnimation(.easeInOut) { viewModel.continueAfterElection() }
            }
            .transition(.opacity)
            .zIndex(1)
        case .gameOver(let summary):
            GameOverPanel(
                summary: summary,
                achievements: viewModel.newlyUnlockedAchievements,
                onNewGame: {
                    withAnimation(.easeInOut) {
                        selectedTab = 0
                        viewModel.startNewGame()
                    }
                },
                onExitToMenu: { dismiss() }
            )
            .transition(.opacity)
            .zIndex(1)
        default:
            EmptyView()
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button {
                    dismiss()
                } label: {
                    Label("Hauptmenü", systemImage: "house")
                }
                #if DEBUG
                Divider()
                DebugMenu(viewModel: viewModel)
                #endif
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(GameTheme.gold)
            }
        }
    }
}

#if DEBUG
private struct DebugMenu: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        Section("Debug") {
            Button("Jahr +1") { viewModel.debugJumpForwardOneYear() }
            Button("Wirtschaft +5") { viewModel.debugBoostEconomy() }
            Button("Vertrauen -5") { viewModel.debugReduceTrust() }
            Button("Erstes Event triggern") { viewModel.debugTriggerCurrentYearFirstEvent() }
            Button("Balancing-Simulation") { viewModel.debugRunBalanceSimulation() }
        }
    }
}
#endif
