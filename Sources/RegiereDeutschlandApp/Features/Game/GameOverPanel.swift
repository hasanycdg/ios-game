import RegiereDeutschlandCore
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Vollbild-Endbericht – Wahlniederlage oder Ende 2026.
struct GameOverPanel: View {
    let summary: GameOverSummary
    var achievements: [Achievement] = []
    var programResults: [GoalProgress] = []
    var partyName: String = ""
    let onNewGame: () -> Void
    var onExitToMenu: (() -> Void)? = nil

    @State private var shareImage: Image?

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
                    if !programResults.isEmpty { programCard }
                    finalStatsCard

                    if !summary.defeatReasons.isEmpty {
                        listCard(title: "Hauptgründe", icon: "exclamationmark.triangle.fill",
                                 tint: GameTheme.red, items: summary.defeatReasons)
                    }

                    if !summary.keyDecisionTitles.isEmpty {
                        listCard(title: "Prägende Entscheidungen", icon: "star.fill",
                                 tint: GameTheme.gold, items: summary.keyDecisionTitles)
                    }

                    if !achievements.isEmpty {
                        achievementsCard
                    }

                    VStack(spacing: 10) {
                        Button(action: onNewGame) {
                            Label("Neues Spiel", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(PrimaryActionButtonStyle())

                        if let shareImage {
                            ShareLink(
                                item: shareImage,
                                preview: SharePreview("Mein Deutschland \(String(summary.startYear))–\(String(summary.endYear))", image: shareImage)
                            ) {
                                Label("Ergebnis teilen", systemImage: "square.and.arrow.up")
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                        }

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
        .onAppear(perform: renderShareImage)
    }

    private func renderShareImage() {
        #if canImport(UIKit)
        let renderer = ImageRenderer(content: ShareCardView(summary: summary))
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            shareImage = Image(uiImage: uiImage)
        }
        #endif
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

    private var fulfilledCount: Int { programResults.filter { $0.status == .fulfilled }.count }

    private var programCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: partyName.isEmpty ? "Programm-Bilanz" : "Programm: \(partyName)",
                          systemImage: "target",
                          accessory: "\(fulfilledCount)/\(programResults.count) erreicht")
            VStack(spacing: 9) {
                ForEach(programResults) { r in
                    HStack(spacing: 11) {
                        Image(systemName: statusIcon(r.status))
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(statusColor(r.status))
                            .frame(width: 22)
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(r.goal.title)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(GameTheme.primaryText)
                                Spacer(minLength: 6)
                                Text("\(r.metricLabel) \(r.metricValue)")
                                    .font(.caption2)
                                    .foregroundStyle(GameTheme.tertiaryText)
                            }
                            ValueBar(value: r.percent, height: 6)
                        }
                    }
                }
            }
            .gameCard(padding: 16)
        }
    }

    private func statusIcon(_ s: GoalStatus) -> String {
        switch s {
        case .fulfilled: "checkmark.seal.fill"
        case .partial:   "circle.lefthalf.filled"
        case .missed:    "xmark.seal.fill"
        }
    }

    private func statusColor(_ s: GoalStatus) -> Color {
        switch s {
        case .fulfilled: GameTheme.green
        case .partial:   GameTheme.amber
        case .missed:    GameTheme.red
        }
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

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Neue Erfolge freigeschaltet", systemImage: "trophy.fill")
            VStack(spacing: 8) {
                ForEach(achievements) { achievement in
                    HStack(spacing: 12) {
                        Image(systemName: achievement.icon)
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(GameTheme.gold)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(GameTheme.gold.opacity(0.15)))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(achievement.title)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(GameTheme.primaryText)
                            Text(achievement.detail)
                                .font(.caption)
                                .foregroundStyle(GameTheme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .gameCard(padding: 12, tint: GameTheme.gold)
                }
            }
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
