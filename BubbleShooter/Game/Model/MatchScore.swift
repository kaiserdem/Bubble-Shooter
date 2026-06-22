//
//  MatchScore.swift
//  BubbleShooter
//

import Foundation

struct MatchScore: Equatable, Sendable {

    private(set) var popPoints = 0
    private(set) var dropPoints = 0
    private(set) var timeBonusPoints = 0

    var total: Int {
        popPoints + dropPoints + timeBonusPoints
    }

    mutating func addPop(bubbleCount: Int) {
        popPoints += ScoreCalculator.popPoints(forBubbleCount: bubbleCount)
    }

    mutating func addDrop(bubbleCount: Int) {
        dropPoints += ScoreCalculator.dropPoints(forBubbleCount: bubbleCount)
    }

    mutating func setTimeBonus(remainingSeconds: Int, multiplier: Int = 1) {
        timeBonusPoints = ScoreCalculator.timeBonus(
            remainingSeconds: remainingSeconds,
            multiplier: multiplier
        )
    }
}
