import SwiftUI
import RevenueCat
import RevenueCatUI
import RegiereDeutschlandCore

// MARK: - Paywall-Container

/// Die drei Offerings werden ausdrücklich nach ihrem Einstiegspunkt geladen.
struct CampaignPaywallView: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let placement: CampaignPaywallPlacement
    @Environment(PurchaseManager.self) private var purchases
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if gamePresentation.country == .unitedStates && purchases.hasFuture2050 {
                USCampaignPaywallView(placement: placement)
            } else if let offering = purchases.offering(for: placement, country: gamePresentation.country), offering.hasPaywall {
                PaywallView(offering: offering, displayCloseButton: true)
                    .customPaywallVariables(bundleVariables)
                    .onPurchaseCompleted { info in
                        purchases.acceptCustomerInfo(info)
                        dismiss()
                    }
                    .onRestoreCompleted { info in
                        purchases.acceptCustomerInfo(info)
                        let restored: Bool = switch placement {
                        case .catalog:
                            info.entitlements.active[Monetization.proEntitlementID] != nil ||
                            info.entitlements.active[Monetization.future2050EntitlementID] != nil
                        case .afterPrologue: purchases.hasCampaign2005
                        case .afterMainCampaign: purchases.hasFuture2050
                        }
                        if restored { dismiss() }
                    }
            } else if gamePresentation.country == .unitedStates {
                // Unpublished or unavailable US paywalls keep an English purchase UI.
                USCampaignPaywallView(placement: placement)
            } else {
                PurchaseUnavailableView(title: placement.loadingTitle)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            if purchases.offering(for: placement, country: gamePresentation.country)?.hasPaywall != true {
                await purchases.loadOfferings()
            }
        }
    }

    private var bundleVariables: [String: CustomVariableValue] {
        // Preisvergleich immer aus dem vollständigen Katalog, auch bei zwei Kaufoptionen.
        let products = purchases.currentOffering?.availablePackages.map(\.storeProduct) ?? []
        var variables: [String: CustomVariableValue] = [
            "bundle_saving": .string(""), "show_bundle_saving": .bool(false)
        ]
        if gamePresentation.country == .unitedStates {
            variables["has_main_campaign"] = .bool(purchases.hasCampaign2005)
        }
        // Am Ende der Hauptkampagne ist diese bereits gekauft: kein irreführender Paket-Rabatt.
        guard placement != .afterMainCampaign,
              !purchases.hasCampaign2005,
              let main = products.first(where: { $0.productIdentifier == Monetization.campaignProductID }),
              let future = products.first(where: { $0.productIdentifier == Monetization.future2050ProductID }),
              let bundle = products.first(where: { $0.productIdentifier == Monetization.completeProductID }),
              let saving = CampaignBundleSaving.amount(main: main.price, future: future.price, bundle: bundle.price,
                  mainCurrency: main.currencyCode, futureCurrency: future.currencyCode, bundleCurrency: bundle.currencyCode),
              let formatted = bundle.priceFormatter?.string(from: NSDecimalNumber(decimal: saving)) else {
            return variables
        }
        variables["bundle_saving"] = .string(formatted)
        variables["show_bundle_saving"] = .bool(true)
        return variables
    }
}

private struct PurchaseUnavailableView: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let title: String
    @Environment(PurchaseManager.self) private var purchases
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40))
                .foregroundStyle(GameTheme.goldGradient)
            Text(L(title))
                .font(.title3.weight(.heavy))
                .foregroundStyle(GameTheme.primaryText)
            Text(L("Das Angebot ist gerade nicht verfügbar. Bitte prüfe deine Internetverbindung und versuche es erneut."))
                .font(.subheadline)
                .foregroundStyle(GameTheme.secondaryText)
                .multilineTextAlignment(.center)
            Button(L("Erneut laden")) {
                Task { await purchases.loadOfferings() }
            }
                .buttonStyle(PrimaryActionButtonStyle())
            Button(L("Schließen")) { dismiss() }
                .buttonStyle(SecondaryActionButtonStyle())
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GameTheme.background.ignoresSafeArea())
    }
}

// MARK: - Zentraler Kaufzugang auf der Startseite

struct CampaignStoreCard: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    @Environment(PurchaseManager.self) private var purchases
    @State private var showPaywall = false
    @State private var showCustomerCenter = false

    private var status: String {
        if purchases.hasFuture2050 { return L("Beide Kampagnen bis 2050 sind freigeschaltet.") }
        if purchases.hasCampaign2005 { return L("Hauptkampagne aktiv. Entdecke die Zukunft bis 2050.") }
        return L("Spiele den Prolog kostenlos und wähle danach deine Kampagne.")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "building.columns.fill")
                    .font(.headline)
                    .foregroundStyle(GameTheme.goldGradient)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(GameTheme.gold.opacity(0.16)))
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("Kampagnen & Pakete"))
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(GameTheme.primaryText)
                    Text(L(status))
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button {
                Haptics.impact(.light)
                showPaywall = true
            } label: {
                Label(L("Alle Angebote ansehen"), systemImage: "sparkles")
            }
            .buttonStyle(PrimaryActionButtonStyle())

            Button {
                showCustomerCenter = true
            } label: {
                Text(L("Käufe verwalten & wiederherstellen"))
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(GameTheme.secondaryText)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .gameCard(tint: GameTheme.gold)
        .sheet(isPresented: $showPaywall) {
            CampaignPaywallView(placement: .catalog)
        }
        .sheet(isPresented: Binding(
            get: { showCustomerCenter && gamePresentation.country == .unitedStates },
            set: { showCustomerCenter = $0 }
        )) {
            USCampaignPaywallView(placement: .catalog)
        }
        .presentCustomerCenter(isPresented: Binding(
            get: { showCustomerCenter && gamePresentation.country == .germany },
            set: { showCustomerCenter = $0 }
        ), onDismiss: {
            showCustomerCenter = false
        })
    }
}

// MARK: - Pro-Gate für einzelne Features

/// Kleines Schloss-Abzeichen, das an Pro-Features angezeigt werden kann.
struct ProLockBadge: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
            Text(L("Pro"))
        }
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.05))
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Capsule().fill(GameTheme.goldGradient))
    }
}

/// Wiederverwendbarer Gate-Modifier: Ist der Nutzer nicht Pro, wird beim
/// Auslösen (`trigger` wird `true`) automatisch die Paywall gezeigt, statt die
/// eigentliche Aktion durchzulassen.
///
/// Nutzung: siehe `HomeScreen` (Gründung einer eigenen Partei).
extension View {
    /// Zeigt Hauptkampagne und Bundle für ein Pro-Feature als Sheet, solange
    /// `isPresented` `true` ist.
    func proPaywallSheet(isPresented: Binding<Bool>) -> some View {
        sheet(isPresented: isPresented) {
            CampaignPaywallView(placement: .afterPrologue)
        }
    }
}
