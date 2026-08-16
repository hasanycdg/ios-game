import RegiereDeutschlandCore
import SwiftUI

/// Vollbild-Begegnung: Interview oder vertrauliches Lobby-Angebot.
struct EncounterView: View {
    let encounter: PoliticalEncounter
    let onSelect: (String) -> Void

    private var accent: Color { encounter.kind == .lobby ? GameTheme.red : GameTheme.gold }
    private var eyebrow: String { encounter.kind == .lobby ? "VERTRAULICHES ANGEBOT" : "LIVE-INTERVIEW" }
    private var icon: String { encounter.kind == .lobby ? "banknote.fill" : "mic.fill" }

    var body: some View {
        ZStack {
            GameTheme.dramaticBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    Text(encounter.prompt)
                        .font(.callout)
                        .foregroundStyle(GameTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    VStack(spacing: 12) {
                        ForEach(encounter.options) { option in
                            optionCard(option)
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
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(accent.opacity(0.15)).frame(width: 66, height: 66)
                Image(systemName: icon).font(.title).foregroundStyle(accent)
            }
            Text(eyebrow)
                .font(.caption.weight(.heavy)).tracking(3)
                .foregroundStyle(accent)
            Text(encounter.source)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(GameTheme.primaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 40)
    }

    private func optionCard(_ option: EncounterOption) -> some View {
        Button {
            onSelect(option.id)
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(GameTheme.primaryText)
                        .multilineTextAlignment(.leading)
                    Text(option.detail)
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                Image(systemName: option.corruptionEffect > 0 ? "eye.slash.fill" : "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(option.corruptionEffect > 0 ? GameTheme.red : GameTheme.tertiaryText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(OptionCardButtonStyle(accent: option.corruptionEffect > 0 ? GameTheme.red : accent))
    }
}
