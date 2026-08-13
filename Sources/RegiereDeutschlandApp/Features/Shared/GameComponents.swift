import SwiftUI

// MARK: - Schwarz-Rot-Gold-Band

/// Dünner Deutschland-Akzent.
struct FlagRibbon: View {
    var height: CGFloat = 4

    var body: some View {
        HStack(spacing: 0) {
            GameTheme.flagBlack
            GameTheme.flagRed
            GameTheme.flagGold
        }
        .frame(height: height)
        .clipShape(Capsule())
    }
}

// MARK: - Abschnittsüberschrift

struct SectionHeader: View {
    let title: String
    var systemImage: String? = nil
    var accessory: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(GameTheme.gold)
            }
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.4)
                .foregroundStyle(GameTheme.secondaryText)
            Spacer(minLength: 0)
            if let accessory {
                Text(accessory)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(GameTheme.tertiaryText)
            }
        }
    }
}

// MARK: - Chips & Pills

struct CategoryChip: View {
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.6)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().fill(color.opacity(0.16)))
        .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 1))
    }
}

struct StatusPill: View {
    let value: Int

    var body: some View {
        Text(GameTheme.statusLabel(for: value).uppercased())
            .font(.system(size: 10, weight: .heavy))
            .tracking(0.5)
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(GameTheme.statusColor(for: value))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(GameTheme.statusColor(for: value).opacity(0.15)))
    }
}

/// Rot pulsierendes "EILMELDUNG"-Tag.
struct BreakingTag: View {
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
                .opacity(pulse ? 0.35 : 1)
            Text("EILMELDUNG")
                .font(.caption2.weight(.heavy))
                .tracking(1.2)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(GameTheme.red))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Balken-Gauge

struct ValueBar: View {
    let value: Int
    var total: Int = 100
    var height: CGFloat = 8
    var color: Color? = nil

    private var fraction: CGFloat {
        guard total > 0 else { return 0 }
        return max(0, min(1, CGFloat(value) / CGFloat(total)))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(GameTheme.surfaceSunken)
                Capsule()
                    .fill(color ?? GameTheme.statusColor(for: value))
                    .frame(width: max(height, geo.size.width * fraction))
            }
        }
        .frame(height: height)
        .animation(.easeInOut(duration: 0.5), value: value)
    }
}

// MARK: - Zustimmungs-Ring

struct ApprovalRing: View {
    let value: Int
    var size: CGFloat = 108
    var caption: String = "Zustimmung"

    private var fraction: CGFloat { max(0, min(1, CGFloat(value) / 100)) }
    private var color: Color { GameTheme.statusColor(for: value) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(GameTheme.surfaceSunken, lineWidth: size * 0.10)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    AngularGradient(colors: [color.opacity(0.7), color], center: .center),
                    style: StrokeStyle(lineWidth: size * 0.10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: value)
            VStack(spacing: 1) {
                Text("\(value)")
                    .font(.system(size: size * 0.30, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.primaryText)
                    .monospacedDigit()
                Text(caption.uppercased())
                    .font(.system(size: size * 0.085, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(GameTheme.secondaryText)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Momentum-Indikator

struct MomentumBadge: View {
    let momentum: Int

    private var icon: String {
        if momentum > 3 { return "arrow.up.right" }
        if momentum < -3 { return "arrow.down.right" }
        return "arrow.right"
    }

    private var color: Color {
        if momentum > 3 { return GameTheme.green }
        if momentum < -3 { return GameTheme.red }
        return GameTheme.secondaryText
    }

    private var label: String {
        if momentum > 3 { return "Rückenwind" }
        if momentum < -3 { return "Gegenwind" }
        return "Ruhige Lage"
    }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.caption.weight(.bold))
            Text(label).font(.caption.weight(.semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(color.opacity(0.14)))
    }
}

// MARK: - Wert-Karte (Ressorts)

struct MetricCard: View {
    let title: String
    let icon: String
    let value: Int
    var blurb: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(GameTheme.statusColor(for: value))
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(GameTheme.statusColor(for: value).opacity(0.15)))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(GameTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.primaryText)
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize()
                Spacer(minLength: 6)
                StatusPill(value: value)
            }

            ValueBar(value: value)

            if let blurb {
                Text(blurb)
                    .font(.caption)
                    .foregroundStyle(GameTheme.tertiaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .gameCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value) von 100, \(GameTheme.statusLabel(for: value))")
    }
}

// MARK: - Effekt-Delta-Zeile (Ergebnis-Screen)

struct DeltaRow: View {
    let label: String
    let icon: String
    let change: Int

    private var color: Color { change >= 0 ? GameTheme.green : GameTheme.red }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(GameTheme.secondaryText)
                .frame(width: 20)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(GameTheme.primaryText)
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                    .font(.caption2.weight(.bold))
                Text(signedString(change))
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
            }
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.15)))
        }
    }
}

// MARK: - Linien-Verlauf (handgezeichnet)

struct ChartSeries: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let values: [Double]
}

struct LineTrendChart: View {
    let years: [Int]
    let series: [ChartSeries]
    var height: CGFloat = 150

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                ForEach(series) { s in
                    HStack(spacing: 6) {
                        Circle().fill(s.color).frame(width: 8, height: 8)
                        Text(s.name)
                            .font(.caption)
                            .foregroundStyle(GameTheme.secondaryText)
                        if let last = s.values.last {
                            Text("\(Int(last.rounded()))")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(s.color)
                                .monospacedDigit()
                        }
                    }
                }
                Spacer(minLength: 0)
            }

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    ForEach([25, 50, 75], id: \.self) { g in
                        let y = h * (1 - CGFloat(g) / 100)
                        Path { p in
                            p.move(to: CGPoint(x: 0, y: y))
                            p.addLine(to: CGPoint(x: w, y: y))
                        }
                        .stroke(GameTheme.hairline, style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                    }
                    ForEach(series) { s in
                        path(for: s.values, w: w, h: h)
                            .stroke(s.color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        if let last = s.values.last, let idx = s.values.indices.last {
                            Circle()
                                .fill(s.color)
                                .frame(width: 7, height: 7)
                                .position(point(idx: idx, value: last, count: s.values.count, w: w, h: h))
                        }
                    }
                }
            }
            .frame(height: height)

            HStack {
                Text(String(years.first ?? 2000))
                    .font(.caption2).foregroundStyle(GameTheme.tertiaryText).monospacedDigit()
                Spacer()
                Text(String(years.last ?? 2000))
                    .font(.caption2).foregroundStyle(GameTheme.tertiaryText).monospacedDigit()
            }
        }
    }

    private func point(idx: Int, value: Double, count: Int, w: CGFloat, h: CGFloat) -> CGPoint {
        let x = count <= 1 ? w / 2 : w * CGFloat(idx) / CGFloat(count - 1)
        let clamped = max(0, min(100, value))
        let y = h * (1 - CGFloat(clamped) / 100)
        return CGPoint(x: x, y: y)
    }

    private func path(for values: [Double], w: CGFloat, h: CGFloat) -> Path {
        Path { p in
            for (i, v) in values.enumerated() {
                let pt = point(idx: i, value: v, count: values.count, w: w, h: h)
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
        }
    }
}

// MARK: - Leerer Zustand

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(GameTheme.tertiaryText)
            Text(title)
                .font(.headline)
                .foregroundStyle(GameTheme.primaryText)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(GameTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
    }
}
