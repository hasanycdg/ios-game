import SwiftUI
import RegiereDeutschlandCore

struct HomeScreen: View {
    @Environment(PurchaseManager.self) private var purchases
    @State private var hasSaveGame = false
    @State private var runResults: [RunResult] = []
    @State private var unlockedAchievements: Set<String> = []
    @State private var selectedPartyID = PartyCatalog.default.id
    @State private var playerName = ""
    @State private var showAchievements = false
    @State private var showOnboarding = false
    @State private var showPartyPaywall = false
    @AppStorage("hasSeenRegiereOnboarding") private var hasSeenOnboarding = false
    @AppStorage("regiereChancellorName") private var storedName = ""
    @AppStorage("regiereDifficulty") private var difficultyRaw = Difficulty.normal.rawValue
    @FocusState private var nameFocused: Bool
    private let persistence = GamePersistence()

    private var selectedParty: PlayerParty {
        PartyCatalog.party(id: selectedPartyID)
    }

    private var effectiveName: String {
        let trimmed = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? PartyCatalog.defaultChancellorName : trimmed
    }

    private var selectedDifficulty: Difficulty {
        Difficulty(rawValue: difficultyRaw) ?? .normal
    }

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 28)
                    hero
                    nameField
                    partyPicker
                    foundPartyButton
                    difficultyPicker
                    actions
                    ProStatusCard()
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
        .sheet(isPresented: $showAchievements) {
            AchievementsSheet(unlocked: unlockedAchievements)
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                hasSeenOnboarding = true
                showOnboarding = false
            }
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
                Text("REGIERE")
                    .font(.subheadline.weight(.bold)).tracking(8)
                    .foregroundStyle(GameTheme.secondaryText)
                Text("DEUTSCHLAND")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(GameTheme.primaryText)
                FlagRibbon(height: 5).frame(width: 150).padding(.top, 2)
                Text("2000 – 2026")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(GameTheme.gold).padding(.top, 6)
            }
        }
    }

    // MARK: Name & Partei

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Dein Name", systemImage: "signature")
            HStack(spacing: 10) {
                Image(systemName: "person.fill")
                    .font(.subheadline)
                    .foregroundStyle(GameTheme.gold)
                TextField("", text: $playerName, prompt: Text("z. B. \(PartyCatalog.defaultChancellorName)")
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
            Text("Oder: eigene Partei gründen")
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
            SectionHeader(title: "Schwierigkeit", systemImage: "dial.medium",
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
                            Text(level.title).font(.subheadline.weight(.bold))
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
            SectionHeader(title: "Wähle deine Partei", systemImage: "flag.2.crossed.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PartyCatalog.playable) { party in
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
                    GameContainerView(mode: .resume)
                } label: { Label("Fortsetzen", systemImage: "play.fill") }
                .buttonStyle(PrimaryActionButtonStyle())

                NavigationLink {
                    GameContainerView(mode: .newGame, party: selectedParty, playerName: effectiveName, difficulty: selectedDifficulty)
                } label: { Label("Neues Spiel", systemImage: "flag.fill") }
                .buttonStyle(SecondaryActionButtonStyle())
            } else {
                NavigationLink {
                    GameContainerView(mode: .newGame, party: selectedParty, playerName: effectiveName, difficulty: selectedDifficulty)
                } label: { Label("Neues Spiel", systemImage: "flag.fill") }
                .buttonStyle(PrimaryActionButtonStyle())
            }
        }
    }

    private var footer: some View {
        Button {
            showAchievements = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                Text("Erfolge")
                Text("\(unlockedAchievements.count)/\(AchievementCatalog.all.count)")
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
                Text("So funktioniert das Spiel")
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
            SectionHeader(title: "Vergangene Amtszeiten", systemImage: "clock.arrow.circlepath",
                          accessory: "Bestwert \(runResults.map(\.score).max() ?? 0)")
            VStack(spacing: 8) {
                ForEach(runResults.prefix(3)) { RunResultRow(run: $0) }
            }
        }
    }
}

private struct PartyCard: View {
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
                        Text(party.name)
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(GameTheme.primaryText)
                        Text(party.fullName)
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
                Text(party.tagline)
                    .font(.caption2)
                    .foregroundStyle(GameTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                HStack(spacing: 5) {
                    Image(systemName: "person.2.fill").font(.system(size: 8))
                    Text("Partner: " + party.naturalPartnerIDs.prefix(2).compactMap {
                        PartyCatalog.reference(id: $0)?.name
                    }.joined(separator: ", "))
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

private struct RunResultRow: View {
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
                Text(verbatim: "\(run.startYear)–\(run.endYear)")
                    .font(.subheadline.weight(.bold)).foregroundStyle(GameTheme.primaryText)
                Text(run.governingStyle)
                    .font(.caption).foregroundStyle(GameTheme.secondaryText).lineLimit(1)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(run.score)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.gold).monospacedDigit()
                Text("Punkte").font(.caption2).foregroundStyle(GameTheme.tertiaryText)
            }
        }
        .gameCard(padding: 12)
    }
}

private struct AchievementsSheet: View {
    let unlocked: Set<String>

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Erfolge")
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
                                Text(achievement.title)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(isUnlocked ? GameTheme.primaryText : GameTheme.secondaryText)
                                Text(achievement.detail)
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
