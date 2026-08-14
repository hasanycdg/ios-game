import Foundation
import RegiereDeutschlandCore
import SwiftUI

/// Ein Eintrag in der Chronik-Timeline. Rein präsentationsbezogen, aus dem
/// bestehenden Spielzustand abgeleitet.
struct TimelineItem: Identifiable {
    enum Kind {
        case decision
        case echo
        case election(won: Bool)
    }

    let id: String
    let year: Int
    let kind: Kind
    let title: String
    let detail: String

    var icon: String {
        switch kind {
        case .decision: return "checkmark.circle.fill"
        case .echo: return "clock.arrow.circlepath"
        case .election(let won): return won ? "checkmark.seal.fill" : "xmark.seal.fill"
        }
    }

    var color: Color {
        switch kind {
        case .decision: return GameTheme.gold
        case .echo: return GameTheme.purple
        case .election(let won): return won ? GameTheme.green : GameTheme.red
        }
    }
}

extension GameViewModel {

    /// Durchschnitt der acht sichtbaren Werte – der "Regierungsindex".
    var governanceIndex: Int {
        let v = state.visible
        let sum = v.economy + v.budget + v.livingStandard + v.society
            + v.security + v.energy + v.internationalRelations + v.trust
        return Int((Double(sum) / 8.0).rounded())
    }

    /// Nach Bevölkerungsanteil gewichtete Zufriedenheit.
    var weightedPopulationApproval: Int {
        NationMood.weightedApproval(for: state.populationGroups)
    }

    var nationMood: (word: String, color: Color) {
        NationMood.headline(for: state)
    }

    /// Bevölkerungsgruppen, sortiert nach Anteil (absteigend).
    var populationGroupsBySize: [PopulationGroup] {
        state.populationGroups.sorted { $0.populationShare > $1.populationShare }
    }

    var happiestGroup: PopulationGroup? {
        state.populationGroups.max { $0.approval < $1.approval }
    }

    var unhappiestGroup: PopulationGroup? {
        state.populationGroups.min { $0.approval < $1.approval }
    }

    /// Chronologische Timeline aus Entscheidungen, historischen Echos und Wahlen.
    var timeline: [TimelineItem] {
        var items: [TimelineItem] = []

        for decision in state.decisions {
            items.append(
                TimelineItem(
                    id: "decision-\(decision.id.uuidString)",
                    year: decision.year,
                    kind: .decision,
                    title: decision.optionTitle,
                    detail: "Entscheidung getroffen"
                )
            )
        }

        for echo in state.triggeredHistoricalEchoes {
            items.append(
                TimelineItem(
                    id: "echo-\(echo.id.uuidString)",
                    year: echo.year,
                    kind: .echo,
                    title: "Echo der Geschichte",
                    detail: echo.note
                )
            )
        }

        for election in state.electionResults {
            items.append(
                TimelineItem(
                    id: "election-\(election.id.uuidString)",
                    year: election.year,
                    kind: .election(won: election.didWin),
                    title: election.didWin ? "Wahl gewonnen" : "Wahl verloren",
                    detail: String(format: "%.1f %% zu %.1f %%", election.governingPartyShare, election.oppositionShare)
                )
            )
        }

        // Neueste zuerst; innerhalb eines Jahres Wahl/Echo vor einfache Entscheidung.
        return items.sorted { lhs, rhs in
            if lhs.year != rhs.year { return lhs.year > rhs.year }
            return sortRank(lhs.kind) < sortRank(rhs.kind)
        }
    }

    private func sortRank(_ kind: TimelineItem.Kind) -> Int {
        switch kind {
        case .election: return 0
        case .echo: return 1
        case .decision: return 2
        }
    }

    var wonElectionsCount: Int {
        state.electionResults.filter { $0.didWin }.count
    }

    /// Die Amtszeit in Jahren seit Spielstart (2000).
    var yearsInOffice: Int {
        max(0, state.currentYear - 2000)
    }

    /// Ob gerade ein bühnenfüllendes Ereignis (Wahlabend/Game Over) läuft.
    var isShowingFullScreenPhase: Bool {
        switch phase {
        case .campaign, .election, .gameOver: return true
        default: return false
        }
    }
}
