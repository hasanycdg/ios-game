import Foundation
import RegiereDeutschlandCore

/// Zentrale Konstanten für die RevenueCat-Anbindung.
///
/// Nur Konfiguration – keine Logik. Alle Werte, die sich pro Umgebung oder
/// beim Wechsel in die Produktion ändern, stehen hier an *einer* Stelle.
enum Monetization {

    // MARK: - API-Key

    /// Öffentlicher RevenueCat-SDK-Key (Apple App Store, Präfix `appl_`).
    ///
    /// Produktions-Key: Käufe laufen über **echtes StoreKit**. Zum Testen brauchst du
    /// entweder eine **StoreKit-Configuration-Datei** (lokal im Simulator, ohne App
    /// Store Connect) oder einen **Sandbox-Tester** auf einem echten Gerät. Die
    /// Produkt-Identifier müssen zu denen in RevenueCat / App Store Connect passen.
    ///
    /// Niemals den **geheimen** `sk_`-Key ins App-Binary schreiben.
    static let apiKey = "appl_KAgQFdSIhNUegjQBRmWbZTeUtpG"

    // MARK: - Entitlement

    /// Bezeichner des Entitlements, das „Pro“ freischaltet.
    ///
    /// Muss **exakt** mit dem Entitlement-*Identifier* im RevenueCat-Dashboard
    /// übereinstimmen (Groß-/Kleinschreibung und Leerzeichen inklusive).
    /// Hinweis: Leerzeichen sind erlaubt, aber ein kurzer, code-freundlicher
    /// Identifier wie `pro` ist robuster. Wenn du im Dashboard `pro` verwendest,
    /// ändere hier nur diesen einen String.
    static let proEntitlementID = CampaignAccess.mainEntitlementID

    /// Dauerhafte Kampagnenerweiterung für die Jahre 2026–2050.
    /// Der Identifier muss mit dem RevenueCat-Entitlement übereinstimmen.
    static let future2050EntitlementID = CampaignAccess.futureEntitlementID

    // Tatsächliche, bereits in App Store Connect angelegte Produkt-IDs.
    static let campaignProductID = "regiere_deutschland_one_time"
    static let future2050ProductID = "regiere_deutschland_one_time_two"
    static let completeProductID = "regiere_deutschland_complett_packet_one"

    // MARK: - Offering

    /// Offering-Identifier im RevenueCat-Dashboard.
    ///
    /// Eigener Katalog für Version 1.6: Veröffentlichte 1.5-Apps verwenden
    /// weiterhin `default1`, während diese Version alle drei Pakete anbietet.
    static let offeringID: String? = "katalog_1_6"

    /// Nach dem kostenlosen Prolog: Hauptkampagne oder Komplettpaket.
    static let campaign2005OfferingID = "kampagne_2005"

    /// Nach 2026: Zukunftserweiterung oder Komplettpaket.
    static let future2050OfferingID = "zukunft_2050"

    /// US presentations reuse the same StoreKit products and entitlements.
    static let usCatalogOfferingID = "catalog_us"
    static let usCampaignOfferingID = "campaign_us"
    static let usFutureOfferingID = "future_us"
}

/// Jeder Einstieg zeigt ausschließlich die für diesen Kaufpunkt vorgesehenen Angebote.
enum CampaignPaywallPlacement: Identifiable, Equatable {
    case catalog
    case afterPrologue
    case afterMainCampaign

    var id: String { offeringID }

    var offeringID: String {
        switch self {
        case .catalog: Monetization.offeringID ?? "katalog_1_6"
        case .afterPrologue: Monetization.campaign2005OfferingID
        case .afterMainCampaign: Monetization.future2050OfferingID
        }
    }

    func offeringID(for country: GameCountry, hasMainCampaign: Bool = false) -> String {
        guard country == .unitedStates else { return offeringID }
        switch self {
        case .catalog:
            // Owners see the expansion with its own default-selected package,
            // rather than a hidden bundle remaining selected in the catalog.
            return hasMainCampaign ? Monetization.usFutureOfferingID : Monetization.usCatalogOfferingID
        case .afterPrologue: return Monetization.usCampaignOfferingID
        case .afterMainCampaign: return Monetization.usFutureOfferingID
        }
    }

    var loadingTitle: String {
        switch self {
        case .catalog: "Kampagnen & Pakete laden"
        case .afterPrologue: "Hauptkampagne laden"
        case .afterMainCampaign: "Zukunft 2050 laden"
        }
    }
}
