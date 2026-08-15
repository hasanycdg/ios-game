import Foundation

/// Art einer politischen Begegnung außerhalb der Sachentscheidungen.
public enum EncounterKind: String, Codable, Sendable {
    case interview
    case lobby
}

/// Eine Antwortmöglichkeit in einer Begegnung.
public struct EncounterOption: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let visibleEffects: [GameEffect]
    public let approvalEffect: Int
    public let polarizationEffect: Int
    public let capitalReward: Int
    public let corruptionEffect: Int

    public init(
        id: String,
        title: String,
        detail: String,
        visibleEffects: [GameEffect] = [],
        approvalEffect: Int = 0,
        polarizationEffect: Int = 0,
        capitalReward: Int = 0,
        corruptionEffect: Int = 0
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.visibleEffects = visibleEffects
        self.approvalEffect = approvalEffect
        self.polarizationEffect = polarizationEffect
        self.capitalReward = capitalReward
        self.corruptionEffect = corruptionEffect
    }
}

/// Ein Interview oder ein vertrauliches Lobby-Angebot.
public struct PoliticalEncounter: Codable, Equatable, Sendable {
    public let kind: EncounterKind
    public let title: String
    public let prompt: String
    public let source: String
    public let options: [EncounterOption]

    public init(kind: EncounterKind, title: String, prompt: String, source: String, options: [EncounterOption]) {
        self.kind = kind
        self.title = title
        self.prompt = prompt
        self.source = source
        self.options = options
    }
}

/// Erzeugt abwechslungsreiche Interviews. Statt immer derselben drei Antworten
/// wählt der Katalog je nach Lage (schwächster Wert, Koalitionsklima, Zustimmung,
/// Jahr) ein passendes Szenario mit eigenen, zugeschnittenen Antwortoptionen.
public enum InterviewFactory {
    public static func make(
        state: GameState,
        year: Int,
        coalition: CoalitionState = .standard(),
        playerPartyName: String = "deiner Partei",
        opponentName: String = "die Opposition"
    ) -> PoliticalEncounter {
        let scenario = selectScenario(state: state, year: year, coalition: coalition)
        let source = sources[abs(year &* 7 &+ scenario.rawValue) % sources.count]
        return scenario.encounter(
            state: state,
            source: source,
            playerPartyName: playerPartyName,
            opponentName: opponentName
        )
    }

    private static let sources = [
        "ARD-Brennpunkt", "Talkshow am Abend", "Hauptstadtstudio",
        "Morgenmagazin", "Politik am Sonntag", "Im Kreuzverhör"
    ]

    private static func selectScenario(state: GameState, year: Int, coalition: CoalitionState) -> InterviewScenario {
        // Angespannte Koalition hat Vorrang – der Bruch droht.
        if !coalition.isMinority, coalition.satisfaction < 38 {
            return .coalitionRift
        }
        // Höhenflug: bei sehr hoher Zustimmung fragt man nach dem Machtanspruch.
        if state.governmentApproval >= 66 {
            return .highApproval
        }
        // Sonst am schwächsten Wert orientieren …
        let v = state.visible
        let byMetric: [(InterviewScenario, Int)] = [
            (.economy, v.economy), (.society, v.society), (.security, v.security),
            (.livingStandard, v.livingStandard), (.trust, v.trust)
        ]
        let weakest = byMetric.min { $0.1 < $1.1 }
        // … aber gelegentlich (je nach Jahr) das Führungs-Interview einstreuen,
        // damit sich Interviews nicht wiederholen.
        if abs(year) % 3 == 0 {
            return .leadership
        }
        return weakest?.0 ?? .trust
    }
}

/// Die verfügbaren Interview-Szenarien. `metric`-Fälle bilden den passenden
/// Themen-Namen ab.
private enum InterviewScenario: Int {
    case economy, society, security, livingStandard, trust
    case coalitionRift, highApproval, leadership

    init(_ metric: VisibleMetric) {
        switch metric {
        case .economy: self = .economy
        case .society: self = .society
        case .security: self = .security
        case .livingStandard: self = .livingStandard
        default: self = .trust
        }
    }

