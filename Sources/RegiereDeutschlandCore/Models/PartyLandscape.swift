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

    /// Baut die Parteienlandschaft aus echten Parteien. Die gewählte Partei des
    /// Spielers erhält den prognostizierten Stimmenanteil; der Koalitionspartner
    /// und die restlichen realen Parteien verteilen sich abhängig von der Lage
    /// (Zustimmung, Wohlstand, Polarisierung, Sicherheit …).
    public static func make(
        state: GameState,
        governingShare: Double,
        coalition: CoalitionState,
        playerParty: PlayerParty = PartyCatalog.default
    ) -> PartyLandscape {
        let player = min(52.0, max(18.0, governingShare))

        // Koalitionspartner (falls keine Minderheitsregierung) an eine echte Partei koppeln.
        let partnerRef: PartyReference? = coalition.isMinority
            ? nil
            : PartyCatalog.landscape.first { $0.name == coalition.partnerName && $0.id != playerParty.id }
        let partnerSupport = partnerRef == nil ? 0.0 : min(15.0, max(4.0, 5.0 + Double(coalition.satisfaction) * 0.08))
        let remaining = max(0.0, 100.0 - player - partnerSupport)

        // Alle übrigen realen Parteien sind Opposition, dynamisch gewichtet.
        let others = PartyCatalog.landscape.filter { $0.id != playerParty.id && $0.id != partnerRef?.id }
        let weights = others.map { (ref: $0, weight: oppositionWeight(for: $0, state: state)) }
        let totalWeight = weights.reduce(0) { $0 + $1.weight }

        var parties: [Party] = [
            Party(id: playerParty.id, name: playerParty.name, shortName: playerParty.shortName,
                  spectrum: playerParty.spectrum, support: round1(player), role: .governing)
        ]
        if let partnerRef {
            parties.append(
                Party(id: partnerRef.id, name: partnerRef.name, shortName: partnerRef.shortName,
                      spectrum: partnerRef.spectrum, support: round1(partnerSupport), role: .coalition)
            )
        }
        for entry in weights {
            let support = totalWeight > 0 ? remaining * (entry.weight / totalWeight) : 0
            parties.append(
                Party(id: entry.ref.id, name: entry.ref.name, shortName: entry.ref.shortName,
                      spectrum: entry.ref.spectrum, support: round1(support), role: .opposition)
            )
        }

        parties.sort { $0.support > $1.support }
        return PartyLandscape(parties: parties)
    }

    /// Dynamisches Gewicht einer Oppositionspartei nach Lage und Grundstärke.
    private static func oppositionWeight(for ref: PartyReference, state: GameState) -> Double {
        let approval = Double(state.governmentApproval)
        let v = state.visible
        let polarization = Double(state.hidden.polarization)
        let base = ref.baseSupport

        switch ref.id {
        case "cdu":
            return base + max(0, 52 - approval) * 0.18 + (v.economy < 45 ? 4 : 0) + (v.security < 45 ? 2 : 0)
        case "spd":
            return base + max(0, 52 - approval) * 0.14 + max(0, 55 - Double(v.livingStandard)) * 0.16
        case "gruene":
            return base + max(0, Double(v.society) - 50) * 0.12 + (v.energy < 45 ? 3 : 0)
        case "fdp":
            return base + max(0, Double(v.economy) - 52) * 0.10 + max(0, Double(v.budget) - 55) * 0.08
        case "linke":
            return base + max(0, 50 - Double(v.livingStandard)) * 0.12 + polarization * 0.05
        case "afd":
            return base + polarization * 0.24 + max(0, 50 - Double(v.trust)) * 0.16
                + max(0, 50 - Double(v.security)) * 0.10 + max(0, Double(state.currentYear - 2013)) * 0.35
        default:
            return base
        }
    }

    private static func round1(_ value: Double) -> Double {
        (value * 10).rounded() / 10
    }
}
