//
//  BubbleNode.swift
//  BubbleShooter
//

import SpriteKit

/// Bubble visual: colored ground disc under the transparent-padding sprite.
final class BubbleNode: SKNode {

    let bubble: Bubble

    /// Filled circle diameter relative to sprite — sits inside artwork padding.
    private static let groundDiameterRatio: CGFloat = 0.86

    init(bubble: Bubble, diameter: CGFloat) {
        self.bubble = bubble
        super.init()
        zPosition = 10
        isUserInteractionEnabled = false

        let groundDiameter = diameter * Self.groundDiameterRatio
        let ground = SKShapeNode(circleOfRadius: groundDiameter / 2)
        ground.fillColor = SKColor(cgColor: bubble.color.themeUIColor.cgColor)
        ground.strokeColor = .clear
        ground.lineWidth = 0
        ground.zPosition = 0
        addChild(ground)

        let texture = BubbleTextureCache.texture(for: bubble.color)
        let size = CGSize(width: diameter, height: diameter)
        let sprite = SKSpriteNode(texture: texture, color: .clear, size: size)
        sprite.colorBlendFactor = 0
        sprite.zPosition = 1
        addChild(sprite)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
