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
            icon: "building.columns.fill",
            accent: GameTheme.gold,
            kicker: "2000 – 2026",
            title: "Du regierst Deutschland",
            message: "26 Jahre, ein Land, deine Entscheidungen. Vom Millennium bis heute führst du die Bundesrepublik durch Krisen, Wahlen und Wandel.",
            bullets: []
        ),
        OnboardingPage(
            icon: "bubble.left.and.bubble.right.fill",
            accent: GameTheme.teal,
            kicker: "Jedes Jahr",
            title: "Reagiere auf Ereignisse",
            message: "Politik kommt als Ereignis: Krisen, Reformen, Skandale. Du wählst A, B oder C – und trägst die Folgen.",
            bullets: [
                .init(icon: "hand.tap.fill", text: "Keine Wirkungs-Hinweise: Du entscheidest wie ein echter Kanzler, ohne Spickzettel."),
                .init(icon: "book.closed.fill", text: "Tippe auf „Historischer Hintergrund“, um die reale Lage zu verstehen.")
            ]
        ),
        OnboardingPage(
            icon: "gauge.with.dots.needle.67percent",
            accent: GameTheme.blue,
            kicker: "Dein Cockpit",
            title: "Behalte die Lage im Blick",
            message: "Acht Kennwerte zeigen den Zustand des Landes – von Wirtschaft und Haushalt bis Vertrauen. Dazu deine Zustimmung im Volk.",
            bullets: [
                .init(icon: "arrow.up.arrow.down", text: "Jede Entscheidung verschiebt mehrere Werte gleichzeitig."),
                .init(icon: "exclamationmark.triangle.fill", text: "Sacken Werte und Zustimmung zu tief, verlierst du die Macht.")
            ]
        ),
        OnboardingPage(
            icon: "clock.arrow.circlepath",
            accent: GameTheme.purple,
            kicker: "Alles wirkt nach",
            title: "Denke langfristig",
            message: "Viele Folgen zeigen sich erst Jahre später. Was du 2008 beschließt, kann dich 2024 einholen.",
            bullets: [
                .init(icon: "link", text: "Entscheidungen bilden Ketten über mehrere Jahre."),
                .init(icon: "eye.slash.fill", text: "Versteckte Effekte formen die Zukunft, ohne dass du sie sofort siehst.")
            ]
        ),
        OnboardingPage(
            icon: "checkmark.seal.fill",
            accent: GameTheme.gold,
            kicker: "Alle 4 Jahre",
            title: "Gewinne Wahlen, schmiede Koalitionen",
            message: "Zur Bundestagswahl zählt deine Bilanz. Führe Wahlkampf, verhandle Koalitionen – oder das Spiel ist vorbei.",
            bullets: [
                .init(icon: "megaphone.fill", text: "Im Wahlkampf setzt du einen Schwerpunkt, der Stimmen bringt."),
                .init(icon: "person.3.fill", text: "Ohne eigene Mehrheit brauchst du Partner mit eigenen Bedingungen.")
            ]
        ),
        OnboardingPage(
            icon: "square.grid.2x2.fill",
            accent: GameTheme.green,
            kicker: "Deine Werkzeuge",
            title: "Fünf Tabs zum Regieren",
            message: "Unten wechselst du zwischen deinen Regierungs-Ansichten.",
            bullets: [
                .init(icon: "flag.fill", text: "Lage – das aktuelle Ereignis und deine Entscheidung."),
                .init(icon: "newspaper.fill", text: "Presse – Schlagzeilen und Chronik deiner Amtszeit."),
                .init(icon: "chart.bar.fill", text: "Ressorts – Haushalt, Politikfelder und Kabinett."),
                .init(icon: "building.columns.fill", text: "Politik – Parteien, Kräfte und Bundesrat."),
                .init(icon: "globe.europe.africa.fill", text: "Welt – Diplomatie und Außenpolitik.")
            ]
        )
    ]
}

// MARK: - Onboarding-Ansicht

/// Wischbare Einführung, die neuen Spielern die Kernmechanik erklärt.
struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var index = 0
    private let pages = OnboardingContent.pages

    private var isLastPage: Bool { index >= pages.count - 1 }

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()

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
            Spacer()
            if !isLastPage {
                Button("Überspringen") { onFinish() }
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
                Label(isLastPage ? "Los geht’s" : "Weiter",
                      systemImage: isLastPage ? "flag.checkered" : "arrow.right")
            }
            .buttonStyle(PrimaryActionButtonStyle())

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    index = max(0, index - 1)
                }
            } label: {
                Text("Zurück")
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

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                Spacer(minLength: 6)

                ZStack {
                    Circle().fill(page.accent.opacity(0.14)).frame(width: 90, height: 90)
                    Circle().stroke(page.accent.opacity(0.4), lineWidth: 1).frame(width: 90, height: 90)
                    Image(systemName: page.icon)
                        .font(.system(size: 38))
                        .foregroundStyle(page.accent)
                }

                VStack(spacing: 10) {
                    Text(page.kicker.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(page.accent)
                    Text(page.title)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(GameTheme.primaryText)
                        .multilineTextAlignment(.center)
                    Text(page.message)
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

private struct OnboardingBulletRow: View {
    let bullet: OnboardingPage.Bullet
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: bullet.icon)
                .font(.footnote.weight(.bold))
                .foregroundStyle(accent)
                .frame(width: 34, height: 34)
                .background(Circle().fill(accent.opacity(0.15)))
            Text(bullet.text)
                .font(.subheadline)
                .foregroundStyle(GameTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .gameCard(padding: 13)
    }
}
