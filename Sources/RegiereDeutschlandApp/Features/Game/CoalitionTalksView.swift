import RegiereDeutschlandCore
import SwiftUI

/// Vollbild-Koalitionsverhandlungen – nach einer Wahl oder beim Amtsantritt.
struct CoalitionTalksView: View {
    let year: Int
    let options: [CoalitionOption]
    var isInitial: Bool = false
    var playerPartyName: String = ""
    let onSelect: (String) -> Void

    var body: some View {
        ZStack {
            GameTheme.dramaticBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    Text(isInitial
                         ? "Deine Partei hat die Wahl gewonnen. Bilde jetzt deine Regierung – mit wem willst du regieren?"
                         : "Du hast die Wahl gewonnen. Mit wem willst du regieren?")
                        .font(.callout)
                        .foregroundStyle(GameTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    VStack(spacing: 12) {
                        ForEach(options) { option in
                            optionCard(option)
                        }
                    }
                }
                .padding(20)
            }
        }
        .foregroundStyle(GameTheme.primaryText)
        .onAppear { Haptics.impact(.medium) }
    }

    private var header: some View {
        VStack(spacing: 8) {
            FlagRibbon(height: 5).frame(width: 90)
            Text(isInitial ? "REGIERUNGSBILDUNG" : "KOALITIONSVERHANDLUNGEN")
                .font(.caption.weight(.heavy)).tracking(2.5)
                .foregroundStyle(GameTheme.gold)
            Text(isInitial
                 ? "\(playerPartyName) · Amtsantritt \(String(year))"
                 : "Bundestagswahl \(String(year))")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(GameTheme.primaryText)
        }
        .padding(.top, 40)
    }

    private func optionCard(_ option: CoalitionOption) -> some View {
        let accent = option.formsMajority ? GameTheme.green : (option.isMinority ? GameTheme.amber : GameTheme.red)
        return Button {
            onSelect(option.id)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: option.isMinority ? "person.fill.viewfinder" : "person.2.fill")
                    .font(.title3)
                    .foregroundStyle(GameTheme.gold)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(GameTheme.gold.opacity(0.15)))
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.isMinority ? "Minderheitsregierung" : "Koalition mit \(option.partyName)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(GameTheme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle(for: option))
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 6) {
                        Text(String(format: "%.0f %%", option.combinedShare))
                            .font(.caption.weight(.bold)).foregroundStyle(GameTheme.primaryText).monospacedDigit()
                        Text(option.formsMajority ? "Mehrheit" : (option.isMinority ? "ohne Mehrheit" : "knapp"))
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(accent)
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(Capsule().fill(accent.opacity(0.16)))
                    }
                    .padding(.top, 2)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(GameTheme.tertiaryText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(OptionCardButtonStyle(accent: GameTheme.gold))
    }

    private func subtitle(for option: CoalitionOption) -> String {
        if option.isMinority {
            return "Regiere ohne festen Partner – niemand bremst dich, aber das Regieren ist zäher."
        }
        return "Ein \(option.leaning.displayName)er Partner. Gemeinsam kommt ihr auf einen Stimmenanteil, der die Regierung trägt."
    }
}
