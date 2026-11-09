import SwiftUI
import RegiereDeutschlandCore
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Bildplätze

/// Optional artwork from the asset catalog. Missing images fall back to the
/// designed placeholder, so new pictures only need to be added to Assets.xcassets:
/// - `event-<category>` (z. B. `event-economy`, `event-security`) – Querformat;
///   optional je Land `event-<category>-<country>` (z. B. `event-historicalEcho-germany`)
/// - `advisor-<role>` (z. B. `advisor-economy`, `advisor-chief`) – quadratisch;
///   optional je Land `advisor-<role>-<country>` (z. B. `advisor-economy-france`)
/// - `election-night` – Querformat
enum Artwork {
    static func image(_ name: String) -> Image? {
        #if canImport(UIKit)
        guard let image = UIImage(named: name) else { return nil }
        return Image(uiImage: image)
        #else
        return nil
        #endif
    }
}

// MARK: - Kabinett

/// Recurring, fictional cabinet members who brief the player on each event and
/// react to the decision. Roles and genders are shared by all countries, so one
/// portrait per role fits everywhere; names differ per country.
enum AdvisorRole: String, CaseIterable {
    case economy, security, foreign, energy, social, digital, chief

    init(category: EventCategory) {
        switch category {
        case .economy, .budget: self = .economy
        case .security: self = .security
        case .foreignPolicy: self = .foreign
        case .energy: self = .energy
        case .society, .welfare: self = .social
        case .digitalization: self = .digital
        case .election, .historicalEcho: self = .chief
        }
    }

    var icon: String {
        switch self {
        case .economy: "banknote.fill"
        case .security: "shield.lefthalf.filled"
        case .foreign: "globe.europe.africa.fill"
        case .energy: "bolt.fill"
        case .social: "heart.fill"
        case .digital: "network"
        case .chief: "building.columns.fill"
        }
    }

    var color: Color {
        switch self {
        case .economy: GameTheme.green
        case .security: GameTheme.red
        case .foreign: GameTheme.teal
        case .energy: GameTheme.amber
        case .social: GameTheme.pink
        case .digital: GameTheme.blue
        case .chief: GameTheme.gold
        }
    }
}

struct Advisor {
    let role: AdvisorRole
    let name: String
    let female: Bool
    var country: GameCountry = .germany

    var initials: String {
        name.split(separator: " ").filter { !$0.hasSuffix(".") }.prefix(2).compactMap(\.first).map(String.init).joined()
    }

    static func of(_ role: AdvisorRole, in country: GameCountry) -> Advisor {
        let cast: [AdvisorRole: (String, Bool)]
        switch country {
        case .germany:
            cast = [.economy: ("Dr. Katharina Wendt", true), .security: ("Thomas Reuter", false),
                    .foreign: ("Miriam Okafor", true), .energy: ("Jonas Hartmann", false),
                    .social: ("Aylin Demir", true), .digital: ("Felix Brandt", false),
                    .chief: ("Henrike Vogt", true)]
        case .unitedStates:
            cast = [.economy: ("Rachel Price", true), .security: ("Marcus Alvarez", false),
                    .foreign: ("Elizabeth Hayes", true), .energy: ("Daniel Brooks", false),
                    .social: ("Maria Bell", true), .digital: ("Kevin Chen", false),
                    .chief: ("Sarah Mercer", true)]
        case .unitedKingdom:
            cast = [.economy: ("Olivia Grant", true), .security: ("Callum Walsh", false),
                    .foreign: ("Charlotte Whitmore", true), .energy: ("Harry Pryce", false),
                    .social: ("Grace Okoye", true), .digital: ("Ben Lowe", false),
                    .chief: ("Alice Ashworth", true)]
        case .france:
            cast = [.economy: ("Claire Dubois", true), .security: ("Antoine Mercier", false),
                    .foreign: ("Sophie Garnier", true), .energy: ("Julien Moreau", false),
                    .social: ("Nadia Benali", true), .digital: ("Lucas Petit", false),
                    .chief: ("Hélène Roussel", true)]
        }
        let entry = cast[role] ?? ("", false)
        return Advisor(role: role, name: entry.0, female: entry.1, country: country)
    }

