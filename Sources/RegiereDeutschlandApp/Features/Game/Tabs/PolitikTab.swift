import RegiereDeutschlandCore
import SwiftUI

/// Politik-Tab: Parteienlandschaft (Umfrage, Spektrum, Lager) und Wählerschaft.
struct PolitikTab: View {
    @ObservedObject var viewModel: GameViewModel

    private var landscape: PartyLandscape { viewModel.partyLandscape }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                masthead
                blocSummary
                pollSection
                spectrumSection
                electorateSection
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }

    // MARK: Kopf

    private var masthead: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                FlagRibbon(height: 4).frame(width: 40)
                Text("PARTEIEN & WÄHLER")
                    .font(.caption2.weight(.bold)).tracking(1.6)
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer(minLength: 0)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Politik")
                    .font(.system(size: 30, weight: .heavy, design: .serif))
                    .foregroundStyle(GameTheme.primaryText)
                Spacer(minLength: 0)
                Text(verbatim: "\(viewModel.state.currentYear)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.gold).monospacedDigit()
            }
            Rectangle().fill(GameTheme.hairlineStrong).frame(height: 1)
        }
    }

    // MARK: Lager

    private var blocSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                blocTile(title: "Regierungslager", value: landscape.governingBloc, color: GameTheme.gold)
                blocTile(title: "Opposition", value: landscape.oppositionBloc, color: GameTheme.blue)
            }
            if let opp = landscape.strongestOpposition {
                HStack(spacing: 8) {
                    Image(systemName: "person.bust.fill")
                        .font(.footnote).foregroundStyle(PartyPresentation.color(for: opp.id))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Oppositionsführer:in")
                            .font(.caption2).foregroundStyle(GameTheme.tertiaryText)
                        Text("\(PartyPresentation.leader(for: opp.id)) · \(opp.name)")
                            .font(.caption.weight(.bold)).foregroundStyle(GameTheme.primaryText)
                    }
                    Spacer(minLength: 0)
                    Text(String(format: "%.1f %%", opp.support))
                        .font(.caption.weight(.bold)).foregroundStyle(GameTheme.primaryText).monospacedDigit()
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GameTheme.surface))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(GameTheme.hairline, lineWidth: 1))
            }
        }
    }

    private func blocTile(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.bold)).tracking(0.4)
                .foregroundStyle(GameTheme.tertiaryText)
            Text(String(format: "%.0f %%", value))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(color).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .gameCard(padding: 14, tint: color)
    }

    // MARK: Umfrage

    private var pollSection: some View {
        let maxSupport = landscape.parties.map(\.support).max() ?? 1
        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Sonntagsfrage", systemImage: "chart.bar.xaxis",
                          accessory: "630 Sitze")
            VStack(spacing: 10) {
                ForEach(landscape.parties) { party in
                    pollRow(party, maxSupport: maxSupport)
                }
            }
        }
    }

    private func pollRow(_ party: Party, maxSupport: Double) -> some View {
        let color = PartyPresentation.color(for: party.id)
        return VStack(spacing: 8) {
            HStack(spacing: 10) {
                Circle().fill(color).frame(width: 10, height: 10)
                Text(party.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(GameTheme.primaryText)
                if party.role != .opposition {
                    Text(party.role == .governing ? "Regierung" : "Koalition")
                        .font(.system(size: 9.5, weight: .heavy))
                        .foregroundStyle(GameTheme.gold)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(GameTheme.gold.opacity(0.15)))
                }
                Spacer(minLength: 0)
                Text(String(format: "%.1f %%", party.support))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(GameTheme.primaryText).monospacedDigit()
            }
            HStack(spacing: 10) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(GameTheme.surfaceSunken)
                        Capsule().fill(color)
                            .frame(width: max(6, geo.size.width * CGFloat(party.support / max(1, maxSupport))))
                    }
                }
                .frame(height: 7)
                Text("\(party.seats)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(GameTheme.tertiaryText).monospacedDigit()
                    .frame(width: 34, alignment: .trailing)
            }
        }
        .gameCard(padding: 12)
    }

    // MARK: Spektrum

    private var spectrumSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Politisches Spektrum", systemImage: "arrow.left.and.right")
            VStack(spacing: 8) {
                GeometryReader { geo in
                    let width = geo.size.width
                    let centerY: CGFloat = 34
                    ZStack {
                        Rectangle().fill(GameTheme.hairlineStrong)
                            .frame(width: width, height: 2).position(x: width / 2, y: centerY)
                        ForEach(landscape.parties) { party in
                            let size = dotSize(for: party.support)
                            let x = min(max(size / 2, CGFloat(party.spectrum) * width), width - size / 2)
                            Circle()
                                .fill(PartyPresentation.color(for: party.id))
                                .frame(width: size, height: size)
                                .overlay(Circle().stroke(GameTheme.surface, lineWidth: 1.5))
                                .position(x: x, y: centerY)
                        }
                    }
                }
                .frame(height: 68)

                HStack {
                    Text("LINKS").font(.caption2.weight(.bold)).foregroundStyle(GameTheme.tertiaryText)
                    Spacer()
                    Text("MITTE").font(.caption2.weight(.bold)).foregroundStyle(GameTheme.tertiaryText)
                    Spacer()
                    Text("RECHTS").font(.caption2.weight(.bold)).foregroundStyle(GameTheme.tertiaryText)
                }
            }
            .gameCard(padding: 16)
        }
    }

    private func dotSize(for support: Double) -> CGFloat {
        min(34, 12 + CGFloat(support) * 0.55)
    }

    // MARK: Wählerschaft

    private var electorateSection: some View {
        let weighted = viewModel.weightedPopulationApproval
        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Wählerschaft", systemImage: "person.3.fill",
                          accessory: "Stimmung \(weighted)")

            HStack(spacing: 16) {
                ApprovalRing(value: weighted, size: 84, caption: "Volk")
                VStack(alignment: .leading, spacing: 6) {
                    Text("Die Bevölkerung ist im Schnitt \(NationMood.moodWord(forApproval: weighted)).")
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    if let happiest = viewModel.happiestGroup {
                        Text("Stärkster Rückhalt: \(happiest.name)")
                            .font(.caption2).foregroundStyle(GameTheme.green)
                    }
                    if let unhappiest = viewModel.unhappiestGroup {
                        Text("Größter Unmut: \(unhappiest.name)")
                            .font(.caption2).foregroundStyle(GameTheme.red)
                    }
                }
                Spacer(minLength: 0)
            }
            .gameCard(padding: 16)

            VStack(spacing: 10) {
                ForEach(viewModel.populationGroupsBySize) { group in
                    GroupRow(group: group)
                }
            }
        }
    }
}

/// Zeile für eine Bevölkerungsgruppe.
private struct GroupRow: View {
    let group: PopulationGroup

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: NationMood.moodEmoji(forApproval: group.approval))
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(GameTheme.statusColor(for: group.approval))
                    .frame(width: 24)
                Text(group.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(GameTheme.primaryText)
                Spacer(minLength: 0)
                Text("\(Int((group.populationShare * 100).rounded())) %")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(GameTheme.tertiaryText)
                Text("\(group.approval)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.statusColor(for: group.approval))
                    .monospacedDigit()
                    .frame(width: 30, alignment: .trailing)
            }
            ValueBar(value: group.approval, height: 7)
        }
        .gameCard(padding: 14)
    }
}
