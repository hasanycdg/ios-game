import SwiftUI
import RevenueCat
import RegiereDeutschlandCore

/// English fallback while a dashboard paywall is unpublished/unavailable,
/// and the purchase-management screen for US players who already own content.
struct USCampaignPaywallView: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let placement: CampaignPaywallPlacement
    @Environment(PurchaseManager.self) private var purchases
    @Environment(\.dismiss) private var dismiss
    @State private var restoreMessage: String?

    private var packages: [Package] {
        let available = purchases.offering(for: placement, country: .unitedStates)?.availablePackages
            ?? purchases.offering(for: placement)?.availablePackages
            ?? purchases.currentOffering?.availablePackages ?? []
        let allowed: Set<String> = switch placement {
        case .catalog:
            purchases.hasCampaign2005
                ? [Monetization.campaignProductID, Monetization.future2050ProductID, Monetization.completeProductID]
                : [Monetization.campaignProductID, Monetization.completeProductID]
        case .afterPrologue: [Monetization.campaignProductID, Monetization.completeProductID]
        case .afterMainCampaign: [Monetization.future2050ProductID]
        }
        return available.filter { allowed.contains($0.storeProduct.productIdentifier) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(L("LEAD AMERICA")).font(.caption.weight(.heavy)).tracking(3)
                        .foregroundStyle(GameTheme.gold)
                    Text(L("Your next chapter"))
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                    Text(L("Play 2000–2004 for free. Unlock the main campaign, then continue with the fictional Future 2050 expansion."))
                        .foregroundStyle(GameTheme.secondaryText)
                    Text(L("One-time purchases. No subscription. The same purchase unlocks the corresponding content for both Germany and the United States. Each country keeps its own saved progress."))
                        .font(.footnote).foregroundStyle(GameTheme.tertiaryText)
                    ForEach(packages, id: \.identifier) { package in
                        packageCard(package)
                    }
                    if packages.isEmpty {
                        Text(L("Offers are currently unavailable. Check your connection and try again."))
                            .font(.callout).foregroundStyle(GameTheme.secondaryText)
                        Button(L("Reload offers")) { Task { await purchases.loadOfferings() } }
                            .buttonStyle(SecondaryActionButtonStyle())
                            .disabled(purchases.isPurchasing)
                    }
                    if purchases.isPurchasing { ProgressView(L("Contacting the App Store…")) }
                    if let error = purchases.lastError {
                        Text(L(error)).font(.footnote).foregroundStyle(GameTheme.red)
                    }
                    if let restoreMessage {
                        Text(L(restoreMessage)).font(.footnote).foregroundStyle(GameTheme.secondaryText)
                    }
                    Button(L("Restore purchases")) {
                        Task {
                            restoreMessage = nil
                            let restored = await purchases.restorePurchases(country: .unitedStates)
                            if restored { dismiss() }
                            else if purchases.lastError == nil { restoreMessage = "No eligible purchases were found for this App Store account." }
                        }
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                    .disabled(purchases.isPurchasing)
                    Text(L("Future 2050 requires the main campaign. Prices and payment confirmation are provided by your App Store storefront."))
                        .font(.caption).foregroundStyle(GameTheme.tertiaryText)
                    HStack(spacing: 20) {
                        Link(L("Terms of Use"), destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        Link(L("Privacy Policy"), destination: URL(string: "https://regieredeutschland-support.lovable.app/datenschutz")!)
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
                    Button(L("Close")) { dismiss() }.disabled(purchases.isPurchasing)
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

    private func packageCard(_ package: Package) -> some View {
        let productID = package.storeProduct.productIdentifier
        let owned = isUnlocked(productID)
        let title: String = switch productID {
        case Monetization.campaignProductID: "Main campaign · 2005–2026"
        case Monetization.future2050ProductID: "Future 2050 · 2026–2050"
        default: "Complete bundle · 2005–2050"
        }
        let detail: String = switch productID {
        case Monetization.campaignProductID: "Continue your party’s administrations through American crises, elections, and reform. Includes founding your own party."
        case Monetization.future2050ProductID: "200 fictional scenario decisions and 75 additional events across crisis prevention, reconstruction, and a new world order."
        default: "The main campaign and Future 2050 expansion together."
        }
        return VStack(alignment: .leading, spacing: 12) {
            Text(L(title)).font(.headline)
            Text(L(detail)).font(.footnote).foregroundStyle(GameTheme.secondaryText)
            Button {
                Task {
                    restoreMessage = nil
                    let succeeded = await purchases.purchase(package, country: .unitedStates)
                    if succeeded && isUnlocked(productID) { dismiss() }
                    else if succeeded { restoreMessage = "Your purchase is being synchronized. Use Restore purchases if access does not appear." }
                }
            } label: {
                HStack {
                    Text(L(owned ? "Unlocked" : "Unlock"))
                    Spacer()
                    Text(owned ? "✓" : package.storeProduct.localizedPriceString)
                }
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(owned || purchases.isPurchasing)
        }
        .gameCard(tint: GameTheme.gold)
    }

    private func isUnlocked(_ productID: String) -> Bool {
        switch productID {
        case Monetization.campaignProductID: purchases.hasCampaign2005
        case Monetization.future2050ProductID: purchases.hasFuture2050
        default: purchases.hasCampaign2005 && purchases.hasFuture2050
        }
    }
}