    func encounter(state: GameState, source: String, playerPartyName: String, opponentName: String) -> PoliticalEncounter {
        PoliticalEncounter(kind: .interview, title: title, prompt: prompt(opponentName: opponentName, playerPartyName: playerPartyName), source: source, options: options)
    }

    var title: String {
        switch self {
        case .coalitionRift: return "Krisengespräch"
        case .highApproval:  return "Das große Interview"
        case .leadership:    return "Portrait am Abend"
        default:             return "Live-Interview"
        }
    }

    func prompt(opponentName: String, playerPartyName: String) -> String {
        switch self {
        case .economy:
            return "Die Wirtschaft schwächelt, \(opponentName) wirft Ihnen Konzeptlosigkeit vor. Was entgegnen Sie?"
        case .society:
            return "Das Land wirkt gespalten. Wie wollen Sie die Gesellschaft wieder zusammenführen?"
        case .security:
            return "Viele Menschen sorgen sich um ihre Sicherheit. Wie reagieren Sie auf diese Ängste?"
        case .livingStandard:
            return "Der Alltag wird für viele teurer. Was sagen Sie denen, die kaum über die Runden kommen?"
        case .trust:
            return "Das Vertrauen in die Politik sinkt. Wie wollen Sie es zurückgewinnen?"
        case .coalitionRift:
            return "In Ihrer Koalition kracht es hörbar. Hält dieses Bündnis überhaupt noch?"
        case .highApproval:
            return "Ihre Umfragewerte sind glänzend. Nutzen Sie die Macht jetzt für die großen Würfe – oder verwalten Sie nur?"
        case .leadership:
            return "Was für ein Mensch sind Sie als Kanzler:in – hart in der Sache oder eher der ausgleichende Typ?"
        }
    }

