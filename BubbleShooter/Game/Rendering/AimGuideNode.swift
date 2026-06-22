//
//  AimGuideNode.swift
//  BubbleShooter
//

import SpriteKit

/// Dotted aim path preview from cannon to predicted hit.
final class AimGuideNode: SKNode {

    private let line = SKShapeNode()

    override init() {
        super.init()
        zPosition = 15
        line.strokeColor = SKColor(white: 1, alpha: 0.45)
        line.lineWidth = 2
        line.lineCap = .round
        line.lineJoin = .round
        addChild(line)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(path: ShotPath?) {
        guard let path, path.points.count >= 2 else {
            line.path = nil
            isHidden = true
            return
        }

        isHidden = false
        let guide = UIBezierPath()
        guide.move(to: path.points[0])
        for point in path.points.dropFirst() {
            guide.addLine(to: point)
        }
        line.path = guide.cgPath
    }
}
