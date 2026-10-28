import Foundation

public struct USCampaignEntry: Codable, Sendable {
    public let id: String
    public let year: Int
    public let title: String
    public let context: String
    public let category: EventCategory
    public let choices: [String]
    public let reality: String?
    public let source: String?
    public let historicalChoice: Int?
    public let step: Int?
}

/// Entirely separate editorial content; never loads German event resources.
public struct USEventRepository: EventRepository {
    private let storedEvents: [GameEvent]

    public init() {
        storedEvents = Self.entries.flatMap { name, entries in
            entries.map { entry in Self.event(entry, future: name == "USFuture") }
        }
    }

    public func loadEvents() -> [GameEvent] { storedEvents }
    public func events(for year: Int) -> [GameEvent] { storedEvents.filter { $0.year == year } }

    static var entries: [(String, [USCampaignEntry])] {
        ["USHistory", "USFuture"].map { name in
            guard let url = Bundle.module.url(forResource: name, withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let entries = try? JSONDecoder().decode([USCampaignEntry].self, from: data) else { return (name, []) }
            return (name, entries)
        }
    }

    private static func event(_ entry: USCampaignEntry, future: Bool) -> GameEvent {
        let id = entry.id
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
        let crisisDecision = future && entry.year == 2030 && entry.step == 2
        let finalSettlement = future && entry.year == 2050 && entry.step == 8
        let choices = crisisDecision
            ? ["Authorize a major military intervention", "Pursue allied deterrence and urgent mediation", "Limit the US role to evacuations and humanitarian relief"]
            : finalSettlement
                ? ["Build a lasting democratic alliance system", "Support a plural international order with shared rules", "Prioritize national autonomy and domestic renewal"]
                : entry.choices
        let options = choices.enumerated().map { choice, title in
            let ambitious = choice == 0
            let compromise = choice == 1
            let flag = "us-path-\(entry.category.rawValue)-\(choice)"
            let gain = metric == .budget ? (ambitious ? -3 : compromise ? 1 : 4) : (ambitious ? 4 : compromise ? 2 : -2)
            let fiscal = ambitious ? -3 : compromise ? -1 : 3
            let trust = ambitious ? -1 : compromise ? 2 : -2
            let memoryTag = "us-\(entry.category.rawValue)"
            let delayNote = ambitious
                ? "\(entry.title): the federal investment is delivering lasting capacity, while its fiscal cost remains."
                : compromise ? "\(entry.title): the negotiated settlement delivers gradual improvements."
                : "\(entry.title): short-term savings leave a capacity gap that later administrations must address."
            var mainEffects: [GameEffect] = [.init(metric: metric, change: gain), .init(metric: .trust, change: trust)]
            var flags = [flag]
            var hiddenChange = metric == .budget ? (ambitious ? -3 : compromise ? 1 : 3) : (ambitious ? 5 : compromise ? 2 : -3)
            let taxCuts = metric == .budget && choice == 2 && title.lowercased().contains("tax")
            if taxCuts {
                mainEffects = [.init(metric: .budget, change: -4), .init(metric: .economy, change: 3), .init(metric: .trust, change: -1)]
                hiddenChange = -3
            }
            if !future {
                // Shocks affect every response. Intervention mitigates damage;
                // it must not make a financial crash or pandemic a free boost.
                if entry.title == "Lehman and the financial panic" {
                    mainEffects += [.init(metric: .economy, change: -9), .init(metric: .budget, change: -5)]
                } else if entry.title == "COVID-19" {
                    mainEffects += [.init(metric: .economy, change: -7), .init(metric: .livingStandard, change: -7), .init(metric: .society, change: -3)]
                } else if entry.title == "September 11" {
                    mainEffects += [.init(metric: .security, change: -8), .init(metric: .economy, change: -4)]
                } else if entry.title == "Hurricane Katrina" || entry.title == "Hurricane Sandy" {
                    mainEffects += [.init(metric: .security, change: -5), .init(metric: .livingStandard, change: -4)]
                }
                if entry.title == "The housing boom accelerates", choice < 2 { flags.append("us_mortgage_oversight") }
                if entry.title == "The dot-com bubble bursts", ambitious { flags.append("us_early_broadband") }
            }
            if crisisDecision {
                flags.append(choice == 0 ? "scenario_world_war" : "scenario_war_avoided")
                mainEffects += choice == 0
                    ? [.init(metric: .internationalRelations, change: -8), .init(metric: .society, change: -6)]
                    : [.init(metric: .internationalRelations, change: 4), .init(metric: .trust, change: 2)]
            }
            if finalSettlement { flags.append("us-world-order-\(choice)") }
            var modifiers = [ConditionalModifier(
                conditions: [EventCondition(requiredFlags: ["us-path-\(entry.category.rawValue)-0"])],
                immediateEffects: [.init(metric: metric, change: 1)],
                note: "Earlier federal investment gives this response a head start.")]
            if entry.id == "us-2008-lehman-and-the-financial-panic" {
                modifiers.append(ConditionalModifier(
                    conditions: [EventCondition(requiredFlags: ["us_mortgage_oversight"])],
                    immediateEffects: [.init(metric: .economy, change: 3), .init(metric: .budget, change: 2)],
                    note: "Earlier mortgage supervision limits the financial crisis's damage."))
            }
            if entry.id == "us-2020-an-economy-in-lockdown" {
                modifiers.append(ConditionalModifier(
                    conditions: [EventCondition(requiredFlags: ["us_early_broadband"])],
                    immediateEffects: [.init(metric: .economy, change: 2)],
                    hiddenEffects: [.init(metric: .digitalization, change: 2)],
                    note: "Early broadband investment supports remote work during the pandemic."))
            }
            if future && entry.year >= 2035 {
                modifiers.append(ConditionalModifier(
                    conditions: [EventCondition(requiredFlags: ["scenario_world_war"])],
                    immediateEffects: [.init(metric: .budget, change: -1)],
                    note: "The earlier military escalation increases the cost of reconstruction."))
                modifiers.append(ConditionalModifier(
                    conditions: [EventCondition(requiredFlags: ["scenario_war_avoided"])],
                    immediateEffects: [.init(metric: .society, change: 1)],
                    note: "Preventing escalation preserved resources and public cohesion for renewal."))
            }
            let budgetEffects: [GameEffect] = metric == .budget
                ? [.init(metric: .livingStandard, change: ambitious ? 3 : compromise ? 1 : -3)]
                : [.init(metric: .budget, change: fiscal)]
            return DecisionOption(id: "\(id)-\(choice)", title: title,
                description: crisisDecision
                    ? (choice == 0
                        ? "The intervention escalates into a wider fictional conflict. Military readiness improves, but international trust and social cohesion suffer. Later reconstruction will cost more."
                        : choice == 1
                            ? "Allied deterrence and emergency mediation contain the immediate crisis. The avoided escalation leaves more resources for long-term renewal."
                            : "The administration limits its exposure and supports civilian evacuation. The immediate escalation is avoided, but allies question the limits of American commitments.")
                    : taxCuts ? "Lower federal taxes to support private spending and investment. Growth may improve, but reduced revenue narrows the budget and fiscal capacity."
                    : ambitious
                    ? "Commit federal resources to this course. It can produce a stronger immediate response, but costs money and political support."
                    : compromise ? "Build a narrower agreement with Congress and the states. Progress is slower, with lower costs and broader support."
                    : "Limit federal commitments and leave more responsibility to states and private actors. Preserve funds now, accepting weaker national capacity.",
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
                    reactivationTags: [memoryTag]))
        }
        let historicalChoice = entry.historicalChoice.flatMap { options.indices.contains($0) ? options[$0].id : nil }
        return GameEvent(id: id, year: entry.year, title: entry.title, category: entry.category,
            headline: entry.title,
            description: entry.context + "\n\nYour administration must choose a response. The outcomes below belong to this alternate-history simulation.",
            historicalContext: HistoricalContext(summary: future
                ? "Fictional scenario. These events are invented for the campaign and are not predictions or claims about real events."
                : entry.reality ?? entry.context, sourceNote: entry.source),
            options: options,
            memoryReactivationTags: ["us-\(entry.category.rawValue)"],
            historicalReality: entry.reality, historicalOptionID: historicalChoice,
            scenarioStep: entry.step)
    }
}

public struct USNewsRepository: NewsRepository {
    public init() {}
    public func loadNews() -> [NewsItem] {
        USEventRepository.entries.flatMap { name, entries in
            entries.map { entry in
                NewsItem(id: "us-news-\(name)-\(entry.id)", year: entry.year, scope: .unitedStates,
                    category: entry.category, headline: entry.title,
                    summary: name == "USFuture" ? "Fictional scenario: " + entry.context : entry.context,
                    source: name == "USFuture" ? "Scenario desk · fiction" : entry.year >= 2025 ? "Policy scenario · fiction" : "Historical briefing")
            }
        }
    }
    public func news(for year: Int) -> [NewsItem] { loadNews().filter { $0.year == year } }
}
