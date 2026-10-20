import RegiereDeutschlandCore
import SwiftUI

/// Container des laufenden Spiels: TabView mit geteiltem ViewModel plus
/// Vollbild-Overlays für Wahlabend und Game Over.
struct GameContainerView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PurchaseManager.self) private var purchases
    @State private var selectedTab = 0
    @State private var campaignPaywall: CampaignPaywallPlacement?

    init(mode: GameViewModel.StartMode = .newGame,
         party: PlayerParty = PartyCatalog.default,
         playerName: String = PartyCatalog.defaultChancellorName,
         difficulty: Difficulty = .normal,
         finalYear: Int = 2026) {
        _viewModel = StateObject(wrappedValue: GameViewModel(mode: mode, party: party, playerName: playerName, difficulty: difficulty, finalYear: finalYear))
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
        .onAppear(perform: synchronizeCampaignAccess)
        .onChange(of: purchases.campaignAccess) { _, _ in
            synchronizeCampaignAccess()
        }
        .sheet(item: $campaignPaywall) { placement in
            CampaignPaywallView(placement: placement)
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
                programResults: viewModel.programResults,
                partyName: viewModel.playerParty.name,
                continuationTitle: continuationTitle(for: summary),
                onContinueCampaign: summary.reason == .reachedFinalYear ? continueCampaign : nil,
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

    private func continuationTitle(for summary: GameOverSummary) -> String? {
        guard summary.reason == .reachedFinalYear else { return nil }
        switch viewModel.finalYear {
        case 2004:
            return purchases.hasCampaign2005 ? "Amtszeit ab 2005 fortsetzen" : "Kampagne 2005–2026 freischalten"
        case 2026:
            return purchases.hasFuture2050 ? "Mit Zukunft 2050 fortsetzen" : "Zukunft 2050 freischalten"
        default:
            return nil
        }
    }

    private func continueCampaign() {
        if purchases.campaignAccess.continuationFinalYear(after: viewModel.finalYear) != nil {
            synchronizeCampaignAccess()
            return
        }
        switch viewModel.finalYear {
        case 2004:
            campaignPaywall = .afterPrologue
        case 2026:
            campaignPaywall = .afterMainCampaign
        default:
            break
        }
    }

    private func synchronizeCampaignAccess() {
        guard let finalYear = purchases.campaignAccess.continuationFinalYear(after: viewModel.finalYear) else { return }
        withAnimation(.easeInOut) { viewModel.extendCampaign(to: finalYear) }
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
