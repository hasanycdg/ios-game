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
                        Text("Wähle dein Land\nChoose your country")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                        Text("Zwei Länder. Deine Entscheidungen.\nTwo countries. Your decisions.")
                            .foregroundStyle(GameTheme.secondaryText)
                    }
                    countryButton(.germany, flag: "🇩🇪", name: "Deutschland", detail: "Regiere Deutschland von 2000 bis 2050.")
                    countryButton(.unitedStates, flag: "🇺🇸", name: "United States", detail: "Lead America from 2000 to 2050.")
                    Text("Spielstände werden für jedes Land separat gespeichert.\nEach country has its own saved progress.")
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
                        Label("Zurück · Back", systemImage: "chevron.left")
                    }
                    .foregroundStyle(GameTheme.gold)
                    .padding(.top, 36)
                    Text(country == .germany ? "🇩🇪 Deutschland" : "🇺🇸 United States")
                        .font(.title2.weight(.bold))
                    Text("Wähle deine Sprache\nChoose your language")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                    languageButton(.german, name: "Deutsch")
                    languageButton(.english, name: "English")
                    Text("Dein Spielstand bleibt für dieses Land erhalten.\nYour saved progress stays with this country.")
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

    private func languageButton(_ language: GameLanguage, name: String) -> some View {
        Button { onSelect(language) } label: {
            HStack {
                Text(name).font(.title3.weight(.bold))
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(GameTheme.gold)
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 18).fill(GameTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(GameTheme.gold.opacity(0.3)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("language.\(language.rawValue)")
    }
}
