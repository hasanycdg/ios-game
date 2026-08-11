import Foundation

public enum PopulationGroupID: String, Codable, CaseIterable, Sendable {
    case workers
    case retirees
    case families
    case youngAdults
    case entrepreneurs
    case lowIncomeAndUnemployed
    case publicSector
}

public struct PopulationGroup: Codable, Equatable, Identifiable, Sendable {
    public let id: PopulationGroupID
    public let name: String
    public let populationShare: Double
    public var approval: Int

    public init(id: PopulationGroupID, name: String, populationShare: Double, approval: Int) {
        self.id = id
        self.name = name
        self.populationShare = populationShare
        self.approval = VisibleMetrics.clamped(approval)
    }
}

public struct PopulationApprovalEffect: Codable, Equatable, Sendable {
    public let group: PopulationGroupID
    public let change: Int

    public init(group: PopulationGroupID, change: Int) {
        self.group = group
        self.change = change
    }
}

public enum PopulationGroupsFactory {
    public static func initialGermany2000() -> [PopulationGroup] {
        [
            PopulationGroup(id: .workers, name: "Arbeitnehmer", populationShare: 0.27, approval: 53),
            PopulationGroup(id: .retirees, name: "Rentner", populationShare: 0.20, approval: 55),
            PopulationGroup(id: .families, name: "Familien", populationShare: 0.18, approval: 52),
            PopulationGroup(id: .youngAdults, name: "Junge Erwachsene", populationShare: 0.11, approval: 48),
            PopulationGroup(id: .entrepreneurs, name: "Unternehmer/Selbststaendige", populationShare: 0.09, approval: 49),
            PopulationGroup(id: .lowIncomeAndUnemployed, name: "Geringverdiener/Arbeitslose", populationShare: 0.10, approval: 50),
            PopulationGroup(id: .publicSector, name: "Oeffentlicher Dienst", populationShare: 0.05, approval: 54)
        ]
    }
}
