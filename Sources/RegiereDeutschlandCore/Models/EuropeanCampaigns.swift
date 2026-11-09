import Foundation

// MARK: - Shared helpers for the United Kingdom and France campaigns
//
// Party names are fictional but recognisably modelled on each country's party
// system, just as the German campaign uses SDP, CDV/CSV, FDV and so on. All
// texts are English source strings; German translations live in
// `UKGerman.json` / `FRGerman.json`.

enum EuropeanParty {
    static func make(id: String, name: String, fullName: String, short: String, tagline: String,
                     spectrum: Double, leaning: PoliticalLeaning, support: Double,
                     icon: String, visible: [GameEffect], hidden: [HiddenEffect],
                     capital: Int = 7, capitalIncomeBonus: Int = 0, costReduction: Int = 0,
                     partnerLeaning: PoliticalLeaning, partnerName: String,
                     partners: [String], agenda: [AgendaItem]) -> PlayerParty {
        PlayerParty(
            id: id, name: name, fullName: fullName, shortName: short, tagline: tagline,
            spectrum: spectrum, leaning: leaning, baseSupport: support,
            profile: KanzlerPersona(
                id: id, title: name, tagline: tagline, icon: icon,
                visibleModifiers: visible, hiddenModifiers: hidden,
                startingCapital: capital, capitalIncomeBonus: capitalIncomeBonus,
                costReduction: costReduction, coalitionLeaning: partnerLeaning,
                coalitionSatisfaction: 62, coalitionPartnerName: partnerName),
            naturalPartnerIDs: partners, agenda: agenda)
    }

    static func item(_ id: String, _ title: String, _ summary: String, _ demand: String,
                     visible: [GameEffect], hidden: [HiddenEffect], reward: Int = 11) -> AgendaItem {
        AgendaItem(id: id, title: title, summary: summary, demand: demand,
                   visibleEffects: visible, hiddenEffects: hidden, satisfactionReward: reward)
    }
}

// MARK: - United Kingdom

public enum UKPartyCatalog {
    public static let defaultLeaderName = "Sam Hartley"

    public static let playable: [PlayerParty] = [
        EuropeanParty.make(
            id: "uk_labour", name: "People's Labour Party", fullName: "People's Labour Party", short: "PLP",
            tagline: "Public services, fair work and a modern, open Britain.",
            spectrum: 0.38, leaning: .left, support: 42, icon: "figure.2.arms.open",
            visible: [.init(metric: .livingStandard, change: 3), .init(metric: .society, change: 2), .init(metric: .budget, change: -2)],
            hidden: [.init(metric: .welfareStrength, change: 5), .init(metric: .healthcareResilience, change: 4)],
            partnerLeaning: .liberal, partnerName: "Liberal Alliance",
            partners: ["uk_libdem", "uk_green", "uk_snp"], agenda: agenda(for: "uk_labour")),
        EuropeanParty.make(
            id: "uk_conservative", name: "Unionist Conservative Party", fullName: "Unionist Conservative Party", short: "UCP",
            tagline: "Enterprise, sound money, strong defence and the Union.",
            spectrum: 0.68, leaning: .conservative, support: 32, icon: "building.columns.fill",
            visible: [.init(metric: .economy, change: 3), .init(metric: .security, change: 3), .init(metric: .society, change: -2)],
            hidden: [.init(metric: .fiscalSpace, change: 5), .init(metric: .defenceReadiness, change: 4), .init(metric: .welfareStrength, change: -2)],
            partnerLeaning: .liberal, partnerName: "Liberal Alliance",
            partners: ["uk_libdem", "uk_reform"], agenda: agenda(for: "uk_conservative")),
        EuropeanParty.make(
            id: "uk_libdem", name: "Liberal Alliance", fullName: "Liberal Alliance", short: "LIB",
            tagline: "Civil liberties, political reform and a European outlook.",
            spectrum: 0.5, leaning: .liberal, support: 18, icon: "bird.fill",
            visible: [.init(metric: .trust, change: 3), .init(metric: .internationalRelations, change: 2), .init(metric: .budget, change: -1)],
            hidden: [.init(metric: .euRelations, change: 6), .init(metric: .integrationCapacity, change: 4)],
            capital: 6, costReduction: 1,
            partnerLeaning: .left, partnerName: "People's Labour Party",
            partners: ["uk_labour", "uk_conservative", "uk_green"], agenda: agenda(for: "uk_libdem")),
        EuropeanParty.make(
            id: "uk_green", name: "Green Alliance Party", fullName: "Green Alliance Party", short: "GAP",
            tagline: "Climate action, clean energy and a fairer economy.",
            spectrum: 0.22, leaning: .left, support: 2, icon: "leaf.fill",
            visible: [.init(metric: .energy, change: 2), .init(metric: .society, change: 2), .init(metric: .economy, change: -2)],
            hidden: [.init(metric: .renewableCapacity, change: 12), .init(metric: .polarization, change: 4)],
            capital: 6, capitalIncomeBonus: 1,
            partnerLeaning: .left, partnerName: "People's Labour Party",
            partners: ["uk_labour", "uk_libdem", "uk_snp"], agenda: agenda(for: "uk_green"))
    ]

