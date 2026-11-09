import Foundation

/// One historical setting of the UK or France campaign (2000–2026).
public struct EuropeanCampaignEntry: Codable, Sendable {
    public let id: String
    public let year: Int
    public let title: String
    public let context: String
    public let category: EventCategory
    public let choices: [String]
    public let reality: String?
    public let source: String?
    public let historicalChoice: Int?
    /// External shock that hurts the country whatever the response:
    /// `financial`, `pandemic`, `terror`, `disaster` or `energy`.
    public let shock: String?
    /// Story step (1–8) of the fictional Future 2050 scenario; nil otherwise.
    public let step: Int?

    var isFuture: Bool { id.hasPrefix("future-") }
}

extension GameCountry {
    /// Short prefix for identifiers and flags of the European campaigns.
    var campaignCode: String {
        switch self {
        case .germany: "de"
        case .unitedStates: "us"
        case .unitedKingdom: "uk"
        case .france: "fr"
        }
    }

    var historyResourceName: String? {
        switch self {
        case .unitedKingdom: "UKHistory"
        case .france: "FRHistory"
        default: nil
        }
    }

    var futureResourceName: String? {
        switch self {
        case .unitedKingdom: "UKFuture"
        case .france: "FRFuture"
        default: nil
        }
    }
}

/// Editorial content of the UK and France campaigns. Never loads German or US
/// event resources.
public struct EuropeanEventRepository: EventRepository {
    public let country: GameCountry
    private let storedEvents: [GameEvent]

    public init(country: GameCountry) {
        self.country = country
        storedEvents = Self.entries(for: country).map { Self.event($0, country: country) }
    }

    public func loadEvents() -> [GameEvent] { storedEvents }
    public func events(for year: Int) -> [GameEvent] { storedEvents.filter { $0.year == year } }

