import Foundation

/// Momentaufnahme der Wahlprognose ("Sonntagsfrage") ohne echte Wahl.
public struct ElectionProjection: Equatable, Sendable {
    public let governingShare: Double
    public let oppositionShare: Double
    public let wouldWin: Bool
    public let nextElectionYear: Int?

    public init(governingShare: Double, oppositionShare: Double, wouldWin: Bool, nextElectionYear: Int?) {
        self.governingShare = governingShare
        self.oppositionShare = oppositionShare
        self.wouldWin = wouldWin
        self.nextElectionYear = nextElectionYear
    }
}

public struct ElectionEngine: Sendable {
    public let electionYears: Set<Int>

    public init(electionYears: Set<Int> = [2005, 2009, 2013, 2017, 2021, 2025]) {
        self.electionYears = electionYears
    }

    public func shouldHoldElection(in state: GameState) -> Bool {
        electionYears.contains(state.currentYear) &&
            !state.yearProgress.isElectionResolved &&
            state.pendingElectionResult == nil
    }

    /// Das nächste Wahljahr ab (inkl.) dem angegebenen Jahr.
    public func nextElectionYear(onOrAfter year: Int) -> Int? {
        electionYears.filter { $0 >= year }.min()
    }

    /// Live-Prognose ohne den Zustand zu verändern – Grundlage des Wahlbarometers.
    public func project(in state: GameState, shareBonus: Double = 0) -> ElectionProjection {
        let shares = computeShares(in: state, campaignBonus: shareBonus)
        return ElectionProjection(
            governingShare: roundedShare(shares.governing),
            oppositionShare: roundedShare(shares.opposition),
            wouldWin: didWin(governing: shares.governing, opposition: shares.opposition),
            nextElectionYear: nextElectionYear(onOrAfter: state.currentYear)
        )
    }

    public func conductElection(in state: GameState, campaignBonus: Double = 0, shareBonus: Double = 0) -> ElectionResult {
        let shares = computeShares(in: state, campaignBonus: campaignBonus + shareBonus)
        return ElectionResult(
            year: state.currentYear,
            governingPartyShare: roundedShare(shares.governing),
            oppositionShare: roundedShare(shares.opposition),
            didWin: didWin(governing: shares.governing, opposition: shares.opposition),
            reasons: reasons(for: state, governingShare: shares.governing)
        )
    }

    /// Berechnet die (ungerundeten) Stimmenanteile. Von Wahl und Prognose geteilt.
    private func computeShares(in state: GameState, campaignBonus: Double = 0) -> (governing: Double, opposition: Double) {
        let fundamentals = Double(
            state.visible.economy +
            state.visible.livingStandard +
            state.visible.trust +
            state.visible.society
        ) / 4.0

        let memoryPenalty = state.decisionMemory.reduce(0.0) { partialResult, record in
            let negativeImpact = min(0, record.impact.immediateApproval)
            return partialResult + (Double(negativeImpact) * record.currentWeight * 0.25)
        }

        let deterministicNoise = Double(((state.currentYear * 17) % 7) - 3) * 0.35
        let rawShare = 18.0 +
            (Double(state.governmentApproval) * 0.31) +
            (fundamentals * 0.11) +
            (Double(state.shortTermMomentum) * 0.08) +
            memoryPenalty +
            deterministicNoise +
            campaignBonus
        let governingShare = min(52.0, max(24.0, rawShare))
        let oppositionShare = min(55.0, max(25.0, 61.0 - governingShare + max(0.0, 50.0 - Double(state.trustAdjustedApproval())) * 0.04))
        return (governingShare, oppositionShare)
    }

    private func didWin(governing: Double, opposition: Double) -> Bool {
        governing >= 35.0 && governing >= opposition - 1.0
    }

    public func makeGameOverSummary(for state: GameState, electionResult: ElectionResult) -> GameOverSummary {
        GameOverSummary(
            reason: .lostElection,
            message: "Deine Regierung wurde abgewählt.",
            startYear: 2000,
            endYear: electionResult.year,
            keyDecisionTitles: state.decisions.suffix(5).map(\.optionTitle),
            finalStats: state.visible,
            defeatReasons: electionResult.reasons,
            governingStyle: governingStyle(for: state),
            score: score(for: state),
            wonElectionCount: state.electionResults.filter(\.didWin).count,
            biggestSuccess: biggestSuccess(for: state),
            biggestMistake: biggestMistake(for: state),
            biggestButterflyEffect: biggestButterflyEffect(for: state),
            strongestHistoricalDeviation: strongestDeviation(for: state)
        )
    }