    var options: [EncounterOption] {
        switch self {
        case .economy:
            return [
                EncounterOption(id: "reform", title: "Investitionsoffensive ankündigen",
                    detail: "Du versprichst Milliarden für Wachstum – mutig, aber teuer.",
                    visibleEffects: [GameEffect(metric: .economy, change: 2), GameEffect(metric: .budget, change: -2)],
                    approvalEffect: 2),
                EncounterOption(id: "calm", title: "Auf Stabilität und Geduld setzen",
                    detail: "Du wirbst um Vertrauen in den eingeschlagenen Kurs.",
                    visibleEffects: [GameEffect(metric: .trust, change: 2)],
                    approvalEffect: 1, polarizationEffect: -1),
                EncounterOption(id: "blame", title: "Weltmarkt und Vorgänger verantwortlich machen",
                    detail: "Du schiebst die Schuld nach außen – riskant fürs Vertrauen.",
                    visibleEffects: [GameEffect(metric: .trust, change: -2)],
                    approvalEffect: 1, polarizationEffect: 4)
            ]
        case .society:
            return [
                EncounterOption(id: "bridge", title: "Zum Dialog aufrufen",
                    detail: "Du lädst zum runden Tisch und zur Versöhnung ein.",
                    visibleEffects: [GameEffect(metric: .society, change: 3), GameEffect(metric: .trust, change: 1)],
                    approvalEffect: 1, polarizationEffect: -4),
                EncounterOption(id: "values", title: "Klare Kante für die eigene Linie",
                    detail: "Du benennst Konflikte scharf und beziehst Position.",
                    visibleEffects: [GameEffect(metric: .society, change: -1)],
                    approvalEffect: 2, polarizationEffect: 4),
                EncounterOption(id: "listen", title: "Zuhören und Sorgen ernst nehmen",
                    detail: "Du gibst dich empathisch und volksnah.",
                    visibleEffects: [GameEffect(metric: .trust, change: 2), GameEffect(metric: .society, change: 1)],
                    approvalEffect: 1, polarizationEffect: -2)
            ]
        case .security:
            return [
                EncounterOption(id: "tough", title: "Härte und mehr Befugnisse versprechen",
                    detail: "Du kündigst mehr Polizei und schärfere Gesetze an.",
                    visibleEffects: [GameEffect(metric: .security, change: 3), GameEffect(metric: .society, change: -1)],
                    approvalEffect: 2, polarizationEffect: 3),
                EncounterOption(id: "balanced", title: "Sicherheit und Bürgerrechte abwägen",
                    detail: "Du wirbst für Augenmaß statt Aktionismus.",
                    visibleEffects: [GameEffect(metric: .security, change: 1), GameEffect(metric: .trust, change: 2)],
                    approvalEffect: 1, polarizationEffect: -2),
                EncounterOption(id: "prevent", title: "Auf Prävention und Ursachen setzen",
                    detail: "Du betonst soziale Ursachen statt reiner Repression.",
                    visibleEffects: [GameEffect(metric: .society, change: 2)],
                    approvalEffect: -1, polarizationEffect: -1)
            ]
        case .livingStandard:
            return [
                EncounterOption(id: "relief", title: "Entlastungspaket zusagen",
                    detail: "Du versprichst schnelle Hilfen – der Haushalt ächzt.",
                    visibleEffects: [GameEffect(metric: .livingStandard, change: 3), GameEffect(metric: .budget, change: -3)],
                    approvalEffect: 3),
                EncounterOption(id: "honest", title: "Ehrlich harte Zeiten ankündigen",
                    detail: "Du sagst unbequeme Wahrheiten – ehrlich, aber unpopulär.",
                    visibleEffects: [GameEffect(metric: .trust, change: 3), GameEffect(metric: .budget, change: 1)],
                    approvalEffect: -2, polarizationEffect: -1),
                EncounterOption(id: "hope", title: "Auf baldige Besserung vertrösten",
                    detail: "Du malst ein optimistisches Bild ohne konkrete Zusagen.",
                    visibleEffects: [GameEffect(metric: .trust, change: -1)],
                    approvalEffect: 1)
            ]
        case .trust:
            return [
                EncounterOption(id: "transparency", title: "Mehr Transparenz versprechen",
                    detail: "Du kündigst offene Bücher und klare Regeln an.",
                    visibleEffects: [GameEffect(metric: .trust, change: 3)],
                    approvalEffect: 1, polarizationEffect: -2),
                EncounterOption(id: "selfcrit", title: "Fehler offen einräumen",
                    detail: "Du zeigst dich selbstkritisch und gelobst Besserung.",
                    visibleEffects: [GameEffect(metric: .trust, change: 4), GameEffect(metric: .society, change: 1)],
                    approvalEffect: -1, polarizationEffect: -2),
                EncounterOption(id: "deflect", title: "Alles als Kampagne abtun",
                    detail: "Du erklärst die Kritik zur Medienmache – riskant.",
                    visibleEffects: [GameEffect(metric: .trust, change: -3)],
                    approvalEffect: 1, polarizationEffect: 4)
            ]
        case .coalitionRift:
            return [
                EncounterOption(id: "loyal", title: "Sich klar zum Partner bekennen",
                    detail: "Du stärkst dem Koalitionspartner öffentlich den Rücken.",
                    visibleEffects: [GameEffect(metric: .trust, change: 1)],
                    approvalEffect: -1, polarizationEffect: -3),
                EncounterOption(id: "distance", title: "Auf Distanz zum Partner gehen",
                    detail: "Du grenzt dich ab – gut fürs Profil, Gift für die Koalition.",
                    visibleEffects: [GameEffect(metric: .trust, change: -1)],
                    approvalEffect: 2, polarizationEffect: 3),
                EncounterOption(id: "mediate", title: "Kompromiss und Sacharbeit betonen",
                    detail: "Du wirbst staatsmännisch für den Zusammenhalt.",
                    visibleEffects: [GameEffect(metric: .society, change: 1), GameEffect(metric: .trust, change: 2)],
                    approvalEffect: 1, polarizationEffect: -2)
            ]
        case .highApproval:
            return [
                EncounterOption(id: "ambition", title: "Große Reformen ankündigen",
                    detail: "Du nutzt deinen Rückhalt für einen mutigen Aufbruch.",
                    visibleEffects: [GameEffect(metric: .economy, change: 1), GameEffect(metric: .society, change: 1)],
                    approvalEffect: 1, polarizationEffect: 2),
                EncounterOption(id: "humble", title: "Bescheiden und bodenständig bleiben",
                    detail: "Du dämpfst die Erwartungen und bleibst nüchtern.",
                    visibleEffects: [GameEffect(metric: .trust, change: 3)],
                    approvalEffect: 1, polarizationEffect: -2),
                EncounterOption(id: "power", title: "Selbstbewusst den Führungsanspruch betonen",
                    detail: "Du stellst deine Stärke heraus – nicht alle mögen das.",
                    visibleEffects: [GameEffect(metric: .trust, change: -1)],
                    approvalEffect: 2, polarizationEffect: 3)
            ]
        case .leadership:
            return [
                EncounterOption(id: "decisive", title: "Als entschlossene:r Macher:in auftreten",
                    detail: "Du inszenierst dich als durchsetzungsstark.",
                    visibleEffects: [GameEffect(metric: .economy, change: 1)],
                    approvalEffect: 2, polarizationEffect: 2),
                EncounterOption(id: "warm", title: "Als nahbare:r Brückenbauer:in auftreten",
                    detail: "Du zeigst die menschliche, verbindende Seite.",
                    visibleEffects: [GameEffect(metric: .society, change: 2), GameEffect(metric: .trust, change: 1)],
                    approvalEffect: 1, polarizationEffect: -2),
                EncounterOption(id: "principled", title: "Auf Prinzipien und Haltung pochen",
                    detail: "Du betonst deine Werte, auch gegen Widerstände.",
                    visibleEffects: [GameEffect(metric: .trust, change: 2), GameEffect(metric: .society, change: -1)],
                    approvalEffect: 0, polarizationEffect: 1)
            ]
        }
    }
}

