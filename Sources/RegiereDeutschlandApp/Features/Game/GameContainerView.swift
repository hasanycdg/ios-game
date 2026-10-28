import RegiereDeutschlandCore
import SwiftUI

/// Container des laufenden Spiels: TabView mit geteiltem ViewModel plus
/// Vollbild-Overlays für Wahlabend und Game Over.
struct GameContainerView: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PurchaseManager.self) private var purchases
    @State private var selectedTab = 0
    @State private var campaignPaywall: CampaignPaywallPlacement?

    init(mode: GameViewModel.StartMode = .newGame,
         party: PlayerParty? = nil,
         playerName: String? = nil,
         difficulty: Difficulty = .normal,
         finalYear: Int = 2026,
         country: GameCountry = .germany) {
        _viewModel = StateObject(wrappedValue: GameViewModel(mode: mode, party: party ?? country.defaultParty, playerName: playerName ?? country.defaultLeaderName, difficulty: difficulty, finalYear: finalYear, country: country))
    }

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()

            TabView(selection: $selectedTab) {
                SituationTab(viewModel: viewModel)
                    .tag(0)
                    .tabItem { Label(L("Lage"), systemImage: "flag.fill") }

                PresseTab(viewModel: viewModel)
                    .tag(1)
                    .tabItem { Label(L("Presse"), systemImage: "newspaper.fill") }

                DepartmentsTab(viewModel: viewModel)
                    .tag(2)
                    .tabItem { Label(L("Ressorts"), systemImage: "chart.bar.fill") }

                PolitikTab(viewModel: viewModel)
                    .tag(3)
                    .tabItem { Label(L("Politik"), systemImage: "building.columns.fill") }

                DiplomacyTab(viewModel: viewModel)
                    .tag(4)
                    .tabItem { Label(L("Welt"), systemImage: "globe.europe.africa.fill") }
            }
            .tint(GameTheme.gold)

            overlay
        }
        .background(GameTheme.background.ignoresSafeArea())
        .foregroundStyle(GameTheme.primaryText)
        .navigationTitle(L("Regieren"))
        .inlineNavigationTitle()
        .toolbar { toolbarContent }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active { viewModel.saveNow() }
        }
        .onAppear {
            viewModel.language = gamePresentation.language
            synchronizeCampaignAccess()
        }
        .onChange(of: gamePresentation.language) { _, language in
            viewModel.language = language
        }
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
            ElectionResultPanel(election: election, parties: viewModel.electionLandscape(election).parties) {
                withAnimation(.easeInOut) { viewModel.continueAfterElection() }
            }
            .transition(.opacity)
            .zIndex(1)
        case .gameOver(let summary):
            gameOverOverlay(summary)
        default:
            EmptyView()
        }
    }

    private func gameOverOverlay(_ summary: GameOverSummary) -> some View {
            GameOverPanel(
                summary: summary,
                achievements: viewModel.newlyUnlockedAchievements,
                programResults: viewModel.programResults,
                partyName: viewModel.playerParty.name,
                continuationTitle: continuationTitle(for: summary),
                onContinueCampaign: summary.reason == .reachedFinalYear ? { continueCampaign() } : nil,
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
    }

    private func continuationTitle(for summary: GameOverSummary) -> String? {
        guard summary.reason == .reachedFinalYear else { return nil }
        switch viewModel.finalYear {
        case 2004:
            return purchases.hasCampaign2005 ? L("Amtszeit ab 2005 fortsetzen") : L("Kampagne 2005–2026 freischalten")
        case 2026:
            return purchases.hasFuture2050 ? L("Mit Zukunft 2050 fortsetzen") : L("Zukunft 2050 freischalten")
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
                    Label(L("Hauptmenü"), systemImage: "house")
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
private struct DebugMenu: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        Section(L("Debug")) {
            Button(L("Jahr +1")) { viewModel.debugJumpForwardOneYear() }
            Button(L("Wirtschaft +5")) { viewModel.debugBoostEconomy() }
            Button(L("Vertrauen -5")) { viewModel.debugReduceTrust() }
            Button(L("Erstes Event triggern")) { viewModel.debugTriggerCurrentYearFirstEvent() }
            Button(L("Balancing-Simulation")) { viewModel.debugRunBalanceSimulation() }
        }
    }
}
#endif
