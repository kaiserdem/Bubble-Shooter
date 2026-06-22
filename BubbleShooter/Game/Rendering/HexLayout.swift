//
//  HexLayout.swift
//  BubbleShooter
//

import CoreGraphics

/// Converts hex grid coordinates to scene positions (odd-row offset / honeycomb layout).
struct HexLayout: Equatable, Sendable {

    /// Center-to-center distance between neighbors in the same row.
    let gridPitch: CGFloat
    /// Rendered bubble diameter — slightly smaller than pitch to fit artwork glow.
    let bubbleVisualDiameter: CGFloat
    let topCenter: CGPoint

    /// Vertical distance between row centers for honeycomb nesting (`√3/2 × pitch`).
    private static let hexRowStepRatio = sqrt(3) / 2
    private static let visualDiameterRatio: CGFloat = 0.94

    private var rowStep: CGFloat { gridPitch * Self.hexRowStepRatio }

    init(sceneSize: CGSize, columnCount: Int, topPadding: CGFloat = 96) {
        let horizontalPadding: CGFloat = 24
        let availableWidth = sceneSize.width - horizontalPadding * 2
        let pitch = floor(availableWidth / CGFloat(columnCount))
        gridPitch = pitch
        bubbleVisualDiameter = floor(pitch * Self.visualDiameterRatio)
        topCenter = CGPoint(x: 0, y: sceneSize.height / 2 - topPadding)
    }

    func center(for position: GridPosition, configuration: GridConfiguration) -> CGPoint {
        // Anchor all rows to the even-row grid, then shift odd rows by half a pitch
        // so bubbles nest in the gap between two bubbles above (not directly underneath).
        let evenColumnCount = configuration.columnCount
        let rowOriginX = -CGFloat(evenColumnCount - 1) * gridPitch / 2

        var x = rowOriginX + CGFloat(position.col) * gridPitch
        if !position.row.isMultiple(of: 2) {
            x += gridPitch / 2
        }

        let y = -CGFloat(position.row) * rowStep
        return CGPoint(x: topCenter.x + x, y: topCenter.y + y)
    }
}
