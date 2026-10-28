import RegiereDeutschlandCore
import SwiftUI

/// Welt-Tab: aktive Außenpolitik gegenüber den wichtigsten Partnern.
struct DiplomacyTab: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                masthead
                ForEach(viewModel.country.diplomaticPartners, id: \.self) { partner in
                    PartnerCard(
                        partner: partner,
                        relation: viewModel.diplomacy.relation(partner),
                        capital: viewModel.politicalCapital
                    ) { actionID in
                        Haptics.impact(.light)
                        viewModel.takeDiplomaticAction(partner, actionID)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }

    private var masthead: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                FlagRibbon(height: 4).frame(width: 40)
                Text(L("DEUTSCHLAND IN DER WELT"))
                    .font(.caption2.weight(.bold)).tracking(1.6)
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer(minLength: 0)
            }
            HStack(alignment: .firstTextBaseline) {
                Text(L("Außenpolitik"))
                    .font(.system(size: 30, weight: .heavy, design: .serif))
                    .foregroundStyle(GameTheme.primaryText)
                Spacer(minLength: 0)
                Text(verbatim: L("\(L(viewModel.state.currentYear))"))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.gold).monospacedDigit()
            }
            Rectangle().fill(GameTheme.hairlineStrong).frame(height: 1)
        }
    }
}

private struct PartnerCard: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let partner: DiplomaticPartner
    let relation: Int
    let capital: Int
    let onAction: (String) -> Void

    private var color: Color { GameTheme.statusColor(for: relation) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: partner.icon)
                    .font(.headline)
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(color.opacity(0.15)))
                VStack(alignment: .leading, spacing: 1) {
                    Text(L(partner.title))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(GameTheme.primaryText)
                    Text(L(DiplomaticState.label(for: relation)))
                        .font(.caption2).foregroundStyle(GameTheme.tertiaryText)
                }
                Spacer(minLength: 0)
                Text(L("\(L(relation))"))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(color).monospacedDigit()
            }

            ValueBar(value: relation, height: 7)

            VStack(spacing: 8) {
                ForEach(DiplomaticActionCatalog.actions(for: partner, country: gamePresentation.country)) { action in
                    actionButton(action)
                }
            }
        }
        .gameCard(padding: 16)
    }

    private func actionButton(_ action: DiplomaticAction) -> some View {
        let affordable = capital >= action.cost
        return Button {
            onAction(action.id)
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L(action.title))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(GameTheme.primaryText)
                    Text(L(action.detail))
                        .font(.caption2)
                        .foregroundStyle(GameTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 4)
                Text(L("\(L(action.cost))"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(GameTheme.gold)
                    .monospacedDigit()
                Image(systemName: "hexagon.fill").font(.caption2).foregroundStyle(GameTheme.gold)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GameTheme.surfaceSunken))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(GameTheme.hairline, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!affordable)
        .opacity(affordable ? 1 : 0.5)
    }
}
