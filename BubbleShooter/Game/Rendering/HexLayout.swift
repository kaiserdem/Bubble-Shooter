//
//  HexLayout.swift
//  BubbleShooter
//

import CoreGraphics

/// Converts hex grid coordinates to scene positions (odd-row offset layout).
struct HexLayout: Equatable, Sendable {

    /// Center-to-center distance between neighbors in the same row.
    let gridPitch: CGFloat
    /// Circular sprite diameter — matches pitch so neighbors touch horizontally.
    let bubbleVisualDiameter: CGFloat
    let topCenter: CGPoint

    /// Looser than tight hex packing (`√3/2`) — artwork extends past the logical circle vertically.
    private static let verticalRowStepRatio: CGFloat = 0.97

    private var rowStep: CGFloat { gridPitch * Self.verticalRowStepRatio }

    init(sceneSize: CGSize, columnCount: Int, topPadding: CGFloat = 96) {
        let horizontalPadding: CGFloat = 24
        let availableWidth = sceneSize.width - horizontalPadding * 2
        let pitch = floor(availableWidth / CGFloat(columnCount))
        gridPitch = pitch
        bubbleVisualDiameter = pitch
        topCenter = CGPoint(x: 0, y: sceneSize.height / 2 - topPadding)
    }

    func center(for position: GridPosition, configuration: GridConfiguration) -> CGPoint {
        let columns = configuration.columnCount(forRow: position.row)
        let rowWidth = gridPitch * CGFloat(max(columns - 1, 0))
        let rowOriginX = -rowWidth / 2
        let oddOffset = position.row.isMultiple(of: 2) ? 0 : gridPitch / 2
        let x = rowOriginX + CGFloat(position.col) * gridPitch + oddOffset
        let y = -CGFloat(position.row) * rowStep
        return CGPoint(x: topCenter.x + x, y: topCenter.y + y)
    }
}
