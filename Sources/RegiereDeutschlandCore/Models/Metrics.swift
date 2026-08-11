import Foundation

public enum VisibleMetric: String, Codable, CaseIterable, Sendable {
    case economy
    case budget
    case livingStandard
    case society
    case security
    case energy
    case internationalRelations
    case trust
}

public enum HiddenMetric: String, Codable, CaseIterable, Sendable {
    case renewableCapacity
    case nuclearCapacity
    case russianEnergyDependency
    case defenceReadiness
    case digitalization
    case infrastructureQuality
    case integrationCapacity
    case labourMarketFlexibility
    case welfareStrength
    case healthcareResilience
    case euRelations
    case usRelations
    case russiaRelations
    case polarization
    case fiscalSpace
}

public struct VisibleMetrics: Codable, Equatable, Sendable {
    public var economy: Int
    public var budget: Int
    public var livingStandard: Int
    public var society: Int
    public var security: Int
    public var energy: Int
    public var internationalRelations: Int
    public var trust: Int

    public init(
        economy: Int,
        budget: Int,
        livingStandard: Int,
        society: Int,
        security: Int,
        energy: Int,
        internationalRelations: Int,
        trust: Int
    ) {
        self.economy = economy
        self.budget = budget
        self.livingStandard = livingStandard
        self.society = society
        self.security = security
        self.energy = energy
        self.internationalRelations = internationalRelations
        self.trust = trust
    }

    public func value(for metric: VisibleMetric) -> Int {
        switch metric {
        case .economy: economy
        case .budget: budget
        case .livingStandard: livingStandard
        case .society: society
        case .security: security
        case .energy: energy
        case .internationalRelations: internationalRelations
        case .trust: trust
        }
    }

    mutating func apply(_ change: Int, to metric: VisibleMetric) {
        switch metric {
        case .economy: economy = Self.clamped(economy + change)
        case .budget: budget = Self.clamped(budget + change)
        case .livingStandard: livingStandard = Self.clamped(livingStandard + change)
        case .society: society = Self.clamped(society + change)
        case .security: security = Self.clamped(security + change)
        case .energy: energy = Self.clamped(energy + change)
        case .internationalRelations: internationalRelations = Self.clamped(internationalRelations + change)
        case .trust: trust = Self.clamped(trust + change)
        }
    }

    mutating func clampAll() {
        for metric in VisibleMetric.allCases {
            apply(0, to: metric)
        }
    }

    static func clamped(_ value: Int) -> Int {
        min(100, max(0, value))
    }
}

public struct HiddenMetrics: Codable, Equatable, Sendable {
    public var renewableCapacity: Int
    public var nuclearCapacity: Int
    public var russianEnergyDependency: Int
    public var defenceReadiness: Int
    public var digitalization: Int
    public var infrastructureQuality: Int
    public var integrationCapacity: Int
    public var labourMarketFlexibility: Int
    public var welfareStrength: Int
    public var healthcareResilience: Int
    public var euRelations: Int
    public var usRelations: Int
    public var russiaRelations: Int
    public var polarization: Int
    public var fiscalSpace: Int

    public init(
        renewableCapacity: Int,
        nuclearCapacity: Int,
        russianEnergyDependency: Int,
        defenceReadiness: Int,
        digitalization: Int,
        infrastructureQuality: Int,
        integrationCapacity: Int,
        labourMarketFlexibility: Int,
        welfareStrength: Int,
        healthcareResilience: Int,
        euRelations: Int,
        usRelations: Int,
        russiaRelations: Int,
        polarization: Int,
        fiscalSpace: Int
    ) {
        self.renewableCapacity = renewableCapacity
        self.nuclearCapacity = nuclearCapacity
        self.russianEnergyDependency = russianEnergyDependency
        self.defenceReadiness = defenceReadiness
        self.digitalization = digitalization
        self.infrastructureQuality = infrastructureQuality
        self.integrationCapacity = integrationCapacity
        self.labourMarketFlexibility = labourMarketFlexibility
        self.welfareStrength = welfareStrength
        self.healthcareResilience = healthcareResilience
        self.euRelations = euRelations
        self.usRelations = usRelations
        self.russiaRelations = russiaRelations
        self.polarization = polarization
        self.fiscalSpace = fiscalSpace
    }

    public func value(for metric: HiddenMetric) -> Int {
        switch metric {
        case .renewableCapacity: renewableCapacity
        case .nuclearCapacity: nuclearCapacity
        case .russianEnergyDependency: russianEnergyDependency
        case .defenceReadiness: defenceReadiness
        case .digitalization: digitalization
        case .infrastructureQuality: infrastructureQuality
        case .integrationCapacity: integrationCapacity
        case .labourMarketFlexibility: labourMarketFlexibility
        case .welfareStrength: welfareStrength
        case .healthcareResilience: healthcareResilience
        case .euRelations: euRelations
        case .usRelations: usRelations
        case .russiaRelations: russiaRelations
        case .polarization: polarization
        case .fiscalSpace: fiscalSpace
        }
    }

    mutating func apply(_ change: Int, to metric: HiddenMetric) {
        switch metric {
        case .renewableCapacity: renewableCapacity = VisibleMetrics.clamped(renewableCapacity + change)
        case .nuclearCapacity: nuclearCapacity = VisibleMetrics.clamped(nuclearCapacity + change)
        case .russianEnergyDependency: russianEnergyDependency = VisibleMetrics.clamped(russianEnergyDependency + change)
        case .defenceReadiness: defenceReadiness = VisibleMetrics.clamped(defenceReadiness + change)
        case .digitalization: digitalization = VisibleMetrics.clamped(digitalization + change)
        case .infrastructureQuality: infrastructureQuality = VisibleMetrics.clamped(infrastructureQuality + change)
        case .integrationCapacity: integrationCapacity = VisibleMetrics.clamped(integrationCapacity + change)
        case .labourMarketFlexibility: labourMarketFlexibility = VisibleMetrics.clamped(labourMarketFlexibility + change)
        case .welfareStrength: welfareStrength = VisibleMetrics.clamped(welfareStrength + change)
        case .healthcareResilience: healthcareResilience = VisibleMetrics.clamped(healthcareResilience + change)
        case .euRelations: euRelations = VisibleMetrics.clamped(euRelations + change)
        case .usRelations: usRelations = VisibleMetrics.clamped(usRelations + change)
        case .russiaRelations: russiaRelations = VisibleMetrics.clamped(russiaRelations + change)
        case .polarization: polarization = VisibleMetrics.clamped(polarization + change)
        case .fiscalSpace: fiscalSpace = VisibleMetrics.clamped(fiscalSpace + change)
        }
    }

    mutating func clampAll() {
        for metric in HiddenMetric.allCases {
            apply(0, to: metric)
        }
    }
}
