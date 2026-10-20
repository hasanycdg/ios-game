import Foundation

/// Store-Produkte werden in RevenueCat diesen dauerhaften Inhaltsrechten zugeordnet.
public struct CampaignAccess: Equatable, Sendable {
    public static let mainEntitlementID = "Regiere Deutschland Pro"
    public static let futureEntitlementID = "zukunft_2050"

    public let hasMainCampaign: Bool
    public let hasFutureCampaign: Bool

    public init(activeEntitlements: Set<String>) {
        hasMainCampaign = activeEntitlements.contains(Self.mainEntitlementID)
        hasFutureCampaign = hasMainCampaign && activeEntitlements.contains(Self.futureEntitlementID)
    }

    public var finalYear: Int { hasFutureCampaign ? 2050 : (hasMainCampaign ? 2026 : 2004) }

    /// Nach Kauf oder Restore dieselbe Amtszeit bis zum tatsächlich gekauften Ende verlängern.
    /// Das Bundle führt auch vom Prolog direkt bis 2050, unabhängig von der Callback-Reihenfolge.
    public func continuationFinalYear(after campaignFinalYear: Int) -> Int? {
        guard campaignFinalYear == 2004 || campaignFinalYear == 2026,
              finalYear > campaignFinalYear else { return nil }
        return finalYear
    }
}

public enum CampaignBundleSaving {
    /// Einen Rabatt nur für vergleichbare Storepreise und einen positiven Betrag zeigen.
    public static func amount(main: Decimal, future: Decimal, bundle: Decimal,
                              mainCurrency: String?, futureCurrency: String?, bundleCurrency: String?) -> Decimal? {
        guard let mainCurrency, !mainCurrency.isEmpty,
              mainCurrency == futureCurrency, mainCurrency == bundleCurrency else { return nil }
        let saving = main + future - bundle
        return saving > 0 ? saving : nil
    }
}