    /// Approximate starting support around the 2001 general election.
    public static let landscape: [PartyReference] = playable.map {
        PartyReference(id: $0.id, name: $0.name, shortName: $0.shortName, spectrum: $0.spectrum,
                       leaning: $0.leaning, baseSupport: $0.baseSupport, isPlayable: true)
    } + [
        PartyReference(id: "uk_snp", name: "Scottish Independence Party", shortName: "SIP", spectrum: 0.36, leaning: .left, baseSupport: 2, isPlayable: false),
        PartyReference(id: "uk_reform", name: "Sovereignty Party", shortName: "SOV", spectrum: 0.86, leaning: .conservative, baseSupport: 1.5, isPlayable: false)
    ]

    public static func agenda(for id: String) -> [AgendaItem] {
        typealias V = GameEffect
        typealias H = HiddenEffect
        switch id {
        case "uk_conservative":
            return [
                EuropeanParty.item("uk-con-tax", "Cut taxes for working families", "Lower income tax and business rates.", "We will only support you if the tax burden falls.",
                    visible: [V(metric: .economy, change: 3), V(metric: .budget, change: -3)], hidden: [H(metric: .labourMarketFlexibility, change: 4)], reward: 12),
                EuropeanParty.item("uk-con-defence", "Strengthen the armed forces", "Higher defence spending and a firm NATO commitment.", "Britain's security comes first: fund the armed forces properly.",
                    visible: [V(metric: .security, change: 3), V(metric: .budget, change: -2)], hidden: [H(metric: .defenceReadiness, change: 6)]),
                EuropeanParty.item("uk-con-deficit", "Bring the deficit down", "A credible plan to balance the books.", "Without a firm grip on the public finances, there is no deal.",
                    visible: [V(metric: .budget, change: 3), V(metric: .livingStandard, change: -2)], hidden: [H(metric: .fiscalSpace, change: 5)])
            ]
        case "uk_libdem":
            return [
                EuropeanParty.item("uk-lib-reform", "Reform the voting system", "A referendum on fairer votes and an elected upper house.", "Political reform is the price of our support.",
                    visible: [V(metric: .trust, change: 3)], hidden: [H(metric: .polarization, change: -4)], reward: 13),
                EuropeanParty.item("uk-lib-liberties", "Protect civil liberties", "Scrap ID cards and limit surveillance powers.", "We will not sign up to a surveillance state.",
                    visible: [V(metric: .trust, change: 2), V(metric: .security, change: -1)], hidden: [H(metric: .integrationCapacity, change: 3)]),
                EuropeanParty.item("uk-lib-schools", "Invest in schools and childcare", "A pupil premium and more support for young families.", "Our partners must back extra money for every disadvantaged child.",
                    visible: [V(metric: .society, change: 2), V(metric: .budget, change: -2)], hidden: [H(metric: .welfareStrength, change: 3)])
            ]
        case "uk_green":
            return [
                EuropeanParty.item("uk-grn-climate", "A legally binding path to net zero", "Faster renewables and an end to new oil and gas licences.", "Climate action is not negotiable for us.",
                    visible: [V(metric: .energy, change: 2), V(metric: .economy, change: -2)], hidden: [H(metric: .renewableCapacity, change: 8)], reward: 13),
                EuropeanParty.item("uk-grn-homes", "Insulate Britain's homes", "A national retrofit programme to cut bills and emissions.", "Warm homes and lower bills must be in the programme.",
                    visible: [V(metric: .livingStandard, change: 2), V(metric: .budget, change: -2)], hidden: [H(metric: .infrastructureQuality, change: 3)]),
                EuropeanParty.item("uk-grn-rail", "Public transport for everyone", "Cheaper fares and investment in rail and buses.", "We expect real money for buses and trains.",
                    visible: [V(metric: .society, change: 2), V(metric: .budget, change: -2)], hidden: [H(metric: .infrastructureQuality, change: 4)])
            ]
        case "uk_snp":
            return [
                EuropeanParty.item("uk-sip-devolution", "More powers for Scotland", "Further devolution of tax and welfare powers.", "Scotland must gain new powers from this agreement.",
                    visible: [V(metric: .society, change: 1), V(metric: .trust, change: -1)], hidden: [H(metric: .polarization, change: 2)], reward: 13),
                EuropeanParty.item("uk-sip-austerity", "End austerity", "Protect public spending in every nation of the UK.", "No support for cuts that hit Scotland's public services.",
                    visible: [V(metric: .livingStandard, change: 2), V(metric: .budget, change: -3)], hidden: [H(metric: .welfareStrength, change: 4)]),
                EuropeanParty.item("uk-sip-europe", "Closer ties with Europe", "Stay close to the European single market.", "Scotland's European future must be respected.",
                    visible: [V(metric: .internationalRelations, change: 2)], hidden: [H(metric: .euRelations, change: 6)])
            ]
        case "uk_reform":
            return [
                EuropeanParty.item("uk-sov-migration", "Cut immigration sharply", "Tight annual caps and faster removals.", "Our voters want immigration brought down now.",
                    visible: [V(metric: .society, change: -2), V(metric: .security, change: 2)], hidden: [H(metric: .integrationCapacity, change: -3), H(metric: .polarization, change: 4)], reward: 13),
                EuropeanParty.item("uk-sov-sovereignty", "Take back control from Brussels", "Repatriate powers and limit European rules.", "Sovereignty is the reason we exist.",
                    visible: [V(metric: .internationalRelations, change: -2), V(metric: .trust, change: 1)], hidden: [H(metric: .euRelations, change: -7)]),
                EuropeanParty.item("uk-sov-energy", "Cheap energy first", "Scrap green levies and expand domestic oil and gas.", "Bills must fall, whatever the climate targets say.",
                    visible: [V(metric: .energy, change: 2), V(metric: .livingStandard, change: 1)], hidden: [H(metric: .renewableCapacity, change: -6)])
            ]
        default: // uk_labour
            return [
                EuropeanParty.item("uk-plp-nhs", "Rebuild the NHS", "Shorter waiting lists and more doctors and nurses.", "The health service must come first in any agreement.",
                    visible: [V(metric: .livingStandard, change: 3), V(metric: .budget, change: -3)], hidden: [H(metric: .healthcareResilience, change: 6)], reward: 12),
                EuropeanParty.item("uk-plp-work", "Fair pay and secure work", "A higher minimum wage and stronger workers' rights.", "Working people need fair pay and protection at work.",
                    visible: [V(metric: .livingStandard, change: 2), V(metric: .economy, change: -1)], hidden: [H(metric: .welfareStrength, change: 4), H(metric: .labourMarketFlexibility, change: -3)]),
                EuropeanParty.item("uk-plp-schools", "Education, education, education", "More teachers and modern school buildings.", "We expect serious investment in schools.",
                    visible: [V(metric: .society, change: 2), V(metric: .budget, change: -2)], hidden: [H(metric: .digitalization, change: 3)])
            ]
        }
    }

