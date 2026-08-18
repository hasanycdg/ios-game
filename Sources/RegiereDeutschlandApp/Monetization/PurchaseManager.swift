import Foundation
import Observation
import RevenueCat

/// Zentrale Schnittstelle zu RevenueCat.
///
/// Verantwortlich für:
/// - einmalige Konfiguration des SDK,
/// - Bereitstellen des aktuellen `CustomerInfo` und des Pro-Status,
/// - Laden der Offerings (Produkte) für eigene Kauf-UIs,
/// - manuelles Kaufen / Wiederherstellen (die RevenueCat-Paywall macht das selbst).
///
/// Wird als Environment-Objekt injiziert und dank `@Observable` aktualisieren
/// sich abhängige Views automatisch, sobald sich `customerInfo` ändert.
@Observable
@MainActor
final class PurchaseManager {

    /// Aktuelle Kundeninformationen (Abos, Käufe, Entitlements). `nil`, solange
    /// noch nichts geladen wurde.
    private(set) var customerInfo: CustomerInfo?

    /// Vom Dashboard konfigurierte Angebote. `nil`, solange noch nicht geladen.
    private(set) var offerings: Offerings?

    /// Läuft gerade ein Kauf-/Wiederherstellungs-Vorgang?
    private(set) var isPurchasing = false

    /// Zuletzt aufgetretene, für den Nutzer verständliche Fehlermeldung.
    var lastError: String?

    /// Kernfrage der App: Ist „Regiere Deutschland Pro“ aktiv?
    var isPro: Bool {
        customerInfo?.entitlements[Monetization.proEntitlementID]?.isActive == true
    }

    /// Das aktuell zu bewerbende Offering (Dashboard-`Current` oder per ID).
    var currentOffering: Offering? {
        guard let offerings else { return nil }
        if let id = Monetization.offeringID { return offerings.offering(identifier: id) }
        return offerings.current
    }

    init() {
        // Konfiguration passiert genau einmal – auch dann korrekt, wenn dieser
        // Manager (z. B. in Previews) mehrfach erzeugt wird.
        PurchaseManager.configureIfNeeded()

        // Reaktiv auf jede Änderung der Kundeninformationen hören (Käufe,
        // Ablauf, Wiederherstellung, Änderungen auf anderen Geräten …).
        Task { await self.observeCustomerInfo() }

        // Ersten Snapshot + Angebote laden.
        Task { await self.refreshCustomerInfo() }
        Task { await self.loadOfferings() }
    }

    // MARK: - Konfiguration

    /// Konfiguriert das RevenueCat-SDK, sofern noch nicht geschehen.
    ///
    /// `Purchases.logLevel` muss **vor** `configure` gesetzt werden. Wir nutzen
    /// den `Configuration.Builder`, weil er sich später ohne Bruch erweitern
    /// lässt (z. B. `appUserID`, `storeKitVersion`).
    static func configureIfNeeded() {
        guard !Purchases.isConfigured else { return }

        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .info
        #endif

        Purchases.configure(
            with: Configuration.Builder(withAPIKey: Monetization.apiKey)
                .build()
        )
    }

    // MARK: - CustomerInfo

    /// Dauerhafter Stream aller `CustomerInfo`-Änderungen. Läuft für die gesamte
    /// Lebensdauer des Managers.
    private func observeCustomerInfo() async {
        for await info in Purchases.shared.customerInfoStream {
            self.customerInfo = info
        }
    }

    /// Holt aktiv den neuesten `CustomerInfo` (aus Cache, wenn frisch genug).
    func refreshCustomerInfo() async {
        do {
            customerInfo = try await Purchases.shared.customerInfo()
        } catch {
            lastError = Self.message(for: error)
        }
    }

    // MARK: - Offerings

    /// Lädt die im Dashboard konfigurierten Angebote (z. B. „Unlimited“ lifetime).
    func loadOfferings() async {
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            lastError = Self.message(for: error)
        }
    }

    // MARK: - Kauf & Wiederherstellung

    /// Kauft ein konkretes Package. Wird nur für **eigene** Kauf-UIs gebraucht –
    /// die RevenueCat-Paywall wickelt Käufe selbst ab.
    /// - Returns: `true`, wenn der Kauf erfolgreich abgeschlossen wurde.
    @discardableResult
    func purchase(_ package: Package) async -> Bool {
        guard !isPurchasing else { return false }
        isPurchasing = true
        defer { isPurchasing = false }
        lastError = nil

        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled { return false }
            customerInfo = result.customerInfo
            return isPro
        } catch {
            lastError = Self.message(for: error)
            return false
        }
    }

    /// Stellt frühere Käufe wieder her (Pflicht-Funktion laut App-Store-Richtlinien,
    /// v. a. bei einem Lifetime-Kauf ohne Abo).
    /// - Returns: `true`, wenn danach ein aktives Pro-Entitlement vorliegt.
    @discardableResult
    func restorePurchases() async -> Bool {
        guard !isPurchasing else { return false }
        isPurchasing = true
        defer { isPurchasing = false }
        lastError = nil

        do {
            customerInfo = try await Purchases.shared.restorePurchases()
            return isPro
        } catch {
            lastError = Self.message(for: error)
            return false
        }
    }

    // MARK: - Fehlermeldungen

    /// Übersetzt einen RevenueCat-Fehler in eine für Nutzer lesbare Meldung.
    private static func message(for error: Error) -> String {
        if let rcError = error as? RevenueCat.ErrorCode {
            return rcError.localizedDescription
        }
        return (error as NSError).localizedDescription
    }
}
