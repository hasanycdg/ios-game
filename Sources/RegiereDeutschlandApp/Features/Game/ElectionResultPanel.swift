import RegiereDeutschlandCore
import SwiftUI

/// Vollbild-"Wahlabend" – dramatischer Moment über allen Tabs.
struct ElectionResultPanel: View {
    let election: ElectionResult
    let onContinue: () -> Void

    @State private var revealed = false

    var body: some View {
        ZStack {
            GameTheme.dramaticBackground.ignoresSafeArea()

            if election.didWin {
                ConfettiView().ignoresSafeArea().zIndex(2)
            }

            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 8) {
                        FlagRibbon(height: 5).frame(width: 90)
                        Text("WAHLABEND")
                            .font(.caption.weight(.heavy))
                            .tracking(4)
                            .foregroundStyle(GameTheme.gold)
                        Text(verbatim: "Bundestagswahl \(election.year)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(GameTheme.primaryText)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 16) {
                        resultBar(title: "Deine Partei", value: election.governingPartyShare,
                                  color: GameTheme.gold, leading: true)
                        resultBar(title: "Stärkste Opposition", value: election.oppositionShare,
                                  color: GameTheme.secondaryText, leading: false)
                    }
                    .gameCard(padding: 18)

                    SeatDistributionBar(election: election)

                    verdict

                    if !election.reasons.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Ausschlaggebend", systemImage: "text.magnifyingglass")
                            ForEach(election.reasons, id: \.self) { reason in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "chevron.right.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(GameTheme.gold)
                                    Text(reason)
                                        .font(.footnote)
                                        .foregroundStyle(GameTheme.secondaryText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .gameCard(padding: 18)
                    }

                    Button(action: onContinue) {
                        Label(election.didWin ? "Weiterregieren" : "Auswertung ansehen",
                              systemImage: election.didWin ? "flag.checkered" : "doc.text.magnifyingglass")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                    .padding(.top, 4)
                }
                .padding(20)
            }
        }
        .foregroundStyle(GameTheme.primaryText)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7)) { revealed = true }
            if election.didWin { Haptics.success() } else { Haptics.warning() }
        }
    }

    private var verdict: some View {
        let win = election.didWin
        return HStack(spacing: 12) {
            Image(systemName: win ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.title)
                .foregroundStyle(win ? GameTheme.green : GameTheme.red)
            VStack(alignment: .leading, spacing: 2) {
                Text(win ? "Wiedergewählt" : "Abgewählt")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(win ? GameTheme.green : GameTheme.red)
                Text(win ? "Deine Regierung bleibt im Amt." : "Deine Regierung muss abtreten.")
                    .font(.subheadline)
                    .foregroundStyle(GameTheme.secondaryText)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .gameCard(padding: 16, tint: win ? GameTheme.green : GameTheme.red)
    }

    private func resultBar(title: String, value: Double, color: Color, leading: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(GameTheme.primaryText)
                Spacer()
                Text(String(format: "%.1f %%", value))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(color == GameTheme.secondaryText ? GameTheme.primaryText : color)
                    .monospacedDigit()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(GameTheme.surfaceSunken)
                    Capsule()
                        .fill(color)
                        .frame(width: revealed ? geo.size.width * CGFloat(min(value, 60) / 60) : 0)
                }
            }
            .frame(height: 12)
            .animation(.easeOut(duration: 0.9), value: revealed)
        }
    }
}