    static func oppositionWeight(for ref: PartyReference, state: GameState) -> Double {
        let approval = Double(state.governmentApproval)
        let v = state.visible
        let polarization = Double(state.hidden.polarization)
        let year = Double(state.currentYear)
        let base = ref.baseSupport
        switch ref.id {
        case "uk_conservative":
            return base + max(0, 52 - approval) * 0.18 + (v.economy < 45 ? 4 : 0) + (v.security < 45 ? 2 : 0)
        case "uk_labour":
            return base + max(0, 52 - approval) * 0.16 + max(0, 55 - Double(v.livingStandard)) * 0.16
        case "uk_libdem":
            return base + max(0, Double(v.society) - 50) * 0.08 + max(0, 50 - Double(v.trust)) * 0.08
        case "uk_green":
            return base + max(0, Double(v.society) - 50) * 0.10 + (v.energy < 45 ? 3 : 0) + max(0, year - 2015) * 0.25
        case "uk_snp":
            return base + (year >= 2014 ? 2.5 : 0) - (year >= 2023 ? 1.5 : 0)
        case "uk_reform":
            return base + polarization * 0.20 + max(0, 50 - Double(v.trust)) * 0.15
                + (v.society < 48 ? 2 : 0) + max(0, year - 2012) * 0.3
        default:
            return base
        }
    }

