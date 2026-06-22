//
//  CannonRenderer.swift
//  BubbleShooter
//

import SpriteKit

/// Cannon sprite (`gun-1`), current bubble in the diamond port, next-bubble preview.
final class CannonRenderer: SKNode {

    private static let gunSpriteName = "gun-1"
    /// Diamond center height as a fraction of gun sprite height (from bottom anchor).
    private static let diamondCenterRatio: CGFloat = 0.82
    private static let gunWidthRatio: CGFloat = 2.35 * 1.6 * 1.1
    private static let gunVerticalOffset: CGFloat = -40
    private static let bubbleVerticalOffset: CGFloat = -35

    private let gunNode: SKSpriteNode
    private let bubbleDiameter: CGFloat
    private let gunHeight: CGFloat

    private(set) var launchBubbleOffsetY: CGFloat

    private var currentBubbleNode: BubbleNode?
    private var nextBubbleNode: BubbleNode?

    init(cannonPosition: CGPoint, bubbleDiameter: CGFloat) {
        self.bubbleDiameter = bubbleDiameter

        let texture = SKTexture(imageNamed: Self.gunSpriteName)
        let textureSize = texture.size()
        let aspect = textureSize.height / max(textureSize.width, 1)
        let gunWidth = bubbleDiameter * Self.gunWidthRatio
        let gunHeight = gunWidth * aspect
        self.gunHeight = gunHeight
        self.launchBubbleOffsetY = Self.gunVerticalOffset
            + gunHeight * Self.diamondCenterRatio
            + Self.bubbleVerticalOffset

        gunNode = SKSpriteNode(texture: texture, size: CGSize(width: gunWidth, height: gunHeight))
        gunNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        gunNode.position = CGPoint(x: 0, y: Self.gunVerticalOffset)
        gunNode.zPosition = 10

        super.init()
        position = cannonPosition
        zPosition = 20
        addChild(gunNode)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(current: Bubble, next: Bubble) {
        currentBubbleNode?.removeFromParent()
        nextBubbleNode?.removeFromParent()

        let currentNode = BubbleNode(bubble: current, diameter: bubbleDiameter, zPosition: -1)
        currentNode.position = CGPoint(x: 0, y: launchBubbleOffsetY)
        currentBubbleNode = currentNode

        let nextDiameter = bubbleDiameter * 0.55
        let nextNode = BubbleNode(bubble: next, diameter: nextDiameter, zPosition: -1)
        nextNode.position = CGPoint(
            x: -bubbleDiameter * 1.2,
            y: gunHeight * 0.28
        )
        nextBubbleNode = nextNode

        placeBubblesBelowGun()
    }

    func hideCurrentBubble() {
        currentBubbleNode?.isHidden = true
    }

    func showCurrentBubble() {
        currentBubbleNode?.isHidden = false
    }

    // MARK: - Private

    /// Bubbles sit under the gun sprite so they show through the diamond port.
    private func placeBubblesBelowGun() {
        gunNode.removeFromParent()

        if let currentBubbleNode {
            addChild(currentBubbleNode)
        }
        if let nextBubbleNode {
            addChild(nextBubbleNode)
        }

        addChild(gunNode)
    }
}
