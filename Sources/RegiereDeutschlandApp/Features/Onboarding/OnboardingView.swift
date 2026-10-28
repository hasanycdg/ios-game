import SwiftUI

// MARK: - Onboarding-Inhalt

/// Eine Seite der Einführung: erklärt einen Baustein der Spielmechanik.
struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let accent: Color
    let kicker: String
    let title: String
    let message: String
    let bullets: [Bullet]

    struct Bullet: Identifiable {
        let id = UUID()
        let icon: String
        let text: String
    }
}

enum OnboardingContent {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "building.columns.fill", accent: GameTheme.gold,
            kicker: "Deine Geschichte beginnt 2000",
            title: "Führe dein Land",
            message: "Wähle deine Partei und führe dein Land durch Wahlen, Krisen und historischen Wandel. Jede Entscheidung zählt.",
            bullets: [
                .init(icon: "flag.2.crossed.fill", text: "Wähle eine bestehende Partei oder gründe deine eigene."),
                .init(icon: "person.2.fill", text: "Sichere dir politische Unterstützung und halte deine Regierung handlungsfähig.")
            ]
        ),
        OnboardingPage(
            icon: "hand.tap.fill", accent: GameTheme.teal,
            kicker: "Du entscheidest",
            title: "Geschichte liegt in deiner Hand",
            message: "Reagiere auf Ereignisse, wäge deine Möglichkeiten ab und erlebe die Folgen – manchmal erst Jahre später.",
            bullets: [
                .init(icon: "chart.line.uptrend.xyaxis", text: "Wirtschaft, Sicherheit und Vertrauen verändern sich mit deinem Kurs."),
                .init(icon: "book.closed.fill", text: "Der historische Hintergrund erklärt, was tatsächlich geschah.")
            ]
        ),
        OnboardingPage(
            icon: "checkmark.seal.fill", accent: GameTheme.blue,
            kicker: "Dein politischer Kurs",
            title: "Bleib an der Macht",
            message: "Behalte die Lage im Blick, gewinne Wahlen und finde Mehrheiten für deine Vorhaben.",
            bullets: [
                .init(icon: "megaphone.fill", text: "Deine Bilanz und dein Wahlkampf entscheiden über deine Zukunft."),
                .init(icon: "globe.europe.africa.fill", text: "Pflege Bündnisse und gestalte die Außenpolitik.")
            ]
        ),
        OnboardingPage(
            icon: "globe.europe.africa.fill", accent: GameTheme.purple,
            kicker: "Zukunft 2050",
            title: "Eine Zukunft am Scheideweg",
            message: "Nach 2026 beginnt ein fiktives Szenario: Internationale Krisen können eskalieren und bis zu einem dritten Weltkrieg führen.",
            bullets: [
                .init(icon: "bubble.left.and.bubble.right.fill", text: "Setze auf Diplomatie und versuche, einen Krieg zu verhindern."),
                .init(icon: "hammer.fill", text: "Bewältige die Folgen deiner Entscheidungen und gestalte den Wiederaufbau.")
            ]
        ),
        OnboardingPage(
            icon: "sparkles", accent: GameTheme.gold,
            kicker: "Dein Einstieg",
            title: "Dein Weg bis 2050",
            message: "Spiele den Prolog von 2000 bis 2004 kostenlos. Danach warten die Hauptkampagne und die fiktive Erweiterung Zukunft 2050 auf dich.",
            bullets: [
                .init(icon: "gift.fill", text: "Der Prolog ist kostenlos spielbar."),
                .init(icon: "tag.fill", text: "Die Angebote und aktuellen Preise siehst du im nächsten Schritt. Du kannst sie jederzeit schließen.")
            ]
        )
    ]
}

// MARK: - Onboarding-Ansicht

/// Wischbare Einführung, die neuen Spielern die Kernmechanik erklärt.
struct OnboardingView: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    var onFinish: () -> Void

    @State private var index = 0
    private let pages = OnboardingContent.pages

    private var isLastPage: Bool { index >= pages.count - 1 }

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()
            RadialGradient(colors: [pages[index].accent.opacity(0.16), .clear], center: .top, startRadius: 20, endRadius: 520)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                TabView(selection: $index) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { offset, page in
                        OnboardingPageView(page: page)
                            .tag(offset)
                            .padding(.horizontal, 24)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: index)

                pageDots
                controls
            }
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(GameTheme.primaryText)
        .preferredColorScheme(.dark)
    }

    // MARK: Kopfzeile

    private var topBar: some View {
        HStack {
            FlagRibbon(height: 5).frame(width: 64)
            Text("\(index + 1) / \(pages.count)")
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(GameTheme.tertiaryText)
                .padding(.leading, 8)
            Spacer()
            if !isLastPage {
                Button(L("Überspringen")) { onFinish() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(GameTheme.secondaryText)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .frame(height: 44)
    }

    // MARK: Seiten-Punkte

    private var pageDots: some View {
        HStack(spacing: 7) {
            ForEach(pages.indices, id: \.self) { i in
                Capsule()
                    .fill(i == index ? GameTheme.gold : GameTheme.hairlineStrong)
                    .frame(width: i == index ? 22 : 7, height: 7)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: index)
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: Steuerung

    private var controls: some View {
        VStack(spacing: 12) {
            Button {
                if isLastPage {
                    onFinish()
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        index += 1
                    }
                }
            } label: {
                Label(L(isLastPage ? L("Los geht’s") : L("Weiter")),
                      systemImage: isLastPage ? "flag.checkered" : "arrow.right")
            }
            .buttonStyle(PrimaryActionButtonStyle())

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    index = max(0, index - 1)
                }
            } label: {
                Text(L("Zurück"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(index == 0 ? GameTheme.tertiaryText : GameTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
            .disabled(index == 0)
            .opacity(index == 0 ? 0 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

// MARK: - Einzelseite

private struct OnboardingPageView: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let page: OnboardingPage

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                Spacer(minLength: 6)

                ZStack {
                    Circle().fill(page.accent.opacity(0.06)).frame(width: 148, height: 148)
                    Circle().stroke(page.accent.opacity(0.14), lineWidth: 1).frame(width: 148, height: 148)
                    Circle().fill(page.accent.opacity(0.16)).frame(width: 108, height: 108)
                    Circle().stroke(page.accent.opacity(0.4), lineWidth: 1).frame(width: 108, height: 108)
                    Image(systemName: page.icon)
                        .font(.system(size: 43, weight: .semibold))
                        .foregroundStyle(page.accent)
                }

                VStack(spacing: 10) {
                    Text(L(page.kicker).uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(page.accent)
                    Text(L(page.title))
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(GameTheme.primaryText)
                        .multilineTextAlignment(.center)
                    Text(L(page.message))
                        .font(.callout)
                        .foregroundStyle(GameTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 4)
                }

                if !page.bullets.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(page.bullets) { bullet in
                            OnboardingBulletRow(bullet: bullet, accent: page.accent)
                        }
                    }
                    .padding(.top, 2)
                }

                Spacer(minLength: 6)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct OnboardingBulletRow: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let bullet: OnboardingPage.Bullet
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: bullet.icon)
                .font(.footnote.weight(.bold))
                .foregroundStyle(accent)
                .frame(width: 34, height: 34)
                .background(Circle().fill(accent.opacity(0.15)))
            Text(L(bullet.text))
                .font(.subheadline)
                .foregroundStyle(GameTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .gameCard(padding: 13)
    }
}
