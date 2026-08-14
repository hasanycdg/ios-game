import Foundation

public enum PartyRole: String, Sendable {
    case governing   // die Partei des Spielers
    case coalition   // Koalitionspartner
    case opposition
}

/// Eine Partei in der Umfrage-Landschaft.
public struct Party: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let shortName: String
    public let spectrum: Double   // 0 = links, 1 = rechts
    public let support: Double    // Prozent
    public let role: PartyRole

    public init(id: String, name: String, shortName: String, spectrum: Double, support: Double, role: PartyRole) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.spectrum = spectrum
        self.support = support
        self.role = role
    }

    /// Sitze im 630er-Bundestag (grob).
    public var seats: Int { Int((support / 100 * 630).rounded()) }
}

/// Die aktuelle Parteienlandschaft – aus dem Spielzustand abgeleitet.
public struct PartyLandscape: Sendable {
    public let parties: [Party]

    public init(parties: [Party]) {
        self.parties = parties
    }

    public var governingBloc: Double {
        parties.filter { $0.role != .opposition }.reduce(0) { $0 + $1.support }
    }

    public var oppositionBloc: Double {
        parties.filter { $0.role == .opposition }.reduce(0) { $0 + $1.support }
    }

    public var strongestOpposition: Party? {
        parties.filter { $0.role == .opposition }.max { $0.support < $1.support }
    }
}

public enum PartyLandscapeFactory {

    /// Baut die Parteienlandschaft. Die Regierungspartei erhält den prognostizierten
    /// Stimmenanteil; der Rest verteilt sich auf Partner und Opposition, abhängig
    /// von der Lage (Zustimmung, Wohlstand, Polarisierung, Sicherheit …).
    public static func make(state: GameState, governingShare: Double, coalition: CoalitionState) -> PartyLandscape {
        let approval = Double(state.governmentApproval)
        let v = state.visible
        let polarization = Double(state.hidden.polarization)

        let player = min(52.0, max(20.0, governingShare))
        let partner = min(14.0, max(4.0, 5.0 + Double(coalition.satisfaction) * 0.07))
        let remaining = max(0.0, 100.0 - player - partner)

        let opposition: [(id: String, name: String, short: String, spectrum: Double, weight: Double)] = [
            ("conservatives", "Konservative", "KON", 0.72,
             20 + max(0, 52 - approval) * 0.18 + (v.economy < 45 ? 3 : 0)),
            ("socialdemocrats", "Sozialdemokraten", "SOZ", 0.34,
             16 + max(0, 52 - Double(v.livingStandard)) * 0.16),
            ("greens", "Grüne", "GRÜ", 0.24,
             11 + max(0, Double(v.society) - 50) * 0.10 + (v.energy < 45 ? 2 : 0)),
            ("farright", "Rechtspopulisten", "RPP", 0.90,
             6 + polarization * 0.22 + max(0, 50 - Double(v.trust)) * 0.14 + max(0, 50 - Double(v.security)) * 0.10),
            ("leftists", "Linke", "LNK", 0.08,
             6 + max(0, 50 - Double(v.livingStandard)) * 0.10 + polarization * 0.06)
        ]
        let totalWeight = opposition.reduce(0) { $0 + $1.weight }

        var parties: [Party] = [
            Party(id: "player", name: "Deine Partei", shortName: "REG", spectrum: 0.5,
                  support: round1(player), role: .governing),
            Party(id: "partner", name: coalition.partnerName, shortName: "KOA",
                  spectrum: partnerSpectrum(for: coalition.leaning), support: round1(partner), role: .coalition)
        ]
        for party in opposition {
            let support = totalWeight > 0 ? remaining * (party.weight / totalWeight) : 0
            parties.append(
                Party(id: party.id, name: party.name, shortName: party.short,
                      spectrum: party.spectrum, support: round1(support), role: .opposition)
            )
        }

        parties.sort { $0.support > $1.support }
        return PartyLandscape(parties: parties)
    }

    private static func partnerSpectrum(for leaning: PoliticalLeaning) -> Double {
        switch leaning {
        case .left: 0.30
        case .liberal: 0.66
        case .conservative: 0.74
        }
    }

    private static func round1(_ value: Double) -> Double {
        (value * 10).rounded() / 10
    }
}
