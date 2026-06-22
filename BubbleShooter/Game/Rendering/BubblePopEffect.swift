//
//  BubblePopEffect.swift
//  BubbleShooter
//

import CoreGraphics
import SpriteKit

struct BubblePopSpec: Sendable {
    let center: CGPoint
    let color: BubbleColor
}

/// Available pop animation variants — switch `BubblePopEffectPlayer.style` to compare.
enum BubblePopEffectStyle: String, CaseIterable, Sendable {
    case spriteFrames
    case cosmicShatter
    case supernova

    var displayName: String {
        switch self {
        case .spriteFrames: "Sprite Frames"
        case .cosmicShatter: "Cosmic Shatter"
        case .supernova: "Supernova"
        }
    }
}

enum BubblePopEffectPlayer {

    /// Active pop animation. Change in sandbox or set before a match.
    static var style: BubblePopEffectStyle = .spriteFrames

    private static let cascadeStep: TimeInterval = 0.02

    static func playGroup(
        _ specs: [BubblePopSpec],
        bubbleDiameter: CGFloat,
        in parent: SKNode
    ) {
        guard !specs.isEmpty else { return }

        switch style {
        case .spriteFrames:
            SpriteBubblePopEffect.playGroup(
                specs,
                bubbleDiameter: bubbleDiameter,
                in: parent
            )

        case .cosmicShatter:
            let ordered = PopEffectCascade.ordered(specs)
            for (index, spec) in ordered.enumerated() {
                let delay = TimeInterval(index) * cascadeStep
                CosmicShatterPopEffect.play(
                    at: spec.center,
                    color: spec.color,
                    diameter: bubbleDiameter,
                    delay: delay,
                    in: parent
                )
            }

        case .supernova:
            SupernovaPopEffect.playGroup(
                specs,
                bubbleDiameter: bubbleDiameter,
                in: parent
            )
        }
    }
}

enum PopEffectCascade {

    static func ordered(_ specs: [BubblePopSpec]) -> [BubblePopSpec] {
        guard specs.count > 1 else { return specs }

        let centroid = CGPoint(
            x: specs.map(\.center.x).reduce(0, +) / CGFloat(specs.count),
            y: specs.map(\.center.y).reduce(0, +) / CGFloat(specs.count)
        )

        return specs.sorted {
            let left = hypot($0.center.x - centroid.x, $0.center.y - centroid.y)
            let right = hypot($1.center.x - centroid.x, $1.center.y - centroid.y)
            if left != right { return left < right }
            if $0.center.y != $1.center.y { return $0.center.y > $1.center.y }
            return $0.center.x < $1.center.x
        }
    }
}
