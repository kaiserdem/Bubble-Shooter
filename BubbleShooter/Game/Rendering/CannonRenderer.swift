//
//  CannonRenderer.swift
//  BubbleShooter
//

import SpriteKit

/// Cannon base, current bubble, and next-bubble preview.
final class CannonRenderer: SKNode {

    private let baseNode = SKShapeNode()
    private let bubbleDiameter: CGFloat
    private var currentBubbleNode: BubbleNode?
    private var nextBubbleNode: BubbleNode?

    init(cannonPosition: CGPoint, bubbleDiameter: CGFloat) {
        self.bubbleDiameter = bubbleDiameter
        super.init()
        position = cannonPosition
        zPosition = 20

        let baseWidth = bubbleDiameter * 1.6
        let baseHeight = bubbleDiameter * 0.45
        baseNode.path = CGPath(
            roundedRect: CGRect(x: -baseWidth / 2, y: -baseHeight / 2, width: baseWidth, height: baseHeight),
            cornerWidth: baseHeight / 2,
            cornerHeight: baseHeight / 2,
            transform: nil
        )
        baseNode.fillColor = SKColor(cgColor: Theme.Background.elevated.cgColor)
        baseNode.strokeColor = SKColor(white: 1, alpha: 0.25)
        baseNode.lineWidth = 1.5
        baseNode.zPosition = 0
        addChild(baseNode)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(current: Bubble, next: Bubble) {
        currentBubbleNode?.removeFromParent()
        nextBubbleNode?.removeFromParent()

        let currentNode = BubbleNode(bubble: current, diameter: bubbleDiameter)
        currentNode.position = CGPoint(x: 0, y: bubbleDiameter * 0.55)
        currentNode.zPosition = 2
        addChild(currentNode)
        currentBubbleNode = currentNode

        let nextDiameter = bubbleDiameter * 0.55
        let nextNode = BubbleNode(bubble: next, diameter: nextDiameter)
        nextNode.position = CGPoint(x: -bubbleDiameter * 1.15, y: bubbleDiameter * 0.2)
        nextNode.zPosition = 1
        addChild(nextNode)
        nextBubbleNode = nextNode
    }

    func hideCurrentBubble() {
        currentBubbleNode?.isHidden = true
    }

    func showCurrentBubble() {
        currentBubbleNode?.isHidden = false
    }
}
