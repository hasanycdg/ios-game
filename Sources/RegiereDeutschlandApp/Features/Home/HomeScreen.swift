import SwiftUI
import RegiereDeutschlandCore

struct HomeScreen: View {
    @State private var hasSaveGame = false
    @State private var runResults: [RunResult] = []
    @State private var unlockedAchievements: Set<String> = []
    @State private var selectedPersonaID = PersonaCatalog.default.id
    @State private var showAchievements = false
    private let persistence = GamePersistence()

    private var selectedPersona: KanzlerPersona {
        PersonaCatalog.persona(id: selectedPersonaID)
    }

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 28)
                    hero
                    personaPicker
                    actions
                    footer
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
    }

    private func reload() {
        hasSaveGame = persistence.hasSaveGame
        runResults = persistence.loadRunResults()
        unlockedAchievements = persistence.loadUnlockedAchievements()
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

    // MARK: Kanzler-Auswahl

    private var personaPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Wähle deinen Kanzler", systemImage: "person.crop.circle.badge.checkmark")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PersonaCatalog.all) { persona in
                        PersonaCard(persona: persona, isSelected: persona.id == selectedPersonaID) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedPersonaID = persona.id
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
                    GameContainerView(mode: .newGame, persona: selectedPersona)
                } label: { Label("Neues Spiel", systemImage: "flag.fill") }
                .buttonStyle(SecondaryActionButtonStyle())
            } else {
                NavigationLink {
                    GameContainerView(mode: .newGame, persona: selectedPersona)
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

private struct PersonaCard: View {
    let persona: KanzlerPersona
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: persona.icon)
                        .font(.headline)
                        .foregroundStyle(GameTheme.gold)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(GameTheme.gold.opacity(0.15)))
                    Spacer(minLength: 0)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(GameTheme.gold)
                    }
                }
                Text(persona.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(GameTheme.primaryText)
                Text(persona.tagline)
                    .font(.caption2)
                    .foregroundStyle(GameTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(13)
            .frame(width: 190, height: 150, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GameTheme.surface))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? GameTheme.gold : GameTheme.hairline, lineWidth: isSelected ? 2 : 1)
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
