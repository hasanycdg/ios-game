import Foundation

public struct DecisionResult: Codable, Equatable, Sendable {
    public let year: Int
    public let eventTitle: String
    public let optionTitle: String
    public let visibleEffects: [GameEffect]
    public let approvalEffect: Int
    public let resultText: String
    public let historicalReality: String?
    public let didChooseHistoricalPath: Bool

    public init(
        year: Int,
        eventTitle: String,
        optionTitle: String,
        visibleEffects: [GameEffect],
        approvalEffect: Int,
        resultText: String,
        historicalReality: String? = nil,
        didChooseHistoricalPath: Bool = false
    ) {
        self.year = year
        self.eventTitle = eventTitle
        self.optionTitle = optionTitle
        self.visibleEffects = visibleEffects
        self.approvalEffect = approvalEffect
        self.resultText = resultText
        self.historicalReality = historicalReality
        self.didChooseHistoricalPath = didChooseHistoricalPath
    }
}

#if DEBUG
public extension GameEngine {
    func debugAdjustVisibleMetric(_ metric: VisibleMetric, by change: Int) {
        state.apply(GameEffect(metric: metric, change: change))
        state.clampAll()
    }

    func debugAdjustHiddenMetric(_ metric: HiddenMetric, by change: Int) {
        state.apply(HiddenEffect(metric: metric, change: change))
        state.clampAll()
    }

    func debugSetApproval(_ value: Int) {
        state.governmentApproval = VisibleMetrics.clamped(value)
    }

    func debugJumpToYear(_ year: Int) {
        let clampedYear = min(2026, max(2000, year))
        state.currentYear = clampedYear
        state.pendingElectionResult = nil
        state.gameOverSummary = nil
        prepareCurrentYear()
        currentEvent = nextQueuedEvent()
    }

    func debugTriggerEvent(id eventID: String) {
        guard let event = eventRepository.loadEvents().first(where: { $0.id == eventID }) else {
            return
        }
        if state.currentYear != event.year {
            state.currentYear = event.year
            prepareCurrentYear()
        }
        currentEvent = event
        lastDecisionResult = nil
    }
}
#endif

public enum GameEngineError: Error, Equatable {
    case noActiveEvent
    case optionNotFound(String)
}

public final class GameEngine {
    private let eventRepository: EventRepository
    private let finalYear: Int
    private let annualSimulation: AnnualSimulation
    private let approvalEngine: ApprovalEngine
    private let memoryService: DecisionMemoryService
    private let electionEngine: ElectionEngine

    public private(set) var state: GameState
    public private(set) var currentEvent: GameEvent?
    public private(set) var lastDecisionResult: DecisionResult?
    public private(set) var annualHistory: [AnnualRecord] = []
    public private(set) var politicalCapital: Int = 7
    public private(set) var coalition: CoalitionState = .standard()
    public private(set) var persona: KanzlerPersona = PersonaCatalog.default
    public private(set) var pendingCampaign: Bool = false
    public private(set) var corruption: Int = 0
    public private(set) var pendingEncounter: PoliticalEncounter?
    public private(set) var cabinet: Cabinet = .standard()
    public private(set) var pendingCoalitionOptions: [CoalitionOption]?
    public private(set) var policies: PolicyState = .standard()
    public private(set) var debt: Int = 60
    public private(set) var interestGroups: [InterestGroup] = InterestGroupsFactory.standard()
    public private(set) var partyWings: PartyWings = .standard()
    public private(set) var hasBundesratMajority: Bool = true
    public let maxCapital = 10

    public init(
        eventRepository: EventRepository = LocalJSONEventRepository(),
        initialState: GameState = GameStateFactory.initialGermany2000(),
        finalYear: Int = 2026,
        annualSimulation: AnnualSimulation = AnnualSimulation(),
        approvalEngine: ApprovalEngine = ApprovalEngine(),
        memoryService: DecisionMemoryService = DecisionMemoryService(),
        electionEngine: ElectionEngine = ElectionEngine()
    ) {
        self.eventRepository = eventRepository
        self.state = initialState
        self.finalYear = finalYear
        self.annualSimulation = annualSimulation
        self.approvalEngine = approvalEngine
        self.memoryService = memoryService
        self.electionEngine = electionEngine
        self.currentEvent = nil
        self.lastDecisionResult = nil
    }

