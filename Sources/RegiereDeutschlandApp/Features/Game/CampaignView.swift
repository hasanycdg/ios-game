import RegiereDeutschlandCore
import SwiftUI

/// Vollbild-Wahlkampf: der Spieler wählt einen Schwerpunkt, bevor die Wahl läuft.
struct CampaignView: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let year: Int
    let state: GameState
    let onSelect: (CampaignFocus) -> Void

    var body: some View {
        ZStack {
            GameTheme.dramaticBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    Text(L("Womit ziehst du in den Wahlkampf? Ein Thema, das zu einer Stärke passt, bringt Stimmen – ein Thema an deiner Schwachstelle kostet welche."))
                        .font(.callout)
                        .foregroundStyle(GameTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 12) {
                        ForEach(CampaignFocusCatalog.all) { focus in
                            FocusCard(focus: focus, alignment: focus.alignment(for: state)) {
                                onSelect(focus)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .foregroundStyle(GameTheme.primaryText)
        .onAppear { Haptics.impact(.rigid) }
    }

    private var header: some View {
        VStack(spacing: 8) {
            FlagRibbon(height: 5).frame(width: 90)
            Text(L("WAHLKAMPF"))
                .font(.caption.weight(.heavy)).tracking(4)
                .foregroundStyle(GameTheme.gold)
            Text(L("Bundestagswahl \(L(String(year)))"))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(GameTheme.primaryText)
        }
        .padding(.top, 40)
    }
}

private struct FocusCard: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let focus: CampaignFocus
    let alignment: CampaignAlignment
    let action: () -> Void

    private var badge: (text: String, color: Color) {
        switch alignment {
        case .strong: (L("Starkes Thema"), GameTheme.green)
        case .solid:  (L("Solides Thema"), GameTheme.gold)
        case .risky:  (L("Riskant"), GameTheme.red)
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: focus.icon)
                    .font(.title3)
                    .foregroundStyle(GameTheme.gold)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(GameTheme.gold.opacity(0.15)))
                VStack(alignment: .leading, spacing: 4) {
                    Text(L(focus.title))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(GameTheme.primaryText)
                    Text(L(focus.detail))
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(L(badge.text))
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(badge.color)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(badge.color.opacity(0.16)))
                        .padding(.top, 2)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(GameTheme.tertiaryText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(OptionCardButtonStyle(accent: GameTheme.gold))
    }
}