    /// First-past-the-post rewards concentrated support. Small parties with a
    /// thinly spread vote win few seats until they become a major force.
    static func seatEfficiency(for id: String, share: Double, year: Int) -> Double {
        let base: Double = switch id {
        case "uk_labour", "uk_conservative": 1.0
        case "uk_libdem": 0.5
        case "uk_green": 0.12
        case "uk_reform": 0.15
        default: 0.6
        }
        return base + (1 - base) * min(1, max(0, (share - 15) / 15))
    }
}

// MARK: - France

public enum FRPartyCatalog {
    public static let defaultLeaderName = "Camille Laurent"

    public static let playable: [PlayerParty] = [
        EuropeanParty.make(
            id: "fr_socialist", name: "Parti Social-Démocrate", fullName: "Parti Social-Démocrate", short: "PSD",
            tagline: "Social justice, strong public services and a working week for living.",
            spectrum: 0.34, leaning: .left, support: 24, icon: "figure.2.arms.open",
            visible: [.init(metric: .livingStandard, change: 3), .init(metric: .society, change: 2), .init(metric: .budget, change: -2)],
            hidden: [.init(metric: .welfareStrength, change: 5), .init(metric: .labourMarketFlexibility, change: -3)],
            partnerLeaning: .left, partnerName: "Alliance Écologiste",
            partners: ["fr_green", "fr_radical_left", "fr_centrist"], agenda: agenda(for: "fr_socialist")),
        EuropeanParty.make(
            id: "fr_republican", name: "Rassemblement Républicain", fullName: "Rassemblement Républicain", short: "RR",
            tagline: "Authority of the state, enterprise and national sovereignty.",
            spectrum: 0.66, leaning: .conservative, support: 27, icon: "building.columns.fill",
            visible: [.init(metric: .security, change: 3), .init(metric: .economy, change: 2), .init(metric: .society, change: -2)],
            hidden: [.init(metric: .defenceReadiness, change: 5), .init(metric: .fiscalSpace, change: 3)],
            partnerLeaning: .liberal, partnerName: "Élan Centriste",
            partners: ["fr_centrist", "fr_socialist"], agenda: agenda(for: "fr_republican")),
        EuropeanParty.make(
            id: "fr_centrist", name: "Élan Centriste", fullName: "Élan Centriste", short: "ÉLAN",
            tagline: "Reform, Europe and a France open to the world.",
            spectrum: 0.55, leaning: .liberal, support: 8, icon: "star.circle.fill",
            visible: [.init(metric: .economy, change: 3), .init(metric: .internationalRelations, change: 2), .init(metric: .livingStandard, change: -1)],
            hidden: [.init(metric: .euRelations, change: 6), .init(metric: .labourMarketFlexibility, change: 6), .init(metric: .digitalization, change: 3)],
            capital: 6, costReduction: 1,
            partnerLeaning: .conservative, partnerName: "Rassemblement Républicain",
            partners: ["fr_republican", "fr_socialist", "fr_green"], agenda: agenda(for: "fr_centrist")),
        EuropeanParty.make(
            id: "fr_green", name: "Alliance Écologiste", fullName: "Alliance Écologiste", short: "AÉ",
            tagline: "Ecological transition, local democracy and solidarity.",
            spectrum: 0.22, leaning: .left, support: 6, icon: "leaf.fill",
            visible: [.init(metric: .energy, change: 2), .init(metric: .society, change: 2), .init(metric: .economy, change: -2)],
            hidden: [.init(metric: .renewableCapacity, change: 12), .init(metric: .nuclearCapacity, change: -5)],
            capital: 6, capitalIncomeBonus: 1,
            partnerLeaning: .left, partnerName: "Parti Social-Démocrate",
            partners: ["fr_socialist", "fr_radical_left", "fr_centrist"], agenda: agenda(for: "fr_green"))
    ]