    public func endSummary(for state: GameState, reason: GameOverReason, messageOverride: String? = nil) -> GameOverSummary {
        GameOverSummary(
            reason: reason,
            message: messageOverride ?? (reason == .reachedFinalYear ? "Dein Deutschland 2026 ist erreicht." : "Deine Regierung wurde abgewählt."),
            startYear: 2000,
            endYear: state.currentYear,
            keyDecisionTitles: state.decisions.suffix(5).map(\.optionTitle),
            finalStats: state.visible,
            defeatReasons: [],
            governingStyle: governingStyle(for: state),
            score: score(for: state),
            wonElectionCount: state.electionResults.filter(\.didWin).count,
            biggestSuccess: biggestSuccess(for: state),
            biggestMistake: biggestMistake(for: state),
            biggestButterflyEffect: biggestButterflyEffect(for: state),
            strongestHistoricalDeviation: strongestDeviation(for: state)
        )
    }

    public func governingStyle(for state: GameState) -> String {
        if state.hidden.renewableCapacity >= 45 && state.hidden.euRelations >= 68 {
            return "Modernisierer mit europäischem Kurs"
        }

        if state.hidden.fiscalSpace >= 55 && state.visible.budget >= 55 {
            return "Haushaltspolitischer Stabilitätskurs"
        }

        if state.hidden.nuclearCapacity >= 55 {
            return "Industrieorientierter Energiepragmatiker"
        }

        if state.visible.society < 45 || state.hidden.polarization > 58 {
            return "Konfliktgetriebene Krisenregierung"
        }

        return "Ausgleichender Regierungsstil"
    }

    private func reasons(for state: GameState, governingShare: Double) -> [String] {
        var reasons: [String] = []

        if state.governmentApproval < 45 { reasons.append("zu niedrige Regierungszustimmung") }
        if state.visible.economy < 48 { reasons.append("schwache Wirtschaftslage") }
        if state.visible.livingStandard < 50 { reasons.append("sinkender Lebensstandard") }
        if state.visible.trust < 45 { reasons.append("Vertrauensverlust") }
        if state.visible.society < 48 { reasons.append("gesellschaftliche Spannungen") }
        if governingShare < 35 { reasons.append("zu schwaches Wahlergebnis") }

        return reasons.isEmpty ? ["knappe Wechselstimmung"] : reasons
    }

    private func roundedShare(_ value: Double) -> Double {
        (value * 10).rounded() / 10
    }

    private func score(for state: GameState) -> Int {
        let visibleAverage = VisibleMetric.allCases
            .map { state.visible.value(for: $0) }
            .reduce(0, +) / VisibleMetric.allCases.count
        let yearsSurvived = max(0, state.currentYear - 2000)
        return max(0, (visibleAverage * 8) + (yearsSurvived * 20) + (state.electionResults.filter(\.didWin).count * 90))
    }

    private func biggestSuccess(for state: GameState) -> String {
        let pairs: [(String, Int)] = [
            ("Wirtschaft", state.visible.economy),
            ("Lebensstandard", state.visible.livingStandard),
            ("Energie", state.visible.energy),
            ("Internationale Beziehungen", state.visible.internationalRelations),
            ("Vertrauen", state.visible.trust)
        ]
        return pairs.max(by: { $0.1 < $1.1 })?.0 ?? "Stabilität"
    }

    private func biggestMistake(for state: GameState) -> String {
        let pairs: [(String, Int)] = [
            ("Haushalt", state.visible.budget),
            ("Gesellschaft", state.visible.society),
            ("Sicherheit", state.visible.security),
            ("Energie", state.visible.energy),
            ("Vertrauen", state.visible.trust)
        ]
        return pairs.min(by: { $0.1 < $1.1 })?.0 ?? "keine eindeutige Schwachstelle"
    }

    private func biggestButterflyEffect(for state: GameState) -> String {
        if state.hidden.renewableCapacity >= 60 {
            return "Fruehe Energieentscheidungen veraendern die Krisenfestigkeit deutlich."
        }
        if state.hidden.digitalization >= 60 {
            return "Digitale Verwaltung verbessert Staat und Wirtschaft langfristig."
        }
        if state.hidden.polarization >= 65 {
            return "Fruehe Konflikte verhaerten die politische Landschaft."
        }
        return "Viele Entscheidungen stabilisieren sich ohne extremen Ausschlag."
    }

    private func strongestDeviation(for state: GameState) -> String {
        let historicalChoices = state.decisions.filter { decision in
            decision.optionID.contains("historical") || decision.optionID.contains("status-quo")
        }.count
        if state.decisions.count > 0, historicalChoices < state.decisions.count / 3 {
            return "Dein Kurs weicht stark von bekannten historischen Pfaden ab."
        }
        return "Dein Kurs bleibt in Teilen nah an historischen Kompromissen."
    }
}

private extension GameState {
    func trustAdjustedApproval() -> Int {
        (governmentApproval + visible.trust) / 2
    }
}
