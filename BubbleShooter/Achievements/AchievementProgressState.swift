//
//  AchievementProgressState.swift
//  BubbleShooter
//

import Foundation

struct AchievementProgressState: Equatable, Sendable {

    var matchesPlayed: Int
    var bubblesPopped: Int
    var boardClears: Int
    var bestScore: Int
    var bestDropsInMatch: Int
    var cosmeticsPurchased: Int
    var claimed: Set<AchievementID>

    static let initial = AchievementProgressState(
        matchesPlayed: 0,
        bubblesPopped: 0,
        boardClears: 0,
        bestScore: 0,
        bestDropsInMatch: 0,
        cosmeticsPurchased: 0,
        claimed: []
    )

    func isClaimed(_ id: AchievementID) -> Bool {
        claimed.contains(id)
    }

    mutating func markClaimed(_ id: AchievementID) {
        claimed.insert(id)
    }

    func merged(withRemote remote: AchievementProgressState) -> AchievementProgressState {
        AchievementProgressState(
            matchesPlayed: max(matchesPlayed, remote.matchesPlayed),
            bubblesPopped: max(bubblesPopped, remote.bubblesPopped),
            boardClears: max(boardClears, remote.boardClears),
            bestScore: max(bestScore, remote.bestScore),
            bestDropsInMatch: max(bestDropsInMatch, remote.bestDropsInMatch),
            cosmeticsPurchased: max(cosmeticsPurchased, remote.cosmeticsPurchased),
            claimed: claimed.union(remote.claimed)
        )
    }

    static func fromProgressionDictionary(_ dictionary: [AnyHashable: Any]) -> AchievementProgressState {
        var claimed = Set<AchievementID>()
        for id in AchievementID.allCases {
            if ProgressionValueParser.bool(from: dictionary[AchievementKeys.claimedKey(for: id)]) {
                claimed.insert(id)
            }
        }

        return AchievementProgressState(
            matchesPlayed: ProgressionValueParser.int(
                from: dictionary[AchievementKeys.statMatchesPlayed]
            ) ?? 0,
            bubblesPopped: ProgressionValueParser.int(
                from: dictionary[AchievementKeys.statBubblesPopped]
            ) ?? 0,
            boardClears: ProgressionValueParser.int(
                from: dictionary[AchievementKeys.statBoardClears]
            ) ?? 0,
            bestScore: ProgressionValueParser.int(
                from: dictionary[AchievementKeys.statBestScore]
            ) ?? 0,
            bestDropsInMatch: ProgressionValueParser.int(
                from: dictionary[AchievementKeys.statBestDropsInMatch]
            ) ?? 0,
            cosmeticsPurchased: ProgressionValueParser.int(
                from: dictionary[AchievementKeys.statCosmeticsPurchased]
            ) ?? 0,
            claimed: claimed
        )
    }

    func progressionDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [
            AchievementKeys.statMatchesPlayed: matchesPlayed,
            AchievementKeys.statBubblesPopped: bubblesPopped,
            AchievementKeys.statBoardClears: boardClears,
            AchievementKeys.statBestScore: bestScore,
            AchievementKeys.statBestDropsInMatch: bestDropsInMatch,
            AchievementKeys.statCosmeticsPurchased: cosmeticsPurchased,
        ]
        for id in AchievementID.allCases {
            dictionary[AchievementKeys.claimedKey(for: id)] = claimed.contains(id)
        }
        return dictionary
    }
}
