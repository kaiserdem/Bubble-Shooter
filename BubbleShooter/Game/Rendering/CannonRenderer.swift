//
//  CannonRenderer.swift
//  BubbleShooter
//

import SpriteKit

/// Cannon sprite (`gun-1`) and the loaded bubble in the diamond port.
/// Next bubble preview lives in the UIKit HUD (`GameHUDView`).
final class CannonRenderer: SKNode {

    private static var gunSpriteName: String { CosmeticSettings.cannonSkin.spriteName }
    /// Diamond center height as a fraction of gun sprite height (from bottom anchor).
    private static let diamondCenterRatio: CGFloat = 0.82
    private static let gunWidthRatio: CGFloat = 2.35 * 1.6 * 1.1
    private static let gunVerticalOffset: CGFloat = -40
    private static let bubbleVerticalOffset: CGFloat = -35
    private static let pivotBottomPadding: CGFloat = 4

    /// Pivot Y so the gun base sits on the bottom edge of the playfield.
    static func pivotY(sceneHeight: CGFloat) -> CGFloat {
        -sceneHeight / 2 + pivotBottomPadding - gunVerticalOffset
    }

    /// Vertical space reserved at the bottom for the cannon artwork.
    static func reservedBottomHeight(bubbleDiameter: CGFloat) -> CGFloat {
        let texture = SKTexture(imageNamed: gunSpriteName)
        let textureSize = texture.size()
        let aspect = textureSize.height / max(textureSize.width, 1)
        let gunHeight = bubbleDiameter * gunWidthRatio * aspect
        return pivotBottomPadding - gunVerticalOffset + gunHeight + 8
    }

    private let gunNode: SKSpriteNode
    private let bubbleDiameter: CGFloat

    private(set) var launchBubbleOffsetY: CGFloat

    private var currentBubbleNode: BubbleNode?

    init(cannonPosition: CGPoint, bubbleDiameter: CGFloat) {
        self.bubbleDiameter = bubbleDiameter

        let texture = SKTexture(imageNamed: Self.gunSpriteName)
        let textureSize = texture.size()
        let aspect = textureSize.height / max(textureSize.width, 1)
        let gunWidth = bubbleDiameter * Self.gunWidthRatio
        let gunHeight = gunWidth * aspect
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

    func update(current: Bubble) {
        setCurrent(current)
    }

    /// Clears the launch port when the bubble leaves the cannon.
    func beginShot() {
        currentBubbleNode?.removeAllActions()
        currentBubbleNode?.removeFromParent()
        currentBubbleNode = nil
    }

    /// Loads the new current bubble after the shot queue advances.
    func setCurrent(_ bubble: Bubble) {
        currentBubbleNode?.removeAllActions()
        currentBubbleNode?.removeFromParent()

        let node = BubbleNode(bubble: bubble, diameter: bubbleDiameter, zPosition: -1)
        node.position = CGPoint(x: 0, y: launchBubbleOffsetY)
        currentBubbleNode = node
        placeCurrentBelowGun()
    }

    func hideCurrentBubble() {
        currentBubbleNode?.isHidden = true
    }

    func showCurrentBubble() {
        currentBubbleNode?.isHidden = false
    }

    // MARK: - Private

    private func placeCurrentBelowGun() {
        guard let currentBubbleNode else { return }
        if currentBubbleNode.parent !== self {
            addChild(currentBubbleNode)
        }
        currentBubbleNode.zPosition = -1
        bringGunToFront()
    }

    private func bringGunToFront() {
        gunNode.removeFromParent()
        addChild(gunNode)
    }
}
