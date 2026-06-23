//
//  AchievementKeys.swift
//  BubbleShooter
//

import Foundation

/// Skillz `PlayerData` keys for achievement stats and claim flags.
enum AchievementKeys {

    static let statMatchesPlayed = "ach_stat_matches_played"
    static let statBubblesPopped = "ach_stat_bubbles_popped"
    static let statBoardClears = "ach_stat_board_clears"
    static let statBestScore = "ach_stat_best_score"
    static let statBestDropsInMatch = "ach_stat_best_drops_in_match"
    static let statCosmeticsPurchased = "ach_stat_cosmetics_purchased"

    static func claimedKey(for id: AchievementID) -> String {
        "ach_claimed_\(id.rawValue)"
    }

    static let allKeys: [String] = {
        var keys = [
            statMatchesPlayed,
            statBubblesPopped,
            statBoardClears,
            statBestScore,
            statBestDropsInMatch,
            statCosmeticsPurchased,
        ]
        keys.append(contentsOf: AchievementID.allCases.map { claimedKey(for: $0) })
        return keys
    }()
}
