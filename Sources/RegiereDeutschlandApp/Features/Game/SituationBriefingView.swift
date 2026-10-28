import RegiereDeutschlandCore
import SwiftUI

/// Kurzes Lage-Briefing zu Spielbeginn: Jahr, Wahlsieg, nationale Lage und die
/// nächste Wahl – bevor die Regierung gebildet wird.
struct SituationBriefingView: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let year: Int
    let playerName: String
    let party: PlayerParty
    let state: GameState
    let governanceIndex: Int
    let nationMood: (word: String, color: Color)
    let nextElectionYear: Int?
    let onContinue: () -> Void

    private var partyColor: Color { PartyPresentation.color(for: party.id) }

    private var yearsToElection: Int? {
        guard let next = nextElectionYear else { return nil }
        return max(0, next - year)
    }

    var body: some View {
        ZStack {
            GameTheme.dramaticBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    victoryCard
                    nationCard
                    electionCard
                    if party.isCustom && !party.agenda.isEmpty {
                        programCard
                    }
                    continueButton
                }
                .padding(20)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(GameTheme.primaryText)
        .onAppear { Haptics.impact(.medium) }
    }

    // MARK: Kopf

    private var header: some View {
        VStack(spacing: 8) {
            FlagRibbon(height: 5).frame(width: 90)
            Text(L("DEIN AMTSANTRITT"))
                .font(.caption.weight(.heavy)).tracking(3)
                .foregroundStyle(GameTheme.gold)
            Text(verbatim: L("\(L(year))"))
                .font(.system(size: 52, weight: .heavy, design: .rounded))
                .foregroundStyle(GameTheme.primaryText)
                .monospacedDigit()
        }
        .padding(.top, 34)
    }

    // MARK: Wahlsieg

    private var victoryCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Circle().fill(partyColor.opacity(0.2)).frame(width: 40, height: 40)
                    .overlay(Image(systemName: "checkmark.seal.fill").foregroundStyle(partyColor))
                VStack(alignment: .leading, spacing: 2) {
                    Text(L("Du hast die Wahl gewonnen!"))
                        .font(.headline)
                        .foregroundStyle(GameTheme.primaryText)
                    Text("\(playerName) · \(L(party.name))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(partyColor)
                }
                Spacer(minLength: 0)
            }
            Text(L("Das Land hat dir das Vertrauen geschenkt. Von jetzt an führst du Deutschland durch die kommenden Jahre – Entscheidung für Entscheidung."))
                .font(.callout)
                .foregroundStyle(GameTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .gameCard(padding: 18, tint: partyColor)
    }

    // MARK: Nationale Lage

    private var nationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(title: L("Die Lage der Nation"), systemImage: "gauge.medium")
                Spacer(minLength: 0)
                Text(L(nationMood.word))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(nationMood.color)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(nationMood.color.opacity(0.15)))
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(VisibleMetric.allCases, id: \.self) { metric in
                    metricTile(metric)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "info.circle").font(.caption2)
                Text(L("Regierungsindex \(L(governanceIndex)) von 100 – so steht das Land, bevor du loslegst."))
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(GameTheme.tertiaryText)
        }
        .gameCard(padding: 18)
    }

    private func metricTile(_ metric: VisibleMetric) -> some View {
        let value = state.visible.value(for: metric)
        let style = MetricPresentation.style(for: metric)
        return HStack(spacing: 10) {
            Image(systemName: style.icon)
                .font(.footnote.weight(.bold))
                .foregroundStyle(GameTheme.statusColor(for: value))
                .frame(width: 22)
            Text(L(style.label))
                .font(.caption)
                .foregroundStyle(GameTheme.secondaryText)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(L("\(L(value))"))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(GameTheme.primaryText)
                .monospacedDigit()
        }
        .padding(.vertical, 9).padding(.horizontal, 11)
        .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(GameTheme.surfaceSunken))
    }

    // MARK: Wahl

    private var electionCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.title3)
                .foregroundStyle(GameTheme.gold)
                .frame(width: 40, height: 40)
                .background(Circle().fill(GameTheme.gold.opacity(0.15)))
            VStack(alignment: .leading, spacing: 2) {
                if let next = nextElectionYear, let years = yearsToElection {
                    Text(L("Nächste Bundestagswahl: \(L(String(next)))"))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(GameTheme.primaryText)
                    Text(L(years == 1 ? L("in einem Jahr wirst du gewählt oder abgewählt.") : L("in \(L(years)) Jahren wirst du gewählt oder abgewählt.")))
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(L("Regiere langfristig"))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(GameTheme.primaryText)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .gameCard(padding: 16)
    }

    // MARK: Programm (eigene Partei)

    private var programCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: L("Dein Programm"), systemImage: "target")
            ForEach(party.agenda) { goal in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2).foregroundStyle(partyColor).padding(.top, 1)
                    Text(L(goal.title))
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(GameTheme.primaryText)
                    Spacer(minLength: 0)
                }
            }
            Text(L("Setze diese Ziele über deine Amtszeit durch."))
                .font(.caption).foregroundStyle(GameTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .gameCard(padding: 18, tint: partyColor)
    }

    private var continueButton: some View {
        Button(action: onContinue) {
            Label(L("Regierung bilden"), systemImage: "arrow.right")
        }
        .buttonStyle(PrimaryActionButtonStyle())
        .padding(.top, 2)
    }
}