    public convenience init(
        snapshot: GameSessionSnapshot,
        eventRepository: EventRepository = LocalJSONEventRepository(),
        finalYear: Int = 2026,
        annualSimulation: AnnualSimulation = AnnualSimulation(),
        approvalEngine: ApprovalEngine = ApprovalEngine(),
        memoryService: DecisionMemoryService = DecisionMemoryService(),
        electionEngine: ElectionEngine = ElectionEngine()
    ) {
        self.init(
            eventRepository: eventRepository,
            initialState: snapshot.state,
            finalYear: finalYear,
            annualSimulation: annualSimulation,
            approvalEngine: approvalEngine,
            memoryService: memoryService,
            electionEngine: electionEngine
        )
        if let currentEventID = snapshot.currentEventID {
            self.currentEvent = eventRepository.events(for: snapshot.state.currentYear).first { $0.id == currentEventID }
        }
        self.lastDecisionResult = snapshot.lastDecisionResult
        self.annualHistory = snapshot.annualHistory
        self.politicalCapital = snapshot.politicalCapital ?? 7
        self.coalition = snapshot.coalition ?? .standard()
        self.persona = PersonaCatalog.persona(id: snapshot.personaID ?? PersonaCatalog.default.id)
        self.pendingCampaign = snapshot.pendingCampaign ?? false
        self.corruption = snapshot.corruption ?? 0
        self.pendingEncounter = snapshot.pendingEncounter
        self.cabinet = snapshot.cabinet ?? .standard()
        self.pendingCoalitionOptions = snapshot.pendingCoalitionOptions
        self.policies = snapshot.policies ?? .standard()
        self.debt = snapshot.debt ?? 60
        self.interestGroups = snapshot.interestGroups ?? InterestGroupsFactory.standard()
        self.partyWings = snapshot.partyWings ?? .standard()
        self.hasBundesratMajority = snapshot.hasBundesratMajority ?? true
    }

    public func snapshot() -> GameSessionSnapshot {
        GameSessionSnapshot(
            state: state,
            currentEventID: currentEvent?.id,
            lastDecisionResult: lastDecisionResult,
            annualHistory: annualHistory,
            politicalCapital: politicalCapital,
            coalition: coalition,
            personaID: persona.id,
            pendingCampaign: pendingCampaign,
            corruption: corruption,
            pendingEncounter: pendingEncounter,
            cabinet: cabinet,
            pendingCoalitionOptions: pendingCoalitionOptions,
            policies: policies,
            debt: debt,
            interestGroups: interestGroups,
            partyWings: partyWings,
            hasBundesratMajority: hasBundesratMajority
        )
    }

    public func startNewGame(persona: KanzlerPersona = PersonaCatalog.default) {
        self.persona = persona
        var initial = GameStateFactory.initialGermany2000()
        for effect in persona.visibleModifiers { initial.apply(effect) }
        for effect in persona.hiddenModifiers { initial.apply(effect) }
        initial.clampAll()
        state = initial
        politicalCapital = persona.startingCapital
        coalition = persona.makeCoalition()
        pendingCampaign = false
        corruption = 0
        pendingEncounter = nil
        cabinet = .standard()
        pendingCoalitionOptions = nil
        policies = .standard()
        debt = 60
        interestGroups = InterestGroupsFactory.standard()
        partyWings = .standard()
        hasBundesratMajority = true
        lastDecisionResult = nil
        annualHistory = []
        prepareCurrentYear()
        currentEvent = nextQueuedEvent()
        recordAnnualSnapshot()
    }

    // MARK: Politisches Kapital & Koalition

