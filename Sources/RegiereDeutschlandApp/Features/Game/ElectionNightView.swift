import SwiftUI
import RegiereDeutschlandCore

/// Live election night before the detailed result: exit poll, projection and
/// final result arrive one after another, then the verdict lands.
struct ElectionNightLive: View {
    @Environment(GamePresentation.self) private var p
    let election: ElectionResult
    let title: String
    let onFinish: () -> Void

    private enum Stage: Int { case waiting, exitPoll, projection, final, verdict }

    @State private var stage: Stage = .waiting
    @State private var ownShare: Double = 0
    @State private var oppositionShare: Double = 0
    @State private var pulse = false

    private var country: GameCountry { p.country }

    /// Local times of the three reporting moments per country.
    private var times: [String] {
        switch country {
        case .germany: ["18:00", "19:30", "23:10"]
        case .unitedStates: ["7:00 PM", "10:30 PM", "1:45 AM"]
        case .unitedKingdom: ["10:00 PM", "2:00 AM", "5:30 AM"]
        case .france: ["20:00", "22:00", "00:30"]
        }
    }

    private var stageLabel: String {
        switch stage {
        case .waiting:
            p.pick("Die Wahllokale schließen …", "Polls are closing …", "Les bureaux de vote ferment …")
        case .exitPoll:
            "\(times[0]) · " + p.pick("Prognose", "Exit poll", "Estimation")
        case .projection:
            "\(times[1]) · " + p.pick("Hochrechnung", "Projection", "Projection")
        case .final, .verdict:
            "\(times[2]) · " + p.pick("Vorläufiges Ergebnis", "Preliminary result", "Résultats provisoires")
        }
    }

    private var commentary: String {
        let gap = abs(ownShare - oppositionShare)
        switch stage {
        case .waiting:
            return p.pick("Im ganzen Land wird ausgezählt.", "Votes are being counted across the country.", "Le dépouillement a commencé dans tout le pays.")
        case .exitPoll, .projection:
            return gap < 3
                ? p.pick("Kopf-an-Kopf-Rennen. Noch ist nichts entschieden.", "Neck and neck. Nothing is decided yet.", "Au coude-à-coude. Rien n’est encore joué.")
                : p.pick("Ein Trend zeichnet sich ab – aber die Nacht ist lang.", "A trend is emerging – but it’s a long night.", "Une tendance se dessine – mais la nuit sera longue.")
        case .final, .verdict:
            return election.didWin
                ? p.pick("Die Zahlen sind eindeutig.", "The numbers are clear.", "Les chiffres sont clairs.")
                : p.pick("Die Stimmung in der Parteizentrale kippt.", "The mood at party headquarters turns.", "L’ambiance au QG du parti bascule.")
        }
    }

    var body: some View {
        ZStack {
            background
            VStack(spacing: 22) {
                HStack {
                    Spacer()
                    if stage != .verdict {
                        Button(p.pick("Überspringen", "Skip", "Passer")) { finishNow() }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(GameTheme.secondaryText)
                    }
                }
                .frame(height: 30)

                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Circle().fill(GameTheme.red).frame(width: 8, height: 8)
                            .opacity(pulse ? 1 : 0.25)
                        Text("LIVE").font(.caption.weight(.heavy)).tracking(2).foregroundStyle(GameTheme.red)
                    }
                    Text(title)
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .multilineTextAlignment(.center)
                    Text(stageLabel)
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(GameTheme.goldBright)
                        .contentTransition(.numericText())
                }

                VStack(spacing: 18) {
                    bar(p.pick("Deine Partei", "Your party", "Ton parti"), ownShare, GameTheme.gold)
                    bar(p.pick("Stärkste Opposition", "Main opposition", "Principale opposition"), oppositionShare, GameTheme.secondaryText)
                }
                .gameCard(padding: 18)

                Text(commentary)
                    .font(.system(.callout, design: .serif).italic())
                    .foregroundStyle(GameTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .contentTransition(.opacity)

                Spacer()

                if stage == .verdict {
                    verdict
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                    Button(action: onFinish) {
                        Label(p.pick("Ergebnis im Detail", "Full results", "Résultats détaillés"), systemImage: "chart.bar.xaxis")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                }
            }
            .padding(20)
            .frame(maxWidth: 560)
        }
        .foregroundStyle(GameTheme.primaryText)
        .task { await play() }
    }

    private var background: some View {
        // The photo is an overlay so its aspect ratio never widens the layout.
        GameTheme.dramaticBackground
            .overlay {
                if let image = Artwork.image("election-night") {
                    image.resizable().scaledToFill().opacity(0.35)
                }
            }
            .overlay {
                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
            }
            .clipped()
            .ignoresSafeArea()
    }

    private var verdict: some View {
        let win = election.didWin
        return VStack(spacing: 6) {
            Image(systemName: win ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(win ? GameTheme.green : GameTheme.red)
            Text(win ? p.pick("Wiedergewählt", "Re-elected", "Réélu") : p.pick("Abgewählt", "Voted out", "Battu"))
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(win ? GameTheme.green : GameTheme.red)
        }
    }

    private func bar(_ label: String, _ value: Double, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label).font(.subheadline.weight(.semibold))
                Spacer()
                Text(String(format: "%.1f %%", value))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: value))
                    .foregroundStyle(color == GameTheme.secondaryText ? GameTheme.primaryText : color)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(GameTheme.surfaceSunken)
                    Capsule().fill(color).frame(width: geometry.size.width * CGFloat(min(value, 60) / 60))
                }
            }
            .frame(height: 14)
        }
    }

    // MARK: Ablauf

    private func play() async {
        guard stage == .waiting else { return }
        withAnimation(.easeInOut(duration: 0.8).repeatForever()) { pulse = true }
        let own = election.governingPartyShare
        let opposition = election.oppositionShare
        // Early numbers drift towards the final result; the exit poll keeps it tense.
        let steps: [(Stage, Double, Double, Int)] = [
            (.exitPoll, own - 1.3, opposition + 0.9, 1100),
            (.projection, own - 0.4, opposition + 0.3, 1900),
            (.final, own, opposition, 1900)
        ]
        for (next, ownValue, oppositionValue, delay) in steps {
            try? await Task.sleep(for: .milliseconds(delay))
            guard stage != .verdict else { return }
            withAnimation(.spring(response: 0.9, dampingFraction: 0.8)) {
                stage = next
                ownShare = max(0, ownValue)
                oppositionShare = max(0, oppositionValue)
            }
            Haptics.impact(next == .final ? .rigid : .medium)
        }
        try? await Task.sleep(for: .milliseconds(900))
        guard stage != .verdict else { return }
        revealVerdict()
    }

    private func finishNow() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            ownShare = election.governingPartyShare
            oppositionShare = election.oppositionShare
        }
        revealVerdict()
    }

    private func revealVerdict() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { stage = .verdict }
        if election.didWin { Haptics.success() } else { Haptics.warning() }
        SoundManager.shared.play(election.didWin ? .electionWon : .electionLost)
    }
}
