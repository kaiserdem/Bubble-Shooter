//
//  SnapResolver.swift
//  BubbleShooter
//

import CoreGraphics

/// Picks the hex cell where a shot bubble should attach after impact.
enum SnapResolver {

    struct Analysis: Sendable {
        struct Candidate: Sendable {
            let position: GridPosition
            let connectionScore: Int
            let distanceToImpact: CGFloat

            static func sortForDisplay(_ lhs: Candidate, _ rhs: Candidate) -> Bool {
                if lhs.connectionScore != rhs.connectionScore {
                    return lhs.connectionScore > rhs.connectionScore
                }
                return lhs.distanceToImpact < rhs.distanceToImpact
            }
        }

        let chosen: GridPosition?
        let candidates: [Candidate]
    }

    static func resolve(
        hit: ShotHit,
        shotBubble: Bubble,
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> GridPosition? {
        analyze(
            hit: hit,
            shotBubble: shotBubble,
            grid: grid,
            layout: layout,
            configuration: configuration
        ).chosen
    }

    static func analyze(
        hit: ShotHit,
        shotBubble: Bubble,
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> Analysis {
        let impactPoint = hit.point
        let candidatePositions: [GridPosition]

        switch hit.target {
        case .bubble(let hitPosition):
            candidatePositions = candidateCellsNearBubble(
                hitPosition: hitPosition,
                grid: grid
            )

        case .ceiling:
            candidatePositions = candidateCellsForCeiling(
                grid: grid,
                configuration: configuration
            )

        case .leftWall, .rightWall:
            return Analysis(chosen: nil, candidates: [])
        }

        let candidates = scoreCandidates(
            candidatePositions,
            impactPoint: impactPoint,
            shotBubble: shotBubble,
            grid: grid,
            layout: layout,
            configuration: configuration
        )

        let chosen = candidates.max { lhs, rhs in
            if lhs.connectionScore != rhs.connectionScore {
                return lhs.connectionScore < rhs.connectionScore
            }
            return lhs.distanceToImpact > rhs.distanceToImpact
        }?.position

        return Analysis(chosen: chosen, candidates: candidates)
    }

    // MARK: - Private

    private static func candidateCellsNearBubble(
        hitPosition: GridPosition,
        grid: BubbleGrid
    ) -> [GridPosition] {
        var candidates = emptyNeighbors(around: hitPosition, grid: grid)

        if candidates.isEmpty {
            let ring = grid.neighbors(of: hitPosition).filter { grid.isOccupied($0) }
            for occupied in ring {
                candidates.append(contentsOf: emptyNeighbors(around: occupied, grid: grid))
            }
            candidates = Array(Set(candidates))
        }

        return candidates
    }

    private static func candidateCellsForCeiling(
        grid: BubbleGrid,
        configuration: GridConfiguration
    ) -> [GridPosition] {
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

        return candidates
    }

    private static func scoreCandidates(
        _ candidates: [GridPosition],
        impactPoint: CGPoint,
        shotBubble: Bubble,
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> [Analysis.Candidate] {
        candidates.map { position in
            let center = layout.center(for: position, configuration: configuration)
            let distance = hypot(center.x - impactPoint.x, center.y - impactPoint.y)
            return Analysis.Candidate(
                position: position,
                connectionScore: connectionScore(at: position, shotBubble: shotBubble, grid: grid),
                distanceToImpact: distance
            )
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
