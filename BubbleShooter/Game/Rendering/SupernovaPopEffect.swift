//
//  SupernovaPopEffect.swift
//  BubbleShooter
//

import SpriteKit

/// "Supernova" pop: Cosmic Shatter base + group flash; shake and boost on 5+ matches.
enum SupernovaPopEffect {

    static let largeMatchThreshold = 5

    private static let particleCount = 14
    private static let anticipationDuration: TimeInterval = 0.08
    private static let popDuration: TimeInterval = 0.10
    private static let rippleDuration: TimeInterval = 0.34
    private static let groundDiameterRatio: CGFloat = 0.86

    static func playGroup(
        _ specs: [BubblePopSpec],
        bubbleDiameter: CGFloat,
        in parent: SKNode
    ) {
        guard !specs.isEmpty else { return }

        let isLargeMatch = specs.count >= largeMatchThreshold
        let ordered = PopEffectCascade.ordered(specs)

        if let scene = parent as? SKScene ?? parent.scene {
            let centroid = groupCentroid(of: specs)
            playGroupFlash(at: centroid, diameter: bubbleDiameter, isLarge: isLargeMatch, in: scene)
            if isLargeMatch {
                playScreenShake(on: scene)
            }
        }

        for (index, spec) in ordered.enumerated() {
            let delay = TimeInterval(index) * 0.02
            play(
                at: spec.center,
                color: spec.color,
                diameter: bubbleDiameter,
                delay: delay,
                isLargeMatch: isLargeMatch,
                in: parent
            )
        }
    }

    static func play(
        at position: CGPoint,
        color: BubbleColor,
        diameter: CGFloat,
        delay: TimeInterval,
        isLargeMatch: Bool,
        in parent: SKNode
    ) {
        let root = SKNode()
        root.position = position
        root.zPosition = 30
        parent.addChild(root)

        let silhouette = makeSilhouette(diameter: diameter, color: color)
        root.addChild(silhouette)

        let peakScale: CGFloat = isLargeMatch ? 1.16 : 1.13
        let anticipation = SKAction.scale(to: peakScale, duration: anticipationDuration)
        anticipation.timingMode = .easeOut
        let pop = SKAction.group([
            SKAction.scale(to: 0.01, duration: popDuration),
            SKAction.fadeOut(withDuration: popDuration)
        ])
        pop.timingMode = .easeIn

        let spawnEffects = SKAction.run {
            spawnParticles(color: color, diameter: diameter, isLargeMatch: isLargeMatch, in: root)
            spawnRipples(diameter: diameter, isLargeMatch: isLargeMatch, in: root)
        }

        root.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            anticipation,
            spawnEffects,
            pop,
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Group

    private static func groupCentroid(of specs: [BubblePopSpec]) -> CGPoint {
        CGPoint(
            x: specs.map(\.center.x).reduce(0, +) / CGFloat(specs.count),
            y: specs.map(\.center.y).reduce(0, +) / CGFloat(specs.count)
        )
    }

    private static func playGroupFlash(
        at position: CGPoint,
        diameter: CGFloat,
        isLarge: Bool,
        in scene: SKScene
    ) {
        let flash = SKShapeNode(circleOfRadius: diameter * (isLarge ? 0.95 : 0.72))
        flash.position = position
        flash.fillColor = SKColor(white: 1, alpha: isLarge ? 0.88 : 0.72)
        flash.strokeColor = Theme.SK.accentGold.withAlphaComponent(0.55)
        flash.lineWidth = isLarge ? 2.5 : 1.5
        flash.zPosition = 34
        flash.setScale(0.35)
        scene.addChild(flash)

        let expand = SKAction.scale(to: isLarge ? 2.4 : 1.8, duration: isLarge ? 0.22 : 0.18)
        expand.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: isLarge ? 0.22 : 0.18)
        flash.run(SKAction.sequence([
            SKAction.group([expand, fade]),
            SKAction.removeFromParent()
        ]))
    }

    private static func playScreenShake(on scene: SKScene) {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 1, duration: 0.025),
            SKAction.moveBy(x: 10, y: -2, duration: 0.05),
            SKAction.moveBy(x: -8, y: 1, duration: 0.045),
            SKAction.moveBy(x: 3, y: 0, duration: 0.03)
        ])
        scene.run(shake)
    }

    // MARK: - Single bubble

    private static func makeSilhouette(diameter: CGFloat, color: BubbleColor) -> SKShapeNode {
        let groundDiameter = diameter * groundDiameterRatio
        let node = SKShapeNode(circleOfRadius: groundDiameter / 2)
        node.fillColor = SKColor(cgColor: color.themeUIColor.cgColor)
        node.strokeColor = SKColor(white: 1, alpha: 0.45)
        node.lineWidth = 1.3
        node.glowWidth = 2
        return node
    }

    private static func spawnParticles(
        color: BubbleColor,
        diameter: CGFloat,
        isLargeMatch: Bool,
        in root: SKNode
    ) {
        let count = isLargeMatch ? particleCount + 4 : particleCount
        let particleSize = diameter * (isLargeMatch ? 0.18 : 0.16)
        let travel = diameter * (isLargeMatch ? 0.68 : 0.55)
        let particleColor = SKColor(cgColor: color.themeUIColor.cgColor)

        for index in 0..<count {
            let angle = (CGFloat(index) / CGFloat(count)) * (.pi * 2)
            let particle = SKShapeNode(circleOfRadius: particleSize / 2)
            particle.fillColor = particleColor
            particle.strokeColor = SKColor(white: 1, alpha: 0.5)
            particle.lineWidth = 0.5
            particle.glowWidth = isLargeMatch ? 1 : 0
            particle.zPosition = 2
            root.addChild(particle)

            let destination = CGPoint(
                x: cos(angle) * travel,
                y: sin(angle) * travel
            )
            let duration: TimeInterval = isLargeMatch ? 0.28 : 0.22
            let move = SKAction.move(to: destination, duration: duration)
            move.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: duration)
            let shrink = SKAction.scale(to: 0.15, duration: duration)
            particle.run(SKAction.sequence([
                SKAction.group([move, fade, shrink]),
                SKAction.removeFromParent()
            ]))
        }
    }

    private static func spawnRipples(diameter: CGFloat, isLargeMatch: Bool, in root: SKNode) {
        spawnRipple(
            diameter: diameter,
            stroke: Theme.SK.accentCyan.withAlphaComponent(0.7),
            endScale: isLargeMatch ? 2.35 : 2.0,
            lineWidth: isLargeMatch ? 2.5 : 2,
            in: root
        )

        if isLargeMatch {
            spawnRipple(
                diameter: diameter,
                stroke: Theme.SK.accentGold.withAlphaComponent(0.55),
                endScale: 2.0,
                lineWidth: 1.5,
                delay: 0.04,
                in: root
            )
        }
    }

    private static func spawnRipple(
        diameter: CGFloat,
        stroke: SKColor,
        endScale: CGFloat,
        lineWidth: CGFloat,
        delay: TimeInterval = 0,
        in root: SKNode
    ) {
        let ripple = SKShapeNode(circleOfRadius: diameter * 0.42)
        ripple.fillColor = .clear
        ripple.strokeColor = stroke
        ripple.lineWidth = lineWidth
        ripple.zPosition = 1
        ripple.setScale(0.55)
        root.addChild(ripple)

        let expand = SKAction.scale(to: endScale, duration: rippleDuration)
        expand.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: rippleDuration)
        ripple.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.group([expand, fade]),
            SKAction.removeFromParent()
        ]))
    }
}
