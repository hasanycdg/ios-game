import RegiereDeutschlandCore
import SwiftUI

/// Notification landing page: describes the expansion without bypassing campaign access.
struct FutureUpdateView: View {
    @Environment(PurchaseManager.self) private var purchases
    @Environment(\.dismiss) private var dismiss
    @State private var paywall: CampaignPaywallPlacement?
    private let persistence = GamePersistence()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Label("DAS NEUE KAPITEL", systemImage: "globe.europe.africa.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(GameTheme.teal)
                    Text("Zukunft 2050")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(GameTheme.gold)
                    Text("Wie entscheidest du, wenn die Welt am Wendepunkt steht?")
                        .font(.title3.weight(.bold))
                    Text("Führe deine Kampagne von 2026 bis 2050 weiter: Eskalation oder Diplomatie, Wiederaufbau und eine neue Weltordnung. 200 Szenario-Entscheidungen und 75 zusätzliche Ereignisse warten auf dich.")
                        .foregroundStyle(GameTheme.secondaryText)
                    Text("Alle Zukunftsszenarien sind fiktiv. Deine Entscheidungen können einen Weltkrieg verhindern.")
                        .font(.footnote)
                        .foregroundStyle(GameTheme.tertiaryText)

                    if purchases.hasFuture2050 {
                        if persistence.hasSaveGame {
                            NavigationLink {
                                GameContainerView(mode: .resume)
                            } label: {
                                Label("Kampagne fortsetzen", systemImage: "play.fill")
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                        } else {
                            Text("Die Erweiterung beginnt nach dem Finale der Hauptkampagne im Jahr 2026.")
                                .font(.footnote)
                                .foregroundStyle(GameTheme.secondaryText)
                            NavigationLink {
                                GameContainerView(mode: .newGame, finalYear: purchases.campaignAccess.finalYear)
                            } label: {
                                Label("Neue Kampagne starten", systemImage: "flag.fill")
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                        }
                    } else {
                        Text("Zukunft 2050 ist eine kostenpflichtige Erweiterung und benötigt die Hauptkampagne. Das Komplettpaket enthält beide Kampagnen.")
                            .font(.footnote)
                            .foregroundStyle(GameTheme.secondaryText)
                        Button {
                            paywall = purchases.hasCampaign2005 ? .afterMainCampaign : .catalog
                        } label: {
                            Label("Erweiterung & Pakete ansehen", systemImage: "sparkles")
                        }
                        .buttonStyle(PrimaryActionButtonStyle())
                    }
                }
                .padding(24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .background(GameTheme.background.ignoresSafeArea())
            .foregroundStyle(GameTheme.primaryText)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Schließen") { dismiss() }
                }
            }
            .sheet(item: $paywall) { CampaignPaywallView(placement: $0) }
        }
        .tint(GameTheme.gold)
        .preferredColorScheme(.dark)
    }
}
