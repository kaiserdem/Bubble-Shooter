//
//  CosmicShatterPopEffect.swift
//  BubbleShooter
//

import SpriteKit

/// "Cosmic Shatter" pop: anticipation scale, particles, cyan ripple.
enum CosmicShatterPopEffect {

    private static let particleCount = 10
    private static let anticipationDuration: TimeInterval = 0.08
    private static let popDuration: TimeInterval = 0.10
    private static let rippleDuration: TimeInterval = 0.30
    private static let groundDiameterRatio: CGFloat = 0.86

    static func play(
        at position: CGPoint,
        color: BubbleColor,
        diameter: CGFloat,
        delay: TimeInterval,
        in parent: SKNode
    ) {
        let root = SKNode()
        root.position = position
        root.zPosition = 30
        parent.addChild(root)

        let silhouette = makeSilhouette(diameter: diameter, color: color)
        root.addChild(silhouette)

        let anticipation = SKAction.scale(to: 1.12, duration: anticipationDuration)
        anticipation.timingMode = .easeOut
        let pop = SKAction.group([
            SKAction.scale(to: 0.01, duration: popDuration),
            SKAction.fadeOut(withDuration: popDuration)
        ])
        pop.timingMode = .easeIn

        let spawnEffects = SKAction.run {
            spawnParticles(color: color, diameter: diameter, in: root)
            spawnRipple(diameter: diameter, in: root)
        }

        let cleanup = SKAction.removeFromParent()
        let sequence = SKAction.sequence([
            SKAction.wait(forDuration: delay),
            anticipation,
            spawnEffects,
            pop,
            cleanup
        ])
        root.run(sequence)
    }

    // MARK: - Private

    private static func makeSilhouette(diameter: CGFloat, color: BubbleColor) -> SKShapeNode {
        let groundDiameter = diameter * groundDiameterRatio
        let node = SKShapeNode(circleOfRadius: groundDiameter / 2)
        node.fillColor = SKColor(cgColor: color.themeUIColor.cgColor)
        node.strokeColor = SKColor(white: 1, alpha: 0.35)
        node.lineWidth = 1.2
        node.glowWidth = 1.5
        return node
    }

    private static func spawnParticles(color: BubbleColor, diameter: CGFloat, in root: SKNode) {
        let particleSize = diameter * 0.16
        let travel = diameter * 0.55
        let particleColor = SKColor(cgColor: color.themeUIColor.cgColor)

        for index in 0..<particleCount {
            let angle = (CGFloat(index) / CGFloat(particleCount)) * (.pi * 2)
            let particle = SKShapeNode(circleOfRadius: particleSize / 2)
            particle.fillColor = particleColor
            particle.strokeColor = SKColor(white: 1, alpha: 0.45)
            particle.lineWidth = 0.5
            particle.zPosition = 2
            root.addChild(particle)

            let destination = CGPoint(
                x: cos(angle) * travel,
                y: sin(angle) * travel
            )
            let move = SKAction.move(to: destination, duration: 0.22)
            move.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: 0.22)
            let shrink = SKAction.scale(to: 0.2, duration: 0.22)
            particle.run(SKAction.sequence([
                SKAction.group([move, fade, shrink]),
                SKAction.removeFromParent()
            ]))
        }
    }

    private static func spawnRipple(diameter: CGFloat, in root: SKNode) {
        let ripple = SKShapeNode(circleOfRadius: diameter * 0.42)
        ripple.fillColor = .clear
        ripple.strokeColor = Theme.SK.accentCyan.withAlphaComponent(0.65)
        ripple.lineWidth = 2
        ripple.zPosition = 1
        ripple.setScale(0.6)
        root.addChild(ripple)

        let expand = SKAction.scale(to: 1.9, duration: rippleDuration)
        expand.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: rippleDuration)
        ripple.run(SKAction.sequence([
            SKAction.group([expand, fade]),
            SKAction.removeFromParent()
        ]))
    }
}
