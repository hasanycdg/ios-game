import Foundation

public struct AnnualSimulation: Sendable {
    private let approvalEngine: ApprovalEngine
    private let memoryService: DecisionMemoryService

    public init(
        approvalEngine: ApprovalEngine = ApprovalEngine(),
        memoryService: DecisionMemoryService = DecisionMemoryService()
    ) {
        self.approvalEngine = approvalEngine
        self.memoryService = memoryService
    }

    public func applyEndOfYearDevelopment(to state: inout GameState) {
        guard !state.yearProgress.isAnnualSimulationApplied else { return }

        if state.visible.economy >= 62 {
            state.apply(GameEffect(metric: .economy, change: 1))
            state.apply(GameEffect(metric: .livingStandard, change: 1))
        } else if state.visible.economy <= 42 {
            state.apply(GameEffect(metric: .budget, change: -1))
            state.apply(GameEffect(metric: .livingStandard, change: -1))
        }

        if state.hidden.polarization >= 52 {
            state.apply(GameEffect(metric: .society, change: -1))
            state.apply(GameEffect(metric: .trust, change: -1))
        }

        if state.hidden.digitalization >= 55 && state.hidden.infrastructureQuality >= 55 {
            state.apply(GameEffect(metric: .economy, change: 1))
        }

        if state.hidden.welfareStrength >= 65 {
            state.apply(GameEffect(metric: .livingStandard, change: 1))
        }

        memoryService.decayMemory(in: &state)
        approvalEngine.normalizePopulationApproval(for: &state)
        state.yearProgress.isAnnualSimulationApplied = true
        state.clampAll()
    }
}
