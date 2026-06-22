//
//  MatchSeedHasher.swift
//  BubbleShooter
//

import Foundation

/// Converts a Skillz match seed string into a stable `UInt64` for GameplayKit RNG.
enum MatchSeedHasher {

    static func uint64Seed(from matchSeed: String) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in matchSeed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 0x100000001b3
        }
        return hash == 0 ? 1 : hash
    }
}
