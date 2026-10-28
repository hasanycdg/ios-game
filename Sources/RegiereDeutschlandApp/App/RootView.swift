import SwiftUI
import RegiereDeutschlandCore

struct RootView: View {
    @Environment(UpdateReminder.self) private var reminder
    @State private var navigationID = UUID()
    @State private var selectedCountry: GameCountry?
    @State private var countryAwaitingLanguage: GameCountry?
    @State private var presentation = GamePresentation()

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
                    navigationID = UUID()
                })
            } else if let country = countryAwaitingLanguage {
                LanguageSelectionView(country: country) { language in
                    presentation.country = country
                    presentation.language = language
                    selectedCountry = country
                    countryAwaitingLanguage = nil
                    navigationID = UUID()
                } onBack: {
                    countryAwaitingLanguage = nil
                }
            } else {
                CountrySelectionView { country in
                    countryAwaitingLanguage = country
                }
            }
        }
        .id(navigationID)
        .tint(GameTheme.gold)
        .preferredColorScheme(.dark)
        .sheet(isPresented: Binding(
            get: { reminder.showFutureUpdate && selectedCountry != nil },
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
}
