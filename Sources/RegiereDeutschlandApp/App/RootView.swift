import SwiftUI
import RegiereDeutschlandCore

struct RootView: View {
    @Environment(UpdateReminder.self) private var reminder
    @State private var navigationID = UUID()
    @State private var selectedCountry: GameCountry?
    @State private var countryAwaitingLanguage: GameCountry?
    @State private var presentation = GamePresentation()
    /// Country and language are chosen once and restored on every launch.
    @AppStorage("selectedGameCountry") private var storedCountry = ""
    @AppStorage("selectedGameLanguage") private var storedLanguage = ""
    @State private var didRestoreSelection = false

    var body: some View {
        Group {
            if let country = selectedCountry {
                NavigationStack {
                    HomeScreen(country: country)
                }
                .environment(\.locale, Locale(identifier: presentation.language.localeIdentifier))
                .environment(\.chooseCountry, {
                    selectedCountry = nil
                    countryAwaitingLanguage = nil
                    storedCountry = ""
                    navigationID = UUID()
                })
            } else if let country = countryAwaitingLanguage {
                LanguageSelectionView(country: country) { language in
                    Analytics.track(.countrySelected, ["country": country.rawValue, "language": language.rawValue])
                    select(country, language)
                } onBack: {
                    countryAwaitingLanguage = nil
                }
            } else if didRestoreSelection {
                CountrySelectionView { country in
                    countryAwaitingLanguage = country
                }
            } else {
                GameTheme.background.ignoresSafeArea()
            }
        }
        .id(navigationID)
        .tint(GameTheme.gold)
        .preferredColorScheme(.dark)
        .onAppear(perform: restoreSelection)
        .sheet(isPresented: Binding(
            get: { reminder.showFutureUpdate && selectedCountry?.hasFutureExpansion == true },
            set: { reminder.showFutureUpdate = $0 }
        )) {
            FutureUpdateView()
        }
        .onChange(of: reminder.showFutureUpdate) { _, isPresented in
            // Close a prior game before the notification page can resume its save.
            if isPresented { navigationID = UUID() }
        }
        .environment(presentation)
    }

    private func select(_ country: GameCountry, _ language: GameLanguage) {
        presentation.country = country
        presentation.language = language
        storedCountry = country.rawValue
        storedLanguage = language.rawValue
        selectedCountry = country
        countryAwaitingLanguage = nil
        navigationID = UUID()
    }

    private func restoreSelection() {
        guard !didRestoreSelection else { return }
        didRestoreSelection = true
        if let country = GameCountry(rawValue: storedCountry),
           let language = GameLanguage(rawValue: storedLanguage) {
            select(country, language)
        }
    }
}
