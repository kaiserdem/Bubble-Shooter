//
//  FlyingBubbleNode.swift
//  BubbleShooter
//

import SpriteKit

enum FlyingBubbleNode {

  static let shotSpeed: CGFloat = 920

  @discardableResult
  static func animate(
    bubble: Bubble,
    diameter: CGFloat,
    along path: ShotPath,
    in parent: SKNode,
    onComplete: @escaping () -> Void
  ) -> BubbleNode {
    let node = BubbleNode(bubble: bubble, diameter: diameter)
    node.position = path.points[0]
    node.zPosition = 25
    parent.addChild(node)

    var actions: [SKAction] = []
    var previous = path.points[0]

    for point in path.points.dropFirst() {
      let distance = hypot(point.x - previous.x, point.y - previous.y)
      let duration = TimeInterval(distance / shotSpeed)
      actions.append(SKAction.move(to: point, duration: max(duration, 0.01)))
      previous = point
    }

    actions.append(SKAction.run(onComplete))
    node.run(SKAction.sequence(actions))
    return node
  }
}
