import SwiftUI
#if os(iOS)
import UIKit
#endif

@main
struct RegiereDeutschlandApp: App {
    /// Zentrale RevenueCat-Anbindung. Konfiguriert das SDK beim Erzeugen und
    /// wird als Environment-Objekt an die gesamte View-Hierarchie durchgereicht.
    @State private var purchaseManager = PurchaseManager()

    init() {
        AppAppearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(purchaseManager)
        }
    }
}

/// Dunkle System-Chrome (Tab-Bar, Navigation-Bar) passend zum Design.
enum AppAppearance {
    static func configure() {
        #if os(iOS)
        let barColor = UIColor(red: 0.045, green: 0.048, blue: 0.062, alpha: 1)

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = barColor
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = barColor
        let titleColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
        nav.titleTextAttributes = [.foregroundColor: titleColor]
        nav.largeTitleTextAttributes = [.foregroundColor: titleColor]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        #endif
    }
}