    static func entries(for country: GameCountry) -> [EuropeanCampaignEntry] {
        [country.historyResourceName, country.futureResourceName].compactMap { $0 }.flatMap { name -> [EuropeanCampaignEntry] in
            guard let url = Bundle.module.url(forResource: name, withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let entries = try? JSONDecoder().decode([EuropeanCampaignEntry].self, from: data) else { return [] }
            return entries
        }
    }

    static let fictionalSummary = "Fictional scenario. These events are invented for the campaign and are not predictions or claims about real events."

    static func crisisChoices(_ country: GameCountry) -> [String] {
        ["Deploy forces to a major NATO combat operation",
         "Pursue allied deterrence and urgent mediation",
         country == .france ? "Limit France's role to evacuations and humanitarian relief"
             : "Limit Britain's role to evacuations and humanitarian relief"]
    }

    static func crisisDescription(_ country: GameCountry, choice: Int) -> String {
        switch choice {
        case 0: "The deployment escalates into a wider fictional European war. Military readiness improves, but international trust and social cohesion suffer. Later reconstruction will cost more."
        case 1: "Allied deterrence and emergency mediation contain the immediate crisis. The avoided escalation leaves more resources for long-term renewal."
        default: country == .france
            ? "The government limits its exposure and supports civilian evacuation. The immediate escalation is avoided, but allies question the limits of French commitments."
            : "The government limits its exposure and supports civilian evacuation. The immediate escalation is avoided, but allies question the limits of British commitments."
        }
    }

    static let settlementChoices = ["Build a lasting democratic alliance system",
                                    "Support a plural international order with shared rules",
                                    "Prioritize national autonomy and domestic renewal"]

    // MARK: Generated option texts (English source; German in the country catalogs)

    static let descriptionSuffix = "\n\nYour government must choose a response. The outcomes below belong to this alternate-history simulation."

    static func ambitiousDescription(_ country: GameCountry) -> String {
        "Commit public resources to this course. It can produce a stronger immediate response, but costs money and political support."
    }

    static func compromiseDescription(_ country: GameCountry) -> String {
        country == .france
            ? "Negotiate with the social partners, the regions and parliament. Progress is slower, with lower costs and broader support."
            : "Build a cross-party agreement and phase the response in. Progress is slower, with lower costs and broader support."
    }

    static func minimalDescription(_ country: GameCountry) -> String {
        country == .france
            ? "Limit state commitments and leave more to the regions, markets and companies. Preserve funds now, accepting weaker national capacity."
            : "Limit government commitments and leave more to councils, markets and the private sector. Preserve funds now, accepting weaker national capacity."
    }

    static let taxCutDescription = "Lower taxes to support private spending and investment. Growth may improve, but reduced revenue narrows the budget and fiscal capacity."

    private static func event(_ entry: EuropeanCampaignEntry, country: GameCountry) -> GameEvent {
        let code = country.campaignCode
        let metric: VisibleMetric
        let hidden: HiddenMetric
        let group: PopulationGroupID
        switch entry.category {
        case .economy: (metric, hidden, group) = (.economy, .labourMarketFlexibility, .workers)
        case .budget: (metric, hidden, group) = (.budget, .fiscalSpace, .entrepreneurs)
        case .security: (metric, hidden, group) = (.security, .defenceReadiness, .publicSector)
        case .energy: (metric, hidden, group) = (.energy, .renewableCapacity, .families)
        case .foreignPolicy: (metric, hidden, group) = (.internationalRelations, .euRelations, .entrepreneurs)
        case .digitalization: (metric, hidden, group) = (.economy, .digitalization, .youngAdults)
        case .welfare: (metric, hidden, group) = (.livingStandard, .healthcareResilience, .lowIncomeAndUnemployed)
        default: (metric, hidden, group) = (.society, .integrationCapacity, .families)
        }
        let shockEffects: [GameEffect] = switch entry.shock {
        case "financial": [.init(metric: .economy, change: -9), .init(metric: .budget, change: -5)]
        case "pandemic": [.init(metric: .economy, change: -7), .init(metric: .livingStandard, change: -7), .init(metric: .society, change: -3)]
        case "terror": [.init(metric: .security, change: -8), .init(metric: .society, change: -3)]
        case "disaster": [.init(metric: .security, change: -5), .init(metric: .livingStandard, change: -4)]
        case "energy": [.init(metric: .energy, change: -7), .init(metric: .livingStandard, change: -4)]
        default: []
        }

        let crisisDecision = entry.isFuture && entry.year == 2030 && entry.step == 2
        let finalSettlement = entry.isFuture && entry.year == 2050 && entry.step == 8
        let choices = crisisDecision ? crisisChoices(country) : finalSettlement ? settlementChoices : Array(entry.choices.prefix(3))
        let options = choices.enumerated().map { choice, title in
            let ambitious = choice == 0
            let compromise = choice == 1
            let gain = metric == .budget ? (ambitious ? -3 : compromise ? 1 : 4) : (ambitious ? 4 : compromise ? 2 : -2)
            let fiscal = ambitious ? -3 : compromise ? -1 : 3
            let trust = ambitious ? -1 : compromise ? 2 : -2
            let delayNote = ambitious
                ? "\(entry.title): the public investment is delivering lasting capacity, while its cost remains."
                : compromise ? "\(entry.title): the negotiated settlement delivers gradual improvements."
                : "\(entry.title): short-term savings leave a capacity gap that later governments must address."
            var mainEffects: [GameEffect] = [.init(metric: metric, change: gain), .init(metric: .trust, change: trust)]
            var hiddenChange = metric == .budget ? (ambitious ? -3 : compromise ? 1 : 3) : (ambitious ? 5 : compromise ? 2 : -3)
            let taxCuts = metric == .budget && choice == 2 && title.lowercased().contains("tax")
            if taxCuts {
                mainEffects = [.init(metric: .budget, change: -4), .init(metric: .economy, change: 3), .init(metric: .trust, change: -1)]
                hiddenChange = -3
            }
            // Shocks affect every response. Intervention mitigates the damage;
            // a crash or a pandemic must never become a free boost.
            mainEffects += shockEffects
            var flags = ["\(code)-path-\(entry.category.rawValue)-\(choice)"]
            if crisisDecision {
                flags.append(choice == 0 ? "scenario_world_war" : "scenario_war_avoided")
                mainEffects += choice == 0
                    ? [.init(metric: .internationalRelations, change: -8), .init(metric: .society, change: -6)]
                    : [.init(metric: .internationalRelations, change: 4), .init(metric: .trust, change: 2)]
            }
            if finalSettlement { flags.append("\(code)-world-order-\(choice)") }
            let budgetEffects: [GameEffect] = metric == .budget
                ? [.init(metric: .livingStandard, change: ambitious ? 3 : compromise ? 1 : -3)]
                : [.init(metric: .budget, change: fiscal)]
            var modifiers = [ConditionalModifier(
                conditions: [EventCondition(requiredFlags: ["\(code)-path-\(entry.category.rawValue)-0"])],
                immediateEffects: [.init(metric: metric, change: 1)],
                note: "Earlier public investment gives this response a head start.")]
            if entry.isFuture && entry.year >= 2035 {
                modifiers.append(ConditionalModifier(
                    conditions: [EventCondition(requiredFlags: ["scenario_world_war"])],
                    immediateEffects: [.init(metric: .budget, change: -1)],
                    note: "The earlier military escalation increases the cost of reconstruction."))
                modifiers.append(ConditionalModifier(
                    conditions: [EventCondition(requiredFlags: ["scenario_war_avoided"])],
                    immediateEffects: [.init(metric: .society, change: 1)],
                    note: "Preventing escalation preserved resources and public cohesion for renewal."))
            }
            return DecisionOption(
                id: "\(entry.id)-\(choice)", title: title,
                description: crisisDecision ? crisisDescription(country, choice: choice)
                    : taxCuts ? taxCutDescription
                    : ambitious ? ambitiousDescription(country)
                    : compromise ? compromiseDescription(country)
                    : minimalDescription(country),
                advisoryNote: taxCuts ? "Lower revenue can increase the deficit even if private investment rises."
                    : ambitious ? "A larger intervention has a larger fiscal and political cost."
                    : compromise ? "A negotiated approach trades speed for durability."
                    : "Short-term savings can create long-term exposure.",
                immediateEffects: mainEffects + budgetEffects,
                hiddenEffects: [.init(metric: hidden, change: hiddenChange),
                                .init(metric: .polarization, change: ambitious ? 2 : compromise ? -2 : 2)],
                approvalEffect: ambitious ? 1 : compromise ? 2 : -1,
                delayedEffects: [DelayedEffect(delayInYears: 2,
                    immediateEffects: [.init(metric: metric, change: ambitious ? 2 : compromise ? 1 : -2)],
                    hiddenEffects: [.init(metric: hidden, change: ambitious ? 2 : compromise ? 1 : -2)],
                    approvalEffect: ambitious ? 1 : compromise ? 1 : -1, note: delayNote)],
                conditionalModifiers: modifiers,
                flagsToSet: flags,
                publicMemoryImpact: PublicMemoryImpact(immediateApproval: 0,
                    groupEffects: [.init(group: group, change: ambitious ? 3 : compromise ? 1 : -2)],
                    reactivationTags: ["\(code)-\(entry.category.rawValue)"]))
        }
        let historicalChoice = entry.historicalChoice.flatMap { options.indices.contains($0) ? options[$0].id : nil }
        return GameEvent(
            id: entry.id, year: entry.year, title: entry.title, category: entry.category,
            headline: entry.title,
            description: entry.context + descriptionSuffix,
            historicalContext: HistoricalContext(summary: entry.isFuture ? fictionalSummary : entry.reality ?? entry.context,
                                                 sourceNote: entry.source),
            options: options,
            memoryReactivationTags: ["\(code)-\(entry.category.rawValue)"],
            historicalReality: entry.reality, historicalOptionID: historicalChoice,
            scenarioStep: entry.step)
    }
}

public struct EuropeanNewsRepository: NewsRepository {
    public let country: GameCountry

    public init(country: GameCountry) { self.country = country }

    public func loadNews() -> [NewsItem] {
        let scope: NewsScope = country == .france ? .france : .unitedKingdom
        return EuropeanEventRepository.entries(for: country).map { entry in
            NewsItem(id: "\(country.campaignCode)-news-\(entry.id)", year: entry.year, scope: scope,
                     category: entry.category, headline: entry.title, summary: entry.context,
                     source: entry.isFuture ? "Scenario desk · fiction" : entry.source ?? "Historical briefing")
        }
    }

    public func news(for year: Int) -> [NewsItem] { loadNews().filter { $0.year == year } }
}
