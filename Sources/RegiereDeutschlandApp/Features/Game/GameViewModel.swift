import Foundation
import RegiereDeutschlandCore

@MainActor
final class GameViewModel: ObservableObject {
    enum StartMode {
        case newGame
        case resume
    }

    enum Phase: Equatable {
        case event
        case result(DecisionResult)
        case encounter
        case campaign
        case election(ElectionResult)
        case briefing
        case coalitionTalks
        case coalitionNegotiation
        case gameOver(GameOverSummary)
        case noEvent
    }

    @Published private(set) var state: GameState
    @Published private(set) var currentEvent: GameEvent?
    @Published private(set) var phase: Phase
    @Published private(set) var annualHistory: [AnnualRecord] = []
    @Published private(set) var politicalCapital: Int = 7
    @Published private(set) var coalition: CoalitionState = .standard()
    @Published private(set) var persona: KanzlerPersona = PersonaCatalog.default
    @Published private(set) var playerParty: PlayerParty = PartyCatalog.default
    @Published private(set) var playerName: String = PartyCatalog.defaultChancellorName
    @Published private(set) var newlyUnlockedAchievements: [Achievement] = []
    @Published private(set) var corruption: Int = 0
    @Published private(set) var pendingEncounter: PoliticalEncounter?
    @Published private(set) var cabinet: Cabinet = .standard()
    @Published private(set) var pendingCoalitionOptions: [CoalitionOption]?
    @Published private(set) var pendingCoalitionTalks: CoalitionNegotiation?
    @Published private(set) var isFormingInitialGovernment = false
    @Published private(set) var policies: PolicyState = .standard()
    @Published private(set) var debt: Int = 60
    @Published private(set) var interestGroups: [InterestGroup] = InterestGroupsFactory.standard()
    @Published private(set) var partyWings: PartyWings = .standard()
    @Published private(set) var hasBundesratMajority: Bool = true
    @Published private(set) var diplomacy: DiplomaticState = .standard(from: GameStateFactory.initialGermany2000().hidden)
    let maxCapital = 10

    var budget: BudgetSummary { engine.budgetSummary() }
    #if DEBUG
    @Published private(set) var balanceSummaryText: String = ""
    #endif

    private let engine: GameEngine
    private let persistence: GamePersistence
    private let electionEngine = ElectionEngine()
    private let newsRepository: NewsRepository
    private lazy var cachedNews: [NewsItem] = newsRepository.loadNews()
    private var didStoreRunResult = false

    init(
        mode: StartMode = .newGame,
        party: PlayerParty = PartyCatalog.default,
        playerName: String = PartyCatalog.defaultChancellorName,
        persistence: GamePersistence = GamePersistence(),
        newsRepository: NewsRepository = LocalJSONNewsRepository()
    ) {
        self.persistence = persistence
        self.newsRepository = newsRepository
        switch mode {
        case .newGame:
            self.engine = GameEngine()
            self.engine.startNewGame(party: party, playerName: playerName)
        case .resume:
            if let snapshot = persistence.loadSnapshot() {
                self.engine = GameEngine(snapshot: snapshot)
            } else {
                self.engine = GameEngine()
                self.engine.startNewGame(party: party, playerName: playerName)
            }
        }
        self.state = engine.state
        self.currentEvent = engine.currentEvent
        self.phase = Self.phase(for: engine)
        self.annualHistory = engine.annualHistory
        self.politicalCapital = engine.politicalCapital
        self.coalition = engine.coalition
        self.persona = engine.persona
        self.playerParty = engine.playerParty
        self.playerName = engine.playerName
        self.corruption = engine.corruption
        self.pendingEncounter = engine.pendingEncounter
        self.cabinet = engine.cabinet
        self.pendingCoalitionOptions = engine.pendingCoalitionOptions
        self.pendingCoalitionTalks = engine.pendingCoalitionTalks
        self.isFormingInitialGovernment = engine.awaitingInitialCoalition
        self.policies = engine.policies
        self.debt = engine.debt
        self.interestGroups = engine.interestGroups
        self.partyWings = engine.partyWings
        self.hasBundesratMajority = engine.hasBundesratMajority
        self.diplomacy = engine.diplomacy
        autosave()
    }

    /// Kapitalkosten einer Option (inkl. Persona-Rabatt).
    func cost(of option: DecisionOption) -> Int {
        engine.effectiveCost(of: option)
    }

    /// Ob der Spieler diese Option aktuell wählen kann.
    func canAfford(_ option: DecisionOption) -> Bool {
        guard let options = currentEvent?.options else { return true }
        return engine.canAfford(option, among: options)
    }

    func choose(_ option: DecisionOption) {
        do {
            let result = try engine.choose(option: option)
            syncFromEngine()
            phase = .result(result)
            autosave()
        } catch {
            syncFromEngine()
            phase = Self.phase(for: engine)
            autosave()
        }
    }

