//
//  CannonAimPivot.swift
//  BubbleShooter
//

import SpriteKit

/// Rotates cannon, loaded bubble, and aim guide together around the cannon base.
final class CannonAimPivot: SKNode {

    let cannon: CannonRenderer
    private let aimGuide = AimGuideNode()

    init(cannonPosition: CGPoint, bubbleDiameter: CGFloat) {
        cannon = CannonRenderer(cannonPosition: .zero, bubbleDiameter: bubbleDiameter)
        super.init()
        position = cannonPosition
        zPosition = 20
        addChild(cannon)
        addChild(aimGuide)
        aimGuide.zPosition = 2
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Gun art points up at `zRotation == 0`; `aimAngle` is the standard shot angle from +X.
    func setAimAngle(_ aimAngle: CGFloat) {
        zRotation = aimAngle - .pi / 2
    }

    func launchOrigin(in scene: SKScene) -> CGPoint {
        convert(CGPoint(x: 0, y: cannon.launchBubbleOffsetY), to: scene)
    }

    func updateAimGuide(path: ShotPath?, in scene: SKScene) {
        guard let path, path.points.count >= 2 else {
            aimGuide.update(path: nil)
            return
        }

        let localPoints = path.points.map { scene.convert($0, to: self) }
        aimGuide.update(path: ShotPath(points: localPoints, hit: path.hit))
    }

    func hideAimGuide() {
        aimGuide.update(path: nil)
    }
}
