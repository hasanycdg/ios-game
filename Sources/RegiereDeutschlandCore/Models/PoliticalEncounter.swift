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

/// Erzeugt Interviews passend zur aktuellen Lage.
public enum InterviewFactory {
    public static func make(state: GameState, year: Int) -> PoliticalEncounter {
        let (prompt, source) = topic(for: state, year: year)
        let options = [
            EncounterOption(
                id: "steady",
                title: "Ruhe und Zuversicht ausstrahlen",
                detail: "Du gibst dich staatsmännisch und verweist auf den eingeschlagenen Kurs.",
                visibleEffects: [GameEffect(metric: .trust, change: 1)],
                approvalEffect: 2, polarizationEffect: -1
            ),
            EncounterOption(
                id: "honest",
                title: "Fehler einräumen, Reformen versprechen",
                detail: "Du zeigst dich selbstkritisch und kündigst Korrekturen an.",
                visibleEffects: [GameEffect(metric: .trust, change: 3), GameEffect(metric: .society, change: 1)],
                approvalEffect: -1, polarizationEffect: -2
            ),
            EncounterOption(
                id: "attack",
                title: "Die Opposition angreifen",
                detail: "Du gehst in die Offensive und machst die Gegner verantwortlich.",
                visibleEffects: [GameEffect(metric: .trust, change: -2)],
                approvalEffect: 2, polarizationEffect: 5
            )
        ]
        return PoliticalEncounter(kind: .interview, title: "Live-Interview", prompt: prompt, source: source, options: options)
    }

    private static func topic(for state: GameState, year: Int) -> (prompt: String, source: String) {
        let v = state.visible
        let candidates: [(VisibleMetric, Int)] = [
            (.economy, v.economy), (.society, v.society), (.security, v.security),
            (.trust, v.trust), (.livingStandard, v.livingStandard)
        ]
        let weakest = candidates.min { $0.1 < $1.1 }?.0 ?? .trust
        let source = ["ARD-Brennpunkt", "Talkshow am Abend", "Hauptstadtstudio", "Morgenmagazin"][abs(year) % 4]
        let prompt: String
        switch weakest {
        case .economy: prompt = "Die Wirtschaft schwächelt und Kritiker werfen Ihnen Konzeptlosigkeit vor. Was entgegnen Sie?"
        case .society: prompt = "Das Land wirkt gespalten. Wie wollen Sie die Gesellschaft wieder zusammenführen?"
        case .security: prompt = "Viele Menschen sorgen sich um die Sicherheit. Wie reagieren Sie auf diese Ängste?"
        case .livingStandard: prompt = "Der Alltag wird für viele teurer. Was sagen Sie den Menschen, die sich Sorgen machen?"
        default: prompt = "Das Vertrauen in die Politik sinkt. Wie wollen Sie es zurückgewinnen?"
        }
        return (prompt, source)
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
