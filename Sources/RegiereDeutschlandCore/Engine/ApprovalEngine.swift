import Foundation

public struct ApprovalEngine: Sendable {
    public init() {}

    public func applyDecisionImpact(_ impact: PublicMemoryImpact, optionApprovalEffect: Int, to state: inout GameState) {
        let groupEffects = impact.groupEffects
        if groupEffects.isEmpty {
            applyGeneralApprovalChange(impact.immediateApproval + optionApprovalEffect, to: &state)
        } else {
            state.applyPopulationEffects(groupEffects)
            if impact.immediateApproval + optionApprovalEffect != 0 {
                applyGeneralApprovalChange(impact.immediateApproval + optionApprovalEffect, to: &state)
            }
        }

        state.shortTermMomentum = min(50, max(-50, state.shortTermMomentum + impact.immediateApproval + optionApprovalEffect))
        recalculateGovernmentApproval(for: &state)
    }

    public func recalculateGovernmentApproval(for state: inout GameState) {
        let weightedGroupApproval = state.populationGroups.reduce(0.0) { partialResult, group in
            partialResult + Double(group.approval) * group.populationShare
        }

        let nationalCondition = Double(
            state.visible.economy +
            state.visible.livingStandard +
            state.visible.society +
            state.visible.security +
            state.visible.trust
        ) / 5.0

        let momentum = Double(state.shortTermMomentum)
        let approval = (weightedGroupApproval * 0.58) + (nationalCondition * 0.34) + (Double(state.visible.trust) * 0.08) + (momentum * 0.18)
        state.governmentApproval = VisibleMetrics.clamped(Int(approval.rounded()))
    }

    public func normalizePopulationApproval(for state: inout GameState) {
        for index in state.populationGroups.indices {
            let approval = state.populationGroups[index].approval
            if approval > 50 {
                state.populationGroups[index].approval -= 1
            } else if approval < 50 {
                state.populationGroups[index].approval += 1
            }
        }

        if state.shortTermMomentum > 0 {
            state.shortTermMomentum -= 1
        } else if state.shortTermMomentum < 0 {
            state.shortTermMomentum += 1
        }

        recalculateGovernmentApproval(for: &state)
    }

    private func applyGeneralApprovalChange(_ change: Int, to state: inout GameState) {
        guard change != 0 else { return }
        for index in state.populationGroups.indices {
            state.populationGroups[index].approval = VisibleMetrics.clamped(state.populationGroups[index].approval + change)
        }
    }
}
