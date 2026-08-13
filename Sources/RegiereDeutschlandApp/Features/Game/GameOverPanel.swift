import RegiereDeutschlandCore
import SwiftUI

/// Vollbild-Endbericht – Wahlniederlage oder Ende 2026.
struct GameOverPanel: View {
    let summary: GameOverSummary
    let onNewGame: () -> Void
    var onExitToMenu: (() -> Void)? = nil

    private var reachedEnd: Bool { summary.reason == .reachedFinalYear }
    private var accent: Color { reachedEnd ? GameTheme.gold : GameTheme.red }

    var body: some View {
        ZStack {
            GameTheme.dramaticBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    scoreHero
                    endReport
                    finalStatsCard

                    if !summary.defeatReasons.isEmpty {
                        listCard(title: "Hauptgründe", icon: "exclamationmark.triangle.fill",
                                 tint: GameTheme.red, items: summary.defeatReasons)
                    }

                    if !summary.keyDecisionTitles.isEmpty {
                        listCard(title: "Prägende Entscheidungen", icon: "star.fill",
                                 tint: GameTheme.gold, items: summary.keyDecisionTitles)
                    }

                    VStack(spacing: 10) {
                        Button(action: onNewGame) {
                            Label("Neues Spiel", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(PrimaryActionButtonStyle())

                        if let onExitToMenu {
                            Button(action: onExitToMenu) {
                                Label("Hauptmenü", systemImage: "house")
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
        }
        .foregroundStyle(GameTheme.primaryText)
    }

    private var header: some View {
        VStack(spacing: 10) {
            FlagRibbon(height: 5).frame(width: 90)
            Image(systemName: reachedEnd ? "flag.checkered.2.crossed" : "building.columns")
                .font(.system(size: 40))
                .foregroundStyle(accent)
            Text(reachedEnd ? "DEIN DEUTSCHLAND 2026" : "REGIERUNG BEENDET")
                .font(.caption.weight(.heavy))
                .tracking(3)
                .foregroundStyle(accent)
            Text(summary.message)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(GameTheme.primaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 36)
    }

    private var scoreHero: some View {
        VStack(spacing: 14) {
            VStack(spacing: 2) {
                Text("\(summary.score)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(GameTheme.gold)
                    .monospacedDigit()
                Text("PUNKTE")
                    .font(.caption.weight(.bold))
                    .tracking(3)
                    .foregroundStyle(GameTheme.secondaryText)
            }

            HStack(spacing: 0) {
                heroStat(value: "\(summary.startYear)–\(summary.endYear)", label: "Amtszeit")
                divider
                heroStat(value: "\(summary.wonElectionCount)", label: "Wahlsiege")
                divider
                heroStat(value: "\(max(0, summary.endYear - summary.startYear))", label: "Jahre")
            }
        }
        .frame(maxWidth: .infinity)
        .gameCard(padding: 20, tint: GameTheme.gold)
        .overlay(alignment: .top) {
            Text(summary.governingStyle)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.05))
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Capsule().fill(GameTheme.goldGradient))
                .offset(y: -12)
        }
    }

    private var divider: some View {
        Rectangle().fill(GameTheme.hairline).frame(width: 1, height: 34)
    }

    private func heroStat(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(GameTheme.primaryText)
            Text(label)
                .font(.caption2)
                .foregroundStyle(GameTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var endReport: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Endbericht", systemImage: "doc.text.magnifyingglass")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                reportTile(icon: "trophy.fill", tint: GameTheme.green, title: "Größter Erfolg", text: summary.biggestSuccess)
                reportTile(icon: "exclamationmark.triangle.fill", tint: GameTheme.red, title: "Größte Schwäche", text: summary.biggestMistake)
                reportTile(icon: "arrow.triangle.branch", tint: GameTheme.purple, title: "Butterfly-Effekt", text: summary.biggestButterflyEffect)
                reportTile(icon: "clock.arrow.2.circlepath", tint: GameTheme.blue, title: "Abweichung", text: summary.strongestHistoricalDeviation)
            }
        }
    }

    private func reportTile(icon: String, tint: Color, title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.footnote.weight(.bold))
                .foregroundStyle(tint)
            Text(title)
                .font(.caption2.weight(.bold))
                .tracking(0.4)
                .foregroundStyle(GameTheme.tertiaryText)
            Text(text)
                .font(.caption)
                .foregroundStyle(GameTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
        .gameCard(padding: 14)
    }

    private var finalStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Bilanz der Nation", systemImage: "chart.bar.doc.horizontal")
            VStack(spacing: 9) {
                ForEach(VisibleMetric.allCases, id: \.self) { metric in
                    let style = MetricPresentation.style(for: metric)
                    let value = summary.finalStats.value(for: metric)
                    HStack(spacing: 10) {
                        Image(systemName: style.icon)
                            .font(.caption)
                            .foregroundStyle(GameTheme.secondaryText)
                            .frame(width: 20)
                        Text(style.label)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(GameTheme.primaryText)
                            .frame(width: 96, alignment: .leading)
                        ValueBar(value: value, height: 7)
                        Text("\(value)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(GameTheme.statusColor(for: value))
                            .monospacedDigit()
                            .frame(width: 26, alignment: .trailing)
                    }
                }
            }
            .gameCard(padding: 16)
        }
    }

    private func listCard(title: String, icon: String, tint: Color, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title, systemImage: icon)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Circle().fill(tint).frame(width: 5, height: 5).padding(.top, 6)
                        Text(item)
                            .font(.footnote)
                            .foregroundStyle(GameTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .gameCard(padding: 16)
        }
    }
}
