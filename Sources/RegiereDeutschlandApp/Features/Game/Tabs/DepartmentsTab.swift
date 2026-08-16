import RegiereDeutschlandCore
import SwiftUI

/// Ressort-Übersicht: alle acht sichtbaren Kennwerte im Detail.
struct DepartmentsTab: View {
    @ObservedObject var viewModel: GameViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                indexHeader
                BudgetCard(budget: viewModel.budget)
                PolicySection(policies: viewModel.policies, capital: viewModel.politicalCapital) { policy, level in
                    Haptics.impact(.light)
                    return viewModel.attemptPolicyChange(policy, to: level)
                }
                trendCard

                ForEach(MetricPresentation.groups, id: \.title) { group in
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: group.title, systemImage: "square.grid.2x2.fill")
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(group.metrics, id: \.self) { metric in
                                let style = MetricPresentation.style(for: metric)
                                MetricCard(
                                    title: style.label,
                                    icon: style.icon,
                                    value: viewModel.state.visible.value(for: metric),
                                    blurb: style.blurb
                                )
                            }
                        }
                    }
                }

                cabinetSection
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }

    private var cabinetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Kabinett", systemImage: "person.crop.rectangle.stack.fill",
                          accessory: "Neubesetzung: 2 Kapital")
            Text("Starke Ressortchefs verbessern ihren Bereich Jahr für Jahr, überforderte schaden ihm.")
                .font(.caption)
                .foregroundStyle(GameTheme.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 10) {
                ForEach(Ministry.allCases, id: \.self) { ministry in
                    CabinetRow(
                        ministry: ministry,
                        minister: viewModel.cabinet.minister(ministry),
                        canAfford: viewModel.politicalCapital >= 2
                    ) {
                        Haptics.impact(.light)
                        viewModel.reshuffleMinister(ministry)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Verlauf seit Amtsbeginn", systemImage: "chart.xyaxis.line")
            if viewModel.annualHistory.count >= 2 {
                LineTrendChart(
                    years: viewModel.annualHistory.map(\.year),
                    series: [
                        ChartSeries(name: "Index", color: GameTheme.gold,
                                    values: viewModel.annualHistory.map { Double($0.governanceIndex) }),
                        ChartSeries(name: "Zustimmung", color: GameTheme.teal,
                                    values: viewModel.annualHistory.map { Double($0.approval) })
                    ]
                )
                .gameCard(padding: 16)
            } else {
                Text("Der Verlauf erscheint nach dem ersten Jahreswechsel.")
                    .font(.caption)
                    .foregroundStyle(GameTheme.tertiaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .gameCard(padding: 16)
            }
        }
    }

    private var indexHeader: some View {
        HStack(spacing: 16) {
            ApprovalRing(value: viewModel.governanceIndex, size: 96, caption: "Index")
            VStack(alignment: .leading, spacing: 8) {
                Text("Regierungsindex")
                    .font(.headline)
                    .foregroundStyle(GameTheme.primaryText)
                Text("Durchschnitt aller Ressorts. Ein Wert für die Gesamtverfassung Deutschlands unter deiner Führung.")
                    .font(.caption)
                    .foregroundStyle(GameTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                StatusPill(value: viewModel.governanceIndex)
            }
            Spacer(minLength: 0)
        }
        .gameCard(padding: 18)
    }
}

private struct CabinetRow: View {
    let ministry: Ministry
    let minister: Minister
    let canAfford: Bool
    let onReshuffle: () -> Void

    private var color: Color { GameTheme.statusColor(for: minister.competence) }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: ministry.icon)
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(color.opacity(0.15)))
                VStack(alignment: .leading, spacing: 1) {
                    Text("Ministerium für \(ministry.title)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(GameTheme.primaryText)
                    Text(minister.name)
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 1) {
                    Text("\(minister.competence)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(color).monospacedDigit()
                    Text(minister.ratingLabel)
                        .font(.caption2).foregroundStyle(GameTheme.tertiaryText)
                }
            }
            ValueBar(value: minister.competence, height: 6)
            Button(action: onReshuffle) {
                Label("Neu besetzen · 2 Kapital", systemImage: "arrow.triangle.2.circlepath")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(canAfford ? GameTheme.primaryText : GameTheme.tertiaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(GameTheme.surfaceElevated))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(GameTheme.hairline, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(!canAfford)
            .opacity(canAfford ? 1 : 0.55)
        }
        .gameCard(padding: 14)
    }
}
