import Observation
import RegiereDeutschlandCore
import UIKit
import UserNotifications

/// One opt-in reminder for this content release, independent of later build numbers.
@MainActor
@Observable
final class UpdateReminder: NSObject, UNUserNotificationCenterDelegate {
    static let shared = UpdateReminder()
    private nonisolated static let identifier = "future2050.update.1.6"
    private let completedKey = "updateReminder.future2050.1.6.completed"
    private let center = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard

    private(set) var canOfferReminder = false
    private(set) var isBusy = false
    private(set) var errorMessage: String?
    var showFutureUpdate = false

    func install() {
        center.delegate = self
    }

    func prepare(country: GameCountry = .germany) async {
        guard !isBusy, !defaults.bool(forKey: completedKey) else { return }
        isBusy = true
        defer { isBusy = false }
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            await schedule(country: country)
        case .notDetermined:
            canOfferReminder = true
        case .denied:
            finish()
        @unknown default:
            canOfferReminder = false
        }
    }

    func enable(country: GameCountry = .germany) async {
        guard !isBusy, !defaults.bool(forKey: completedKey) else { return }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }
        do {
            if try await center.requestAuthorization(options: [.alert, .sound]) {
                await schedule(country: country)
            } else {
                finish()
            }
        } catch {
            errorMessage = "Die Erinnerung konnte nicht aktiviert werden. Bitte versuche es erneut."
        }
    }

    func skip() {
        guard !isBusy else { return }
        finish()
    }

    private func schedule(country: GameCountry) async {
        let content = UNMutableNotificationContent()
        content.title = country == .germany ? "Bereit für die Zukunft?" : "Ready for the future?"
        content.body = country == .germany
            ? "Neue fiktive Weltkrisen, Wiederaufbau und Weltordnung: Entdecke Zukunft 2050 in Regiere Deutschland."
            : "New fictional crises, reconstruction, and a new world order: discover Future 2050 in Lead America."
        content.sound = .default
        let request = UNNotificationRequest(identifier: Self.identifier, content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false))
        do {
            try await center.add(request)
            // Persist only after iOS accepted the request; failed scheduling remains retryable.
            finish()
        } catch {
            canOfferReminder = true
            errorMessage = "Die Erinnerung konnte nicht geplant werden. Bitte versuche es erneut."
        }
    }

    private func finish() {
        defaults.set(true, forKey: completedKey)
        canOfferReminder = false
        errorMessage = nil
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse) async {
        guard response.notification.request.identifier == Self.identifier,
              response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }
        await MainActor.run { self.showFutureUpdate = true }
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
        willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        // While playing, keep the reminder in Notification Center without interrupting the game.
        [.list]
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UpdateReminder.shared.install()
        return true
    }
}
