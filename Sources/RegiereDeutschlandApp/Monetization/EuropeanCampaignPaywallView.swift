import SwiftUI
import RevenueCat
import RegiereDeutschlandCore

/// Native purchase and restore screen for the United Kingdom and France. It
/// sells the same StoreKit products and entitlements as Germany and the USA.
struct EuropeanCampaignPaywallView: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    var placement: CampaignPaywallPlacement = .catalog
    @Environment(PurchaseManager.self) private var purchases
    @Environment(\.dismiss) private var dismiss
    @State private var message: String?

    private var productIDs: [String] {
        switch placement {
        case .afterMainCampaign: [Monetization.future2050ProductID]
        case .afterPrologue: [Monetization.campaignProductID, Monetization.completeProductID]
        case .catalog: purchases.hasCampaign2005
            ? [Monetization.campaignProductID, Monetization.future2050ProductID]
            : [Monetization.campaignProductID, Monetization.completeProductID]
        }
    }

    private var packages: [Package] {
        let sources = [purchases.offering(for: placement, country: gamePresentation.country),
                       purchases.offering(for: .catalog, country: gamePresentation.country),
                       purchases.offering(for: .afterMainCampaign, country: gamePresentation.country),
                       purchases.offering(for: placement), purchases.offering(for: .catalog),
                       purchases.offering(for: .afterMainCampaign), purchases.currentOffering]
        return productIDs.compactMap { id in
            sources.lazy.compactMap { $0?.availablePackages.first { $0.storeProduct.productIdentifier == id } }.first
        }
    }

    private func isUnlocked(_ id: String) -> Bool {
        switch id {
        case Monetization.campaignProductID: purchases.hasCampaign2005
        case Monetization.future2050ProductID: purchases.hasFuture2050
        default: purchases.hasCampaign2005 && purchases.hasFuture2050
        }
    }

    private func title(_ id: String) -> String {
        switch id {
        case Monetization.campaignProductID: "Hauptkampagne · 2005–2026"
        case Monetization.future2050ProductID: "Zukunft 2050 · 2026–2050"
        default: "Komplettpaket · 2005–2050"
        }
    }

    private func detail(_ id: String) -> String {
        switch id {
        case Monetization.campaignProductID: "Alle Wahlen, Krisen und Reformen bis 2026. Inklusive Gründung einer eigenen Partei."
        case Monetization.future2050ProductID: "200 fiktive Szenario-Entscheidungen und 75 zusätzliche Ereignisse: Krisenprävention, Wiederaufbau und eine neue Weltordnung. Benötigt die Hauptkampagne."
        default: "Hauptkampagne und Zukunft 2050 zusammen."
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(gamePresentation.country.flag).font(.system(size: 48))
                    Text(L(placement == .afterMainCampaign ? String("Zukunft 2050") : String("Kampagnen & Pakete")))
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                    Text(L("Spiele den Prolog von 2000 bis 2004 kostenlos. Die Hauptkampagne führt dein Land bis 2026, die fiktive Erweiterung Zukunft 2050 bis 2050."))
                        .foregroundStyle(GameTheme.secondaryText)
                    Text(L("Einmalkauf, kein Abo. Derselbe Kauf schaltet die Hauptkampagne in allen Ländern frei. Jedes Land behält seinen eigenen Spielstand."))
                        .font(.footnote).foregroundStyle(GameTheme.tertiaryText)

                    ForEach(packages, id: \.identifier) { package in
                        let id = package.storeProduct.productIdentifier
                        VStack(alignment: .leading, spacing: 12) {
                            Text(L(title(id))).font(.headline)
                            Text(L(detail(id))).font(.footnote).foregroundStyle(GameTheme.secondaryText)
                            Button { buy(package) } label: {
                                HStack {
                                    Text(L(isUnlocked(id) ? String("Freigeschaltet") : String("Freischalten")))
                                    Spacer()
                                    Text(isUnlocked(id) ? "✓" : package.storeProduct.localizedPriceString)
                                }
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                            .disabled(isUnlocked(id) || purchases.isPurchasing)
                        }
                        .gameCard(tint: GameTheme.gold)
                    }
                    if packages.isEmpty {
                        Text(L("Das Angebot ist gerade nicht verfügbar. Bitte prüfe deine Internetverbindung und versuche es erneut."))
                            .font(.callout).foregroundStyle(GameTheme.secondaryText)
                        Button(L("Erneut laden")) { Task { await purchases.loadOfferings() } }
                            .buttonStyle(SecondaryActionButtonStyle())
                            .disabled(purchases.isPurchasing)
                    }

                    if purchases.isPurchasing { ProgressView() }
                    if let error = purchases.lastError {
                        Text(L(error)).font(.footnote).foregroundStyle(GameTheme.red)
                    }
                    if let message {
                        Text(L(message)).font(.footnote).foregroundStyle(GameTheme.secondaryText)
                    }
                    Button(L("Käufe wiederherstellen")) {
                        Task {
                            message = nil
                            let restored = await purchases.restorePurchases(country: gamePresentation.country)
                            if restored && productIDs.allSatisfy({ isUnlocked($0) || $0 == Monetization.completeProductID }) { dismiss() }
                            else if purchases.lastError == nil { message = "Keine passenden Käufe gefunden." }
                        }
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                    .disabled(purchases.isPurchasing)
                    HStack(spacing: 20) {
                        Link(L("Nutzungsbedingungen"), destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        Link(L("Datenschutz"), destination: URL(string: "https://regieredeutschland-support.lovable.app/datenschutz")!)
                    }
                    .font(.caption)
                }
                .padding(24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .background(GameTheme.background.ignoresSafeArea())
            .foregroundStyle(GameTheme.primaryText)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("Schließen")) { dismiss() }.disabled(purchases.isPurchasing)
                }
            }
        }
        .tint(GameTheme.gold)
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled(purchases.isPurchasing)
        .task {
            purchases.lastError = nil
            if packages.isEmpty { await purchases.loadOfferings() }
        }
    }

    private func buy(_ package: Package) {
        Task {
            message = nil
            let succeeded = await purchases.purchase(package, country: gamePresentation.country)
            if succeeded && isUnlocked(package.storeProduct.productIdentifier) { dismiss() }
            else if succeeded { message = "Dein Kauf wird synchronisiert. Falls nötig, stelle deine Käufe wieder her." }
        }
    }
}
