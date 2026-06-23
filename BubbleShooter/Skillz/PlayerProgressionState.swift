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
    var ownedCannonNebula: Bool
    var ownedCannonSolar: Bool
    var ownedCannonEmerald: Bool
    var ownedCannonRuby: Bool
    var ownedCannonAurora: Bool
    var ownedCannonCrystal: Bool
    var ownedCannonCopper: Bool

    static let initial = PlayerProgressionState(
        softCurrency: startingCoins,
        ownedBubbleRibbon: false,
        ownedBubbleShimmer: false,
        ownedBubblePlanet: false,
        ownedBubbleGlossy: false,
        ownedCannonGold: false,
        ownedCannonNebula: false,
        ownedCannonSolar: false,
        ownedCannonEmerald: false,
        ownedCannonRuby: false,
        ownedCannonAurora: false,
        ownedCannonCrystal: false,
        ownedCannonCopper: false
    )

    func isOwned(_ item: CosmeticShopItem) -> Bool {
        switch item {
        case .bubbleRibbon: ownedBubbleRibbon
        case .bubbleShimmer: ownedBubbleShimmer
        case .bubblePlanet: ownedBubblePlanet
        case .bubbleGlossy: ownedBubbleGlossy
        case .cannonGold: ownedCannonGold
        case .cannonNebula: ownedCannonNebula
        case .cannonSolar: ownedCannonSolar
        case .cannonEmerald: ownedCannonEmerald
        case .cannonRuby: ownedCannonRuby
        case .cannonAurora: ownedCannonAurora
        case .cannonCrystal: ownedCannonCrystal
        case .cannonCopper: ownedCannonCopper
        }
    }

    func isOwned(_ skin: CannonSkin) -> Bool {
        switch skin {
        case .standard: true
        case .gold: ownedCannonGold
        case .nebula: ownedCannonNebula
        case .solar: ownedCannonSolar
        case .emerald: ownedCannonEmerald
        case .ruby: ownedCannonRuby
        case .aurora: ownedCannonAurora
        case .crystal: ownedCannonCrystal
        case .copper: ownedCannonCopper
        }
    }

    mutating func applyPurchase(_ item: CosmeticShopItem) {
        switch item {
        case .bubbleRibbon: ownedBubbleRibbon = true
        case .bubbleShimmer: ownedBubbleShimmer = true
        case .bubblePlanet: ownedBubblePlanet = true
        case .bubbleGlossy: ownedBubbleGlossy = true
        case .cannonGold: ownedCannonGold = true
        case .cannonNebula: ownedCannonNebula = true
        case .cannonSolar: ownedCannonSolar = true
        case .cannonEmerald: ownedCannonEmerald = true
        case .cannonRuby: ownedCannonRuby = true
        case .cannonAurora: ownedCannonAurora = true
        case .cannonCrystal: ownedCannonCrystal = true
        case .cannonCopper: ownedCannonCopper = true
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
        case .cannonNebula:
            updates[ProgressionKeys.ownedCannonNebula] = true
        case .cannonSolar:
            updates[ProgressionKeys.ownedCannonSolar] = true
        case .cannonEmerald:
            updates[ProgressionKeys.ownedCannonEmerald] = true
        case .cannonRuby:
            updates[ProgressionKeys.ownedCannonRuby] = true
        case .cannonAurora:
            updates[ProgressionKeys.ownedCannonAurora] = true
        case .cannonCrystal:
            updates[ProgressionKeys.ownedCannonCrystal] = true
        case .cannonCopper:
            updates[ProgressionKeys.ownedCannonCopper] = true
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
            ),
            ownedCannonNebula: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedCannonNebula]
            ),
            ownedCannonSolar: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedCannonSolar]
            ),
            ownedCannonEmerald: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedCannonEmerald]
            ),
            ownedCannonRuby: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedCannonRuby]
            ),
            ownedCannonAurora: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedCannonAurora]
            ),
            ownedCannonCrystal: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedCannonCrystal]
            ),
            ownedCannonCopper: ProgressionValueParser.bool(
                from: dictionary[ProgressionKeys.ownedCannonCopper]
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
    case cannonNebula
    case cannonSolar
    case cannonEmerald
    case cannonRuby
    case cannonAurora
    case cannonCrystal
    case cannonCopper

    var displayName: String {
        switch self {
        case .bubbleRibbon: "Ribbon Bubbles"
        case .bubbleShimmer: "Shimmer Bubbles"
        case .bubblePlanet: "Planet Bubbles"
        case .bubbleGlossy: "Glossy Bubbles"
        case .cannonGold: CannonSkin.gold.displayName
        case .cannonNebula: CannonSkin.nebula.displayName
        case .cannonSolar: CannonSkin.solar.displayName
        case .cannonEmerald: CannonSkin.emerald.displayName
        case .cannonRuby: CannonSkin.ruby.displayName
        case .cannonAurora: CannonSkin.aurora.displayName
        case .cannonCrystal: CannonSkin.crystal.displayName
        case .cannonCopper: CannonSkin.copper.displayName
        }
    }

    var price: Int {
        switch self {
        case .bubbleRibbon: 400
        case .bubbleShimmer: 600
        case .bubblePlanet: 500
        case .bubbleGlossy: 750
        case .cannonCopper: 350
        case .cannonEmerald: 400
        case .cannonNebula: 450
        case .cannonSolar: 500
        case .cannonRuby: 550
        case .cannonAurora: 600
        case .cannonCrystal: 700
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
        case .cannonNebula: ProgressionKeys.ownedCannonNebula
        case .cannonSolar: ProgressionKeys.ownedCannonSolar
        case .cannonEmerald: ProgressionKeys.ownedCannonEmerald
        case .cannonRuby: ProgressionKeys.ownedCannonRuby
        case .cannonAurora: ProgressionKeys.ownedCannonAurora
        case .cannonCrystal: ProgressionKeys.ownedCannonCrystal
        case .cannonCopper: ProgressionKeys.ownedCannonCopper
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
        case .cannonNebula:
            [CannonSkin.nebula.spriteName]
        case .cannonSolar:
            [CannonSkin.solar.spriteName]
        case .cannonEmerald:
            [CannonSkin.emerald.spriteName]
        case .cannonRuby:
            [CannonSkin.ruby.spriteName]
        case .cannonAurora:
            [CannonSkin.aurora.spriteName]
        case .cannonCrystal:
            [CannonSkin.crystal.spriteName]
        case .cannonCopper:
            [CannonSkin.copper.spriteName]
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
