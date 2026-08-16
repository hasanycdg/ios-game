import Foundation

/// Deterministischer, plattformstabiler Zufallsgenerator (SplitMix64).
/// Gleicher Seed → gleiche Folge, damit sich ein Spiel exakt wiederherstellen
/// lässt und Tests reproduzierbar bleiben.
public struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64

    public init(seed: UInt64) {
        // Seed 0 würde eine degenerierte Folge geben – auf eine Konstante heben.
        self.state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
    }

    public mutating func next() -> UInt64 {
        state = state &+ 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
