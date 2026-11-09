import RegiereDeutschlandCore
import SwiftUI

/// Ereignis als Szene: Bild mit Ortszeile, Lagebericht aus dem Kabinett,
/// Entscheidungsoptionen und ein kurzer „Beschlossen“-Stempel beim Wählen.
struct EventCard: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let event: GameEvent
    let cost: (DecisionOption) -> Int
    let canAfford: (DecisionOption) -> Bool
    let onChoose: (DecisionOption) -> Void

    @State private var stampedOptionID: String?
    @State private var appeared = false

    private var category: CategoryStyle {
        CategoryPresentation.style(for: event.category)
    }
    private var country: GameCountry { gamePresentation.country }
    private var advisor: Advisor { Advisor.of(AdvisorRole(category: event.category), in: country) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hero
            VStack(alignment: .leading, spacing: 16) {
                briefing

                Text(L(event.description))
                    .font(.callout)
                    .foregroundStyle(GameTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                SectionHeader(title: L("Deine Entscheidung"), systemImage: "hand.tap.fill")

                VStack(spacing: 10) {
                    ForEach(Array(event.options.enumerated()), id: \.element.id) { index, option in
                        OptionCard(
                            option: option,
                            index: index,
                            accent: category.color,
                            cost: cost(option),
                            affordable: canAfford(option)
                        ) {
                            decide(option)
                        }
                        .opacity(stampedOptionID == nil || stampedOptionID == option.id ? 1 : 0.35)
                        .overlay {
                            if stampedOptionID == option.id { DecisionStamp() }
                        }
                    }
                }
                .disabled(stampedOptionID != nil)
            }
            .padding(18)
        }
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(GameTheme.surface))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(category.color.opacity(0.35), lineWidth: 1))
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appeared = true }
            let urgent = event.category == .security || event.category == .foreignPolicy
            SoundManager.shared.play(urgent ? .teletype : .paper)
        }
    }

    // MARK: Bild & Ortszeile

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = Artwork.image("event-\(event.category.rawValue)-\(country.rawValue)")
                ?? Artwork.image("event-\(event.category.rawValue)") {
                Color.clear
                    .frame(maxWidth: .infinity).frame(height: 168)
                    .overlay {
                        image.resizable().scaledToFill()
                            .scaleEffect(appeared ? 1 : 1.08)
                    }
                    .clipped()
            } else {
                ZStack {
                    LinearGradient(colors: [category.color.opacity(0.42), GameTheme.surfaceSunken],
                                   startPoint: .topTrailing, endPoint: .bottomLeading)
                    Image(systemName: category.icon)
                        .font(.system(size: 120, weight: .bold))
                        .foregroundStyle(category.color.opacity(0.16))
                        .rotationEffect(.degrees(-8))
                        .offset(x: 90, y: -6)
                        .scaleEffect(appeared ? 1 : 1.15)
                }
                .frame(maxWidth: .infinity).frame(height: 168)
                .clipped()
            }
            LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    BreakingTag()
                    CategoryChip(label: category.label, icon: category.icon, color: category.color)
                }
                Text(verbatim: "\(country.capital.uppercased()) · \(event.year)")
                    .font(.caption.weight(.heavy)).tracking(2)
                    .foregroundStyle(.white.opacity(0.8))
                Text(L(event.title))
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
        }
        .frame(height: 168)
    }

    // MARK: Lagebericht

    private var briefing: some View {
        HStack(alignment: .top, spacing: 12) {
            AdvisorPortrait(advisor: advisor)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Text(advisor.name).font(.footnote.weight(.bold))
                    Text("·").foregroundStyle(GameTheme.tertiaryText)
                    Text(advisor.title(country: country, presentation: gamePresentation))
                        .font(.caption)
                        .foregroundStyle(GameTheme.tertiaryText)
                        .lineLimit(1).minimumScaleFactor(0.8)
                }
                Text(verbatim: "„\(L(event.headline))“")
                    .font(.system(.body, design: .serif).weight(.semibold))
                    .foregroundStyle(GameTheme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 14,
                                               bottomTrailingRadius: 14, topTrailingRadius: 14, style: .continuous)
                            .fill(advisor.role.color.opacity(0.1))
                    )
            }
        }
    }

    private func decide(_ option: DecisionOption) {
        guard stampedOptionID == nil else { return }
        Haptics.impact(.rigid)
        SoundManager.shared.play(.stamp)
        withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) { stampedOptionID = option.id }
        Task {
            try? await Task.sleep(for: .milliseconds(650))
            onChoose(option)
        }
    }
}

/// Der „Beschlossen“-Stempel über der gewählten Option.
private struct DecisionStamp: View {
    @Environment(GamePresentation.self) private var p
    @State private var landed = false

    var body: some View {
        Text(p.pick("BESCHLOSSEN", "DECIDED", "ADOPTÉ"))
            .font(.system(size: 22, weight: .black, design: .serif))
            .tracking(3)
            .foregroundStyle(GameTheme.red)
            .padding(.horizontal, 14).padding(.vertical, 6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(GameTheme.red, lineWidth: 3))
            .rotationEffect(.degrees(-9))
            .scaleEffect(landed ? 1 : 2.2)
            .opacity(landed ? 0.92 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { landed = true }
            }
            .allowsHitTesting(false)
    }
}

/// Einzelne Entscheidungsoption.
private struct OptionCard: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let option: DecisionOption
    let index: Int
    let accent: Color
    let cost: Int
    let affordable: Bool
    let action: () -> Void

    private let letters = ["A", "B", "C", "D", "E"]

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    Text(L(letters[safe: index] ?? "•"))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(accent)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(accent.opacity(0.15)))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(L(option.title))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(GameTheme.primaryText)
                            .multilineTextAlignment(.leading)
                        Text(L(option.advisoryNote))
                            .font(.caption)
                            .foregroundStyle(GameTheme.secondaryText)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 4)

                    VStack(spacing: 6) {
                        CostDots(cost: cost, accent: accent)
                        Image(systemName: affordable ? "chevron.right" : "lock.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(affordable ? GameTheme.tertiaryText : GameTheme.red)
                    }
                }

                if !affordable {
                    Text(L("Zu teuer – nicht genug politisches Kapital."))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(GameTheme.red)
                        .padding(.leading, 46)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .opacity(affordable ? 1 : 0.55)
        }
        .buttonStyle(OptionCardButtonStyle(accent: accent))
        .disabled(!affordable)
        .accessibilityHint(L(affordable ? option.advisoryNote : L("Nicht genug politisches Kapital")))
    }
}

/// Kapitalkosten als Punkte (gefüllt = Kosten).
private struct CostDots: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let cost: Int
    let accent: Color

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<DecisionCost.maximum, id: \.self) { index in
                Circle()
                    .fill(index < cost ? accent : GameTheme.surfaceElevated)
                    .frame(width: 6, height: 6)
            }
        }
        .accessibilityLabel(L("Kosten: \(L(cost)) von \(L(DecisionCost.maximum))"))
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