    /// Approximate starting support around the 2002 elections.
    public static let landscape: [PartyReference] = playable.map {
        PartyReference(id: $0.id, name: $0.name, shortName: $0.shortName, spectrum: $0.spectrum,
                       leaning: $0.leaning, baseSupport: $0.baseSupport, isPlayable: true)
    } + [
        PartyReference(id: "fr_radical_left", name: "Gauche Radicale", shortName: "GR", spectrum: 0.1, leaning: .left, baseSupport: 8, isPlayable: false),
        PartyReference(id: "fr_patriot", name: "Front Patriote", shortName: "FP", spectrum: 0.92, leaning: .conservative, baseSupport: 14, isPlayable: false)
    ]

    public static func agenda(for id: String) -> [AgendaItem] {
        typealias V = GameEffect
        typealias H = HiddenEffect
        switch id {
        case "fr_republican":
            return [
                EuropeanParty.item("fr-rr-security", "Restore public order", "More police, faster justice and firm sentencing.", "Security is the first freedom: we demand a firm hand.",
                    visible: [V(metric: .security, change: 3), V(metric: .society, change: -1)], hidden: [H(metric: .polarization, change: 2)], reward: 12),
                EuropeanParty.item("fr-rr-charges", "Lower taxes and social charges", "Relieve companies and the middle classes.", "French businesses must finally breathe again.",
                    visible: [V(metric: .economy, change: 3), V(metric: .budget, change: -3)], hidden: [H(metric: .labourMarketFlexibility, change: 4)]),
                EuropeanParty.item("fr-rr-debt", "Control public spending", "A credible path back under the 3% deficit rule.", "No agreement without a grip on the debt.",
                    visible: [V(metric: .budget, change: 3), V(metric: .livingStandard, change: -2)], hidden: [H(metric: .fiscalSpace, change: 5)])
            ]
        case "fr_centrist":
            return [
                EuropeanParty.item("fr-elan-europe", "A stronger Europe", "Deeper European integration and a common defence.", "Our support depends on a resolutely European course.",
                    visible: [V(metric: .internationalRelations, change: 3)], hidden: [H(metric: .euRelations, change: 7)], reward: 12),
                EuropeanParty.item("fr-elan-labour", "Modernise the labour market", "Simpler rules for hiring and training.", "France must unblock its labour market.",
                    visible: [V(metric: .economy, change: 3), V(metric: .society, change: -2)], hidden: [H(metric: .labourMarketFlexibility, change: 7)]),
                EuropeanParty.item("fr-elan-innovation", "Invest in innovation", "Start-ups, research and a digital state.", "We want France to become a start-up nation.",
                    visible: [V(metric: .economy, change: 2), V(metric: .budget, change: -2)], hidden: [H(metric: .digitalization, change: 6)])
            ]
        case "fr_green":
            return [
                EuropeanParty.item("fr-ae-transition", "Accelerate the ecological transition", "Renewables, efficiency and a fair carbon policy.", "The ecological transition must be at the heart of the programme.",
                    visible: [V(metric: .energy, change: 2), V(metric: .economy, change: -2)], hidden: [H(metric: .renewableCapacity, change: 9)], reward: 13),
                EuropeanParty.item("fr-ae-nuclear", "Reduce dependence on nuclear power", "Close the oldest reactors step by step.", "We expect a clear plan to reduce nuclear power.",
                    visible: [V(metric: .energy, change: -2), V(metric: .society, change: 1)], hidden: [H(metric: .nuclearCapacity, change: -8), H(metric: .renewableCapacity, change: 4)]),
                EuropeanParty.item("fr-ae-transport", "Trains instead of motorways", "Night trains, rail freight and cycle networks.", "Public transport must win priority over new roads.",
                    visible: [V(metric: .society, change: 2), V(metric: .budget, change: -2)], hidden: [H(metric: .infrastructureQuality, change: 4)])
            ]
        case "fr_radical_left":
            return [
                EuropeanParty.item("fr-gr-wages", "Raise wages and the minimum wage", "A sharp increase in the minimum wage and price freezes.", "Workers' purchasing power comes first.",
                    visible: [V(metric: .livingStandard, change: 3), V(metric: .economy, change: -2)], hidden: [H(metric: .welfareStrength, change: 4)], reward: 13),
                EuropeanParty.item("fr-gr-pensions", "Retirement at 60", "Reverse increases in the pension age.", "We will never accept a higher retirement age.",
                    visible: [V(metric: .livingStandard, change: 2), V(metric: .budget, change: -4)], hidden: [H(metric: .fiscalSpace, change: -4)]),
                EuropeanParty.item("fr-gr-wealth", "Tax the wealthiest", "A strengthened wealth tax and higher top rates.", "The richest must contribute their fair share.",
                    visible: [V(metric: .budget, change: 2), V(metric: .economy, change: -2)], hidden: [H(metric: .polarization, change: 2)])
            ]
        case "fr_patriot":
            return [
                EuropeanParty.item("fr-fp-immigration", "Drastically reduce immigration", "National preference and stricter borders.", "Our voters want borders that protect them.",
                    visible: [V(metric: .security, change: 2), V(metric: .society, change: -3)], hidden: [H(metric: .integrationCapacity, change: -4), H(metric: .polarization, change: 5)], reward: 13),
                EuropeanParty.item("fr-fp-sovereignty", "Put national law above Europe", "Limit the reach of European rules.", "France must remain sovereign.",
                    visible: [V(metric: .internationalRelations, change: -2)], hidden: [H(metric: .euRelations, change: -7)]),
                EuropeanParty.item("fr-fp-fuel", "Cut taxes on fuel and energy", "Lower VAT on energy for households.", "Fuel prices are crushing rural France.",
                    visible: [V(metric: .livingStandard, change: 2), V(metric: .budget, change: -3)], hidden: [H(metric: .renewableCapacity, change: -2)])
            ]
        default: // fr_socialist
            return [
                EuropeanParty.item("fr-psd-services", "Protect public services", "More hospital staff, teachers and local services.", "Public services are the heritage of those who have nothing.",
                    visible: [V(metric: .livingStandard, change: 3), V(metric: .budget, change: -3)], hidden: [H(metric: .healthcareResilience, change: 5)], reward: 12),
                EuropeanParty.item("fr-psd-jobs", "Fight unemployment", "Subsidised jobs for young people and job security.", "Every young person deserves a job or training.",
                    visible: [V(metric: .economy, change: 1), V(metric: .budget, change: -2)], hidden: [H(metric: .welfareStrength, change: 4)]),
                EuropeanParty.item("fr-psd-housing", "Affordable housing", "Social housing and rent controls in tense areas.", "Housing must not become a luxury.",
                    visible: [V(metric: .society, change: 2), V(metric: .budget, change: -2)], hidden: [H(metric: .integrationCapacity, change: 3)])
            ]
        }
    }

