import Foundation

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

    public func conductElection(in state: GameState) -> ElectionResult {
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
            deterministicNoise
        let governingShare = min(52.0, max(24.0, rawShare))
        let oppositionShare = min(55.0, max(25.0, 61.0 - governingShare + max(0.0, 50.0 - Double(state.trustAdjustedApproval())) * 0.04))
        let didWin = governingShare >= 35.0 && governingShare >= oppositionShare - 1.0

        return ElectionResult(
            year: state.currentYear,
            governingPartyShare: roundedShare(governingShare),
            oppositionShare: roundedShare(oppositionShare),
            didWin: didWin,
            reasons: reasons(for: state, governingShare: governingShare)
        )
    }

    public func makeGameOverSummary(for state: GameState, electionResult: ElectionResult) -> GameOverSummary {
        GameOverSummary(
            reason: .lostElection,
            message: "Deine Regierung wurde abgewaehlt.",
            startYear: 2000,
            endYear: electionResult.year,
            keyDecisionTitles: state.decisions.suffix(5).map(\.optionTitle),
            finalStats: state.visible,
            defeatReasons: electionResult.reasons,
            governingStyle: governingStyle(for: state)
        )
    }

    public func governingStyle(for state: GameState) -> String {
        if state.hidden.renewableCapacity >= 45 && state.hidden.euRelations >= 68 {
            return "Modernisierer mit europaeischem Kurs"
        }

        if state.hidden.fiscalSpace >= 55 && state.visible.budget >= 55 {
            return "Haushaltspolitischer Stabilitaetskurs"
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
}

private extension GameState {
    func trustAdjustedApproval() -> Int {
        (governmentApproval + visible.trust) / 2
    }
}
