import Foundation

/// A campaign's country is explicit and saved with the session. Germany is the
/// default for older saves and for every existing public API.
public enum GameCountry: String, Codable, CaseIterable, Identifiable, Sendable {
    case germany
    case unitedStates

    public var id: String { rawValue }
    public var localeIdentifier: String { self == .germany ? "de_DE" : "en_US" }
    public var defaultLeaderName: String { self == .germany ? PartyCatalog.defaultChancellorName : "Alex Morgan" }
    public var playableParties: [PlayerParty] { self == .germany ? PartyCatalog.playable : USPartyCatalog.playable }
    public var defaultParty: PlayerParty { playableParties[0] }
    public var partyLandscape: [PartyReference] { self == .germany ? PartyCatalog.landscape : USPartyCatalog.landscape }
    public var diplomaticPartners: [DiplomaticPartner] { self == .germany ? [.eu, .usa, .russia, .china] : [.eu, .canada, .russia, .china] }

    public func party(id: String) -> PlayerParty {
        playableParties.first { $0.id == id } ?? defaultParty
    }

    public func initialState() -> GameState {
        guard self == .unitedStates else { return GameStateFactory.initialGermany2000() }
        return GameState(
            currentYear: 2000, governmentApproval: 54,
            visible: VisibleMetrics(economy: 68, budget: 65, livingStandard: 63, society: 54,
                security: 67, energy: 60, internationalRelations: 68, trust: 51),
            hidden: HiddenMetrics(renewableCapacity: 12, nuclearCapacity: 40,
                russianEnergyDependency: 5, defenceReadiness: 82, digitalization: 42,
                infrastructureQuality: 65, integrationCapacity: 56, labourMarketFlexibility: 72,
                welfareStrength: 43, healthcareResilience: 55, euRelations: 70,
                usRelations: 82, russiaRelations: 48, polarization: 40, fiscalSpace: 62),
            populationGroups: [
                PopulationGroup(id: .workers, name: "Workers", populationShare: 0.28, approval: 53),
                PopulationGroup(id: .retirees, name: "Retirees", populationShare: 0.16, approval: 55),
                PopulationGroup(id: .families, name: "Families", populationShare: 0.20, approval: 52),
                PopulationGroup(id: .youngAdults, name: "Young adults", populationShare: 0.13, approval: 48),
                PopulationGroup(id: .entrepreneurs, name: "Small business owners", populationShare: 0.11, approval: 54),
                PopulationGroup(id: .lowIncomeAndUnemployed, name: "Low-income and unemployed voters", populationShare: 0.08, approval: 47),
                PopulationGroup(id: .publicSector, name: "Public employees", populationShare: 0.04, approval: 52)
            ]
        )
    }
}

public enum USPartyCatalog {
    public static let playable: [PlayerParty] = [
        make(id: "democratic", name: "Democratic Party", short: "DEM", tagline: "Opportunity, affordable healthcare, and climate action.", spectrum: 0.35, leaning: .left, support: 48,
             visible: [.init(metric: .livingStandard, change: 3), .init(metric: .budget, change: -2)],
             hidden: [.init(metric: .welfareStrength, change: 6)], icon: "person.3.fill"),
        make(id: "republican", name: "Republican Party", short: "GOP", tagline: "Lower taxes, a strong defense, and American enterprise.", spectrum: 0.7, leaning: .conservative, support: 48,
             visible: [.init(metric: .economy, change: 3), .init(metric: .security, change: 2), .init(metric: .budget, change: -2)],
             hidden: [.init(metric: .defenceReadiness, change: 5)], icon: "building.columns.fill"),
        make(id: "libertarian", name: "Libertarian Party", short: "LIB", tagline: "Civil liberties, limited government, and free markets.", spectrum: 0.58, leaning: .liberal, support: 2,
             visible: [.init(metric: .economy, change: 4), .init(metric: .livingStandard, change: -2)],
             hidden: [.init(metric: .labourMarketFlexibility, change: 8)], icon: "flame.fill"),
        make(id: "green_us", name: "Green Party", short: "GRN", tagline: "A green economy, social justice, and grassroots democracy.", spectrum: 0.18, leaning: .left, support: 2,
             visible: [.init(metric: .energy, change: 3), .init(metric: .budget, change: -2)],
             hidden: [.init(metric: .renewableCapacity, change: 12)], icon: "leaf.fill")
    ]

    public static let landscape: [PartyReference] = playable.map {
        PartyReference(id: $0.id, name: $0.name, shortName: $0.shortName, spectrum: $0.spectrum,
                       leaning: $0.leaning, baseSupport: $0.baseSupport, isPlayable: true)
    }

    private static func make(id: String, name: String, short: String, tagline: String,
                             spectrum: Double, leaning: PoliticalLeaning, support: Double,
                             visible: [GameEffect], hidden: [HiddenEffect], icon: String) -> PlayerParty {
        PlayerParty(id: id, name: name, fullName: name, shortName: short, tagline: tagline,
            spectrum: spectrum, leaning: leaning, baseSupport: support,
            profile: KanzlerPersona(id: id, title: name, tagline: tagline, icon: icon,
                visibleModifiers: visible, hiddenModifiers: hidden, startingCapital: 7,
                coalitionLeaning: leaning, coalitionSatisfaction: 62, coalitionPartnerName: "Congressional caucus"),
            naturalPartnerIDs: [], agenda: agenda(for: id))
    }

    public static func agenda(for id: String) -> [AgendaItem] {
        let priorities: [(String, String, VisibleMetric, HiddenMetric)]
        switch id {
        case "republican": priorities = [("tax", "Cut federal taxes", .economy, .labourMarketFlexibility), ("defense", "Strengthen national defense", .security, .defenceReadiness), ("energy", "Expand American energy production", .energy, .nuclearCapacity)]
        case "libertarian": priorities = [("tax", "Reduce the federal tax burden", .economy, .fiscalSpace), ("rights", "Protect civil liberties", .trust, .integrationCapacity), ("enterprise", "Remove barriers to enterprise", .economy, .labourMarketFlexibility)]
        case "green_us": priorities = [("climate", "Build a clean energy economy", .energy, .renewableCapacity), ("care", "Expand access to healthcare", .livingStandard, .healthcareResilience), ("justice", "Strengthen environmental justice", .society, .welfareStrength)]
        default: priorities = [("care", "Make healthcare affordable", .livingStandard, .healthcareResilience), ("jobs", "Invest in American jobs", .economy, .infrastructureQuality), ("climate", "Accelerate clean energy", .energy, .renewableCapacity)]
        }
        return priorities.map { key, title, visible, hidden in
            AgendaItem(id: "us-\(id)-\(key)", title: title,
                summary: "Make this a priority of the administration's legislative agenda.",
                demand: "Our caucus expects a commitment to this priority: \(title.lowercased()).",
                visibleEffects: [.init(metric: visible, change: 3), .init(metric: .budget, change: -2)],
                hiddenEffects: [.init(metric: hidden, change: 5)], satisfactionReward: 11)
        }
    }
}