    static func oppositionWeight(for ref: PartyReference, state: GameState) -> Double {
        let approval = Double(state.governmentApproval)
        let v = state.visible
        let polarization = Double(state.hidden.polarization)
        let year = Double(state.currentYear)
        let base = ref.baseSupport
        switch ref.id {
        case "fr_republican":
            return base + max(0, 52 - approval) * 0.16 + (v.economy < 45 ? 3 : 0) + (v.security < 45 ? 3 : 0)
        case "fr_socialist":
            return base + max(0, 52 - approval) * 0.14 + max(0, 55 - Double(v.livingStandard)) * 0.14
        case "fr_centrist":
            return base + max(0, Double(v.economy) - 50) * 0.10 + (year >= 2016 ? 10 : 0)
        case "fr_green":
            return base + max(0, Double(v.society) - 50) * 0.10 + (v.energy < 45 ? 3 : 0)
        case "fr_radical_left":
            return base + max(0, 50 - Double(v.livingStandard)) * 0.14 + polarization * 0.05 + (year >= 2012 ? 3 : 0)
        case "fr_patriot":
            return base + polarization * 0.22 + max(0, 50 - Double(v.trust)) * 0.15
                + max(0, 50 - Double(v.security)) * 0.10 + max(0, year - 2010) * 0.35
        default:
            return base
        }
    }