    /// Effektive Kapitalkosten einer Option (inkl. Persona-Rabatt).
    public func effectiveCost(of option: DecisionOption) -> Int {
        max(1, DecisionCost.cost(of: option) - persona.costReduction)
    }

    /// Ob eine Option bezahlbar ist. Die günstigste Option ist immer wählbar,
    /// damit der Spieler nie handlungsunfähig wird.
    public func canAfford(_ option: DecisionOption, among options: [DecisionOption]) -> Bool {
        let cost = effectiveCost(of: option)
        if politicalCapital >= cost { return true }
        let minCost = options.map { effectiveCost(of: $0) }.min() ?? cost
        return cost == minCost
    }

    private func capitalIncome() -> Int {
        var income = 3 + persona.capitalIncomeBonus
        if state.governmentApproval >= 55 { income += 1 }
        if state.governmentApproval >= 70 { income += 1 }
        if coalition.isMinority { income -= 1 } // Regieren ohne Mehrheit ist zäher
        return max(1, income)
    }

    public func availableEvents() -> [GameEvent] {
        eventRepository
            .events(for: state.currentYear)
            .filter { event in
                !state.yearProgress.completedEventIDs.contains(event.id)
            }
            .filter { $0.isAvailable(in: state) }
    }

    @discardableResult
    public func choose(option optionID: String) throws -> DecisionResult {
        guard let event = currentEvent ?? nextQueuedEvent() else {
            throw GameEngineError.noActiveEvent
        }

        guard let option = event.options.first(where: { $0.id == optionID }) else {
            throw GameEngineError.optionNotFound(optionID)
        }

        var visibleEffects = option.immediateEffects
        var hiddenEffects = option.hiddenEffects
        var approvalEffect = option.approvalEffect
        var flagsToSet = option.flagsToSet

        memoryService.reactivateMemory(tags: event.memoryReactivationTags, in: &state)

        for modifier in option.conditionalModifiers where modifier.isSatisfied(by: state) {
            visibleEffects.append(contentsOf: modifier.immediateEffects)
            hiddenEffects.append(contentsOf: modifier.hiddenEffects)
            approvalEffect += modifier.approvalEffect
            flagsToSet.append(contentsOf: modifier.memoryReactivationTags.map { "reactivated_\($0)" })
            memoryService.reactivateMemory(tags: modifier.memoryReactivationTags, in: &state)
        }

        for effect in visibleEffects {
            state.apply(effect)
        }

        for effect in hiddenEffects {
            state.apply(effect)
        }

        approvalEngine.applyDecisionImpact(option.publicMemoryImpact, optionApprovalEffect: approvalEffect, to: &state)
        state.historicalFlags.formUnion(flagsToSet)
        state.yearProgress.completedEventIDs.insert(event.id)
        state.decisions.append(
            DecisionRecord(
                year: state.currentYear,
                eventID: event.id,
                optionID: option.id,
                optionTitle: option.title
            )
        )
        memoryService.recordDecision(event: event, option: option, in: &state)

        for delayedEffect in option.delayedEffects {
            state.scheduledEffects.append(
                ScheduledEffect(
                    sourceEventID: event.id,
                    sourceOptionID: option.id,
                    dueYear: state.currentYear + delayedEffect.delayInYears,
                    immediateEffects: delayedEffect.immediateEffects,
                    hiddenEffects: delayedEffect.hiddenEffects,
                    approvalEffect: delayedEffect.approvalEffect,
                    flagsToSet: delayedEffect.flagsToSet,
                    note: delayedEffect.note
                )
            )
        }

        if !option.delayedEffects.isEmpty || !option.conditionalModifiers.isEmpty {
            state.activeLongTermEffects.append(
                ActiveLongTermEffect(
                    sourceEventID: event.id,
                    sourceOptionID: option.id,
                    startedYear: state.currentYear,
                    note: "Langfristige Effekte sind fuer spaetere Jahre vorgemerkt."
                )
            )
        }

        politicalCapital = max(0, politicalCapital - effectiveCost(of: option))
        let coalitionDelta = CoalitionDynamics.reaction(to: option, leaning: coalition.leaning, damping: coalition.reactionDamping)
        coalition.satisfaction = VisibleMetrics.clamped(coalition.satisfaction + coalitionDelta)

        state.clampAll()

        let result = DecisionResult(
            year: state.currentYear,
            eventTitle: event.title,
            optionTitle: option.title,
            visibleEffects: visibleEffects,
            approvalEffect: approvalEffect,
            resultText: option.description,
            historicalReality: event.historicalReality,
            didChooseHistoricalPath: event.historicalOptionID == option.id
        )
        lastDecisionResult = result
        currentEvent = nil
        return result
    }

