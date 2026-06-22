//
//  SnapResolver.swift
//  BubbleShooter
//

import CoreGraphics

/// Picks the hex cell where a shot bubble should attach after impact.
enum SnapResolver {

    static func resolve(
        hit: ShotHit,
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> GridPosition? {
        switch hit.target {
        case .bubble(let hitPosition):
            return snapNearBubble(
                hitPosition: hitPosition,
                impactPoint: hit.point,
                grid: grid,
                layout: layout,
                configuration: configuration
            )

        case .ceiling:
            return snapToCeiling(
                impactPoint: hit.point,
                grid: grid,
                layout: layout,
                configuration: configuration
            )

        case .leftWall, .rightWall:
            return nil
        }
    }

    // MARK: - Private

    private static func snapNearBubble(
        hitPosition: GridPosition,
        impactPoint: CGPoint,
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> GridPosition? {
        var candidates = emptyNeighbors(around: hitPosition, grid: grid)

        if candidates.isEmpty {
            let ring = grid.neighbors(of: hitPosition).filter { grid.isOccupied($0) }
            for occupied in ring {
                candidates.append(contentsOf: emptyNeighbors(around: occupied, grid: grid))
            }
            candidates = Array(Set(candidates))
        }

        return closestPosition(to: impactPoint, among: candidates, layout: layout, configuration: configuration)
    }

    private static func snapToCeiling(
        impactPoint: CGPoint,
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> GridPosition? {
        var candidates: [GridPosition] = []
        for position in grid.occupiedPositions {
            candidates.append(contentsOf: emptyNeighbors(around: position, grid: grid))
        }
        candidates = Array(Set(candidates))

        if candidates.isEmpty {
            let row = 0
            let columnCount = configuration.columnCount(forRow: row)
            candidates = (0..<columnCount).map { GridPosition(row: row, col: $0) }
        }

        return closestPosition(to: impactPoint, among: candidates, layout: layout, configuration: configuration)
    }

    private static func emptyNeighbors(around position: GridPosition, grid: BubbleGrid) -> [GridPosition] {
        grid.neighbors(of: position).filter { !grid.isOccupied($0) }
    }

    private static func closestPosition(
        to point: CGPoint,
        among candidates: [GridPosition],
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> GridPosition? {
        candidates.min { lhs, rhs in
            let left = layout.center(for: lhs, configuration: configuration)
            let right = layout.center(for: rhs, configuration: configuration)
            return hypot(left.x - point.x, left.y - point.y) < hypot(right.x - point.x, right.y - point.y)
        }
    }
}