    /// The two-round system punishes isolated parties: without allies they rarely
    /// win run-offs. The far right becomes more competitive from 2022 onwards.
    static func seatEfficiency(for id: String, share: Double, year: Int) -> Double {
        let base: Double = switch id {
        case "fr_socialist", "fr_republican": 1.0
        case "fr_centrist": 0.7
        case "fr_green": 0.4
        case "fr_radical_left": 0.45
        case "fr_patriot": year >= 2022 ? 0.6 : 0.2
        default: 0.6
        }
        return base + (1 - base) * min(1, max(0, (share - 18) / 12))
    }
}

// MARK: - Election calendars, seats and mid-term contests

public enum EuropeanElectionSystem {
    /// General elections (UK) and presidential elections (France) as they
    /// actually took place; the year after 2026 shows the next scheduled vote.
    public static func electionYears(for country: GameCountry) -> Set<Int> {
        switch country {
        // Historical votes until 2024/2022, then the regular five-year cycle.
        case .unitedKingdom: [2001, 2005, 2010, 2015, 2017, 2019, 2024, 2029, 2034, 2039, 2044, 2049]
        case .france: [2002, 2007, 2012, 2017, 2022, 2027, 2032, 2037, 2042, 2047]
        default: []
        }
    }

    /// UK local elections and French Senate renewals change how easily laws pass.
    public static func midtermYears(for country: GameCountry) -> Set<Int> {
        switch country {
        case .unitedKingdom: [2003, 2006, 2008, 2012, 2014, 2016, 2021, 2023, 2026, 2028, 2031, 2033, 2036, 2038, 2041, 2043, 2046, 2048]
        case .france: [2001, 2004, 2008, 2011, 2014, 2020, 2023, 2026, 2029, 2035, 2038, 2041, 2044, 2050]
        default: []
        }
    }

    public static func midtermNote(for country: GameCountry, regained: Bool, lost: Bool, holds: Bool) -> String {
        if country == .france {
            if regained { return "Senatswahlen: Die Regierung gewinnt die Mehrheit im Senat zurück." }
            if lost { return "Senatswahlen: Die Regierung verliert die Mehrheit im Senat – Gesetze werden schwerer." }
            return holds ? "Senatswahlen: Die Regierung behauptet ihre Mehrheit im Senat."
                : "Senatswahlen: Die Opposition dominiert weiter den Senat."
        }
        if regained { return "Kommunalwahlen: Die Regierung gewinnt an Boden – das Oberhaus bremst weniger." }
        if lost { return "Kommunalwahlen: Schwere Verluste für die Regierung – das Oberhaus bremst Gesetze stärker." }
        return holds ? "Kommunalwahlen: Die Regierung behauptet sich in den Rathäusern."
            : "Kommunalwahlen: Die Opposition dominiert weiter die Rathäuser."
    }