    public func choose(option: DecisionOption) throws -> DecisionResult {
        try choose(option: option.id)
    }

    public func advanceGame() {
        lastDecisionResult = nil
        guard state.gameOverSummary == nil else { return }
        guard state.pendingElectionResult == nil else { return }

        if coalition.isBroken {
            triggerCoalitionCollapse()
            return
        }

        if let nextEvent = nextQueuedEvent() {
            currentEvent = nextEvent
            return
        }

        annualSimulation.applyEndOfYearDevelopment(to: &state)
        applyCabinetInfluence()
        applyPolicyInfluence()
        applyInterestGroupInfluence()
        applyFederalism()
        applyPartyWingInfluence()
        recordAnnualSnapshot()
        applyCorruptionExposure()

        if state.gameOverSummary != nil {
            currentEvent = nil
            return
        }

        if electionEngine.shouldHoldElection(in: state) {
            pendingCampaign = true
            currentEvent = nil
            return
        }

        guard state.currentYear < finalYear else {
            state.gameOverSummary = makeFinalYearSummary()
            currentEvent = nil
            return
        }

        enterYear(state.currentYear + 1)
        currentEvent = nextQueuedEvent()
    }

    /// Wählt einen Wahlkampf-Schwerpunkt und führt danach die Wahl durch.
    public func runCampaign(focus: CampaignFocus) {
        guard pendingCampaign else { return }
        pendingCampaign = false
        let bonus = focus.bonus(for: state)
        let base = electionEngine.conductElection(in: state, campaignBonus: bonus)
        let election = ElectionResult(
            year: base.year,
            governingPartyShare: base.governingPartyShare,
            oppositionShare: base.oppositionShare,
            didWin: base.didWin,
            reasons: ["Wahlkampf-Schwerpunkt: \(focus.title)"] + base.reasons
        )
        state.pendingElectionResult = election
        state.electionResults.append(election)
        state.yearProgress.isElectionResolved = true
        if !election.didWin {
            state.gameOverSummary = electionEngine.makeGameOverSummary(for: state, electionResult: election)
        }
        currentEvent = nil
    }

    public func continueAfterElection() {
        guard let election = state.pendingElectionResult else { return }
        state.pendingElectionResult = nil
        guard election.didWin, state.gameOverSummary == nil else {
            currentEvent = nil
            return
        }

        // Nach dem Sieg: Koalitionsverhandlungen.
        pendingCoalitionOptions = makeCoalitionOptions()
        currentEvent = nil
    }

    /// Wählt eine Koalition nach der Wahl und schaltet dann das Jahr fort.
    public func formCoalition(optionID: String) {
        guard let options = pendingCoalitionOptions,
              let choice = options.first(where: { $0.id == optionID }) else { return }
        pendingCoalitionOptions = nil

        if choice.isMinority {
            coalition = CoalitionState(partnerName: "Minderheitsregierung", leaning: coalition.leaning,
                                       satisfaction: 45, reactionDamping: 0, isMinority: true)
        } else {
            coalition = CoalitionState(partnerName: choice.partyName, leaning: choice.leaning,
                                       satisfaction: 60, reactionDamping: 1.0, isMinority: false)
        }

        guard state.gameOverSummary == nil else { currentEvent = nil; return }
        if state.currentYear >= finalYear {
            state.gameOverSummary = makeFinalYearSummary()
            currentEvent = nil
            return
        }
        enterYear(state.currentYear + 1)
        currentEvent = nextQueuedEvent()
    }

