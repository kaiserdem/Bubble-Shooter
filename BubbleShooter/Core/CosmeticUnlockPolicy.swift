//
//  CosmeticUnlockPolicy.swift
//  BubbleShooter
//

import Foundation

/// Which cosmetics are free vs unlocked through the shop.
enum CosmeticUnlockPolicy {

    static func isFree(_ pack: BubbleSkinPack) -> Bool {
        pack == .classic
    }

    static func isFree(_ skin: CannonSkin) -> Bool {
        skin != .gold
    }

    static func isOwned(_ pack: BubbleSkinPack, progression: PlayerProgressionState) -> Bool {
        if isFree(pack) { return true }
        switch pack {
        case .classic: return true
        case .ribbon: return progression.ownedBubbleRibbon
        case .shimmer: return progression.ownedBubbleShimmer
        case .planet: return progression.ownedBubblePlanet
        case .glossy: return progression.ownedBubbleGlossy
        }
    }

    static func isOwned(_ skin: CannonSkin, progression: PlayerProgressionState) -> Bool {
        if isFree(skin) { return true }
        return progression.ownedCannonGold
    }

    static func canEquip(_ pack: BubbleSkinPack) -> Bool {
        isOwned(pack, progression: SkillzProgressionService.shared.state)
    }

    static func canEquip(_ skin: CannonSkin) -> Bool {
        isOwned(skin, progression: SkillzProgressionService.shared.state)
    }

    static func shopItem(for pack: BubbleSkinPack) -> CosmeticShopItem? {
        switch pack {
        case .classic: nil
        case .ribbon: .bubbleRibbon
        case .shimmer: .bubbleShimmer
        case .planet: .bubblePlanet
        case .glossy: .bubbleGlossy
        }
    }

    static func shopItem(for skin: CannonSkin) -> CosmeticShopItem? {
        switch skin {
        case .gold: .cannonGold
        default: nil
        }
    }
}
