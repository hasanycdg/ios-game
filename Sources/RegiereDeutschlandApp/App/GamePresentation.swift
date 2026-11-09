import SwiftUI
import Observation
import RegiereDeutschlandCore

/// Display language and campaign are independent of the saved game.
@MainActor
@Observable
final class GamePresentation {
    var country: GameCountry = .germany {
        didSet { translations.removeAll(keepingCapacity: true) }
    }
    var language: GameLanguage = .german {
        didSet { translations.removeAll(keepingCapacity: true) }
    }
    @ObservationIgnored private var translations: [String: String] = [:]

    func text(_ source: String) -> String {
        if let cached = translations[source] { return cached }
        let result = GameTextLocalization.translate(source, country: country, language: language)
        if translations.count > 4096 { translations.removeAll(keepingCapacity: true) }
        translations[source] = result
        return result
    }

    /// Copy written directly in all three languages (onboarding, offers).
    func pick(_ german: String, _ english: String, _ french: String) -> String {
        switch language {
        case .german: german
        case .english: english
        case .french: french
        }
    }
}

extension GameLanguage {
    /// The device's preferred language, if the game supports it.
    static var deviceDefault: GameLanguage {
        for identifier in Locale.preferredLanguages {
            switch Locale(identifier: identifier).language.languageCode?.identifier {
            case "de": return .german
            case "fr": return .french
            case "en": return .english
            default: continue
            }
        }
        return .english
    }
}

@MainActor
protocol LocalizedGameView: View {
    var gamePresentation: GamePresentation { get }
}

extension LocalizedGameView {
    func L(_ source: String) -> String { gamePresentation.text(source) }
    /// Numeric and other interpolated values retain their native formatting.
    func L<Value>(_ value: Value) -> Value { value }
}

private struct ChooseCountryKey: EnvironmentKey {
    static let defaultValue: @MainActor () -> Void = {}
}

extension EnvironmentValues {
    var chooseCountry: @MainActor () -> Void {
        get { self[ChooseCountryKey.self] }
        set { self[ChooseCountryKey.self] = newValue }
    }
}

struct CountrySelectionView: View {
    let onSelect: (GameCountry) -> Void

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(GameTheme.gold)
                        .padding(.top, 48)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Wähle dein Land\nChoose your country\nChoisis ton pays")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                        Text("Vier Länder. Deine Entscheidungen.\nFour countries. Your decisions.\nQuatre pays. Tes décisions.")
                            .foregroundStyle(GameTheme.secondaryText)
                    }
                    countryButton(.germany, flag: "🇩🇪", name: "Deutschland", detail: "Regiere Deutschland · 2000–2050")
                    countryButton(.unitedStates, flag: "🇺🇸", name: "United States", detail: "Lead America · 2000–2050")
                    countryButton(.unitedKingdom, flag: "🇬🇧", name: "United Kingdom", detail: "Govern Britain · 2000–2050")
                    countryButton(.france, flag: "🇫🇷", name: "France", detail: "Gouverne la France · 2000–2050")
                    Text("Spielstände werden für jedes Land separat gespeichert.\nEach country has its own saved progress.\nChaque pays a sa propre sauvegarde.")
                        .font(.footnote)
                        .foregroundStyle(GameTheme.tertiaryText)
                    Spacer(minLength: 32)
                }
                .padding(24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(GameTheme.primaryText)
    }

    private func countryButton(_ country: GameCountry, flag: String, name: String, detail: String) -> some View {
        Button { onSelect(country) } label: {
            HStack(spacing: 16) {
                Text(flag).font(.system(size: 42))
                VStack(alignment: .leading, spacing: 5) {
                    Text(name).font(.title2.weight(.bold))
                    Text(detail).font(.footnote).foregroundStyle(GameTheme.secondaryText)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").foregroundStyle(GameTheme.gold)
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 18).fill(GameTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(GameTheme.gold.opacity(0.3)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("country.\(country.rawValue)")
    }
}

struct LanguageSelectionView: View {
    let country: GameCountry
    let onSelect: (GameLanguage) -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            GameTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Button(action: onBack) {
                        Label("Zurück · Back · Retour", systemImage: "chevron.left")
                    }
                    .foregroundStyle(GameTheme.gold)
                    .padding(.top, 36)
                    Text(country.flag + " " + country.nativeName)
                        .font(.title2.weight(.bold))
                    Text("Wähle deine Sprache\nChoose your language\nChoisis ta langue")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                    ForEach(orderedLanguages, id: \.self) { language in
                        languageButton(language, name: language.nativeName,
                                       recommended: language == GameLanguage.deviceDefault)
                    }
                    Text("Dein Spielstand bleibt für dieses Land erhalten.\nYour saved progress stays with this country.\nTa sauvegarde reste liée à ce pays.")
                        .font(.footnote)
                        .foregroundStyle(GameTheme.tertiaryText)
                }
                .padding(24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(GameTheme.primaryText)
    }

    /// The device language comes first, so most players confirm with one tap.
    private var orderedLanguages: [GameLanguage] {
        let preferred = GameLanguage.deviceDefault
        return [preferred] + GameLanguage.allCases.filter { $0 != preferred }
    }

    private func languageButton(_ language: GameLanguage, name: String, recommended: Bool) -> some View {
        Button { onSelect(language) } label: {
            HStack {
                Text(name).font(.title3.weight(.bold))
                if recommended {
                    Image(systemName: "iphone")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(GameTheme.gold)
                        .accessibilityLabel("Device language")
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(GameTheme.gold)
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 18).fill(recommended ? GameTheme.gold.opacity(0.12) : GameTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(GameTheme.gold.opacity(recommended ? 0.8 : 0.3), lineWidth: recommended ? 1.5 : 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("language.\(language.rawValue)")
    }
}

extension GameLanguage {
    var nativeName: String {
        switch self {
        case .german: "Deutsch"
        case .english: "English"
        case .french: "Français"
        }
    }
}

extension GameCountry {
    var flag: String {
        switch self {
        case .germany: "🇩🇪"
        case .unitedStates: "🇺🇸"
        case .unitedKingdom: "🇬🇧"
        case .france: "🇫🇷"
        }
    }

    /// Name shown on the country and language screens (before a language is chosen).
    var nativeName: String {
        switch self {
        case .germany: "Deutschland"
        case .unitedStates: "United States"
        case .unitedKingdom: "United Kingdom"
        case .france: "France"
        }
    }

    /// Suffix for per-country preference keys. Germany keeps its original keys.
    var preferenceSuffix: String {
        switch self {
        case .germany: ""
        case .unitedStates: ".us"
        case .unitedKingdom: ".uk"
        case .france: ".fr"
        }
    }
}