    /// Baut die Koalitionsoptionen aus der aktuellen Parteienlandschaft.
    private func makeCoalitionOptions() -> [CoalitionOption] {
        let projection = electionEngine.project(in: state)
        let landscape = PartyLandscapeFactory.make(state: state, governingShare: projection.governingShare, coalition: coalition)
        let playerShare = landscape.parties.first { $0.role == .governing }?.support ?? 40
        let candidates = landscape.parties
            .filter { $0.role == .opposition }
            .sorted { $0.support > $1.support }
            .prefix(3)

        var options = candidates.map { party -> CoalitionOption in
            let combined = playerShare + party.support
            return CoalitionOption(
                id: party.id,
                partyName: party.name,
                leaning: coalitionLeaning(for: party.id),
                combinedShare: (combined * 10).rounded() / 10,
                formsMajority: combined >= 47,
                isMinority: false
            )
        }
        options.append(
            CoalitionOption(id: "none", partyName: "Minderheitsregierung", leaning: coalition.leaning,
                            combinedShare: (playerShare * 10).rounded() / 10, formsMajority: false, isMinority: true)
        )
        return options
    }

    private func coalitionLeaning(for partyID: String) -> PoliticalLeaning {
        switch partyID {
        case "conservatives", "farright": .conservative
        case "socialdemocrats", "greens", "leftists": .left
        default: .liberal
        }
    }

    // MARK: Gesetze & Haushalt

    /// Aktueller Haushalt aus den Politikfeldern.
    public func budgetSummary() -> BudgetSummary {
        let income = PolicyEngine.fiscal(.taxes, level: policies.level(.taxes))
        let spending = PolicyID.allCases
            .filter { !$0.isRevenue }
            .reduce(0) { $0 + PolicyEngine.fiscal($1, level: policies.level($1)) }
        return BudgetSummary(income: income, spending: spending, debt: debt)
    }

    /// Versucht, ein Politikfeld zu ändern. Die Änderung kostet Kapital und muss
    /// im Parlament (Koalition) eine Mehrheit finden.
    @discardableResult
    public func attemptPolicyChange(_ policy: PolicyID, to newLevel: Int) -> PolicyVoteResult {
        let target = min(PolicyEngine.maxLevel, max(0, newLevel))
        let current = policies.level(policy)
        guard target != current else { return .unchanged }

        let cost = abs(target - current)
        guard politicalCapital >= cost else { return .noCapital }
        politicalCapital -= cost

        let direction = target > current ? 1 : -1
        let alignment = direction * PolicyEngine.leaningPreference(policy, coalition.leaning)
        let voteScore = coalition.satisfaction + alignment * 8

        // Minderheitsregierungen und ein verlorener Bundesrat erschweren Mehrheiten.
        let threshold = (coalition.isMinority ? 52 : 45) + (hasBundesratMajority ? 0 : 7)

        guard voteScore >= threshold else {
            coalition.satisfaction = VisibleMetrics.clamped(coalition.satisfaction - 4)
            return .rejected
        }

        policies.levels[policy.rawValue] = target
        coalition.satisfaction = VisibleMetrics.clamped(coalition.satisfaction + alignment * 2)
        state.applyPopulationEffects(PolicyEngine.groupReaction(policy, delta: target - current))
        state.clampAll()
        return .passed
    }

