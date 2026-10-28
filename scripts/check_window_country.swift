import Foundation
import SwiftUI
import RegiereDeutschlandCore

@main
struct WindowCountryCheck {
    @MainActor static func main() {
        let germanWindow = GamePresentation()
        let americanWindow = GamePresentation()
        americanWindow.country = .unitedStates
        precondition(germanWindow.text("DEUTSCHLAND") == "DEUTSCHLAND")
        precondition(americanWindow.text("DEUTSCHLAND") == "AMERICA")
        precondition(americanWindow.text("Nächste Bundestagswahl: 2004") == "Next presidential election: 2004")
        americanWindow.country = .germany
        precondition(americanWindow.text("DEUTSCHLAND") == "DEUTSCHLAND")
        precondition(germanWindow.text("Zustimmung") == "Zustimmung")
        americanWindow.country = .unitedStates
        precondition(americanWindow.text("Zustimmung") == "Approval")
        precondition(germanWindow.text("Zustimmung") == "Zustimmung")
        // Paywalls follow each window's selected campaign, independently of ownership.
        let placements: [CampaignPaywallPlacement] = [.catalog, .afterPrologue, .afterMainCampaign]
        let germanOfferings = ["katalog_1_6", "kampagne_2005", "zukunft_2050"]
        let usOfferings = ["catalog_us", "campaign_us", "future_us"]
        for (index, placement) in placements.enumerated() {
            precondition(placement.offeringID(for: germanWindow.country) == germanOfferings[index])
            precondition(placement.offeringID(for: germanWindow.country, hasMainCampaign: true) == germanOfferings[index])
            precondition(placement.offeringID(for: americanWindow.country) == usOfferings[index])
        }
        precondition(CampaignPaywallPlacement.catalog.offeringID(
            for: americanWindow.country, hasMainCampaign: true) == "future_us")
        americanWindow.country = .germany
        precondition(CampaignPaywallPlacement.catalog.offeringID(
            for: americanWindow.country, hasMainCampaign: true) == "katalog_1_6")
        precondition(Ministry.security.departmentTitle(in: .unitedStates, year: 2000) == "Department of Justice")
        precondition(Ministry.security.departmentTitle(in: .unitedStates, year: 2003) == "Department of Homeland Security")
        print("Window-local country, language cache, country switching, paywall routing/ownership, and US department timeline checks passed")
    }
}
