import RegiereDeutschlandCore
import SwiftUI

/// Haupt-Tab: Nationaler Lagebericht + der Entscheidungs-Loop.
struct SituationTab: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                situationHeader
                quickStatStrip
                CoalitionCard(coalition: viewModel.coalition)
                if viewModel.corruption > 0 {
                    ShadowFundsCard(corruption: viewModel.corruption)
                }
                ElectionBarometer(
                    projection: viewModel.electionProjection,
                    currentYear: viewModel.state.currentYear
                )
                phaseContent
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }

    // MARK: Kopfbereich

    private var situationHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                FlagRibbon(height: 4).frame(width: 46)
                Text("AMTSZEIT · \(viewModel.yearsInOffice + 1). JAHR")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(GameTheme.secondaryText)
                    .lineLimit(1)
                Spacer(minLength: 8)
                CapitalBadge(value: viewModel.politicalCapital, maximum: viewModel.maxCapital)
            }

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(verbatim: "\(viewModel.state.currentYear)")
                            .font(.system(size: 46, weight: .bold, design: .rounded))
                            .foregroundStyle(GameTheme.primaryText)
                            .monospacedDigit()
                        Text("/ 2026")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(GameTheme.tertiaryText)
                    }

                    HStack(spacing: 6) {
                        Text("Lage:")
                            .font(.subheadline)
                            .foregroundStyle(GameTheme.secondaryText)
                        Text(viewModel.nationMood.word)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(viewModel.nationMood.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(viewModel.nationMood.color.opacity(0.15)))
                    }

                    MomentumBadge(momentum: viewModel.state.shortTermMomentum)
                }

                Spacer(minLength: 0)

                ApprovalRing(value: viewModel.state.governmentApproval, size: 104)
            }
        }
        .gameCard(padding: 18)
    }

    // MARK: Werte-Kurzleiste

    private var quickStatStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Nationale Lage", systemImage: "gauge.medium",
                          accessory: "Index \(viewModel.governanceIndex)")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(VisibleMetric.allCases, id: \.self) { metric in
                        let value = viewModel.state.visible.value(for: metric)
                        let style = MetricPresentation.style(for: metric)
                        VStack(spacing: 6) {
                            Image(systemName: style.icon)
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(GameTheme.statusColor(for: value))
                            Text("\(value)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(GameTheme.primaryText)
                                .monospacedDigit()
                            Text(style.label)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(GameTheme.tertiaryText)
                                .lineLimit(1)
                        }
                        .frame(width: 72)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(GameTheme.surface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(GameTheme.hairline, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: Phasen

    @ViewBuilder
    private var phaseContent: some View {
        switch viewModel.phase {
        case .event:
            if let event = viewModel.currentEvent {
                EventCard(
                    event: event,
                    cost: { viewModel.cost(of: $0) },
                    canAfford: { viewModel.canAfford($0) }
                ) { option in
                    Haptics.impact(.medium)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        viewModel.choose(option)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                waitingCard
            }
        case .result(let result):
            DecisionResultView(result: result) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    viewModel.continueAfterResult()
                }
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        case .noEvent:
            NoEventCard(year: viewModel.state.currentYear) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    viewModel.continueWithoutEvent()
                }
            }
        case .encounter, .campaign, .election, .coalitionTalks, .gameOver:
            // Wird als Vollbild-Overlay im Container dargestellt.
            waitingCard
        }
    }

    private var waitingCard: some View {
        EmptyStateView(
            icon: "hourglass",
            title: "Einen Moment …",
            message: "Der nächste Vorgang wird vorbereitet."
        )
        .gameCard()
    }
}

/// "Ruhiges Jahr" – kein Event hinterlegt.
private struct NoEventCard: View {
    let year: Int
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(GameTheme.gold)
                Text("Ein ruhiges Jahr")
                    .font(.headline)
                    .foregroundStyle(GameTheme.primaryText)
            }
            Text("\(String(year)) verläuft ohne große Entscheidungen. Die Verwaltung arbeitet im Regelbetrieb – nutze die Ruhe.")
                .font(.callout)
                .foregroundStyle(GameTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: onContinue) {
                Label("Jahr abschließen", systemImage: "arrow.right")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
        .gameCard(padding: 18)
    }
}
