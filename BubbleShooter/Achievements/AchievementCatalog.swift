//
//  AchievementCatalog.swift
//  BubbleShooter
//

import Foundation

struct AchievementDefinition: Sendable {

    let id: AchievementID
    let title: String
    let detail: String
    let tier: AchievementTier
    let reward: AchievementReward
    let targetValue: Int

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: .firstSteps,
            title: "First Steps",
            detail: "Finish your first match.",
            tier: .bronze,
            reward: .coins(25),
            targetValue: 1
        ),
        AchievementDefinition(
            id: .regularPlayer,
            title: "Regular Player",
            detail: "Finish 10 matches.",
            tier: .bronze,
            reward: .coins(50),
            targetValue: 10
        ),
        AchievementDefinition(
            id: .bubblePopper,
            title: "Bubble Popper",
            detail: "Pop 250 bubbles across all matches.",
            tier: .bronze,
            reward: .coins(75),
            targetValue: 250
        ),
        AchievementDefinition(
            id: .boardMaster,
            title: "Board Master",
            detail: "Clear the entire board once.",
            tier: .silver,
            reward: .cosmetic(.bubbleShimmer),
            targetValue: 1
        ),
        AchievementDefinition(
            id: .highScorer,
            title: "High Scorer",
            detail: "Score 8,000 points in a single match.",
            tier: .silver,
            reward: .cosmetic(.cannonNebula),
            targetValue: 8_000
        ),
        AchievementDefinition(
            id: .dropArtist,
            title: "Drop Artist",
            detail: "Drop 25 bubbles in one match.",
            tier: .silver,
            reward: .coins(75),
            targetValue: 25
        ),
        AchievementDefinition(
            id: .shopper,
            title: "Shopper",
            detail: "Buy any cosmetic in the Shop.",
            tier: .bronze,
            reward: .coins(50),
            targetValue: 1
        ),
        AchievementDefinition(
            id: .dedicated,
            title: "Dedicated",
            detail: "Finish 50 matches.",
            tier: .silver,
            reward: .coins(150),
            targetValue: 50
        ),
        AchievementDefinition(
            id: .veteran,
            title: "Veteran",
            detail: "Finish 100 matches.",
            tier: .gold,
            reward: .cosmetic(.cannonSolar),
            targetValue: 100
        ),
        AchievementDefinition(
            id: .perfectionist,
            title: "Perfectionist",
            detail: "Clear the board 10 times.",
            tier: .gold,
            reward: .cosmetic(.bubbleRibbon),
            targetValue: 10
        ),
        AchievementDefinition(
            id: .legend,
            title: "Legend",
            detail: "Score 20,000 points in a single match.",
            tier: .gold,
            reward: .cosmetic(.cannonGold),
            targetValue: 20_000
        ),
        AchievementDefinition(
            id: .collector,
            title: "Collector",
            detail: "Own 5 paid cosmetics.",
            tier: .gold,
            reward: .cosmetic(.bubblePlanet),
            targetValue: 5
        ),
    ]

    static func definition(for id: AchievementID) -> AchievementDefinition {
        all.first { $0.id == id }!
    }

    func currentValue(
        progress: AchievementProgressState,
        progression: PlayerProgressionState
    ) -> Int {
        switch id {
        case .firstSteps, .regularPlayer, .dedicated, .veteran:
            progress.matchesPlayed
        case .bubblePopper:
            progress.bubblesPopped
        case .boardMaster, .perfectionist:
            progress.boardClears
        case .highScorer, .legend:
            progress.bestScore
        case .dropArtist:
            progress.bestDropsInMatch
        case .shopper:
            progress.cosmeticsPurchased
        case .collector:
            progression.paidCosmeticsOwnedCount
        }
    }

    func isComplete(
        progress: AchievementProgressState,
        progression: PlayerProgressionState
    ) -> Bool {
        currentValue(progress: progress, progression: progression) >= targetValue
    }

    func progressFraction(
        progress: AchievementProgressState,
        progression: PlayerProgressionState
    ) -> Float {
        guard targetValue > 0 else { return 1 }
        let value = currentValue(progress: progress, progression: progression)
        return min(1, Float(value) / Float(targetValue))
    }

    func progressText(
        progress: AchievementProgressState,
        progression: PlayerProgressionState
    ) -> String {
        let value = currentValue(progress: progress, progression: progression)
        if isComplete(progress: progress, progression: progression) {
            return "Completed"
        }
        switch id {
        case .highScorer, .legend:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let current = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
            let target = formatter.string(from: NSNumber(value: targetValue)) ?? "\(targetValue)"
            return "\(current) / \(target) pts"
        default:
            return "\(min(value, targetValue)) / \(targetValue)"
        }
    }
}

extension PlayerProgressionState {

    var paidCosmeticsOwnedCount: Int {
        CosmeticShopItem.allCases.filter { isOwned($0) }.count
    }
}
