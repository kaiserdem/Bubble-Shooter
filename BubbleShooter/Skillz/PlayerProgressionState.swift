//
//  PlayerProgressionState.swift
//  BubbleShooter
//

import Foundation

/// Cached shop / unlock state synced from Skillz Progression or local mock storage.
struct PlayerProgressionState: Equatable, Sendable {

    static let matchCoinReward = 50
    static let startingCoins = 100

    var softCurrency: Int
    var ownedBubbleRibbon: Bool
    var ownedBubbleShimmer: Bool
    var ownedBubblePlanet: Bool
    var ownedBubbleGlossy: Bool
    var ownedCannonGold: Bool

    static let initial = PlayerProgressionState(
        softCurrency: startingCoins,
        ownedBubbleRibbon: false,
        ownedBubbleShimmer: false,
        ownedBubblePlanet: false,
        ownedBubbleGlossy: false,
        ownedCannonGold: false
    )

    func isOwned(_ item: CosmeticShopItem) -> Bool {
        switch item {
        case .bubbleRibbon: ownedBubbleRibbon
        case .bubbleShimmer: ownedBubbleShimmer
        case .bubblePlanet: ownedBubblePlanet
        case .bubbleGlossy: ownedBubbleGlossy
        case .cannonGold: ownedCannonGold
        }
    }

    mutating func applyPurchase(_ item: CosmeticShopItem) {
        switch item {
        case .bubbleRibbon: ownedBubbleRibbon = true
        case .bubbleShimmer: ownedBubbleShimmer = true
        case .bubblePlanet: ownedBubblePlanet = true
        case .bubbleGlossy: ownedBubbleGlossy = true
        case .cannonGold: ownedCannonGold = true
        }
        softCurrency = max(0, softCurrency - item.price)
    }

    mutating func grantMatchReward() {
        softCurrency += Self.matchCoinReward
    }

    func progressionUpdates(for item: CosmeticShopItem) -> [String: Any] {
        var updates: [String: Any] = [
            ProgressionKeys.softCurrency: softCurrency,
        ]
        switch item {
        case .bubbleRibbon:
            updates[ProgressionKeys.ownedBubbleRibbon] = true
        case .bubbleShimmer:
            updates[ProgressionKeys.ownedBubbleShimmer] = true
        case .bubblePlanet:
            updates[ProgressionKeys.ownedBubblePlanet] = true
        case .bubbleGlossy:
            updates[ProgressionKeys.ownedBubbleGlossy] = true
        case .cannonGold:
            updates[ProgressionKeys.ownedCannonGold] = true
        }
        return updates
    }

    func matchRewardUpdates() -> [String: Any] {
        [ProgressionKeys.softCurrency: softCurrency]
    }

    static func fromProgressionDictionary(_ dictionary: [AnyHashable: Any]) -> PlayerProgressionState {
        PlayerProgressionState(
            softCurrency: ProgressionValueParser.int(
                from: dictionary[ProgressionKeys.softCurrency]
            ) ?? startingCoins,
            ownedBubbleRibbon: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedBubbleRibbon]
            ),
            ownedBubbleShimmer: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedBubbleShimmer]
            ),
            ownedBubblePlanet: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedBubblePlanet]
            ),
            ownedBubbleGlossy: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedBubbleGlossy]
            ),
            ownedCannonGold: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedCannonGold]
            )
        )
    }
}

enum CosmeticShopItem: CaseIterable, Sendable {
    case bubbleRibbon
    case bubbleShimmer
    case bubblePlanet
    case bubbleGlossy
    case cannonGold

    var displayName: String {
        switch self {
        case .bubbleRibbon: "Ribbon Bubbles"
        case .bubbleShimmer: "Shimmer Bubbles"
        case .bubblePlanet: "Planet Bubbles"
        case .bubbleGlossy: "Glossy Bubbles"
        case .cannonGold: "Gold Cannon"
        }
    }

    var price: Int {
        switch self {
        case .bubbleRibbon: 400
        case .bubbleShimmer: 600
        case .bubblePlanet: 500
        case .bubbleGlossy: 750
        case .cannonGold: 1_000
        }
    }

    var progressionKey: String {
        switch self {
        case .bubbleRibbon: ProgressionKeys.ownedBubbleRibbon
        case .bubbleShimmer: ProgressionKeys.ownedBubbleShimmer
        case .bubblePlanet: ProgressionKeys.ownedBubblePlanet
        case .bubbleGlossy: ProgressionKeys.ownedBubbleGlossy
        case .cannonGold: ProgressionKeys.ownedCannonGold
        }
    }

    var previewImageNames: [String] {
        switch self {
        case .bubbleRibbon:
            BubbleColor.allCases.map { BubbleSkinPack.ribbon.spriteName(for: $0) }
        case .bubbleShimmer:
            BubbleColor.allCases.map { BubbleSkinPack.shimmer.spriteName(for: $0) }
        case .bubblePlanet:
            BubbleColor.allCases.map { BubbleSkinPack.planet.spriteName(for: $0) }
        case .bubbleGlossy:
            BubbleColor.allCases.map { BubbleSkinPack.glossy.spriteName(for: $0) }
        case .cannonGold:
            [CannonSkin.gold.spriteName]
        }
    }
}

enum ProgressionValueParser {

    static func int(from value: Any?) -> Int? {
        switch value {
        case let number as NSNumber:
            return number.intValue
        case let string as String:
            return Int(string)
        case let dictionary as [String: Any]:
            return int(from: dictionary["value"])
        case let dictionary as NSDictionary:
            return int(from: dictionary["value"])
        default:
            return nil
        }
    }

    static func bool(from value: Any?) -> Bool {
        switch value {
        case let number as NSNumber:
            return number.boolValue
        case let string as String:
            return (string as NSString).boolValue
        case let dictionary as [String: Any]:
            return bool(from: dictionary["value"])
        case let dictionary as NSDictionary:
            return bool(from: dictionary["value"])
        default:
            return false
        }
    }
}
