//
//  JellySquishPopEffect.swift
//  BubbleShooter
//

import SpriteKit

/// "Jelly Squish" pop: squash → stretch → candy burst with soft globs.
enum JellySquishPopEffect {

    private static let squashDuration: TimeInterval = 0.07
    private static let stretchDuration: TimeInterval = 0.06
    private static let popDuration: TimeInterval = 0.12
    private static let globCount = 6
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

        let squash = SKAction.scaleX(to: 1.30, y: 0.68, duration: squashDuration)
        squash.timingMode = .easeIn
        let stretch = SKAction.scaleX(to: 0.78, y: 1.22, duration: stretchDuration)
        stretch.timingMode = .easeOut

        let spawnGlobs = SKAction.run {
            spawnJellyGlobs(color: color, diameter: diameter, in: root)
            spawnColorSplash(color: color, diameter: diameter, in: root)
        }

        let pop = SKAction.group([
            SKAction.moveBy(x: 0, y: diameter * 0.07, duration: popDuration),
            SKAction.scale(to: 0.01, duration: popDuration),
            SKAction.fadeOut(withDuration: popDuration)
        ])
        pop.timingMode = .easeIn

        root.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            squash,
            stretch,
            spawnGlobs,
            pop,
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Private

    private static func makeSilhouette(diameter: CGFloat, color: BubbleColor) -> SKShapeNode {
        let groundDiameter = diameter * groundDiameterRatio
        let node = SKShapeNode(circleOfRadius: groundDiameter / 2)
        node.fillColor = SKColor(cgColor: color.themeUIColor.cgColor)
        node.strokeColor = SKColor(white: 1, alpha: 0.42)
        node.lineWidth = 1.4
        node.glowWidth = 1
        return node
    }

    private static func spawnJellyGlobs(color: BubbleColor, diameter: CGFloat, in root: SKNode) {
        let globColor = SKColor(cgColor: color.themeUIColor.cgColor)
        let width = diameter * 0.15
        let height = diameter * 0.10
        let travel = diameter * 0.45

        for index in 0..<globCount {
            let angle = (CGFloat(index) / CGFloat(globCount)) * (.pi * 2) + .pi / 6
            let glob = SKShapeNode(ellipseOf: CGSize(width: width, height: height))
            glob.fillColor = globColor
            glob.strokeColor = SKColor(white: 1, alpha: 0.35)
            glob.lineWidth = 0.5
            glob.zPosition = 2
            root.addChild(glob)

            let horizontal = cos(angle) * travel
            let vertical = sin(angle) * travel * 0.35 - diameter * 0.18
            let destination = CGPoint(x: horizontal, y: vertical)

            let move = SKAction.move(to: destination, duration: 0.24)
            move.timingMode = .easeOut
            let squish = SKAction.scaleX(to: 1.35, y: 0.65, duration: 0.12)
            let fade = SKAction.fadeOut(withDuration: 0.24)

            glob.run(SKAction.sequence([
                SKAction.group([move, squish, fade]),
                SKAction.removeFromParent()
            ]))
        }
    }

    private static func spawnColorSplash(color: BubbleColor, diameter: CGFloat, in root: SKNode) {
        let splash = SKShapeNode(circleOfRadius: diameter * 0.38)
        splash.fillColor = SKColor(cgColor: color.themeUIColor.withAlphaComponent(0.25).cgColor)
        splash.strokeColor = SKColor(white: 1, alpha: 0.4)
        splash.lineWidth = 1.5
        splash.zPosition = 1
        splash.setScale(0.55)
        root.addChild(splash)

        let expand = SKAction.scale(to: 1.75, duration: 0.26)
        expand.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: 0.26)
        splash.run(SKAction.sequence([
            SKAction.group([expand, fade]),
            SKAction.removeFromParent()
        ]))
    }
}