/// Erzeugt vertrauliche Lobby-Angebote.
public enum LobbyFactory {
    private static let firms: [(name: String, metric: VisibleMetric)] = [
        ("Ein großer Energiekonzern", .energy),
        ("Ein Automobilkonzern", .economy),
        ("Eine internationale Großbank", .budget),
        ("Ein Pharmakonzern", .livingStandard),
        ("Ein Rüstungskonzern", .security)
    ]

    public static func make(state: GameState, year: Int) -> PoliticalEncounter {
        let firm = firms[abs(year) % firms.count]
        let prompt = "\(firm.name) bietet dir im Verborgenen großzügige Unterstützung – im Gegenzug für eine wohlwollende Politik. Niemand soll davon erfahren."
        let options = [
            EncounterOption(
                id: "accept",
                title: "Das Angebot annehmen",
                detail: "Diskretes politisches Kapital fließt – doch solche Deals kommen irgendwann ans Licht.",
                visibleEffects: [GameEffect(metric: firm.metric, change: 3)],
                capitalReward: 3, corruptionEffect: 20
            ),
            EncounterOption(
                id: "decline",
                title: "Höflich ablehnen",
                detail: "Du bleibst sauber – die Lobbyisten ziehen enttäuscht ab.",
                visibleEffects: [GameEffect(metric: .trust, change: 2)],
                approvalEffect: 1
            ),
            EncounterOption(
                id: "expose",
                title: "Den Bestechungsversuch öffentlich machen",
                detail: "Du machst den Vorgang publik – die Wirtschaft ist verstimmt, die Bürger honorieren die Integrität.",
                visibleEffects: [GameEffect(metric: .trust, change: 4), GameEffect(metric: .economy, change: -2)],
                approvalEffect: 2, polarizationEffect: 2
            )
        ]
        return PoliticalEncounter(kind: .lobby, title: "Vertrauliches Angebot", prompt: prompt, source: firm.name, options: options)
    }
}
