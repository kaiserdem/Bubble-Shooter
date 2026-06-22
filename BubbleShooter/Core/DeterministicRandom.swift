//
//  DeterministicRandom.swift
//  BubbleShooter
//

import Foundation
import GameplayKit

/// Deterministic RNG backed by `GKLinearCongruentialRandomSource`.
/// All players with the same `matchSeed` receive identical sequences.
final class DeterministicRandom {

    private let source: GKLinearCongruentialRandomSource

    init(matchSeed: String) {
        let seed = MatchSeedHasher.uint64Seed(from: matchSeed)
        source = GKLinearCongruentialRandomSource(seed: seed)
    }

    init(seed: UInt64) {
        source = GKLinearCongruentialRandomSource(seed: seed == 0 ? 1 : seed)
    }

    /// Returns a value in `[0, upperBound)`.
    func nextInt(upperBound: Int) -> Int {
        guard upperBound > 0 else { return 0 }
        return Int(source.nextInt(upperBound: upperBound))
    }

    /// Returns a value in `[0, 1)`.
    func nextUniform() -> Double {
        Double(source.nextUniform())
    }

    /// Returns a value in `[min, max)`.
    func nextInt(min: Int, max: Int) -> Int {
        guard max > min else { return min }
        return nextInt(upperBound: max - min) + min
    }
}
