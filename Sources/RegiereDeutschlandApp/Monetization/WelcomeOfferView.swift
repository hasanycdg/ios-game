import SwiftUI
import RevenueCat
import RegiereDeutschlandCore

/// A dismissible introduction to the paid campaigns, shown after onboarding
/// and occasionally on returning to the app. Other purchase entry points keep
/// their existing RevenueCat paywalls.
struct WelcomeOfferView: View {
    @Environment(GamePresentation.self) private var presentation
    @Environment(PurchaseManager.self) private var purchases
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProductID: String?
    @State private var restoreMessage: String?

    private var english: Bool { presentation.language == .english }
    private func copy(_ german: String, _ englishText: String) -> String {
        english ? englishText : german
    }
    private var placement: CampaignPaywallPlacement {
        purchases.hasCampaign2005 ? .afterMainCampaign : .catalog
    }
    private var packages: [Package] {
        let available = purchases.offering(for: placement, country: presentation.country)?.availablePackages ?? []
        let ids = purchases.hasCampaign2005
            ? [Monetization.future2050ProductID]
            : [Monetization.completeProductID, Monetization.campaignProductID]
        return ids.compactMap { id in available.first { $0.storeProduct.productIdentifier == id } }
    }
    private var selected: Package? {
        packages.first { $0.storeProduct.productIdentifier == selectedProductID } ?? packages.first
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(red: 0.025, green: 0.035, blue: 0.055).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    hero
                    VStack(spacing: 20) {
                        benefitStrip
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(copy("WÄHLE DEINEN WEG", "CHOOSE YOUR PATH"))
                                    .font(.system(size: 10, weight: .heavy)).tracking(1.7)
                                    .foregroundStyle(GameTheme.goldBright)
                                Spacer()
                                Text(copy("EINMALIG", "ONE-TIME"))
                                    .font(.system(size: 10, weight: .bold)).tracking(1.3)
                                    .foregroundStyle(GameTheme.secondaryText)
                            }
                            ForEach(packages, id: \.identifier) { package in
                                packageRow(package)
                            }
                            if packages.isEmpty { unavailable }
                        }
                        if let selected {
                            Button { buy(selected) } label: {
                                HStack(spacing: 8) {
                                    Text(copy("Jetzt freischalten", "Unlock now"))
                                    Text("·")
                                    Text(selected.storeProduct.localizedPriceString)
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                            .disabled(purchases.isPurchasing)
                        }
                        if purchases.isPurchasing { ProgressView(copy("App Store wird kontaktiert …", "Contacting the App Store…")) }
                        if let error = purchases.lastError {
                            Text(error).font(.footnote).foregroundStyle(GameTheme.red)
                        }
                        if let restoreMessage {
                            Text(restoreMessage).font(.footnote).foregroundStyle(GameTheme.secondaryText)
                        }
                        Text(copy("Einmal zahlen. Dauerhaft spielen. Kein Abo.", "Pay once. Play forever. No subscription."))
                            .font(.footnote.weight(.medium)).foregroundStyle(GameTheme.secondaryText)
                        Button(copy("Kostenlos weiterspielen", "Continue for free")) { dismiss() }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(GameTheme.primaryText)
                            .disabled(purchases.isPurchasing)
                        footer
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 30)
                    .frame(maxWidth: 540)
                }
                .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(edges: .top)
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.black.opacity(0.55), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.2)))
            }
            .accessibilityLabel(copy("Schließen", "Close"))
            .padding(.top, 12).padding(.trailing, 18)
            .disabled(purchases.isPurchasing)
        }
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled(purchases.isPurchasing)
        .task {
            purchases.lastError = nil
            if packages.isEmpty { await purchases.loadOfferings() }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geometry in
                Image(presentation.country == .germany ? "PaywallGermany" : "PaywallUSA")
                    .resizable().scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            LinearGradient(colors: [.clear, .black.opacity(0.45), Color(red: 0.025, green: 0.035, blue: 0.055)], startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 9) {
                Text(copy("DEINE GESCHICHTE BEGINNT", "YOUR STORY BEGINS"))
                    .font(.system(size: 10, weight: .heavy)).tracking(2)
                    .foregroundStyle(GameTheme.goldBright)
                Text(purchases.hasCampaign2005
                     ? copy("Die Zukunft liegt\nin deiner Hand.", "The future is\nin your hands.")
                     : copy("Deine Macht.\nDeine Geschichte.", "Your power.\nYour legacy."))
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .lineSpacing(-1).foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(purchases.hasCampaign2005
                     ? copy("Schreibe dein nächstes Kapitel bis 2050.", "Write your next chapter through 2050.")
                     : copy("Führe dein Land durch Krisen, Wahlen und eine ungewisse Zukunft.", "Lead your country through crises, elections and an uncertain future."))
                    .font(.subheadline).foregroundStyle(.white.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 500, alignment: .leading)
            .padding(.horizontal, 24).padding(.bottom, 8)
        }
        .frame(height: 325)
    }

    private var benefitStrip: some View {
        HStack(alignment: .top, spacing: 8) {
            benefit("building.columns.fill", copy("Wahlen & Politik", "Elections & politics"))
            benefit("globe.europe.africa.fill", copy("Zwei Länder", "Two countries"))
            benefit("sparkles", copy("Deine Zukunft", "Your future"))
        }
    }
    private func benefit(_ icon: String, _ title: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon).font(.system(size: 15, weight: .semibold)).foregroundStyle(GameTheme.goldBright)
            Text(title).font(.system(size: 10, weight: .semibold)).foregroundStyle(GameTheme.secondaryText).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 14))
    }
    private func packageRow(_ package: Package) -> some View {
        let id = package.storeProduct.productIdentifier
        let active = selected?.storeProduct.productIdentifier == id
        let bundle = id == Monetization.completeProductID
        let future = id == Monetization.future2050ProductID
        return Button { selectedProductID = id } label: {
            HStack(spacing: 12) {
                Image(systemName: active ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 20)).foregroundStyle(active ? GameTheme.goldBright : GameTheme.tertiaryText)
                VStack(alignment: .leading, spacing: 4) {
                    Text(bundle ? copy("Komplettpaket", "Complete bundle") : future ? copy("Zukunft 2050", "Future 2050") : copy("Hauptkampagne", "Main campaign"))
                        .font(.subheadline.weight(.bold)).foregroundStyle(.white)
                    Text(bundle ? copy("Hauptkampagne + Zukunft 2050", "Main campaign + Future 2050") : future ? copy("Fiktive Erweiterung · 2026–2050", "Fictional expansion · 2026–2050") : "2005–2026")
                        .font(.caption).foregroundStyle(GameTheme.secondaryText)
                }
                Spacer(minLength: 4)
                Text(package.storeProduct.localizedPriceString)
                    .font(.subheadline.weight(.heavy)).foregroundStyle(.white)
            }
            .padding(15)
            .background(active ? GameTheme.gold.opacity(0.13) : .white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(active ? GameTheme.gold.opacity(0.8) : .white.opacity(0.09), lineWidth: active ? 1.5 : 1))
        }
        .buttonStyle(.plain)
        .disabled(purchases.isPurchasing)
        .accessibilityAddTraits(active ? .isSelected : [])
    }
    private var unavailable: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(copy("Angebote sind gerade nicht verfügbar.", "Offers are currently unavailable."))
                .font(.footnote).foregroundStyle(GameTheme.secondaryText)
            Button(copy("Erneut laden", "Try again")) { Task { await purchases.loadOfferings() } }
                .font(.footnote.weight(.bold)).foregroundStyle(GameTheme.goldBright)
        }.padding(.vertical, 10)
    }
    private var footer: some View {
        VStack(spacing: 10) {
            Button(copy("Käufe wiederherstellen", "Restore purchases")) {
                Task {
                    restoreMessage = nil
                    let needsFuture = purchases.hasCampaign2005
                    let restored = await purchases.restorePurchases(country: presentation.country)
                    if restored && (!needsFuture || purchases.hasFuture2050) { dismiss() }
                    else if purchases.lastError == nil {
                        restoreMessage = copy("Keine passenden Käufe gefunden.", "No eligible purchases were found.")
                    }
                }
            }
            .disabled(purchases.isPurchasing)
            HStack(spacing: 20) {
                Link(copy("Nutzungsbedingungen", "Terms of Use"), destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Link(copy("Datenschutz", "Privacy Policy"), destination: URL(string: "https://regieredeutschland-support.lovable.app/datenschutz")!)
            }
        }
        .font(.caption).foregroundStyle(GameTheme.tertiaryText)
    }
    private func buy(_ package: Package) {
        Task {
            restoreMessage = nil
            let success = await purchases.purchase(package, country: presentation.country)
            guard success else { return }
            let id = package.storeProduct.productIdentifier
            let unlocked = id == Monetization.completeProductID ? purchases.hasCampaign2005 && purchases.hasFuture2050
                : id == Monetization.future2050ProductID ? purchases.hasFuture2050 : purchases.hasCampaign2005
            if unlocked { dismiss() }
            else { restoreMessage = copy("Dein Kauf wird synchronisiert. Falls nötig, stelle deine Käufe wieder her.", "Your purchase is syncing. Restore purchases if access does not appear.") }
        }
    }
}
