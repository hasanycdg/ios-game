import RegiereDeutschlandCore
import SwiftUI

// MARK: - Interessengruppen

struct InterestGroupsSection: View {
    let groups: [InterestGroup]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Interessengruppen", systemImage: "megaphone.fill", accessory: "Macht · Stimmung")
            VStack(spacing: 10) {
                ForEach(groups) { group in
                    InterestGroupRow(group: group)
                }
            }
        }
    }
}

private struct InterestGroupRow: View {
    let group: InterestGroup
    private var color: Color { GameTheme.statusColor(for: group.satisfaction) }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: group.id.icon)
                    .font(.footnote.weight(.bold)).foregroundStyle(color)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(color.opacity(0.15)))
                VStack(alignment: .leading, spacing: 1) {
                    Text(group.id.title)
                        .font(.subheadline.weight(.semibold)).foregroundStyle(GameTheme.primaryText)
                    Text(group.moodLabel)
                        .font(.caption2).foregroundStyle(GameTheme.tertiaryText)
                }
                Spacer(minLength: 0)
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index < group.power ? GameTheme.gold : GameTheme.surfaceElevated)
                            .frame(width: 5, height: 5)
                    }
                }
                Text("\(group.satisfaction)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(color).monospacedDigit()
                    .frame(width: 28, alignment: .trailing)
            }
            ValueBar(value: group.satisfaction, height: 6)
        }
        .gameCard(padding: 14)
    }
}

// MARK: - Partei-Flügel

struct PartyWingsCard: View {
    let wings: PartyWings

    private var backingColor: Color { GameTheme.statusColor(for: wings.leadershipBacking) }
    private var atRisk: Bool { wings.leadershipBacking < 28 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "person.2.wave.2.fill")
                    .font(.footnote.weight(.bold)).foregroundStyle(GameTheme.gold)
                Text("DEINE PARTEI")
                    .font(.caption.weight(.bold)).tracking(1.2).foregroundStyle(GameTheme.secondaryText)
                Spacer(minLength: 0)
                Text(wings.backingLabel)
                    .font(.caption2.weight(.heavy)).foregroundStyle(backingColor)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(backingColor.opacity(0.16)))
            }

            wingRow(label: "Reformflügel", value: wings.progressive)
            wingRow(label: "Traditionsflügel", value: wings.traditional)

            Divider().overlay(GameTheme.hairline)

            HStack {
                Text("Rückhalt für die Führung")
                    .font(.caption.weight(.semibold)).foregroundStyle(GameTheme.primaryText)
                Spacer()
                Text("\(wings.leadershipBacking)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(backingColor).monospacedDigit()
            }
            ValueBar(value: wings.leadershipBacking, height: 7)

            if atRisk {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.caption2)
                    Text("Die eigene Partei murrt – ohne Rückhalt droht der Sturz durch die Fraktion.")
                        .font(.caption2.weight(.semibold)).fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(GameTheme.red)
            }
        }
        .gameCard(padding: 16, tint: atRisk ? GameTheme.red : nil)
    }

    private func wingRow(label: String, value: Int) -> some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.caption).foregroundStyle(GameTheme.secondaryText)
                .frame(width: 118, alignment: .leading)
            ValueBar(value: value, height: 6)
            Text("\(value)")
                .font(.caption.weight(.bold)).foregroundStyle(GameTheme.statusColor(for: value))
                .monospacedDigit().frame(width: 26, alignment: .trailing)
        }
    }
}

// MARK: - Bundesrat

struct BundesratCard: View {
    let hasMajority: Bool

    private var color: Color { hasMajority ? GameTheme.green : GameTheme.red }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "building.2.fill")
                .font(.footnote.weight(.bold)).foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(Circle().fill(color.opacity(0.15)))
            VStack(alignment: .leading, spacing: 1) {
                Text("Bundesrat")
                    .font(.subheadline.weight(.bold)).foregroundStyle(GameTheme.primaryText)
                Text(hasMajority ? "Mehrheit gesichert – Gesetze gehen leichter durch." : "Keine Mehrheit – Gesetze brauchen mehr Überzeugung.")
                    .font(.caption2).foregroundStyle(GameTheme.tertiaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Text(hasMajority ? "Mehrheit" : "Blockade")
                .font(.caption2.weight(.heavy)).foregroundStyle(color)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(color.opacity(0.16)))
        }
        .gameCard(padding: 14, tint: hasMajority ? nil : GameTheme.red)
    }
}
