//
//  SpriteBubblePopEffect.swift
//  BubbleShooter
//

import SpriteKit

/// Pop animation from PNG frame sequences (`Expression/*-explosion-*`).
enum SpriteBubblePopEffect {

    private static let frameDuration: TimeInterval = 0.09
    private static let cascadeStep: TimeInterval = 0.02
    /// Explosion art includes outward splashes beyond the bubble circle.
    private static let visualScale: CGFloat = 1.28

    static func playGroup(
        _ specs: [BubblePopSpec],
        bubbleDiameter: CGFloat,
        in parent: SKNode
    ) {
        guard !specs.isEmpty else { return }

        let ordered = PopEffectCascade.ordered(specs)
        for (index, spec) in ordered.enumerated() {
            let delay = TimeInterval(index) * cascadeStep
            play(
                at: spec.center,
                color: spec.color,
                diameter: bubbleDiameter,
                delay: delay,
                in: parent
            )
        }
    }

    static func play(
        at position: CGPoint,
        color: BubbleColor,
        diameter: CGFloat,
        delay: TimeInterval,
        in parent: SKNode
    ) {
        guard let textures = BubbleExplosionTextureCache.frames(for: color), !textures.isEmpty else {
            CosmicShatterPopEffect.play(
                at: position,
                color: color,
                diameter: diameter,
                delay: delay,
                in: parent
            )
            return
        }

        let visualSize = diameter * visualScale
        let node = SKSpriteNode(texture: textures[0], size: CGSize(width: visualSize, height: visualSize))
        node.position = position
        node.zPosition = 30
        parent.addChild(node)

        var actions: [SKAction] = [SKAction.wait(forDuration: delay)]
        if textures.count == 1 {
            actions.append(SKAction.wait(forDuration: frameDuration))
        } else {
            actions.append(SKAction.animate(with: textures, timePerFrame: frameDuration))
        }
        actions.append(SKAction.removeFromParent())
        node.run(SKAction.sequence(actions))
    }
}
