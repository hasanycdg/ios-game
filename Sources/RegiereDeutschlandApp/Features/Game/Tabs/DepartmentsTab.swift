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
            }
            .padding(16)
            .padding(.bottom, 24)
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
