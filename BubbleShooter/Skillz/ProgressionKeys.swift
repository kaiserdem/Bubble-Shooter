//
//  ProgressionKeys.swift
//  BubbleShooter
//

import Foundation

/// Skillz `PlayerData` namespace keys — create matching keys in Developer Console.
enum ProgressionKeys {

    static let namespacePlayerData = "PlayerData"

    static let softCurrency = "soft_currency"
    static let ownedBubbleRibbon = "owned_bubble_ribbon"
    static let ownedBubbleShimmer = "owned_bubble_shimmer"
    static let ownedBubblePlanet = "owned_bubble_planet"
    static let ownedBubbleGlossy = "owned_bubble_glossy"
    static let ownedCannonGold = "owned_cannon_gold"

    static let allShopKeys: [String] = [
        softCurrency,
        ownedBubbleRibbon,
        ownedBubbleShimmer,
        ownedBubblePlanet,
        ownedBubbleGlossy,
        ownedCannonGold,
    ]
}