    /// Interessengruppen driften Richtung Zielzufriedenheit; kippt eine mächtige
    /// Gruppe, folgt eine Protest-/Streik-Aktion.
    private func applyInterestGroupInfluence() {
        for index in interestGroups.indices {
            let group = interestGroups[index]
            let target = InterestGroupsFactory.target(group.id, policies: policies, state: state)
            let step = target > group.satisfaction ? 4 : -4
            interestGroups[index].satisfaction = VisibleMetrics.clamped(
                group.satisfaction + (abs(target - group.satisfaction) < 4 ? (target - group.satisfaction) : step)
            )

            if interestGroups[index].satisfaction <= 18 && group.power >= 2 {
                let action = InterestGroupsFactory.action(group.id)
                for effect in action.visible { state.apply(effect) }
                for effect in action.hidden { state.apply(effect) }
                approvalEngine.applyDecisionImpact(
                    PublicMemoryImpact(immediateApproval: action.approval),
                    optionApprovalEffect: 0, to: &state
                )
                state.triggeredHistoricalEchoes.append(
                    TriggeredHistoricalEcho(year: state.currentYear, sourceEventID: "interest-\(group.id.rawValue)",
                                            sourceOptionID: "action", note: action.note)
                )
                interestGroups[index].satisfaction = VisibleMetrics.clamped(interestGroups[index].satisfaction + 16)
            }
        }
        state.clampAll()
    }

    /// Partei-Flügel driften mit dem politischen Kurs; bricht der Rückhalt weg,
    /// stürzt die eigene Partei die Führung.
    private func applyPartyWingInfluence() {
        let progTarget = PartyWingsDynamics.progressiveTarget(policies: policies)
        let tradTarget = PartyWingsDynamics.traditionalTarget(policies: policies)
        partyWings.progressive = drift(partyWings.progressive, toward: progTarget)
        partyWings.traditional = drift(partyWings.traditional, toward: tradTarget)

        let wingAverage = (partyWings.progressive + partyWings.traditional) / 2
        let backingTarget = VisibleMetrics.clamped(
            Int(Double(wingAverage) * 0.55 + Double(state.governmentApproval) * 0.45) + state.shortTermMomentum / 3
        )
        partyWings.leadershipBacking = drift(partyWings.leadershipBacking, toward: backingTarget)

        if partyWings.leadershipBacking <= PartyWings.ousterPoint {
            state.gameOverSummary = electionEngine.endSummary(
                for: state, reason: .lostElection,
                messageOverride: "Deine eigene Partei hat dich gestürzt."
            )
        }
    }

    /// Landtagswahlen verschieben die Mehrheit im Bundesrat.
    private func applyFederalism() {
        let offset = state.currentYear - 2000
        guard offset > 0, offset % 3 == 0, !electionEngine.electionYears.contains(state.currentYear) else { return }
        let hadMajority = hasBundesratMajority
        hasBundesratMajority = state.governmentApproval >= 48
        let note: String
        if hasBundesratMajority && !hadMajority {
            note = "Landtagswahlen: Die Regierung gewinnt die Mehrheit im Bundesrat zurück."
        } else if !hasBundesratMajority && hadMajority {
            note = "Landtagswahlen: Die Regierung verliert die Mehrheit im Bundesrat – Gesetze werden schwerer."
        } else if hasBundesratMajority {
            note = "Landtagswahlen: Die Regierung behauptet ihre Mehrheit im Bundesrat."
        } else {
            note = "Landtagswahlen: Die Opposition dominiert weiter den Bundesrat."
        }
        state.triggeredHistoricalEchoes.append(
            TriggeredHistoricalEcho(year: state.currentYear, sourceEventID: "landtagswahl",
                                    sourceOptionID: "result", note: note)
        )
    }

    private func drift(_ value: Int, toward target: Int) -> Int {
        let delta = target - value
        if abs(delta) < 4 { return VisibleMetrics.clamped(target) }
        return VisibleMetrics.clamped(value + (delta > 0 ? 4 : -4))
    }

    /// Jährliche Wirkung der Politikfelder auf Werte und Haushalt.
    private func applyPolicyInfluence() {
        for policy in PolicyID.allCases {
            let level = policies.level(policy)
            for effect in PolicyEngine.annualVisible(policy, level: level) { state.apply(effect) }
            for effect in PolicyEngine.annualHidden(policy, level: level) { state.apply(effect) }
        }

        let budget = budgetSummary()
        debt = min(200, max(0, debt + budget.deficit))
        if budget.deficit <= 0 {
            state.apply(GameEffect(metric: .budget, change: 1))
        } else {
            state.apply(GameEffect(metric: .budget, change: budget.deficit > 15 ? -2 : -1))
        }
        if debt > 120 { state.apply(GameEffect(metric: .budget, change: -1)) }
        state.clampAll()
    }

