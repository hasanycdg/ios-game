import Foundation
import os
import Aptabase

/// Funnel-Events vom ersten Start bis zum Kauf, gesendet an Aptabase
/// (datenschutzfreundlich, ohne Geräte-IDs und ohne Tracking).
///
/// Debug-Builds landen im Aptabase-Dashboard unter „Debug“, Release-Builds
/// unter „Release“ (`TrackingMode.readFromEnvironment`). Zusätzlich steht jedes
/// Event im System-Log (Console.app, Subsystem `RegiereDeutschland`, Kategorie `funnel`).
enum Analytics {
    /// Öffentlicher Aptabase-App-Key (EU-Region).
    static let appKey = "A-EU-6118890067"

    enum Event: String {
        case appOpened = "app_opened"
        case countrySelected = "country_selected"
        case onboardingStep = "onboarding_step"
        case onboardingDecision = "onboarding_decision"
        case onboardingCompleted = "onboarding_completed"
        case onboardingSkipped = "onboarding_skipped"
        case offerShown = "offer_shown"
        case offerDismissed = "offer_dismissed"
        case purchaseStarted = "purchase_started"
        case purchaseCompleted = "purchase_completed"
        case prologueStarted = "prologue_started"
        case prologueCompleted = "prologue_completed"
        case continueAfterPrologueTapped = "continue_after_prologue_tapped"
    }

    private static let logger = Logger(subsystem: "RegiereDeutschland", category: "funnel")

    /// Einmal beim App-Start aufrufen.
    static func configure() {
        Aptabase.shared.initialize(appKey: appKey)
        track(.appOpened)
    }

    static func track(_ event: Event, _ parameters: [String: String] = [:]) {
        let properties: [String: any Value] = parameters.mapValues { $0 }
        Aptabase.shared.trackEvent(event.rawValue, with: properties)
        let details = parameters.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
        logger.info("\(event.rawValue, privacy: .public) \(details, privacy: .public)")
    }
}
