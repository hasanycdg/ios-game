import SwiftUI
import RegiereDeutschlandCore

/// Eigene Partei gründen: Name, Ideologie und Ziele wählen – daraus wird eine
/// spielbare Partei, mit der man ins Spiel startet.
struct PartyFounderView: View {
    let playerName: String

    @State private var partyName = ""
    @State private var shortName = ""
    @State private var ideologyID = IdeologyCatalog.default.id
    @State private var selectedGoals: Set<String> = []
    @FocusState private var focus: Field?

    private enum Field { case name, short }

    private let maxGoals = 3

    private var ideology: PartyIdeology { IdeologyCatalog.ideology(id: ideologyID) }

    private var builtParty: PlayerParty {
        CustomPartyFactory.make(
            name: partyName,
            shortName: shortName,
            ideologyID: ideologyID,
            goalIDs: Array(orderedSelectedGoals)
        )
    }

    /// Ziele in Katalog-Reihenfolge (stabil), nur die ausgewählten.
    private var orderedSelectedGoals: [String] {
        CustomGoalCatalog.all.map(\.id).filter { selectedGoals.contains($0) }
    }

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    hero
                    nameSection
                    ideologySection
                    goalsSection
                    startButton
                    Spacer(minLength: 20)
                }
                .padding(20)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(GameTheme.primaryText)
        .navigationTitle("Partei gründen")
        .inlineNavigationTitle()
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: Hero

    private var hero: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(GameTheme.teal.opacity(0.16)).frame(width: 76, height: 76)
                Image(systemName: "flag.2.crossed.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(GameTheme.teal)
            }
            Text("Gründe deine eigene Partei")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
            Text("Wähle Namen, Ideologie und Ziele – und setze im Spiel dein eigenes Programm durch.")
                .font(.callout)
                .foregroundStyle(GameTheme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Name deiner Partei", systemImage: "signature")
            textField("z. B. Zukunftspartei", text: $partyName, field: .name)
            HStack(spacing: 12) {
                Text("Kürzel")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(GameTheme.secondaryText)
                textField(autoShort, text: $shortName, field: .short)
                    .frame(maxWidth: 130)
            }
        }
    }

    private var autoShort: String {
        let initials = partyName.split(separator: " ").compactMap { $0.first }.map(String.init).joined()
        return initials.isEmpty ? "z. B. ZP" : String(initials.prefix(4)).uppercased()
    }

    private func textField(_ placeholder: String, text: Binding<String>, field: Field) -> some View {
        HStack {
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(GameTheme.tertiaryText))
                .textInputAutocapitalization(field == .short ? .characters : .words)
                .autocorrectionDisabled()
                .focused($focus, equals: field)
                .foregroundStyle(GameTheme.primaryText)
                .tint(GameTheme.teal)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GameTheme.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(focus == field ? GameTheme.teal : GameTheme.hairline, lineWidth: 1)
        )
    }

    // MARK: Ideologie

    private var ideologySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Ideologie", systemImage: "arrow.left.and.right.circle")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(IdeologyCatalog.all) { ideology in
                        IdeologyCard(ideology: ideology, isSelected: ideology.id == ideologyID) {
                            Haptics.impact(.light)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                ideologyID = ideology.id
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: Ziele

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Deine Ziele", systemImage: "target",
                          accessory: "\(selectedGoals.count)/\(maxGoals)")
            Text("Wähle bis zu \(maxGoals) Vorhaben. Sie werden dein Programm – und geben dir schon zum Start Rückenwind.")
                .font(.caption)
                .foregroundStyle(GameTheme.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)
            FlowLayout(spacing: 8) {
                ForEach(CustomGoalCatalog.all) { goal in
                    goalChip(goal)
                }
            }
        }
    }

    private func goalChip(_ goal: AgendaItem) -> some View {
        let isOn = selectedGoals.contains(goal.id)
        let atLimit = selectedGoals.count >= maxGoals && !isOn
        return Button {
            Haptics.impact(.light)
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                if isOn { selectedGoals.remove(goal.id) }
                else if !atLimit { selectedGoals.insert(goal.id) }
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "plus.circle")
                    .font(.caption2)
                Text(goal.title).font(.caption.weight(.semibold))
            }
            .foregroundStyle(isOn ? Color.black.opacity(0.85) : (atLimit ? GameTheme.tertiaryText : GameTheme.primaryText))
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(
                Capsule().fill(isOn ? GameTheme.teal : GameTheme.surface)
            )
            .overlay(Capsule().stroke(isOn ? Color.clear : GameTheme.hairline, lineWidth: 1))
            .opacity(atLimit ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .disabled(atLimit)
    }

    // MARK: Start

    private var startButton: some View {
        VStack(spacing: 8) {
            NavigationLink {
                GameContainerView(mode: .newGame, party: builtParty, playerName: playerName)
            } label: {
                Label("Partei gründen & regieren", systemImage: "flag.fill")
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(selectedGoals.isEmpty)
            .opacity(selectedGoals.isEmpty ? 0.5 : 1)

            if selectedGoals.isEmpty {
                Text("Wähle mindestens ein Ziel.")
                    .font(.caption).foregroundStyle(GameTheme.tertiaryText)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Ideologie-Karte

private struct IdeologyCard: View {
    let ideology: PartyIdeology
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: ideology.icon)
                        .font(.headline)
                        .foregroundStyle(GameTheme.teal)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(GameTheme.teal.opacity(0.16)))
                    Spacer(minLength: 0)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(GameTheme.teal)
                    }
                }
                Text(ideology.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(GameTheme.primaryText)
                Text(ideology.tagline)
                    .font(.caption2)
                    .foregroundStyle(GameTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(13)
            .frame(width: 190, height: 148, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GameTheme.surface))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? GameTheme.teal : GameTheme.hairline, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Einfaches Flow-Layout für die Ziel-Chips

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
