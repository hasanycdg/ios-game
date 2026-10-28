import Foundation

/// A deliberately simplified alternate-history electoral model, not a forecast.
/// The national vote swings fictional state margins; census-era allocations
/// determine the electoral count. Maine and Nebraska are modeled statewide.
public enum USElectoralCollege {
    private static let states: [(String, Int, Double)] = [
        ("AL",9,15),("AK",3,12),("AZ",11,3),("AR",6,14),("CA",54,-18),
        ("CO",10,-5),("CT",7,-12),("DE",3,-10),("DC",3,-35),("FL",30,2),
        ("GA",16,2),("HI",4,-20),("ID",4,22),("IL",19,-12),("IN",11,10),
        ("IA",6,3),("KS",6,13),("KY",8,16),("LA",8,13),("ME",4,-4),
        ("MD",10,-20),("MA",11,-23),("MI",15,-1),("MN",10,-3),("MS",6,13),
        ("MO",10,8),("MT",4,12),("NE",5,17),("NV",6,0),("NH",4,-2),
        ("NJ",14,-10),("NM",5,-5),("NY",28,-17),("NC",16,2),("ND",3,22),
        ("OH",17,4),("OK",7,23),("OR",8,-10),("PA",19,0),("RI",4,-15),
        ("SC",9,10),("SD",3,19),("TN",11,15),("TX",40,7),("UT",6,20),
        ("VT",3,-20),("VA",13,-3),("WA",12,-12),("WV",4,20),("WI",10,0),("WY",3,28)
    ]

    private static let allocations2000 = ["AZ":8,"CA":54,"CO":8,"CT":8,"FL":25,"GA":13,"IL":22,"IN":12,"IA":7,"KS":6,"KY":8,"LA":9,"MD":10,"MA":12,"MI":18,"MN":10,"MS":7,"MO":11,"MT":3,"NV":4,"NJ":15,"NY":33,"NC":14,"OH":21,"OK":8,"OR":7,"PA":23,"SC":8,"TN":11,"TX":32,"UT":5,"VA":13,"WA":11,"WV":5,"WI":11]
    private static let allocations2004 = ["AZ":10,"CA":55,"CO":9,"CT":7,"FL":27,"GA":15,"IL":21,"IN":11,"IA":7,"LA":9,"MA":12,"MI":17,"MN":10,"MS":6,"MO":11,"MT":3,"NV":5,"NJ":15,"NY":31,"NC":15,"OH":20,"OK":7,"OR":7,"PA":21,"SC":8,"TX":34,"UT":5,"WA":11,"WV":5,"WI":10]
    private static let allocations2012 = ["AZ":11,"CA":55,"CO":9,"FL":29,"GA":16,"IL":20,"IA":6,"LA":8,"MA":11,"MI":16,"MO":10,"MT":3,"NV":6,"NJ":14,"NY":29,"NC":15,"OH":18,"OR":7,"PA":20,"SC":9,"TX":38,"UT":6,"WA":12,"WV":5]

    public static func allocations(for year: Int) -> [String: Int] {
        let overrides = year < 2004 ? allocations2000 : year < 2012 ? allocations2004 : year < 2024 ? allocations2012 : [:]
        return Dictionary(uniqueKeysWithValues: states.map { ($0.0, overrides[$0.0] ?? $0.1) })
    }

    public static func votes(popularShare: Double, oppositionShare: Double, year: Int,
                             leaning: PoliticalLeaning) -> Int {
        let allocation = allocations(for: year)
        let swing = popularShare - oppositionShare
        return states.reduce(0) { result, state in
            let tilt = leaning == .conservative ? state.2 : -state.2
            return result + (swing + tilt >= 0 ? allocation[state.0, default: 0] : 0)
        }
    }
}
