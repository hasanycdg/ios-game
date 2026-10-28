import SwiftUI
import RegiereDeutschlandCore

struct HomeScreen: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    @Environment(PurchaseManager.self) private var purchases
    @State private var hasSaveGame = false
    @State private var runResults: [RunResult] = []
    @State private var unlockedAchievements: Set<String> = []
    @State private var selectedPartyID: String
    @State private var playerName = ""
    @State private var showAchievements = false
    @State private var showOnboarding = false
    @State private var showPartyPaywall = false
    @State private var showWelcomePaywall = false
    @State private var offerAfterOnboarding = false
    @AppStorage("lastAutomaticCampaignOffer") private var lastAutomaticCampaignOffer = 0.0
    @AppStorage private var hasSeenOnboarding: Bool
    @AppStorage private var storedName: String
    @AppStorage private var difficultyRaw: String
    @FocusState private var nameFocused: Bool
    @Environment(\.chooseCountry) private var chooseCountry
    private let country: GameCountry
    private let persistence: GamePersistence

    init(country: GameCountry = .germany) {
        self.country = country
        self.persistence = GamePersistence(country: country)
        _selectedPartyID = State(initialValue: country.defaultParty.id)
        let suffix = country == .germany ? "" : ".us"
        _hasSeenOnboarding = AppStorage(wrappedValue: false, "hasSeenRegiereOnboarding" + suffix)
        _storedName = AppStorage(wrappedValue: "", "regiereChancellorName" + suffix)
        _difficultyRaw = AppStorage(wrappedValue: Difficulty.normal.rawValue, "regiereDifficulty" + suffix)
    }

    private var selectedParty: PlayerParty {
        country.party(id: selectedPartyID)
    }

    private var effectiveName: String {
        let trimmed = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? country.defaultLeaderName : trimmed
    }

    private var selectedDifficulty: Difficulty {
        Difficulty(rawValue: difficultyRaw) ?? .normal
    }

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Button(action: chooseCountry) {
                        Label(L(country == .germany ? L("Deutschland · Land wechseln") : L("United States · Change country")), systemImage: "globe.americas.fill")
                            .font(.footnote.weight(.semibold))
                    }
                    .foregroundStyle(GameTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    Spacer(minLength: 8)
                    hero
                    nameField
                    partyPicker
                    foundPartyButton
                    difficultyPicker
                    actions
                    CampaignStoreCard()
                    footer
                    howItWorksButton
                    if !runResults.isEmpty { recentRuns }
                    Spacer(minLength: 20)
                }
                .padding(20)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(GameTheme.primaryText)
        .inlineNavigationTitle()
        .hiddenNavigationBar()
        .onAppear(perform: reload)
        .task {
            guard hasSeenOnboarding else { return }
            await purchases.refreshCustomerInfo()
            guard purchases.customerInfo != nil, !showOnboarding else { return }
            presentAutomaticOffer(force: false)
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsSheet(unlocked: unlockedAchievements)
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            guard offerAfterOnboarding else { return }
            offerAfterOnboarding = false
            Task {
                await purchases.refreshCustomerInfo()
                presentAutomaticOffer(force: true)
            }
        }) {
            OnboardingView {
                offerAfterOnboarding = !hasSeenOnboarding
                hasSeenOnboarding = true
                showOnboarding = false
            }
        }
        .sheet(isPresented: $showWelcomePaywall) {
            CampaignPaywallView(placement: purchases.hasCampaign2005 ? .afterMainCampaign : .catalog)
        }
        .proPaywallSheet(isPresented: $showPartyPaywall)
    }

    private func reload() {
        hasSaveGame = persistence.hasSaveGame
        runResults = persistence.loadRunResults()
        unlockedAchievements = persistence.loadUnlockedAchievements()
        if playerName.isEmpty, !storedName.isEmpty {
            playerName = storedName
        }
        if !hasSeenOnboarding {
            showOnboarding = true
        }
    }

    // MARK: Hero

    private func presentAutomaticOffer(force: Bool) {
        guard !showWelcomePaywall else { return }
        let now = Date().timeIntervalSince1970
        guard CampaignOfferSchedule.shouldPresent(hasFutureCampaign: purchases.hasFuture2050,
                                                  lastPresented: lastAutomaticCampaignOffer,
                                                  now: now, afterOnboarding: force) else { return }
        lastAutomaticCampaignOffer = now
        showWelcomePaywall = true
    }

    private var hero: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(GameTheme.gold.opacity(0.14)).frame(width: 88, height: 88)
                Circle().stroke(GameTheme.gold.opacity(0.4), lineWidth: 1).frame(width: 88, height: 88)
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(GameTheme.goldGradient)
            }
            VStack(spacing: 6) {
                Text(L("REGIERE"))
                    .font(.subheadline.weight(.bold)).tracking(8)
                    .foregroundStyle(GameTheme.secondaryText)
                Text(L("DEUTSCHLAND"))
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(GameTheme.primaryText)
                FlagRibbon(height: 5).frame(width: 150).padding(.top, 2)
                Text(L("2000 – 2050"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(GameTheme.gold).padding(.top, 6)
            }
        }
    }

    // MARK: Name & Partei

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: L("Dein Name"), systemImage: "signature")
            HStack(spacing: 10) {
                Image(systemName: "person.fill")
                    .font(.subheadline)
                    .foregroundStyle(GameTheme.gold)
                TextField(L(""), text: $playerName, prompt: Text(L("z. B. \(L(country.defaultLeaderName))"))
                    .foregroundColor(GameTheme.tertiaryText))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($nameFocused)
                    .foregroundStyle(GameTheme.primaryText)
                    .tint(GameTheme.gold)
                    .onSubmit { nameFocused = false }
                if !playerName.isEmpty {
                    Button {
                        playerName = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(GameTheme.tertiaryText)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GameTheme.surface))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(nameFocused ? GameTheme.gold : GameTheme.hairline, lineWidth: 1)
            )
            .onChange(of: playerName) { _, _ in storedName = effectiveName }
        }
    }

    // Beispiel für Entitlement-Gating: Das Gründen einer eigenen Partei ist ein
    // Pro-Feature. Nicht-Pro-Nutzer sehen ein „Pro“-Abzeichen und bekommen beim
    // Tippen die Paywall. Um das Feature freizugeben, einfach wieder durch die
    // reine `NavigationLink`-Variante ersetzen.
    @ViewBuilder
    private var foundPartyButton: some View {
        if purchases.isPro {
            NavigationLink {
                PartyFounderView(playerName: effectiveName, difficulty: selectedDifficulty)
            } label: {
                foundPartyLabel(locked: false)
            }
            .buttonStyle(.plain)
        } else {
            Button {
                Haptics.impact(.light)
                showPartyPaywall = true
            } label: {
                foundPartyLabel(locked: true)
            }
            .buttonStyle(.plain)
        }
    }

    private func foundPartyLabel(locked: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
            Text(L("Oder: eigene Partei gründen"))
            Spacer(minLength: 0)
            if locked {
                ProLockBadge()
            } else {
                Image(systemName: "chevron.right").font(.caption.weight(.bold))
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(GameTheme.teal)
        .padding(.vertical, 13).padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GameTheme.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(GameTheme.teal.opacity(0.4), lineWidth: 1)
        )
    }

    private var difficultyPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: L("Schwierigkeit"), systemImage: "dial.medium",
                          accessory: selectedDifficulty.subtitle)
            HStack(spacing: 8) {
                ForEach(Difficulty.allCases, id: \.self) { level in
                    let isOn = level == selectedDifficulty
                    Button {
                        Haptics.impact(.light)
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            difficultyRaw = level.rawValue
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: level.icon).font(.caption2.weight(.bold))
                            Text(L(level.title)).font(.subheadline.weight(.bold))
                        }
                        .foregroundStyle(isOn ? Color(red: 0.12, green: 0.10, blue: 0.05) : GameTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                                .fill(isOn ? GameTheme.goldGradient : LinearGradient(colors: [GameTheme.surface, GameTheme.surface], startPoint: .top, endPoint: .bottom))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                                .stroke(isOn ? Color.clear : GameTheme.hairline, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var partyPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: L("Wähle deine Partei"), systemImage: "flag.2.crossed.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(country.playableParties) { party in
                        PartyCard(party: party, isSelected: party.id == selectedPartyID) {
                            Haptics.impact(.light)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedPartyID = party.id
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: Aktionen

    private var actions: some View {
        VStack(spacing: 12) {
            if hasSaveGame {
                NavigationLink {
                    GameContainerView(mode: .resume, country: country)
                } label: { Label(L("Fortsetzen"), systemImage: "play.fill") }
                .buttonStyle(PrimaryActionButtonStyle())

                NavigationLink {
                    GameContainerView(mode: .newGame, party: selectedParty, playerName: effectiveName, difficulty: selectedDifficulty, finalYear: accessibleFinalYear, country: country)
                } label: { Label(L("Neues Spiel"), systemImage: "flag.fill") }
                .buttonStyle(SecondaryActionButtonStyle())
            } else {
                NavigationLink {
                    GameContainerView(mode: .newGame, party: selectedParty, playerName: effectiveName, difficulty: selectedDifficulty, finalYear: accessibleFinalYear, country: country)
                } label: { Label(L(purchases.hasCampaign2005 ? L("Neues Spiel") : L("Prolog 2000–2004 starten")), systemImage: "flag.fill") }
                .buttonStyle(PrimaryActionButtonStyle())
            }
        }
    }

    private var accessibleFinalYear: Int {
        purchases.campaignAccess.finalYear
    }

    private var footer: some View {
        Button {
            showAchievements = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                Text(L("Erfolge"))
                Text(L("\(L(unlockedAchievements.count))/\(L(AchievementCatalog.all.count))"))
                    .foregroundStyle(GameTheme.gold)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(GameTheme.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GameTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(GameTheme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var howItWorksButton: some View {
        Button {
            showOnboarding = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "questionmark.circle")
                Text(L("So funktioniert das Spiel"))
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(GameTheme.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: Vergangene Amtszeiten

    private var recentRuns: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: L("Vergangene Amtszeiten"), systemImage: "clock.arrow.circlepath",
                          accessory: L("Bestwert \(L(runResults.map(\.score).max() ?? 0))"))
            VStack(spacing: 8) {
                ForEach(runResults.prefix(3)) { RunResultRow(run: $0) }
            }
        }
    }
}

private struct PartyCard: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let party: PlayerParty
    let isSelected: Bool
    let action: () -> Void

    private var accent: Color { PartyPresentation.color(for: party.id) }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: party.profile.icon)
                        .font(.headline)
                        .foregroundStyle(accent)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(accent.opacity(0.18)))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(L(party.name))
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(GameTheme.primaryText)
                        Text(L(party.fullName))
                            .font(.system(size: 9.5))
                            .foregroundStyle(GameTheme.tertiaryText)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(accent)
                    }
                }
                Text(L(party.tagline))
                    .font(.caption2)
                    .foregroundStyle(GameTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                HStack(spacing: 5) {
                    Image(systemName: "person.2.fill").font(.system(size: 8))
                    Text(L(gamePresentation.country == .unitedStates ? "Congressional caucus agreements" : L("Partner: ") + party.naturalPartnerIDs.prefix(2).compactMap { id in
                        gamePresentation.country.partyLandscape.first { $0.id == id }?.name
                    }.joined(separator: ", ")))
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(GameTheme.tertiaryText)
            }
            .padding(13)
            .frame(width: 210, height: 158, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GameTheme.surface))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? accent : GameTheme.hairline, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct RunResultRow: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let run: RunResult
    private var won: Bool { run.endReason == .reachedFinalYear }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: won ? "flag.checkered" : "xmark.seal.fill")
                .font(.footnote.weight(.bold))
                .foregroundStyle(won ? GameTheme.green : GameTheme.red)
                .frame(width: 30, height: 30)
                .background(Circle().fill((won ? GameTheme.green : GameTheme.red).opacity(0.15)))
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: L("\(L(run.startYear))–\(L(run.endYear))"))
                    .font(.subheadline.weight(.bold)).foregroundStyle(GameTheme.primaryText)
                Text(L(run.governingStyle))
                    .font(.caption).foregroundStyle(GameTheme.secondaryText).lineLimit(1)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 2) {
                Text(L("\(L(run.score))"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.gold).monospacedDigit()
                Text(L("Punkte")).font(.caption2).foregroundStyle(GameTheme.tertiaryText)
            }
        }
        .gameCard(padding: 12)
    }
}

private struct AchievementsSheet: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let unlocked: Set<String>

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(L("Erfolge"))
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(GameTheme.primaryText)
                        .padding(.top, 8)
                    ForEach(AchievementCatalog.all) { achievement in
                        let isUnlocked = unlocked.contains(achievement.id)
                        HStack(spacing: 14) {
                            Image(systemName: isUnlocked ? achievement.icon : "lock.fill")
                                .font(.headline)
                                .foregroundStyle(isUnlocked ? GameTheme.gold : GameTheme.tertiaryText)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill((isUnlocked ? GameTheme.gold : GameTheme.tertiaryText).opacity(0.15)))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(L(achievement.title))
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(isUnlocked ? GameTheme.primaryText : GameTheme.secondaryText)
                                Text(L(achievement.detail))
                                    .font(.caption)
                                    .foregroundStyle(GameTheme.tertiaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        .gameCard(padding: 14, tint: isUnlocked ? GameTheme.gold : nil)
                    }
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
    }
}
