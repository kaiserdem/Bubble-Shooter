//
//  AchievementID.swift
//  BubbleShooter
//

import Foundation

enum AchievementID: String, CaseIterable, Sendable {
    case firstSteps
    case regularPlayer
    case bubblePopper
    case boardMaster
    case highScorer
    case dropArtist
    case shopper
    case dedicated
    case veteran
    case perfectionist
    case legend
    case collector
}

enum AchievementTier: Sendable {
    case bronze
    case silver
    case gold
}

enum AchievementReward: Equatable, Sendable {
    case coins(Int)
    case cosmetic(CosmeticShopItem)

    var displayText: String {
        switch self {
        case .coins(let amount):
            "\(amount) coins"
        case .cosmetic(let item):
            item.displayName
        }
    }
}
