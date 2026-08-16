import RegiereDeutschlandCore
import SwiftUI

/// Ereignis als "Breaking News"-Karte samt Entscheidungsoptionen.
struct EventCard: View {
    let event: GameEvent
    let cost: (DecisionOption) -> Int
    let canAfford: (DecisionOption) -> Bool
    let onChoose: (DecisionOption) -> Void

    private var category: CategoryStyle {
        CategoryPresentation.style(for: event.category)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Kopf: Breaking-Tag + Kategorie
            HStack(spacing: 8) {
                BreakingTag()
                CategoryChip(label: category.label, icon: category.icon, color: category.color)
                Spacer(minLength: 0)
            }

            // Schlagzeile
            VStack(alignment: .leading, spacing: 8) {
                Text(event.headline)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(event.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(category.color)
            }

            Text(event.description)
                .font(.callout)
                .foregroundStyle(GameTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Divider().overlay(GameTheme.hairline)

            SectionHeader(title: "Deine Entscheidung", systemImage: "hand.tap.fill")

            VStack(spacing: 10) {
                ForEach(Array(event.options.enumerated()), id: \.element.id) { index, option in
                    OptionCard(
                        option: option,
                        index: index,
                        accent: category.color,
                        cost: cost(option),
                        affordable: canAfford(option)
                    ) {
                        onChoose(option)
                    }
                }
            }
        }
        .gameCard(padding: 18, tint: category.color)
    }
}

/// Einzelne Entscheidungsoption.
private struct OptionCard: View {
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
                    Text(letters[safe: index] ?? "•")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(accent)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(accent.opacity(0.15)))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(option.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(GameTheme.primaryText)
                            .multilineTextAlignment(.leading)
                        Text(option.advisoryNote)
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
                    Text("Zu teuer – nicht genug politisches Kapital.")
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
        .accessibilityHint(affordable ? option.advisoryNote : "Nicht genug politisches Kapital")
    }
}

/// Kapitalkosten als Punkte (gefüllt = Kosten).
private struct CostDots: View {
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
        .accessibilityLabel("Kosten: \(cost) von \(DecisionCost.maximum)")
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
