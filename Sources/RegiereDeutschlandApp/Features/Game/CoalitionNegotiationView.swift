import RegiereDeutschlandCore
import SwiftUI

/// Koalitionsgespräche: Der Partner legt seine Forderungen auf den Tisch,
/// der Kanzler sagt sie zu oder lehnt sie ab.
struct CoalitionNegotiationView: View {
    let negotiation: CoalitionNegotiation
    let onConclude: (Set<String>) -> Void

    @State private var accepted: Set<String>

    init(negotiation: CoalitionNegotiation, onConclude: @escaping (Set<String>) -> Void) {
        self.negotiation = negotiation
        self.onConclude = onConclude
        // Voreinstellung: alle Forderungen zunächst zugesagt.
        _accepted = State(initialValue: Set(negotiation.demands.map(\.id)))
    }

    private var accent: Color { PartyPresentation.color(for: negotiation.partnerID) }

    var body: some View {
        ZStack {
            GameTheme.dramaticBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    intro
                    VStack(spacing: 12) {
                        ForEach(negotiation.demands) { demand in
                            demandCard(demand)
                        }
                    }
                    moodHint
                    concludeButton
                }
                .padding(20)
            }
        }
        .foregroundStyle(GameTheme.primaryText)
        .onAppear { Haptics.impact(.medium) }
    }

    // MARK: Kopf

    private var header: some View {
        VStack(spacing: 8) {
            FlagRibbon(height: 5).frame(width: 90)
            Text("KOALITIONSGESPRÄCHE")
                .font(.caption.weight(.heavy)).tracking(2.5)
                .foregroundStyle(GameTheme.gold)
            HStack(spacing: 10) {
                Circle().fill(accent.opacity(0.2)).frame(width: 30, height: 30)
                    .overlay(Image(systemName: "person.2.fill").font(.caption).foregroundStyle(accent))
                Text("Verhandlung mit \(negotiation.partnerName)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.primaryText)
                    .multilineTextAlignment(.center)
            }
            HStack(spacing: 6) {
                Text(String(format: "%.0f %%", negotiation.combinedShare))
                    .font(.caption.weight(.bold)).monospacedDigit()
                Text(negotiation.formsMajority ? "gemeinsame Mehrheit" : "knappe Basis")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(negotiation.formsMajority ? GameTheme.green : GameTheme.amber)
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(Capsule().fill((negotiation.formsMajority ? GameTheme.green : GameTheme.amber).opacity(0.16)))
            }
            .foregroundStyle(GameTheme.secondaryText)
        }
        .padding(.top, 36)
    }

    private var intro: some View {
        Text("\(negotiation.partnerName) legt die Bedingungen für das Bündnis auf den Tisch. Jede Zusage stimmt den Partner milder – kostet dich aber an anderer Stelle.")
            .font(.callout)
            .foregroundStyle(GameTheme.secondaryText)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Forderung

    private func demandCard(_ demand: AgendaItem) -> some View {
        let isAccepted = accepted.contains(demand.id)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "quote.opening")
                    .font(.caption)
                    .foregroundStyle(accent)
                Text(demand.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(GameTheme.primaryText)
                Spacer(minLength: 0)
            }
            Text("„\(demand.demand)“")
                .font(.footnote)
                .foregroundStyle(GameTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                choiceButton(title: "Zusagen", systemImage: "checkmark", isOn: isAccepted, color: GameTheme.green) {
                    accepted.insert(demand.id)
                }
                choiceButton(title: "Ablehnen", systemImage: "xmark", isOn: !isAccepted, color: GameTheme.red) {
                    accepted.remove(demand.id)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GameTheme.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isAccepted ? GameTheme.green.opacity(0.4) : GameTheme.hairline, lineWidth: 1)
        )
    }

    private func choiceButton(title: String, systemImage: String, isOn: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.impact(.light)
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { action() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage).font(.caption2.weight(.bold))
                Text(title).font(.caption.weight(.bold))
            }
            .foregroundStyle(isOn ? Color.black.opacity(0.85) : GameTheme.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isOn ? color : GameTheme.surfaceSunken)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Stimmung & Abschluss

    private var moodHint: some View {
        let count = accepted.count
        let total = negotiation.demands.count
        let (text, color): (String, Color) = {
            if count == total { return ("\(negotiation.partnerName) ist rundum zufrieden – ein stabiles Bündnis.", GameTheme.green) }
            if count == 0 { return ("\(negotiation.partnerName) fühlt sich übergangen – das Bündnis startet zerrüttet.", GameTheme.red) }
            return ("\(negotiation.partnerName) macht Abstriche – die Koalition steht, aber es knirscht.", GameTheme.amber)
        }()
        return HStack(spacing: 8) {
            Image(systemName: "heart.text.square.fill").font(.footnote)
            Text(text).font(.caption).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundStyle(color)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(color.opacity(0.10)))
    }

    private var concludeButton: some View {
        Button {
            onConclude(accepted)
        } label: {
            Label("Koalitionsvertrag besiegeln", systemImage: "signature")
        }
        .buttonStyle(PrimaryActionButtonStyle())
    }
}
