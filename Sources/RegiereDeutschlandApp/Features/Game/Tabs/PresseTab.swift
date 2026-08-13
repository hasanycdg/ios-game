import RegiereDeutschlandCore
import SwiftUI

/// Presse-Tab: Welt- und Deutschland-Schlagzeilen des Jahres plus reaktive
/// Meldungen zur Politik des Spielers.
struct PresseTab: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                masthead

                let domestic = viewModel.domesticNews
                if !domestic.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Schlagzeilen zu deiner Politik", systemImage: "megaphone.fill")
                        ForEach(domestic) { NewsCard(item: $0) }
                    }
                }

                let world = viewModel.worldNews
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Deutschland & Welt", systemImage: "globe",
                                  accessory: String(viewModel.state.currentYear))
                    if world.isEmpty {
                        EmptyStateView(
                            icon: "newspaper",
                            title: "Ruhige Nachrichtenlage",
                            message: "Für dieses Jahr sind keine Meldungen hinterlegt."
                        )
                        .gameCard()
                    } else {
                        ForEach(world) { NewsCard(item: $0) }
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
                Text("DIE LAGE DER NATION")
                    .font(.caption2.weight(.bold))
                    .tracking(1.6)
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer(minLength: 0)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Presse")
                    .font(.system(size: 30, weight: .heavy, design: .serif))
                    .foregroundStyle(GameTheme.primaryText)
                Spacer(minLength: 0)
                Text(verbatim: "\(viewModel.state.currentYear)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.gold)
                    .monospacedDigit()
            }
            Rectangle().fill(GameTheme.hairlineStrong).frame(height: 1)
        }
    }
}
