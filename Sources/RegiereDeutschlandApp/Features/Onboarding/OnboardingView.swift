import SwiftUI
import RegiereDeutschlandCore

// MARK: - Ergebnis

/// What the player chose during onboarding; nil fields keep the current values.
struct OnboardingResult {
    var playerName: String
    var partyID: String
}

// MARK: - Inhalte

/// Copy for the onboarding, written directly in German, English and French.
@MainActor
enum OnboardingContent {
    struct Headline: Identifiable {
        let id = UUID()
        let icon: String
        let text: String
    }

    struct DemoOption: Identifiable {
        let id: Int
        let icon: String
        let title: String
        let effects: [(metric: String, change: Int)]
        let consequence: String
    }

    static func office(_ country: GameCountry, _ p: GamePresentation) -> String {
        switch country {
        case .germany: p.pick("Bundeskanzleramt", "Federal Chancellery", "Chancellerie fédérale")
        case .unitedStates: p.pick("Weißes Haus", "The White House", "Maison-Blanche")
        case .unitedKingdom: "10 Downing Street"
        case .france: p.pick("Élysée-Palast", "Élysée Palace", "Palais de l’Élysée")
        }
    }

    static func countryName(_ country: GameCountry, _ p: GamePresentation) -> String {
        switch country {
        case .germany: p.pick("Deutschland", "Germany", "l’Allemagne")
        case .unitedStates: p.pick("die USA", "America", "les États-Unis")
        case .unitedKingdom: p.pick("Großbritannien", "Britain", "le Royaume-Uni")
        case .france: p.pick("Frankreich", "France", "la France")
        }
    }

    /// Real headlines from 2000 that set the scene of each campaign.
    static func headlines(_ country: GameCountry, _ p: GamePresentation) -> [Headline] {
        switch country {
        case .germany:
            [Headline(icon: "person.3.fill", text: p.pick("Fast vier Millionen Arbeitslose", "Almost four million unemployed", "Près de quatre millions de chômeurs")),
             Headline(icon: "bolt.fill", text: p.pick("Atomkonsens: Der Ausstieg wird verhandelt", "Nuclear consensus: the phase-out is negotiated", "Consensus nucléaire : la sortie se négocie")),
             Headline(icon: "chart.line.downtrend.xyaxis", text: p.pick("Die Dotcom-Blase platzt", "The dot-com bubble bursts", "La bulle Internet éclate"))]
        case .unitedStates:
            [Headline(icon: "dollarsign.circle.fill", text: p.pick("Rekord-Haushaltsüberschuss", "Record budget surplus", "Excédent budgétaire record")),
             Headline(icon: "chart.line.downtrend.xyaxis", text: p.pick("Die Dotcom-Blase platzt", "The dot-com bubble bursts", "La bulle Internet éclate")),
             Headline(icon: "checkmark.square.fill", text: p.pick("Die knappste Wahl der Geschichte", "The closest election in history", "L’élection la plus serrée de l’histoire"))]
        case .unitedKingdom:
            [Headline(icon: "fuelpump.fill", text: p.pick("Treibstoffproteste legen das Land lahm", "Fuel protests bring the country to a halt", "Les blocages du carburant paralysent le pays")),
             Headline(icon: "building.2.fill", text: p.pick("Der Millennium Dome öffnet", "The Millennium Dome opens", "Le Millennium Dome ouvre ses portes")),
             Headline(icon: "chart.line.downtrend.xyaxis", text: p.pick("Die Dotcom-Blase platzt", "The dot-com bubble bursts", "La bulle Internet éclate"))]
        case .france:
            [Headline(icon: "clock.fill", text: p.pick("Die 35-Stunden-Woche tritt in Kraft", "The 35-hour week takes effect", "Les 35 heures entrent en vigueur")),
             Headline(icon: "checkmark.square.fill", text: p.pick("Referendum über das Quinquennat", "Referendum on the five-year term", "Référendum sur le quinquennat")),
             Headline(icon: "chart.line.downtrend.xyaxis", text: p.pick("Die Dotcom-Blase platzt", "The dot-com bubble bursts", "La bulle Internet éclate"))]
        }
    }

