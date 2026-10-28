import Foundation

public enum USDiplomacy {
    public static func actions(for partner: DiplomaticPartner) -> [DiplomaticAction] {
        switch partner {
        case .eu:
            return [action("us-eu-summit", "Transatlantic summit", "Coordinate with European allies on trade and security.", 2, 8, .internationalRelations, 2, .euRelations, 4),
                    action("us-eu-trade", "Negotiate a trade framework", "Reduce trade barriers while protecting workers and standards.", 3, 10, .economy, 2, .euRelations, 5)]
        case .canada:
            return [action("us-ca-summit", "Meet the Canadian prime minister", "Strengthen the border, defense, and energy partnership.", 2, 8, .security, 2, .usRelations, 4),
                    action("us-ca-trade", "North American trade talks", "Keep supply chains open across the northern border.", 2, 6, .economy, 3, .usRelations, 3)]
        case .russia:
            return [action("us-ru-arms", "Arms-control talks", "Reduce the risk of nuclear escalation through verification.", 2, 7, .internationalRelations, 2, .russiaRelations, 4),
                    action("us-ru-sanctions", "Coordinate targeted sanctions", "Apply pressure at a cost to trade and diplomatic relations.", 2, -12, .security, 2, .russiaRelations, -8)]
        case .china:
            return [action("us-cn-trade", "Trade and supply-chain talks", "Pursue market access while managing strategic dependence.", 2, 7, .economy, 3, .digitalization, 2),
                    action("us-cn-rights", "Raise human rights concerns", "Defend civil liberties despite diplomatic friction.", 1, -8, .trust, 2, .euRelations, 2)]
        case .usa: return [] // A US administration cannot conduct diplomacy with itself.
        }
    }

    private static func action(_ id: String, _ title: String, _ detail: String, _ cost: Int,
                               _ delta: Int, _ metric: VisibleMetric, _ change: Int,
                               _ hidden: HiddenMetric, _ hiddenChange: Int) -> DiplomaticAction {
        DiplomaticAction(id: id, title: title, detail: detail, cost: cost, relationDelta: delta,
            visible: [.init(metric: metric, change: change)], hidden: [.init(metric: hidden, change: hiddenChange)])
    }
}