    /// Neubesetzung eines Ressorts – kostet politisches Kapital.
    @discardableResult
    public func reshuffleMinister(_ ministry: Ministry) -> Bool {
        guard politicalCapital >= 2 else { return false }
        politicalCapital -= 2
        let index = Ministry.allCases.firstIndex(of: ministry) ?? 0
        let seed = state.currentYear &* 31 &+ index &* 17 &+ state.decisions.count &* 5
        cabinet.ministers[ministry.rawValue] = MinisterPool.make(seed: seed)
        return true
    }

    /// Starke Ressorts heben ihren Kennwert leicht, überforderte senken ihn.
    private func applyCabinetInfluence() {
        for ministry in Ministry.allCases {
            let competence = cabinet.minister(ministry).competence
            if competence >= 70 {
                state.apply(GameEffect(metric: ministry.metric, change: 1))
            } else if competence <= 35 {
                state.apply(GameEffect(metric: ministry.metric, change: -1))
            }
        }
        state.clampAll()
    }

    private func prepareCurrentYear() {
        state.yearProgress = YearProgress(year: state.currentYear)
        applyScheduledEffectsDueThisYear()
        rebuildEventQueue()
    }

    private func enterYear(_ year: Int) {
        state.currentYear = year
        politicalCapital = min(maxCapital, politicalCapital + capitalIncome())
        prepareCurrentYear()
        maybeScheduleEncounter(for: year)
    }

    /// Legt zu Jahresbeginn ggf. ein Interview oder Lobby-Angebot fest.
    private func maybeScheduleEncounter(for year: Int) {
        guard pendingEncounter == nil, !electionEngine.electionYears.contains(year) else { return }
        let offset = year - 2000
        if offset % 3 == 2 {
            pendingEncounter = LobbyFactory.make(state: state, year: year)
        } else if offset % 2 == 1 {
            pendingEncounter = InterviewFactory.make(state: state, year: year)
        }
    }

    /// Wendet die gewählte Antwort einer Begegnung an.
    public func resolveEncounter(optionID: String) {
        guard let encounter = pendingEncounter,
              let option = encounter.options.first(where: { $0.id == optionID }) else { return }

        for effect in option.visibleEffects { state.apply(effect) }
        if option.polarizationEffect != 0 {
            state.apply(HiddenEffect(metric: .polarization, change: option.polarizationEffect))
        }
        if option.approvalEffect != 0 {
            approvalEngine.applyDecisionImpact(
                PublicMemoryImpact(immediateApproval: option.approvalEffect),
                optionApprovalEffect: 0,
                to: &state
            )
        }
        politicalCapital = min(maxCapital, politicalCapital + option.capitalReward)
        corruption = VisibleMetrics.clamped(corruption + option.corruptionEffect)

        state.decisions.append(
            DecisionRecord(
                year: state.currentYear,
                eventID: encounter.kind.rawValue,
                optionID: option.id,
                optionTitle: option.title
            )
        )
        pendingEncounter = nil
        state.clampAll()
    }

    /// Der Koalitionspartner verlässt die Regierung – es kommt zur Neuwahl.
    private func triggerCoalitionCollapse() {
        let base = electionEngine.conductElection(in: state)
        let election = ElectionResult(
            year: base.year,
            governingPartyShare: base.governingPartyShare,
            oppositionShare: base.oppositionShare,
            didWin: base.didWin,
            reasons: ["Koalitionsbruch – vorgezogene Neuwahl"] + base.reasons
        )
        state.pendingElectionResult = election
        state.electionResults.append(election)
        state.yearProgress.isElectionResolved = true
        if !election.didWin {
            state.gameOverSummary = electionEngine.makeGameOverSummary(for: state, electionResult: election)
        } else {
            coalition.satisfaction = 45
        }
        currentEvent = nil
    }