    static func oppositionWeight(for ref: PartyReference, state: GameState, country: GameCountry) -> Double {
        country == .france ? FRPartyCatalog.oppositionWeight(for: ref, state: state)
            : UKPartyCatalog.oppositionWeight(for: ref, state: state)
    }

    /// Seats per party using a disproportional allocation (exponent > 1 rewards
    /// the leading parties) and the largest-remainder method so totals are exact.
    public static func allocateSeats(_ parties: [(id: String, share: Double)], country: GameCountry, year: Int) -> [String: Int] {
        let total = country.parliamentSeats
        let exponent = country == .france ? 1.8 : 2.2
        var reserved: [String: Int] = [:]
        var contested = parties
        if country == .unitedKingdom, let regional = parties.first(where: { $0.id == "uk_snp" }) {
            // A Scotland-only party: seats depend on its Scottish strength, not UK-wide share.
            reserved["uk_snp"] = Int((59 * min(0.95, max(0, (regional.share - 1.5) / 3.3))).rounded())
            contested.removeAll { $0.id == "uk_snp" }
        }
        let available = total - reserved.values.reduce(0, +)
        let weights = contested.map { party -> (String, Double) in
            let efficiency = country == .france
                ? FRPartyCatalog.seatEfficiency(for: party.id, share: party.share, year: year)
                : UKPartyCatalog.seatEfficiency(for: party.id, share: party.share, year: year)
            return (party.id, efficiency * pow(max(0, party.share), exponent))
        }
        let weightSum = weights.reduce(0) { $0 + $1.1 }
        guard weightSum > 0 else { return reserved }
        let quotas = weights.map { ($0.0, Double(available) * $0.1 / weightSum) }
        var result = reserved
        for (id, quota) in quotas { result[id] = Int(quota.rounded(.down)) }
        var remaining = total - result.values.reduce(0, +)
        for (id, quota) in quotas.sorted(by: { ($0.1 - $0.1.rounded(.down)) > ($1.1 - $1.1.rounded(.down)) }) where remaining > 0 {
            result[id, default: 0] += 1
            remaining -= 1
        }
        return result
    }
}

// MARK: - Starting positions in 2000

enum EuropeanCampaignStart {
    /// The UK in 2000: steady growth, low unemployment and a budget surplus, but
    /// strained public services, an ailing railway and fuel-price protests.
    static func unitedKingdom2000() -> GameState {
        GameState(
            currentYear: 2000, governmentApproval: 55,
            visible: VisibleMetrics(economy: 64, budget: 62, livingStandard: 61, society: 56,
                security: 66, energy: 64, internationalRelations: 70, trust: 50),
            hidden: HiddenMetrics(renewableCapacity: 8, nuclearCapacity: 38,
                russianEnergyDependency: 3, defenceReadiness: 72, digitalization: 38,
                infrastructureQuality: 52, integrationCapacity: 56, labourMarketFlexibility: 74,
                welfareStrength: 50, healthcareResilience: 48, euRelations: 58,
                usRelations: 85, russiaRelations: 52, polarization: 34, fiscalSpace: 66))
    }

    /// France in 2000: strong growth and falling unemployment, the 35-hour week,
    /// a nuclear-powered electricity system and a highly rated health service,
    /// but a rigid labour market and tense suburbs.
    static func france2000() -> GameState {
        GameState(
            currentYear: 2000, governmentApproval: 52,
            visible: VisibleMetrics(economy: 60, budget: 52, livingStandard: 64, society: 54,
                security: 64, energy: 74, internationalRelations: 68, trust: 46),
            hidden: HiddenMetrics(renewableCapacity: 12, nuclearCapacity: 85,
                russianEnergyDependency: 12, defenceReadiness: 70, digitalization: 28,
                infrastructureQuality: 74, integrationCapacity: 48, labourMarketFlexibility: 30,
                welfareStrength: 75, healthcareResilience: 76, euRelations: 76,
                usRelations: 58, russiaRelations: 52, polarization: 40, fiscalSpace: 50))
    }
}
