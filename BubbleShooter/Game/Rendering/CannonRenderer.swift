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
    private static let nextBubbleHorizontalRatio: CGFloat = 0
    private static let nextBubbleBelowGunPadding: CGFloat = -3
    private static let nextBubbleScaleRatio: CGFloat = 0.55
    private static let promoteIntoLaunchDuration: TimeInterval = 0.22

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

        let nextDiameter = bubbleDiameter * Self.nextBubbleScaleRatio
        let nextNode = BubbleNode(bubble: next, diameter: nextDiameter, zPosition: -1)
        nextNode.position = nextBubbleSlotPosition(nextDiameter: nextDiameter)
        nextBubbleNode = nextNode

        placeBubblesBelowGun()
    }

    /// Removes the shot bubble and animates the next bubble up into the launch slot.
    func beginShot() {
        currentBubbleNode?.removeAllActions()
        currentBubbleNode?.removeFromParent()
        currentBubbleNode = nil

        guard let promotingNode = nextBubbleNode else { return }
        promotingNode.removeAllActions()

        let launchPosition = CGPoint(x: 0, y: launchBubbleOffsetY)
        let move = SKAction.move(to: launchPosition, duration: Self.promoteIntoLaunchDuration)
        move.timingMode = .easeIn
        let scaleUp = SKAction.scale(
            to: 1 / Self.nextBubbleScaleRatio,
            duration: Self.promoteIntoLaunchDuration
        )
        scaleUp.timingMode = .easeIn

        promotingNode.run(SKAction.sequence([
            SKAction.group([move, scaleUp]),
            SKAction.run { [weak self] in
                guard let self else { return }
                self.currentBubbleNode = promotingNode
                self.nextBubbleNode = nil
                self.bringGunToFront()
            }
        ]))
    }

    /// Spawns the new queue preview bubble below the cannon after a shot resolves.
    func replenishAfterShot(next: Bubble) {
        nextBubbleNode?.removeAllActions()
        nextBubbleNode?.removeFromParent()

        let nextDiameter = bubbleDiameter * Self.nextBubbleScaleRatio
        let nextNode = BubbleNode(bubble: next, diameter: nextDiameter, zPosition: -1)
        nextNode.position = nextBubbleSlotPosition(nextDiameter: nextDiameter)
        nextNode.alpha = 0
        nextBubbleNode = nextNode
        placeBubblesBelowGun()
        nextNode.run(SKAction.fadeIn(withDuration: 0.14))
    }

    func hideCurrentBubble() {
        currentBubbleNode?.isHidden = true
    }

    func showCurrentBubble() {
        currentBubbleNode?.isHidden = false
    }

    // MARK: - Private

    private func nextBubbleSlotPosition(nextDiameter: CGFloat) -> CGPoint {
        CGPoint(
            x: bubbleDiameter * Self.nextBubbleHorizontalRatio,
            y: Self.gunVerticalOffset - nextDiameter * 0.5 - Self.nextBubbleBelowGunPadding
        )
    }

    /// Bubbles sit under the gun sprite so they show through the diamond port.
    private func placeBubblesBelowGun() {
        if let currentBubbleNode {
            attachIfNeeded(currentBubbleNode)
            currentBubbleNode.zPosition = -1
        }
        if let nextBubbleNode {
            attachIfNeeded(nextBubbleNode)
            nextBubbleNode.zPosition = -1
        }
        bringGunToFront()
    }

    private func attachIfNeeded(_ node: SKNode) {
        guard node.parent !== self else { return }
        addChild(node)
    }

    private func bringGunToFront() {
        gunNode.removeFromParent()
        addChild(gunNode)
    }
}