    static func demoQuestion(_ p: GamePresentation) -> String {
        p.pick("Die Dotcom-Blase platzt. Tausende Jobs in der Tech-Branche sind in Gefahr. Wie reagierst du?",
               "The dot-com bubble bursts. Thousands of tech jobs are at risk. How do you respond?",
               "La bulle Internet éclate. Des milliers d’emplois sont menacés. Comment réagis-tu ?")
    }

    static func demoMetrics(_ p: GamePresentation) -> [String] {
        [p.pick("Wirtschaft", "Economy", "Économie"),
         p.pick("Haushalt", "Budget", "Budget"),
         p.pick("Zustimmung", "Approval", "Popularité")]
    }

    static func demoOptions(_ p: GamePresentation) -> [DemoOption] {
        let m = demoMetrics(p)
        return [
            DemoOption(id: 0, icon: "banknote.fill",
                       title: p.pick("Konjunkturpaket schnüren", "Pass a stimulus package", "Lancer un plan de relance"),
                       effects: [(m[0], 6), (m[1], -9), (m[2], 5)],
                       consequence: p.pick("Die Menschen sind erleichtert. Aber die neuen Schulden holen dich bei der nächsten Haushaltsdebatte wieder ein.",
                                           "People are relieved. But the new debt will catch up with you in the next budget fight.",
                                           "Les gens sont soulagés. Mais la nouvelle dette te rattrapera au prochain débat budgétaire.")),
            DemoOption(id: 1, icon: "scissors",
                       title: p.pick("Sparkurs halten", "Hold the line on spending", "Maintenir la rigueur"),
                       effects: [(m[0], -4), (m[1], 6), (m[2], -6)],
                       consequence: p.pick("Die Märkte loben dich, die Gewerkschaften nicht. Die Opposition wittert ihre Chance.",
                                           "Markets praise you, unions don’t. The opposition smells an opportunity.",
                                           "Les marchés t’applaudissent, les syndicats beaucoup moins. L’opposition flaire sa chance.")),
            DemoOption(id: 2, icon: "graduationcap.fill",
                       title: p.pick("In Bildung und Digitales investieren", "Invest in education and digital", "Investir dans l’éducation et le numérique"),
                       effects: [(m[0], 2), (m[1], -4), (m[2], 1)],
                       consequence: p.pick("Kurzfristig passiert wenig. Doch Jahre später kann genau diese Entscheidung den Unterschied machen.",
                                           "Little happens at first. But years later, this decision can make all the difference.",
                                           "Peu de choses changent à court terme. Mais des années plus tard, ce choix peut tout changer."))
        ]
    }
}

// MARK: - Onboarding-Ansicht

