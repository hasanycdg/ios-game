import RegiereDeutschlandCore
import SwiftUI

/// Ereignis als "Breaking News"-Karte samt Entscheidungsoptionen.
struct EventCard: View {
    let event: GameEvent
    let onChoose: (DecisionOption) -> Void

    @State private var showContext = false

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

            // Historischer Hintergrund (einklappbar)
            if !event.historicalContext.summary.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        showContext.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.closed.fill").font(.caption2)
                        Text("Historischer Hintergrund")
                            .font(.caption.weight(.semibold))
                        Image(systemName: showContext ? "chevron.up" : "chevron.down")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(GameTheme.gold)
                }
                .buttonStyle(.plain)

                if showContext {
                    Text(event.historicalContext.summary)
                        .font(.footnote)
                        .foregroundStyle(GameTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(GameTheme.surfaceSunken)
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            Divider().overlay(GameTheme.hairline)

            SectionHeader(title: "Deine Entscheidung", systemImage: "hand.tap.fill")

            VStack(spacing: 10) {
                ForEach(Array(event.options.enumerated()), id: \.element.id) { index, option in
                    OptionCard(option: option, index: index, accent: category.color) {
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
    let action: () -> Void

    private let letters = ["A", "B", "C", "D", "E"]

    private var reactions: [StakeholderReaction] {
        StakeholderAnalysis.reactions(for: option).filter { $0.stance != .neutral }
    }

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

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(GameTheme.tertiaryText)
                }

                if !reactions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(reactions.prefix(5)) { reaction in
                                ReactionChip(reaction: reaction)
                            }
                        }
                    }
                    .padding(.leading, 46)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(OptionCardButtonStyle(accent: accent))
        .accessibilityHint(option.advisoryNote)
    }
}

private struct ReactionChip: View {
    let reaction: StakeholderReaction

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: reaction.icon).font(.system(size: 9))
            Text(reaction.name).font(.system(size: 10.5, weight: .semibold))
            Image(systemName: reaction.symbol).font(.system(size: 8, weight: .bold))
        }
        .foregroundStyle(reaction.color)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(Capsule().fill(reaction.color.opacity(0.14)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reaction.name): \(reaction.stance == .positive ? "dafür" : "dagegen")")
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
