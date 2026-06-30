//
//  AchievementRewardArt.swift
//  BubbleShooter
//

import Foundation

/// Maps achievements to cut-out Shop reward artwork (coins & gifts).
enum AchievementRewardArt {

    static func coinIconName(for definition: AchievementDefinition) -> String {
        guard case .coins(let amount) = definition.reward else {
            return Theme.Asset.Shop.coin1
        }

        switch definition.id {
        case .firstSteps:
            return Theme.Asset.Shop.coin4
        case .regularPlayer:
            return Theme.Asset.Shop.coin5
        default:
            break
        }

        switch definition.tier {
        case .bronze:
            return Theme.Asset.Shop.coin1
        case .silver:
            return amount >= 100 ? Theme.Asset.Shop.coin3 : Theme.Asset.Shop.coin2
        case .gold:
            return Theme.Asset.Shop.coin3
        }
    }

    static func giftIconName(for id: AchievementID) -> String {
        switch id {
        case .boardMaster, .perfectionist, .collector:
            Theme.Asset.Shop.gift2
        case .highScorer, .veteran:
            Theme.Asset.Shop.gift1
        case .legend:
            Theme.Asset.Shop.gift3
        default:
            Theme.Asset.Shop.gift1
        }
    }

    static func previewIconName(for definition: AchievementDefinition) -> String {
        switch definition.reward {
        case .coins:
            coinIconName(for: definition)
        case .cosmetic:
            giftIconName(for: definition.id)
        }
    }
}
