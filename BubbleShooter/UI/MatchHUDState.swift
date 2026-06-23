//
//  MatchHUDState.swift
//  BubbleShooter
//

import Foundation

/// Display model for the in-match HUD overlay. Updated by Track A via `GameSceneHUDDelegate`.
struct MatchHUDState: Equatable {

    var score: Int
    var timeRemainingSeconds: Int
    var nextBubble: BubbleColor
    var currentBubble: BubbleColor
    var isDangerActive: Bool
    var canSwap: Bool

    static let preview = MatchHUDState(
        score: 12_450,
        timeRemainingSeconds: 87,
        nextBubble: .aqua,
        currentBubble: .ruby,
        isDangerActive: false,
        canSwap: true
    )
}

/// Display model for the post-match results overlay.
struct MatchResultsState: Equatable {

    var finalScore: Int
    var popPoints: Int
    var dropPoints: Int
    var timeBonus: Int
    var isNewBest: Bool
    var didClearBoard: Bool
    var didLoseOnDanger: Bool

    var poppedBubbleCount: Int {
        popPoints / ScoreCalculator.pointsPerPopBubble
    }

    var droppedBubbleCount: Int {
        dropPoints / ScoreCalculator.pointsPerDropBubble
    }

    static let preview = MatchResultsState(
        finalScore: 18_750,
        popPoints: 12_400,
        dropPoints: 4_200,
        timeBonus: 2_150,
        isNewBest: true,
        didClearBoard: false,
        didLoseOnDanger: false
    )

    static let dangerPreview = MatchResultsState(
        finalScore: 3_200,
        popPoints: 2_800,
        dropPoints: 400,
        timeBonus: 0,
        isNewBest: false,
        didClearBoard: false,
        didLoseOnDanger: true
    )

    static let timeUpPreview = MatchResultsState(
        finalScore: 9_100,
        popPoints: 7_200,
        dropPoints: 900,
        timeBonus: 1_000,
        isNewBest: false,
        didClearBoard: false,
        didLoseOnDanger: false
    )
}
