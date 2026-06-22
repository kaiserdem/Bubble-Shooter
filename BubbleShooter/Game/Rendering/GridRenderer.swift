//
//  GridRenderer.swift
//  BubbleShooter
//

import SpriteKit

final class GridRenderer {

    let container = SKNode()

    private let layout: HexLayout
    private let configuration: GridConfiguration

    init(layout: HexLayout, configuration: GridConfiguration) {
        self.layout = layout
        self.configuration = configuration
        container.name = "bubbleGrid"
        container.zPosition = 5
    }

    func render(grid: BubbleGrid) {
        container.removeAllChildren()

        for position in grid.occupiedPositions {
            guard let bubble = grid.bubble(at: position) else { continue }
            let node = BubbleNode(bubble: bubble, diameter: layout.bubbleVisualDiameter)
            node.position = layout.center(for: position, configuration: configuration)
            container.addChild(node)
        }
    }
}
