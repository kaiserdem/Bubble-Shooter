//
//  MatchTimer.swift
//  BubbleShooter
//

import Foundation

/// Countdown timer for a Skillz match — driven by fixed `delta` steps from `GameScene.update`.
struct MatchTimer: Equatable, Sendable {

    private(set) var remainingSeconds: Int
    private var accumulated: TimeInterval = 0

    init(durationSeconds: Int) {
        remainingSeconds = max(0, durationSeconds)
    }

    var isExpired: Bool {
        remainingSeconds <= 0
    }

    /// Advances internal clock; returns `true` when at least one whole second elapsed.
    mutating func advance(delta: TimeInterval) -> Bool {
        guard remainingSeconds > 0, delta > 0 else { return false }

        accumulated += delta
        guard accumulated >= 1 else { return false }

        let wholeSeconds = Int(accumulated)
        accumulated -= TimeInterval(wholeSeconds)
        remainingSeconds = max(0, remainingSeconds - wholeSeconds)
        return true
    }
}
