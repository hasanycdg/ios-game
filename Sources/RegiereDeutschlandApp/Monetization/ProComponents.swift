import SwiftUI
import RevenueCat
import RevenueCatUI

// MARK: - Paywall-Container

/// Rendert die Paywall des konfigurierten Offerings (`Monetization.offeringID`,
/// hier `default1`). Sobald die Offerings geladen sind, wird das Offering
/// explizit übergeben – so wird auch dann die richtige Paywall gezeigt, wenn
/// `default1` im Dashboard nicht als *Current* markiert ist.
struct ProPaywallView: View {
    @Environment(PurchaseManager.self) private var purchases

    var body: some View {
        Group {
            if let offering = purchases.currentOffering {
                PaywallView(offering: offering, displayCloseButton: true)
            } else {
                // Fallback, solange die Offerings noch laden.
                PaywallView(displayCloseButton: true)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Upsell-/Status-Karte für den Home-Screen

/// Zeigt auf dem Startbildschirm entweder ein Upsell für „Regiere Deutschland Pro“
/// oder – wenn bereits gekauft – den aktiven Status samt „Abo verwalten“.
struct ProStatusCard: View {
    @Environment(PurchaseManager.self) private var purchases
    @State private var showPaywall = false
    @State private var showCustomerCenter = false

    var body: some View {
        Group {
            if purchases.isPro {
                activeCard
            } else {
                upsellCard
            }
        }
        // Explizites Upsell: vom Dashboard konfigurierte Paywall als Sheet.
        .sheet(isPresented: $showPaywall) {
            ProPaywallView()
        }
        // Customer Center: Käufe wiederherstellen, Kaufhistorie, Support …
        .presentCustomerCenter(isPresented: $showCustomerCenter) {
            showCustomerCenter = false
        }
    }

    // MARK: Upsell (nicht Pro)

    private var upsellCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "crown.fill")
                    .font(.headline)
                    .foregroundStyle(GameTheme.goldGradient)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(GameTheme.gold.opacity(0.16)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Regiere Deutschland Pro")
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(GameTheme.primaryText)
                    Text("Einmal kaufen, für immer freigeschaltet")
                        .font(.caption)
                        .foregroundStyle(GameTheme.secondaryText)
                }
                Spacer(minLength: 0)
            }

            Button {
                Haptics.impact(.light)
                showPaywall = true
            } label: {
                Label("Freischalten", systemImage: "sparkles")
            }
            .buttonStyle(PrimaryActionButtonStyle())

            Button {
                showCustomerCenter = true
            } label: {
                Text("Käufe wiederherstellen")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(GameTheme.secondaryText)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .gameCard(tint: GameTheme.gold)
    }

    // MARK: Aktiv (Pro)

    private var activeCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.headline)
                .foregroundStyle(GameTheme.goldGradient)
                .frame(width: 36, height: 36)
                .background(Circle().fill(GameTheme.gold.opacity(0.16)))
            VStack(alignment: .leading, spacing: 2) {
                Text("Pro ist aktiv")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(GameTheme.primaryText)
                Text("Danke für deine Unterstützung!")
                    .font(.caption)
                    .foregroundStyle(GameTheme.secondaryText)
            }
            Spacer(minLength: 0)
            Button {
                showCustomerCenter = true
            } label: {
                Text("Verwalten")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(GameTheme.gold)
            }
            .buttonStyle(.plain)
        }
        .gameCard(tint: GameTheme.gold)
    }
}

// MARK: - Pro-Gate für einzelne Features

/// Kleines Schloss-Abzeichen, das an Pro-Features angezeigt werden kann.
struct ProLockBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
            Text("Pro")
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
    /// Zeigt die RevenueCat-Paywall (`default1`) als Sheet, solange
    /// `isPresented` `true` ist.
    func proPaywallSheet(isPresented: Binding<Bool>) -> some View {
        sheet(isPresented: isPresented) {
            ProPaywallView()
        }
    }
}
