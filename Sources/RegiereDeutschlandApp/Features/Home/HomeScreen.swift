import SwiftUI
import RegiereDeutschlandCore

struct HomeScreen: View {
    @State private var hasSaveGame = false
    @State private var runResults: [RunResult] = []
    private let persistence = GamePersistence()

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 26) {
                    Spacer(minLength: 40)
                    hero
                    actions
                    if !runResults.isEmpty {
                        recentRuns
                    }
                    Spacer(minLength: 20)
                }
                .padding(24)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(GameTheme.primaryText)
        .inlineNavigationTitle()
        .hiddenNavigationBar()
        .onAppear(perform: reload)
    }

    private func reload() {
        hasSaveGame = persistence.hasSaveGame
        runResults = persistence.loadRunResults()
    }

    // MARK: Hero

    private var hero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(GameTheme.gold.opacity(0.14))
                    .frame(width: 96, height: 96)
                Circle()
                    .stroke(GameTheme.gold.opacity(0.4), lineWidth: 1)
                    .frame(width: 96, height: 96)
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(GameTheme.goldGradient)
            }

            VStack(spacing: 6) {
                Text("REGIERE")
                    .font(.subheadline.weight(.bold))
                    .tracking(8)
                    .foregroundStyle(GameTheme.secondaryText)
                Text("DEUTSCHLAND")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(GameTheme.primaryText)
                FlagRibbon(height: 5)
                    .frame(width: 150)
                    .padding(.top, 2)
                Text("2000 – 2026")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(GameTheme.gold)
                    .padding(.top, 6)
            }

            Text("Deutschland seit 2000 – aber diesmal entscheidest DU. Jede Entscheidung schreibt Geschichte.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(GameTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
        }
    }

    // MARK: Aktionen

    private var actions: some View {
        VStack(spacing: 12) {
            if hasSaveGame {
                NavigationLink {
                    GameContainerView(mode: .resume)
                } label: {
                    Label("Fortsetzen", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryActionButtonStyle())

                NavigationLink {
                    GameContainerView(mode: .newGame)
                } label: {
                    Label("Neues Spiel", systemImage: "flag.fill")
                }
                .buttonStyle(SecondaryActionButtonStyle())
            } else {
                NavigationLink {
                    GameContainerView(mode: .newGame)
                } label: {
                    Label("Neues Spiel", systemImage: "flag.fill")
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
        }
    }

    // MARK: Vergangene Amtszeiten

    private var recentRuns: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Vergangene Amtszeiten", systemImage: "trophy.fill",
                          accessory: "Bestwert \(bestScore)")
            VStack(spacing: 8) {
                ForEach(runResults.prefix(3)) { run in
                    RunResultRow(run: run)
                }
            }
        }
    }

    private var bestScore: Int {
        runResults.map(\.score).max() ?? 0
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
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(GameTheme.primaryText)
                Text(run.governingStyle)
                    .font(.caption)
                    .foregroundStyle(GameTheme.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(run.score)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.gold)
                    .monospacedDigit()
                Text("Punkte")
                    .font(.caption2)
                    .foregroundStyle(GameTheme.tertiaryText)
            }
        }
        .gameCard(padding: 12)
    }
}