    private func rebuildEventQueue() {
        let pendingIDs = availableEvents().map(\.id)
        state.eventQueue = EventQueue(year: state.currentYear, pendingEventIDs: pendingIDs)
    }

    private func nextQueuedEvent() -> GameEvent? {
        if state.eventQueue.year != state.currentYear || state.eventQueue.isEmpty {
            rebuildEventQueue()
        }

        while let eventID = state.eventQueue.popNext() {
            guard let event = event(withID: eventID), event.isAvailable(in: state) else {
                continue
            }
            return event
        }

        return nil
    }

    private func event(withID eventID: String) -> GameEvent? {
        eventRepository.events(for: state.currentYear).first { $0.id == eventID }
    }

    private func applyScheduledEffectsDueThisYear() {
        let dueEffects = state.scheduledEffects.filter { $0.dueYear <= state.currentYear }
        guard !dueEffects.isEmpty else { return }

        for scheduledEffect in dueEffects {
            for effect in scheduledEffect.immediateEffects {
                state.apply(effect)
            }
            for effect in scheduledEffect.hiddenEffects {
                state.apply(effect)
            }
            if scheduledEffect.approvalEffect != 0 {
                approvalEngine.applyDecisionImpact(
                    PublicMemoryImpact(immediateApproval: scheduledEffect.approvalEffect),
                    optionApprovalEffect: 0,
                    to: &state
                )
            }
            state.historicalFlags.formUnion(scheduledEffect.flagsToSet)

            if let note = scheduledEffect.note {
                state.triggeredHistoricalEchoes.append(
                    TriggeredHistoricalEcho(
                        year: state.currentYear,
                        sourceEventID: scheduledEffect.sourceEventID,
                        sourceOptionID: scheduledEffect.sourceOptionID,
                        note: note
                    )
                )
            }
        }

        let dueIDs = Set(dueEffects.map(\.id))
        state.scheduledEffects.removeAll { dueIDs.contains($0.id) }
        state.clampAll()
    }

    private func makeFinalYearSummary() -> GameOverSummary {
        electionEngine.endSummary(for: state, reason: .reachedFinalYear)
    }

    /// Prüft am Jahresende, ob ein Korruptionsskandal auffliegt. Je höher die
    /// angehäufte Korruption, desto wahrscheinlicher und heftiger.
    private func applyCorruptionExposure() {
        guard corruption >= 25 else { return }
        let roll = (state.currentYear * 31 + corruption * 7) % 100
        guard roll < (corruption - 10) else { return }

        state.apply(GameEffect(metric: .trust, change: -16))
        state.apply(GameEffect(metric: .society, change: -8))
        state.apply(HiddenEffect(metric: .polarization, change: 10))
        approvalEngine.applyDecisionImpact(
            PublicMemoryImpact(immediateApproval: -14),
            optionApprovalEffect: 0,
            to: &state
        )
        coalition.satisfaction = VisibleMetrics.clamped(coalition.satisfaction - 20)
        corruption = corruption / 3
        state.historicalFlags.insert("corruption_scandal")
        state.triggeredHistoricalEchoes.append(
            TriggeredHistoricalEcho(
                year: state.currentYear,
                sourceEventID: "corruption",
                sourceOptionID: "scandal",
                note: "Korruptionsskandal: Geheime Zahlungen aufgedeckt – Vertrauen und Zustimmung brechen ein."
            )
        )
        state.clampAll()
    }

    /// Speichert bzw. aktualisiert die Jahres-Momentaufnahme für das laufende Jahr.
    private func recordAnnualSnapshot() {
        let record = AnnualRecord(
            year: state.currentYear,
            visible: state.visible,
            approval: state.governmentApproval
        )
        if let index = annualHistory.firstIndex(where: { $0.year == record.year }) {
            annualHistory[index] = record
        } else {
            annualHistory.append(record)
        }
    }
}
