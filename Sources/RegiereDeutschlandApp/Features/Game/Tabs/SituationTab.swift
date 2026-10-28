import RegiereDeutschlandCore
import SwiftUI

/// Haupt-Tab: Nationaler Lagebericht + der Entscheidungs-Loop.
struct SituationTab: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                situationHeader
                if let scenario = FutureScenario.chapter(in: viewModel.state) {
                    futureScenarioCard(scenario)
                }
                quickStatStrip
                // Der Entscheidungs-Loop steht bewusst weit oben – er ist die
                // Hauptaktion des Tabs, nicht das Ende einer langen Karten-Liste.
                phaseContent
                CoalitionCard(coalition: viewModel.coalition)
                PartyWingsCard(wings: viewModel.partyWings)
                if viewModel.corruption > 0 {
                    ShadowFundsCard(corruption: viewModel.corruption)
                }
                ElectionBarometer(
                    projection: viewModel.electionProjection,
                    currentYear: viewModel.state.currentYear
                )
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }

    // MARK: Kopfbereich

    private func futureScenarioCard(_ scenario: FutureScenario) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("ZUKUNFT 2050 · \(L(String(scenario.years.lowerBound)))–\(L(String(scenario.years.upperBound)))"))
                .font(.caption2.weight(.bold))
                .foregroundStyle(GameTheme.gold)
            Text(L(scenario.title))
                .font(.headline)
                .foregroundStyle(GameTheme.primaryText)
            Text(L(scenario.summary))
                .font(.caption)
                .foregroundStyle(GameTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            let completed = FutureScenario.completedDecisions(in: viewModel.state)
            ProgressView(value: Double(completed), total: Double(FutureScenario.decisionsPerYear))
                .tint(GameTheme.gold)
                .accessibilityLabel(L("Szenariofortschritt"))
                .accessibilityValue(L("\(L(completed)) von \(L(FutureScenario.decisionsPerYear)) Entscheidungen"))
            Text(L("\(L(completed)) von \(L(FutureScenario.decisionsPerYear)) Szenarioentscheidungen in diesem Jahr abgeschlossen"))
                .font(.caption2)
                .foregroundStyle(GameTheme.secondaryText)
            if viewModel.state.historicalFlags.contains("scenario_world_war") {
                Text(L("Dein Verlauf: Weltkrieg und seine Folgen"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(GameTheme.red)
            } else if viewModel.state.historicalFlags.contains("scenario_war_avoided") {
                Text(L("Dein Verlauf: Der Weltkrieg wurde verhindert"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(GameTheme.green)
            }
        }
        .gameCard(tint: GameTheme.gold)
    }

    private var situationHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Circle()
                    .fill(PartyPresentation.color(for: viewModel.playerParty.id).opacity(0.18))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Text(L(viewModel.playerParty.shortName.prefix(3)))
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(PartyPresentation.color(for: viewModel.playerParty.id))
                    )
                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.playerName)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(GameTheme.primaryText)
                        .lineLimit(1)
                    Text(L("\(L(viewModel.playerParty.name)) · \(L(viewModel.yearsInOffice + 1)). Amtsjahr"))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(GameTheme.secondaryText)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                CapitalBadge(value: viewModel.politicalCapital, maximum: viewModel.maxCapital)
            }

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(verbatim: L("\(L(viewModel.state.currentYear))"))
                            .font(.system(size: 46, weight: .bold, design: .rounded))
                            .foregroundStyle(GameTheme.primaryText)
                            .monospacedDigit()
                        Text(L("/ \(L(viewModel.finalYear))"))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(GameTheme.tertiaryText)
                    }

                    HStack(spacing: 6) {
                        Text(L("Lage:"))
                            .font(.subheadline)
                            .foregroundStyle(GameTheme.secondaryText)
                        Text(L(viewModel.nationMood.word))
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
            SectionHeader(title: L("Nationale Lage"), systemImage: "gauge.medium",
                          accessory: L("Index \(L(viewModel.governanceIndex))"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(VisibleMetric.allCases, id: \.self) { metric in
                        let value = viewModel.state.visible.value(for: metric)
                        let style = MetricPresentation.style(for: metric)
                        VStack(spacing: 6) {
                            Image(systemName: style.icon)
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(GameTheme.statusColor(for: value))
                            Text(L("\(L(value))"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(GameTheme.primaryText)
                                .monospacedDigit()
                            Text(L(style.label))
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
        case .encounter, .campaign, .election, .briefing, .coalitionTalks, .coalitionNegotiation, .gameOver:
            // Wird als Vollbild-Overlay im Container dargestellt.
            waitingCard
        }
    }

    private var waitingCard: some View {
        EmptyStateView(
            icon: "hourglass",
            title: L("Einen Moment …"),
            message: L("Der nächste Vorgang wird vorbereitet.")
        )
        .gameCard()
    }
}

/// "Ruhiges Jahr" – kein Event hinterlegt.
private struct NoEventCard: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let year: Int
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(GameTheme.gold)
                Text(L("Ein ruhiges Jahr"))
                    .font(.headline)
                    .foregroundStyle(GameTheme.primaryText)
            }
            Text(L("\(L(String(year))) verläuft ohne große Entscheidungen. Die Verwaltung arbeitet im Regelbetrieb – nutze die Ruhe."))
                .font(.callout)
                .foregroundStyle(GameTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: onContinue) {
                Label(L("Jahr abschließen"), systemImage: "arrow.right")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
        .gameCard(padding: 18)
    }
}
