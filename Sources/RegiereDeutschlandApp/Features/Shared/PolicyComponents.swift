import RegiereDeutschlandCore
import SwiftUI

// MARK: - Haushalt

struct BudgetCard: View {
    let budget: BudgetSummary

    private var balanced: Bool { budget.deficit <= 0 }
    private var maxFlow: Double { Double(max(budget.income, budget.spending, 1)) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Haushalt", systemImage: "building.columns.fill",
                          accessory: "Schulden \(budget.debt)")

            flowRow(label: "Einnahmen", value: budget.income, color: GameTheme.green)
            flowRow(label: "Ausgaben", value: budget.spending, color: GameTheme.amber)

            Divider().overlay(GameTheme.hairline)

            HStack {
                Text(balanced ? "Überschuss" : "Defizit")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(GameTheme.secondaryText)
                Spacer()
                Text("\(balanced ? "+" : "")\(-budget.deficit)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(balanced ? GameTheme.green : GameTheme.red)
                    .monospacedDigit()
            }
        }
        .gameCard(padding: 16)
    }

    private func flowRow(label: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label).font(.caption).foregroundStyle(GameTheme.secondaryText)
                Spacer()
                Text("\(value)").font(.caption.weight(.bold)).foregroundStyle(GameTheme.primaryText).monospacedDigit()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(GameTheme.surfaceSunken)
                    Capsule().fill(color).frame(width: max(6, geo.size.width * CGFloat(Double(value) / maxFlow)))
                }
            }
            .frame(height: 7)
        }
    }
}

// MARK: - Gesetze (Politikfelder)

struct PolicySection: View {
    let policies: PolicyState
    let capital: Int
    let onChange: (PolicyID, Int) -> PolicyVoteResult

    @State private var message: (text: String, color: Color)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Gesetze", systemImage: "doc.text.fill", accessory: "Parlament")
            Text("Politikfelder wirken Jahr für Jahr. Jede Änderung kostet Kapital und braucht eine Mehrheit deiner Koalition.")
                .font(.caption)
                .foregroundStyle(GameTheme.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)

            if let message {
                HStack(spacing: 8) {
                    Image(systemName: "building.columns").font(.caption2)
                    Text(message.text).font(.caption.weight(.semibold))
                }
                .foregroundStyle(message.color)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(message.color.opacity(0.14)))
            }

            VStack(spacing: 10) {
                ForEach(PolicyID.allCases, id: \.self) { policy in
                    PolicyRow(
                        policy: policy,
                        level: policies.level(policy),
                        capital: capital,
                        onDecrease: { apply(policy, policies.level(policy) - 1) },
                        onIncrease: { apply(policy, policies.level(policy) + 1) }
                    )
                }
            }
        }
    }

    private func apply(_ policy: PolicyID, _ level: Int) {
        switch onChange(policy, level) {
        case .passed:
            message = ("\(policy.title) im Parlament beschlossen.", GameTheme.green)
        case .rejected:
            message = ("\(policy.title): im Parlament gescheitert – der Koalitionspartner blockiert.", GameTheme.red)
        case .noCapital:
            message = ("Nicht genug politisches Kapital.", GameTheme.amber)
        case .unchanged:
            break
        }
    }
}

private struct PolicyRow: View {
    let policy: PolicyID
    let level: Int
    let capital: Int
    let onDecrease: () -> Void
    let onIncrease: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: policy.icon)
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(GameTheme.gold)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(GameTheme.gold.opacity(0.15)))
                VStack(alignment: .leading, spacing: 1) {
                    Text(policy.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(GameTheme.primaryText)
                    Text(PolicyEngine.label(policy, level: level))
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 12) {
                stepButton(system: "minus", enabled: level > 0 && capital >= 1, action: onDecrease)
                HStack(spacing: 5) {
                    ForEach(0..<(PolicyEngine.maxLevel + 1), id: \.self) { index in
                        Capsule()
                            .fill(index <= level ? GameTheme.gold : GameTheme.surfaceElevated)
                            .frame(height: 6)
                    }
                }
                stepButton(system: "plus", enabled: level < PolicyEngine.maxLevel && capital >= 1, action: onIncrease)
            }
        }
        .gameCard(padding: 14)
    }

    private func stepButton(system: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(enabled ? GameTheme.primaryText : GameTheme.tertiaryText)
                .frame(width: 34, height: 34)
                .background(Circle().fill(GameTheme.surfaceElevated))
                .overlay(Circle().stroke(GameTheme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.5)
    }
}
