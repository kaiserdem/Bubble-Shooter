//
//  SnapResolver.swift
//  BubbleShooter
//

import CoreGraphics

/// Picks the hex cell where a shot bubble should attach after impact.
enum SnapResolver {

    static func resolve(
        hit: ShotHit,
        shotBubble: Bubble,
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> GridPosition? {
        switch hit.target {
        case .bubble(let hitPosition):
            return snapNearBubble(
                hitPosition: hitPosition,
                impactPoint: hit.point,
                shotBubble: shotBubble,
                grid: grid,
                layout: layout,
                configuration: configuration
            )

        case .ceiling:
            return snapToCeiling(
                impactPoint: hit.point,
                shotBubble: shotBubble,
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
        shotBubble: Bubble,
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

        return bestSnapPosition(
            among: candidates,
            impactPoint: impactPoint,
            shotBubble: shotBubble,
            grid: grid,
            layout: layout,
            configuration: configuration
        )
    }

    private static func snapToCeiling(
        impactPoint: CGPoint,
        shotBubble: Bubble,
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

        return bestSnapPosition(
            among: candidates,
            impactPoint: impactPoint,
            shotBubble: shotBubble,
            grid: grid,
            layout: layout,
            configuration: configuration
        )
    }

    private static func bestSnapPosition(
        among candidates: [GridPosition],
        impactPoint: CGPoint,
        shotBubble: Bubble,
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> GridPosition? {
        guard !candidates.isEmpty else { return nil }

        return candidates.max { lhs, rhs in
            let leftScore = connectionScore(
                at: lhs,
                shotBubble: shotBubble,
                grid: grid
            )
            let rightScore = connectionScore(
                at: rhs,
                shotBubble: shotBubble,
                grid: grid
            )
            if leftScore != rightScore { return leftScore < rightScore }

            let leftCenter = layout.center(for: lhs, configuration: configuration)
            let rightCenter = layout.center(for: rhs, configuration: configuration)
            let leftDistance = hypot(leftCenter.x - impactPoint.x, leftCenter.y - impactPoint.y)
            let rightDistance = hypot(rightCenter.x - impactPoint.x, rightCenter.y - impactPoint.y)
            return leftDistance > rightDistance
        }
    }

    private static func connectionScore(
        at position: GridPosition,
        shotBubble: Bubble,
        grid: BubbleGrid
    ) -> Int {
        var simulated = grid
        do {
            try simulated.place(shotBubble, at: position)
        } catch {
            return 0
        }
        return MatchFinder.connectedGroup(including: position, in: simulated).count
    }

    private static func emptyNeighbors(around position: GridPosition, grid: BubbleGrid) -> [GridPosition] {
        grid.neighbors(of: position).filter { !grid.isOccupied($0) }
    }
}
