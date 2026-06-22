//
//  BubbleDropEffect.swift
//  BubbleShooter
//

import SpriteKit

enum BubbleDropEffect {

    private static let cascadeStep: TimeInterval = 0.03
    private static let fallDistanceRatio: CGFloat = 2.2

    static func playGroup(
        _ specs: [BubblePopSpec],
        bubbleDiameter: CGFloat,
        in parent: SKNode
    ) {
        let ordered = PopEffectCascade.ordered(specs)
        let fallDistance = bubbleDiameter * fallDistanceRatio

        for (index, spec) in ordered.enumerated() {
            let delay = TimeInterval(index) * cascadeStep
            let node = BubbleNode(bubble: Bubble(color: spec.color), diameter: bubbleDiameter)
            node.position = spec.center
            node.zPosition = 24
            node.alpha = 0.92
            parent.addChild(node)

            let move = SKAction.moveBy(x: 0, y: -fallDistance, duration: 0.34)
            move.timingMode = .easeIn
            let fade = SKAction.fadeOut(withDuration: 0.34)
            let group = SKAction.group([move, fade])
            let wait = SKAction.wait(forDuration: delay)
            node.run(SKAction.sequence([wait, group, SKAction.removeFromParent()]))
        }
    }
}
