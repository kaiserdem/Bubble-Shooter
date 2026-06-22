//
//  ScoreCalculator.swift
//  BubbleShooter
//

import Foundation

enum ScoreCalculator {

    static let pointsPerPopBubble = 10
    static let pointsPerDropBubble = 10

    static func popPoints(forBubbleCount count: Int) -> Int {
        count * pointsPerPopBubble
    }

    static func dropPoints(forBubbleCount count: Int) -> Int {
        count * pointsPerDropBubble
    }

    /// End-of-match bonus from remaining seconds and Skillz multiplier.
    static func timeBonus(remainingSeconds: Int, multiplier: Int = 1) -> Int {
        max(0, remainingSeconds) * max(1, multiplier)
    }
}
