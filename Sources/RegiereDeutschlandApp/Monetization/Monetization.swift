import Foundation

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
    static let proEntitlementID = "Regiere Deutschland Pro"

    // MARK: - Offering

    /// Offering-Identifier im RevenueCat-Dashboard.
    ///
    /// Hier explizit `default1`, weil die Paywall an diesem Offering hängt.
    /// Alternative: `nil` setzen **und** `default1` im Dashboard als *Current*
    /// markieren – dann kannst du Angebote ohne App-Update umstellen.
    static let offeringID: String? = "default1"
}
