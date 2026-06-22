//
//  ScoreFloater.swift
//  BubbleShooter
//

import CoreGraphics
import SpriteKit

/// "+N" label that appears after pop/drop FX, floats up, and fades out.
enum ScoreFloater {

    enum Kind {
        case pop
        case drop

        fileprivate var textColor: SKColor {
            switch self {
            case .pop: Theme.SK.accentGold
            case .drop: Theme.SK.accentCyan
            }
        }

        fileprivate func effectCompletionDelay(bubbleCount: Int) -> TimeInterval {
            switch self {
            case .pop:
                let cascadeStep = 0.02
                let frameDuration = 0.09
                let frameCount: TimeInterval = 2
                let lastDelay = TimeInterval(max(0, bubbleCount - 1)) * cascadeStep
                return lastDelay + frameCount * frameDuration

            case .drop:
                let cascadeStep = 0.03
                let fallDuration = 0.34
                let lastDelay = TimeInterval(max(0, bubbleCount - 1)) * cascadeStep
                return lastDelay + fallDuration
            }
        }
    }

    static func play(
        points: Int,
        near specs: [BubblePopSpec],
        kind: Kind,
        in parent: SKNode
    ) {
        guard points > 0, !specs.isEmpty else { return }

        let center = centroid(of: specs)
        let bubbleCount = specs.count
        let delay = kind.effectCompletionDelay(bubbleCount: bubbleCount)

        let label = SKLabelNode(fontNamed: Theme.Typography.skTitle())
        label.text = "+\(points)"
        label.fontSize = 32
        label.fontColor = kind.textColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = center
        label.zPosition = 45
        label.alpha = 0
        label.setScale(0.72)
        parent.addChild(label)

        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.scale(to: 1.08, duration: 0.14),
        ])
        appear.timingMode = .easeOut

        let float = SKAction.group([
            SKAction.moveBy(x: 0, y: 96, duration: 0.82),
            SKAction.sequence([
                SKAction.wait(forDuration: 0.18),
                SKAction.fadeOut(withDuration: 0.64),
            ]),
            SKAction.sequence([
                SKAction.wait(forDuration: 0.22),
                SKAction.scale(to: 0.92, duration: 0.6),
            ]),
        ])
        float.timingMode = .easeOut

        label.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            appear,
            float,
            SKAction.removeFromParent(),
        ]))
    }

    private static func centroid(of specs: [BubblePopSpec]) -> CGPoint {
        guard specs.count > 1 else { return specs[0].center }

        return CGPoint(
            x: specs.map(\.center.x).reduce(0, +) / CGFloat(specs.count),
            y: specs.map(\.center.y).reduce(0, +) / CGFloat(specs.count)
        )
    }
}