    func continueAfterResult() {
        engine.advanceGame()
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func runCampaign(_ focus: CampaignFocus) {
        engine.runCampaign(focus: focus)
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func continueAfterElection() {
        engine.continueAfterElection()
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func continueWithoutEvent() {
        engine.advanceGame()
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func startNewGame() {
        didStoreRunResult = false
        newlyUnlockedAchievements = []
        engine.startNewGame(party: playerParty, playerName: playerName)
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func saveNow() {
        autosave()
    }

    // MARK: Presse & Wahlprognose

    /// Live-Wahlprognose ("Sonntagsfrage") für das Wahlbarometer.
    var electionProjection: ElectionProjection {
        electionEngine.project(in: state)
    }

    /// Historische Welt-/Deutschland-Schlagzeilen des aktuellen Jahres.
    var worldNews: [NewsItem] {
        cachedNews.filter { $0.year == state.currentYear }
    }

    /// Reaktive Schlagzeilen zur Politik des Spielers.
    var domesticNews: [NewsItem] {
        var items = DynamicNewsFactory.make(for: state, corruption: corruption)
        if state.governmentApproval <= 46, let opponent = partyLandscape.strongestOpposition {
            let leader = PartyPresentation.leader(for: opponent.id)
            items.insert(
                NewsItem(
                    id: "opp-attack-\(state.currentYear)-\(state.governmentApproval)",
                    year: state.currentYear,
                    scope: .domestic,
                    category: .society,
                    headline: "Oppositionsführer \(leader) attackiert die Regierung",
                    summary: "\(opponent.name) wirft der Regierung Versagen vor und fordert einen Kurswechsel.",
                    source: "Bundestag"
                ),
                at: 0
            )
        }
        return items
    }

    private func syncFromEngine() {
        state = engine.state
        currentEvent = engine.currentEvent
        annualHistory = engine.annualHistory
        politicalCapital = engine.politicalCapital
        coalition = engine.coalition
        playerParty = engine.playerParty
        playerName = engine.playerName
        corruption = engine.corruption
        pendingEncounter = engine.pendingEncounter
        cabinet = engine.cabinet
        pendingCoalitionOptions = engine.pendingCoalitionOptions
        pendingCoalitionTalks = engine.pendingCoalitionTalks
        isFormingInitialGovernment = engine.awaitingInitialCoalition
        policies = engine.policies
        debt = engine.debt
        interestGroups = engine.interestGroups
        partyWings = engine.partyWings
        hasBundesratMajority = engine.hasBundesratMajority
        diplomacy = engine.diplomacy
    }

    @discardableResult
    func takeDiplomaticAction(_ partner: DiplomaticPartner, _ actionID: String) -> Bool {
        let ok = engine.takeDiplomaticAction(partner, actionID: actionID)
        syncFromEngine()
        autosave()
        return ok
    }

    @discardableResult
    func attemptPolicyChange(_ policy: PolicyID, to level: Int) -> PolicyVoteResult {
        let result = engine.attemptPolicyChange(policy, to: level)
        syncFromEngine()
        autosave()
        return result
    }

    func resolveEncounter(_ optionID: String) {
        engine.resolveEncounter(optionID: optionID)
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func formCoalition(_ optionID: String) {
        engine.formCoalition(optionID: optionID)
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func dismissBriefing() {
        engine.dismissInitialBriefing()
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func concludeCoalitionTalks(accepted: Set<String>) {
        engine.concludeCoalitionTalks(acceptedDemandIDs: accepted)
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func reshuffleMinister(_ ministry: Ministry) {
        engine.reshuffleMinister(ministry)
        syncFromEngine()
        autosave()
    }

    private func autosave() {
        if let summary = engine.state.gameOverSummary {
            storeRunResultIfNeeded(summary)
            try? persistence.deleteSnapshot()
        } else {
            try? persistence.saveSnapshot(engine.snapshot())
        }
    }

    private func storeRunResultIfNeeded(_ summary: GameOverSummary) {
        guard !didStoreRunResult else { return }
        didStoreRunResult = true
        try? persistence.appendRunResult(
            RunResult(
                startYear: summary.startYear,
                endYear: summary.endYear,
                endReason: summary.reason,
                score: summary.score,
                governingStyle: summary.governingStyle
            )
        )
        let satisfied = AchievementCatalog.satisfiedIDs(summary: summary)
        if let newIDs = try? persistence.unlockAchievements(satisfied) {
            newlyUnlockedAchievements = newIDs.compactMap { AchievementCatalog.achievement(id: $0) }
        }
    }

    private static func phase(for engine: GameEngine) -> Phase {
        if let summary = engine.state.gameOverSummary {
            return .gameOver(summary)
        }

        if let election = engine.state.pendingElectionResult {
            return .election(election)
        }

        if engine.awaitingInitialBriefing {
            return .briefing
        }

        if let options = engine.pendingCoalitionOptions, !options.isEmpty {
            return .coalitionTalks
        }

        if engine.pendingCoalitionTalks != nil {
            return .coalitionNegotiation
        }

        if engine.pendingCampaign {
            return .campaign
        }

        if engine.pendingEncounter != nil {
            return .encounter
        }

        if let result = engine.lastDecisionResult {
            return .result(result)
        }

        return engine.currentEvent == nil ? .noEvent : .event
    }
}

#if DEBUG
extension GameViewModel {
    func debugJumpForwardOneYear() {
        engine.debugJumpToYear(state.currentYear + 1)
        syncFromEngine()
        phase = Self.phase(for: engine)
        autosave()
    }

    func debugBoostEconomy() {
        engine.debugAdjustVisibleMetric(.economy, by: 5)
        syncFromEngine()
        autosave()
    }

    func debugReduceTrust() {
        engine.debugAdjustVisibleMetric(.trust, by: -5)
        syncFromEngine()
        autosave()
    }

    func debugTriggerCurrentYearFirstEvent() {
        if let eventID = LocalJSONEventRepository().events(for: state.currentYear).first?.id {
            engine.debugTriggerEvent(id: eventID)
            syncFromEngine()
            phase = Self.phase(for: engine)
            autosave()
        }
    }

    func debugRunBalanceSimulation() {
        let summary = GameBalanceSimulator().runAllStrategies()
        balanceSummaryText = summary.runs
            .map { report in
                "\(report.strategy.rawValue): Jahr \(report.reachedYear), Score \(report.score), Approval \(report.finalApproval)"
            }
            .joined(separator: "\n")
    }
}
#endif
