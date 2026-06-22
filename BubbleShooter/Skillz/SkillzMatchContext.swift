//
//  SkillzMatchContext.swift
//  BubbleShooter
//

import Foundation

/// Normalized match payload used by gameplay regardless of Skillz SDK presence.
struct SkillzMatchContext: Equatable, Sendable {

    let matchID: UInt64
    let matchSeed: String
    let gameParameters: [String: String]
    let isSynchronous: Bool

    init(
        matchID: UInt64,
        matchSeed: String? = nil,
        gameParameters: [String: String] = [:],
        isSynchronous: Bool = false
    ) {
        self.matchID = matchID
        self.matchSeed = matchSeed ?? String(matchID)
        self.gameParameters = gameParameters
        self.isSynchronous = isSynchronous
    }
}
