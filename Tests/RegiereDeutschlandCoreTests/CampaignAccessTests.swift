import Foundation
import Testing
@testable import RegiereDeutschlandCore

@Test func campaignPurchasesGrantOnlyTheirIntendedAccess() {
    let free = CampaignAccess(activeEntitlements: [])
    #expect(free.finalYear == 2004)
    let main = CampaignAccess(activeEntitlements: [CampaignAccess.mainEntitlementID])
    #expect(main.finalYear == 2026)
    #expect(!main.hasFutureCampaign)
    let expansionOnly = CampaignAccess(activeEntitlements: [CampaignAccess.futureEntitlementID])
    #expect(!expansionOnly.hasMainCampaign)
    #expect(!expansionOnly.hasFutureCampaign)
    #expect(expansionOnly.finalYear == 2004)
    let complete = CampaignAccess(activeEntitlements: [CampaignAccess.mainEntitlementID, CampaignAccess.futureEntitlementID])
    #expect(complete.hasMainCampaign)
    #expect(complete.hasFutureCampaign)
    #expect(complete.finalYear == 2050)
}

@Test func bundleSavingsUseTheActualCurrencyAndNeverInventADiscount() {
    let saving = CampaignBundleSaving.amount(main: Decimal(string: "4.99")!, future: Decimal(string: "6.99")!,
        bundle: Decimal(string: "9.99")!, mainCurrency: "EUR", futureCurrency: "EUR", bundleCurrency: "EUR")
    #expect(saving == Decimal(string: "1.99"))
    #expect(CampaignBundleSaving.amount(main: 3, future: 5, bundle: 8,
        mainCurrency: "CHF", futureCurrency: "CHF", bundleCurrency: "CHF") == nil)
    #expect(CampaignBundleSaving.amount(main: 3, future: 5, bundle: 9,
        mainCurrency: "CHF", futureCurrency: "CHF", bundleCurrency: "CHF") == nil)
    #expect(CampaignBundleSaving.amount(main: 5, future: 7, bundle: 10,
        mainCurrency: "USD", futureCurrency: "EUR", bundleCurrency: "EUR") == nil)
    #expect(CampaignBundleSaving.amount(main: 5, future: 7, bundle: 10,
        mainCurrency: nil, futureCurrency: nil, bundleCurrency: nil) == nil)
}

@Test func aBundleContinuesTheSameCampaignAtEitherPurchaseCheckpoint() {
    let free = CampaignAccess(activeEntitlements: [])
    let main = CampaignAccess(activeEntitlements: [CampaignAccess.mainEntitlementID])
    let expansionOnly = CampaignAccess(activeEntitlements: [CampaignAccess.futureEntitlementID])
    let bundle = CampaignAccess(activeEntitlements: [CampaignAccess.mainEntitlementID, CampaignAccess.futureEntitlementID])

    #expect(free.continuationFinalYear(after: 2004) == nil)
    #expect(expansionOnly.continuationFinalYear(after: 2004) == nil)
    #expect(main.continuationFinalYear(after: 2004) == 2026)
    #expect(main.continuationFinalYear(after: 2026) == nil)
    // Both rights arrive in a single CustomerInfo, so no intermediate 2026 gate is needed.
    #expect(bundle.continuationFinalYear(after: 2004) == 2050)
    #expect(bundle.continuationFinalYear(after: 2026) == 2050)
    #expect(bundle.continuationFinalYear(after: 2050) == nil)
    #expect(bundle.continuationFinalYear(after: 2003) == nil)
}