/// Interactive first-run experience: a cinematic intro, the player's name and
/// party, a first sample decision with visible consequences and the oath of office.
struct OnboardingView: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let country: GameCountry
    var initialName: String = ""
    var initialPartyID: String? = nil
    var onFinish: (OnboardingResult?) -> Void

    private enum Step: Int, CaseIterable {
        case intro, name, party, decision, oath
    }

    @State private var step: Step = .intro
    @State private var name = ""
    @State private var partyID = ""
    @FocusState private var nameFocused: Bool

    private var p: GamePresentation { gamePresentation }
    private var effectiveName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? country.defaultLeaderName : trimmed
    }
    private var party: PlayerParty { country.party(id: partyID) }
    private var accent: Color {
        switch step {
        case .intro, .oath: GameTheme.gold
        case .name: GameTheme.teal
        case .party: PartyPresentation.color(for: partyID)
        case .decision: GameTheme.blue
        }
    }

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()
            RadialGradient(colors: [accent.opacity(0.2), .clear], center: .top, startRadius: 20, endRadius: 560)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: step)

            VStack(spacing: 0) {
                topBar
                Group {
                    switch step {
                    case .intro:
                        IntroStep(country: country) { advance() }
                    case .name:
                        nameStep
                    case .party:
                        partyStep
                    case .decision:
                        DecisionStep { option in
                            Analytics.track(.onboardingDecision, ["option": String(option)])
                        } onContinue: { advance() }
                    case .oath:
                        OathStep(country: country, name: effectiveName, party: party) {
                            Analytics.track(.onboardingCompleted, ["country": country.rawValue, "party": partyID])
                            onFinish(OnboardingResult(playerName: effectiveName, partyID: partyID))
                        }
                    }
                }
                .id(step)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
            }
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(GameTheme.primaryText)
        .preferredColorScheme(.dark)
        .onAppear {
            name = initialName
            partyID = initialPartyID ?? country.defaultParty.id
            Analytics.track(.onboardingStep, ["step": "intro"])
        }
    }

    private func advance() {
        guard let next = Step(rawValue: step.rawValue + 1) else { return }
        Haptics.impact(.light)
        nameFocused = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.88)) { step = next }
        Analytics.track(.onboardingStep, ["step": String(describing: next)])
    }

    // MARK: Kopfzeile

    private var topBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 5) {
                ForEach(Step.allCases, id: \.self) { item in
                    Capsule()
                        .fill(item.rawValue <= step.rawValue ? GameTheme.gold : GameTheme.hairlineStrong)
                        .frame(width: item == step ? 22 : 7, height: 6)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: step)
            Spacer()
            if step != .oath {
                Button(p.pick("Überspringen", "Skip", "Passer")) {
                    Analytics.track(.onboardingSkipped, ["step": String(describing: step)])
                    onFinish(nil)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(GameTheme.secondaryText)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .frame(height: 44)
    }

    // MARK: Name

    private var nameStep: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 10)
            StepHeader(icon: "signature", accent: GameTheme.teal,
                       kicker: p.pick("Vereidigung", "Swearing-in", "Investiture"),
                       title: p.pick("Wie heißt du?", "What’s your name?", "Comment t’appelles-tu ?"),
                       message: p.pick("Unter diesem Namen schreibst du Geschichte.",
                                       "History will remember you by this name.",
                                       "C’est sous ce nom que tu entreras dans l’histoire."))
            TextField("", text: $name, prompt: Text(L(country.defaultLeaderName)).foregroundColor(GameTheme.tertiaryText))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .focused($nameFocused)
                .onSubmit(advance)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GameTheme.surface))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(nameFocused ? GameTheme.teal : GameTheme.hairline, lineWidth: 1.5))
            Spacer()
            Button(action: advance) {
                Label(p.pick("Weiter", "Continue", "Continuer"), systemImage: "arrow.right")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .task {
            try? await Task.sleep(for: .milliseconds(450))
            nameFocused = true
        }
    }

    // MARK: Partei

    private var partyStep: some View {
        VStack(spacing: 16) {
            StepHeader(icon: "flag.2.crossed.fill", accent: PartyPresentation.color(for: partyID),
                       kicker: p.pick("Deine Partei", "Your party", "Ton parti"),
                       title: p.pick("Wofür stehst du?", "What do you stand for?", "Quelles sont tes valeurs ?"),
                       message: p.pick("Deine Partei bestimmt Programm, Partner und Gegner.",
                                       "Your party shapes your agenda, your allies and your rivals.",
                                       "Ton parti définit ton programme, tes alliés et tes adversaires."))
                .padding(.top, 8)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(country.playableParties) { item in
                        partyRow(item)
                    }
                }
                .padding(.vertical, 4)
            }
            Button(action: advance) {
                Label(p.pick("Mit \(L(party.name)) antreten", "Run with \(L(party.name))", "Se présenter avec \(L(party.name))"),
                      systemImage: "arrow.right")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    private func partyRow(_ item: PlayerParty) -> some View {
        let selected = item.id == partyID
        let color = PartyPresentation.color(for: item.id)
        return Button {
            Haptics.impact(.light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { partyID = item.id }
        } label: {
            HStack(spacing: 13) {
                Image(systemName: item.profile.icon)
                    .font(.headline)
                    .foregroundStyle(color)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(color.opacity(0.18)))
                VStack(alignment: .leading, spacing: 3) {
                    Text(L(item.name)).font(.headline.weight(.heavy))
                    Text(L(item.tagline))
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selected ? color : GameTheme.tertiaryText)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(selected ? color.opacity(0.12) : GameTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(selected ? color : GameTheme.hairline, lineWidth: selected ? 2 : 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

// MARK: - Schritt-Kopf

private struct StepHeader: View {
    let icon: String
    let accent: Color
    let kicker: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 64, height: 64)
                .background(Circle().fill(accent.opacity(0.15)))
                .overlay(Circle().stroke(accent.opacity(0.4), lineWidth: 1))
            Text(kicker.uppercased())
                .font(.caption.weight(.bold)).tracking(2)
                .foregroundStyle(accent)
            Text(title)
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
            Text(message)
                .font(.callout)
                .foregroundStyle(GameTheme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Intro

/// "1 January 2000": the date types itself, then the headlines of the day arrive.
private struct IntroStep: View {
    @Environment(GamePresentation.self) private var p
    let country: GameCountry
    let onContinue: () -> Void

    @State private var typedDate = ""
    @State private var visibleHeadlines = 0
    @State private var showCall = false

    private var date: String { p.pick("1. Januar 2000", "January 1, 2000", "1er janvier 2000") }

    var body: some View {
        let headlines = OnboardingContent.headlines(country, p)
        VStack(spacing: 22) {
            Spacer(minLength: 10)
            VStack(spacing: 12) {
                Text(country.flag).font(.system(size: 54))
                Text(typedDate.isEmpty ? " " : typedDate)
                    .font(.system(size: 34, weight: .heavy, design: .serif))
                    .monospacedDigit()
                FlagRibbon(height: 4).frame(width: 120)
            }
            VStack(spacing: 10) {
                ForEach(Array(headlines.enumerated()), id: \.element.id) { index, headline in
                    if index < visibleHeadlines {
                        HStack(spacing: 12) {
                            Image(systemName: headline.icon)
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(GameTheme.goldBright)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(GameTheme.gold.opacity(0.15)))
                            Text(headline.text)
                                .font(.system(.subheadline, design: .serif).weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .gameCard(padding: 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            if showCall {
                VStack(spacing: 8) {
                    Text(p.pick("Das Land braucht eine neue Führung.", "The country needs new leadership.", "Le pays a besoin d’un nouveau dirigeant."))
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text(p.pick("Führe \(OnboardingContent.countryName(country, p)) durch 50 Jahre Geschichte – jede Entscheidung hat Folgen.",
                                "Lead \(OnboardingContent.countryName(country, p)) through 50 years of history – every decision has consequences.",
                                "Dirige \(OnboardingContent.countryName(country, p)) pendant 50 ans d’histoire – chaque décision a des conséquences."))
                        .font(.callout)
                        .foregroundStyle(GameTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
            Spacer()
            Button(action: onContinue) {
                Label(p.pick("Amt antreten", "Take office", "Prendre ses fonctions"), systemImage: "building.columns.fill")
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .opacity(showCall ? 1 : 0)
            .disabled(!showCall)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .task { await play(headlineCount: headlines.count) }
    }

    private func play(headlineCount: Int) async {
        guard typedDate.isEmpty else { return }
        try? await Task.sleep(for: .milliseconds(350))
        for character in date {
            typedDate.append(character)
            if character != " " { Haptics.impact(.light) }
            try? await Task.sleep(for: .milliseconds(55))
        }
        for index in 0..<headlineCount {
            try? await Task.sleep(for: .milliseconds(index == 0 ? 400 : 650))
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { visibleHeadlines = index + 1 }
            Haptics.impact(.medium)
        }
        try? await Task.sleep(for: .milliseconds(700))
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { showCall = true }
    }
}

// MARK: - Erste Entscheidung

/// A sample decision: the player taps, the metrics move, the consequence lands.
private struct DecisionStep: View {
    @Environment(GamePresentation.self) private var p
    let onChoose: (Int) -> Void
    let onContinue: () -> Void

    @State private var chosen: Int?
    @State private var values: [Double] = [50, 50, 50]

    var body: some View {
        let options = OnboardingContent.demoOptions(p)
        let metrics = OnboardingContent.demoMetrics(p)
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Text(p.pick("DEINE ERSTE ENTSCHEIDUNG", "YOUR FIRST DECISION", "TA PREMIÈRE DÉCISION"))
                    .font(.caption.weight(.bold)).tracking(2)
                    .foregroundStyle(GameTheme.blue)
                VStack(alignment: .leading, spacing: 10) {
                    Label(p.pick("EILMELDUNG · 2000", "BREAKING · 2000", "ALERTE · 2000"), systemImage: "bolt.horizontal.fill")
                        .font(.caption.weight(.heavy)).tracking(1.4)
                        .foregroundStyle(GameTheme.red)
                        .lineLimit(1)
                    Text(OnboardingContent.demoQuestion(p))
                        .font(.system(size: 21, weight: .bold, design: .serif))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .gameCard(padding: 16)

                VStack(spacing: 10) {
                    ForEach(Array(metrics.enumerated()), id: \.offset) { index, metric in
                        metricBar(metric, value: values[index], change: chosen.map { options[$0].effects[index].change })
                    }
                }
                .gameCard(padding: 14)

                if let chosen {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(options[chosen].title, systemImage: options[chosen].icon)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(GameTheme.goldBright)
                        Text(options[chosen].consequence)
                            .font(.callout)
                            .fixedSize(horizontal: false, vertical: true)
                        Label(p.pick("Manche Folgen zeigen sich erst Jahre später.",
                                     "Some consequences only appear years later.",
                                     "Certaines conséquences n’apparaissent que des années plus tard."),
                              systemImage: "clock.arrow.2.circlepath")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(GameTheme.purple)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .gameCard(padding: 14)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    VStack(spacing: 10) {
                        ForEach(options) { option in
                            Button { choose(option, all: options) } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: option.icon)
                                        .foregroundStyle(GameTheme.gold)
                                        .frame(width: 30)
                                    Text(option.title)
                                        .font(.subheadline.weight(.bold))
                                        .multilineTextAlignment(.leading)
                                    Spacer(minLength: 0)
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(GameTheme.tertiaryText)
                                }
                                .padding(15)
                                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(GameTheme.surface))
                                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(GameTheme.gold.opacity(0.35)))
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 6)
        }
        .safeAreaInset(edge: .bottom) {
            if chosen != nil {
                Button(action: onContinue) {
                    Label(p.pick("Weiter", "Continue", "Continuer"), systemImage: "arrow.right")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .transition(.opacity)
            }
        }
    }

    private func choose(_ option: OnboardingContent.DemoOption, all: [OnboardingContent.DemoOption]) {
        Haptics.impact(.medium)
        onChoose(option.id)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { chosen = option.id }
        Task {
            try? await Task.sleep(for: .milliseconds(250))
            withAnimation(.spring(response: 0.9, dampingFraction: 0.7)) {
                values = option.effects.map { 50 + Double($0.change) * 2.5 }
            }
            if option.effects.contains(where: { $0.change < -5 }) { Haptics.warning() } else { Haptics.success() }
        }
    }

    private func metricBar(_ title: String, value: Double, change: Int?) -> some View {
        let tint: Color = change.map { $0 >= 0 ? GameTheme.green : GameTheme.red } ?? GameTheme.gold
        return VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title).font(.caption.weight(.semibold)).foregroundStyle(GameTheme.secondaryText)
                Spacer()
                if let change {
                    Text(change > 0 ? "+\(change)" : "\(change)")
                        .font(.caption.weight(.heavy)).monospacedDigit()
                        .foregroundStyle(tint)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(GameTheme.hairline)
                    Capsule().fill(tint).frame(width: geometry.size.width * value / 100)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Amtseid

/// The player's credentials: name, party and office, ready to start the prologue.
private struct OathStep: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let country: GameCountry
    let name: String
    let party: PlayerParty
    let onStart: () -> Void

    @State private var revealed = false
    private var p: GamePresentation { gamePresentation }

    var body: some View {
        ZStack {
            if revealed { ConfettiView().allowsHitTesting(false).ignoresSafeArea() }
            VStack(spacing: 20) {
                Spacer(minLength: 6)
                credential
                    .scaleEffect(revealed ? 1 : 0.85)
                    .opacity(revealed ? 1 : 0)
                VStack(spacing: 8) {
                    fact("gift.fill", GameTheme.green,
                         p.pick("Prolog 2000–2004 · fünf Jahre · kostenlos",
                                "Prologue 2000–2004 · five years · free",
                                "Prologue 2000–2004 · cinq ans · gratuit"))
                    fact("building.columns.fill", GameTheme.gold,
                         p.pick("Hauptkampagne bis 2026 · über 85 historische Ereignisse",
                                "Main campaign to 2026 · 85+ historical events",
                                "Campagne principale jusqu’en 2026 · plus de 85 événements historiques"))
                    fact("globe.europe.africa.fill", GameTheme.purple,
                         p.pick("Zukunft 2050 · über 270 Entscheidungen bis zur neuen Weltordnung",
                                "Future 2050 · 270+ decisions to a new world order",
                                "Futur 2050 · plus de 270 décisions jusqu’au nouvel ordre mondial"))
                }
                .opacity(revealed ? 1 : 0)
                Spacer()
                Button(action: onStart) {
                    Label(p.pick("Prolog starten", "Start the prologue", "Lancer le prologue"), systemImage: "flag.checkered")
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .task {
            try? await Task.sleep(for: .milliseconds(200))
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { revealed = true }
            Haptics.success()
        }
    }

    private var credential: some View {
        let color = PartyPresentation.color(for: party.id)
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(OnboardingContent.office(country, p).uppercased())
                    .font(.caption.weight(.heavy)).tracking(1.6)
                    .foregroundStyle(GameTheme.goldBright)
                Spacer()
                Text(country.flag).font(.title2)
            }
            FlagRibbon(height: 3)
            HStack(spacing: 14) {
                Image(systemName: party.profile.icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 58, height: 58)
                    .background(RoundedRectangle(cornerRadius: 14).fill(color.opacity(0.18)))
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .lineLimit(1).minimumScaleFactor(0.6)
                    Text(L(party.fullName))
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                        .lineLimit(2)
                }
            }
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(p.pick("AMTSANTRITT", "TAKING OFFICE", "PRISE DE FONCTIONS"))
                        .font(.system(size: 9, weight: .bold)).tracking(1.2)
                        .foregroundStyle(GameTheme.tertiaryText)
                    Text(p.pick("1. Januar 2000", "January 1, 2000", "1er janvier 2000"))
                        .font(.subheadline.weight(.bold))
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(GameTheme.goldGradient)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(colors: [GameTheme.surface, color.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(GameTheme.gold.opacity(0.55), lineWidth: 1.2))
        .shadow(color: GameTheme.gold.opacity(0.25), radius: 24, y: 8)
    }

    private func fact(_ icon: String, _ tint: Color, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.footnote.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(Circle().fill(tint.opacity(0.15)))
            Text(text)
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}