    @MainActor func title(country: GameCountry, presentation p: GamePresentation) -> String {
        let f = female
        switch role {
        case .economy:
            return p.pick(f ? "Finanzministerin" : "Finanzminister",
                          country == .unitedStates ? "Treasury Secretary" : country == .unitedKingdom ? "Chancellor of the Exchequer" : "Finance Minister",
                          "Ministre des Finances")
        case .security:
            return p.pick(f ? "Innenministerin" : "Innenminister",
                          country == .unitedStates ? "Homeland Security Secretary" : country == .unitedKingdom ? "Home Secretary" : "Interior Minister",
                          "Ministre de l’Intérieur")
        case .foreign:
            return p.pick(f ? "Außenministerin" : "Außenminister",
                          country == .unitedStates ? "Secretary of State" : country == .unitedKingdom ? "Foreign Secretary" : "Foreign Minister",
                          "Ministre des Affaires étrangères")
        case .energy:
            return p.pick(f ? "Energieministerin" : "Energieminister",
                          country == .unitedStates || country == .unitedKingdom ? "Energy Secretary" : "Energy Minister",
                          "Ministre de l’Énergie")
        case .social:
            return p.pick(f ? "Sozialministerin" : "Sozialminister",
                          country == .unitedStates ? "Labor Secretary" : country == .unitedKingdom ? "Work and Pensions Secretary" : "Social Affairs Minister",
                          "Ministre des Affaires sociales")
        case .digital:
            return p.pick(f ? "Digitalministerin" : "Digitalminister",
                          country == .unitedStates ? "Chief Technology Officer" : country == .unitedKingdom ? "Science and Technology Secretary" : "Digital Minister",
                          "Ministre du Numérique")
        case .chief:
            switch country {
            case .germany:
                return p.pick(f ? "Chefin des Kanzleramts" : "Chef des Kanzleramts", "Head of the Chancellery",
                              f ? "Cheffe de la Chancellerie" : "Chef de la Chancellerie")
            case .unitedStates:
                return p.pick(f ? "Stabschefin im Weißen Haus" : "Stabschef im Weißen Haus", "White House Chief of Staff",
                              "Chef de cabinet de la Maison-Blanche")
            case .unitedKingdom:
                return p.pick(f ? "Stabschefin, Downing Street" : "Stabschef, Downing Street", "Downing Street Chief of Staff",
                              "Chef de cabinet de Downing Street")
            case .france:
                return p.pick(f ? "Generalsekretärin des Élysée" : "Generalsekretär des Élysée", "Secretary-General of the Élysée",
                              f ? "Secrétaire générale de l’Élysée" : "Secrétaire général de l’Élysée")
            }
        }
    }
}

// MARK: - Reaktionen

enum AdvisorReaction {
    enum Tone { case positive, mixed, negative }

    static func tone(effects: [GameEffect], approval: Int) -> Tone {
        let score = effects.reduce(0) { $0 + $1.change } + approval
        if score >= 3 { return .positive }
        if score <= -3 { return .negative }
        return .mixed
    }

    /// A line chosen deterministically per event, so a resumed save shows the same quote.
    @MainActor static func line(_ tone: Tone, seed: String, presentation p: GamePresentation) -> String {
        let lines: [(String, String, String)]
        switch tone {
        case .positive:
            lines = [("Das war die richtige Entscheidung. Die ersten Reaktionen sind gut.",
                      "That was the right call. The first reactions are good.",
                      "C’était la bonne décision. Les premières réactions sont bonnes."),
                     ("Gute Wahl. Das gibt uns Rückenwind.",
                      "Good choice. That gives us momentum.",
                      "Bon choix. Cela nous donne de l’élan."),
                     ("Damit haben wir die Lage im Griff – vorerst.",
                      "We have the situation under control – for now.",
                      "Nous avons la situation en main – pour l’instant.")]
        case .mixed:
            lines = [("Ein Kompromiss. Nicht alle werden zufrieden sein.",
                      "A compromise. Not everyone will be happy.",
                      "Un compromis. Tout le monde ne sera pas satisfait."),
                     ("Das trägt – aber wir müssen es gut erklären.",
                      "It will hold – but we have to explain it well.",
                      "Ça tiendra – mais il faudra bien l’expliquer."),
                     ("Die Reaktionen sind gespalten. Ich behalte das im Blick.",
                      "Reactions are split. I’ll keep an eye on it.",
                      "Les réactions sont partagées. Je garde un œil là-dessus.")]
        case .negative:
            lines = [("Das wird Gegenwind geben. Ich bereite die Pressestelle vor.",
                      "This will cause a backlash. I’ll brief the press office.",
                      "Ça va provoquer des remous. Je préviens le service de presse."),
                     ("Mutig. Aber die Rechnung kommt noch.",
                      "Bold. But the bill is still to come.",
                      "Audacieux. Mais l’addition arrivera."),
                     ("Die Opposition wird das ausschlachten. Jetzt müssen wir liefern.",
                      "The opposition will exploit this. Now we have to deliver.",
                      "L’opposition va s’en servir. Maintenant, il faut des résultats.")]
        }
        let index = seed.unicodeScalars.reduce(0) { ($0 &+ Int($1.value)) % 997 } % lines.count
        let line = lines[index]
        return p.pick(line.0, line.1, line.2)
    }
}

// MARK: - Porträt

/// Portrait from `advisor-<role>-<country>` (optional) or `advisor-<role>`,
/// otherwise a monogram placeholder.
struct AdvisorPortrait: View {
    let advisor: Advisor
    var size: CGFloat = 46

    var body: some View {
        Group {
            if let image = Artwork.image("advisor-\(advisor.role.rawValue)-\(advisor.country.rawValue)")
                ?? Artwork.image("advisor-\(advisor.role.rawValue)") {
                image.resizable().scaledToFill()
            } else {
                ZStack {
                    LinearGradient(colors: [advisor.role.color.opacity(0.55), advisor.role.color.opacity(0.18)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    Text(advisor.initials)
                        .font(.system(size: size * 0.36, weight: .heavy, design: .serif))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(advisor.role.color.opacity(0.8), lineWidth: 1.5))
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: advisor.role.icon)
                .font(.system(size: size * 0.2, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
                .frame(width: size * 0.38, height: size * 0.38)
                .background(Circle().fill(advisor.role.color))
                .offset(x: 2, y: 2)
        }
        .accessibilityHidden(true)
    }
}

extension GameCountry {
    /// Dateline for news-style scenes.
    var capital: String {
        switch self {
        case .germany: "Berlin"
        case .unitedStates: "Washington"
        case .unitedKingdom: "London"
        case .france: "Paris"
        }
    }
}
