//
//  HexLayout.swift
//  BubbleShooter
//

import CoreGraphics

/// Converts hex grid coordinates to scene positions (odd-row offset / honeycomb layout).
struct HexLayout: Equatable, Sendable {

    /// Insets that align the grid with the bordered playfield `SKView`.
    enum Metrics {
        static let horizontalEdgeInset: CGFloat = 4
        static let topEdgeInset: CGFloat = 6
    }

    /// Vertical space reserved for the cannon — depends on bubble size.
    let cannonReservedBottomHeight: CGFloat

    /// Base center-to-center pitch derived from screen width.
    let gridPitch: CGFloat
    /// Horizontal center distance after tightening.
    let horizontalPitch: CGFloat
    /// Rendered bubble diameter.
    let bubbleVisualDiameter: CGFloat
    /// Raycast radius — slightly larger than sprite so shots cannot thread visible gaps.
    let bubbleCollisionRadius: CGFloat
    let topCenter: CGPoint

    /// Center-to-center distance between rows.
    var verticalRowStep: CGFloat { rowStep }

    private let rowStep: CGFloat

    private static let hexRowStepRatio = sqrt(3) / 2
    private static let visualDiameterRatio: CGFloat = 0.96
    /// Pull bubble centers closer on both axes (points).
    private static let spacingTighten: CGFloat = 2

    init(sceneSize: CGSize, columnCount: Int) {
        let availableWidth = sceneSize.width - Metrics.horizontalEdgeInset * 2
        let pitch = floor(availableWidth / CGFloat(columnCount))
        gridPitch = pitch
        horizontalPitch = pitch - Self.spacingTighten
        rowStep = pitch * Self.hexRowStepRatio - Self.spacingTighten
        bubbleVisualDiameter = floor(horizontalPitch * Self.visualDiameterRatio) + Self.spacingTighten
        bubbleCollisionRadius = max(
            bubbleVisualDiameter / 2,
            gridPitch / 2 - 0.5
        )
        topCenter = CGPoint(
            x: 0,
            y: sceneSize.height / 2 - Metrics.topEdgeInset - bubbleVisualDiameter / 2
        )
        cannonReservedBottomHeight = CannonRenderer.reservedBottomHeight(
            bubbleDiameter: bubbleVisualDiameter
        )
    }

    /// Top Y of the grid play area in scene coordinates.
    var gridAreaTopY: CGFloat {
        topCenter.y + bubbleVisualDiameter / 2
    }

    /// Bottom Y reserved for the cannon in scene coordinates.
    func gridAreaBottomY(sceneHeight: CGFloat) -> CGFloat {
        -sceneHeight / 2 + cannonReservedBottomHeight
    }

    /// Invisible lose threshold — same position the old danger line used.
    func dangerLineY(sceneHeight: CGFloat, normalizedY: CGFloat = 0.72) -> CGFloat {
        let gridAreaTop = gridAreaTopY
        let gridAreaBottom = gridAreaBottomY(sceneHeight: sceneHeight)
        let gridAreaHeight = gridAreaTop - gridAreaBottom
        return gridAreaTop - gridAreaHeight * normalizedY
    }

    func center(for position: GridPosition, configuration: GridConfiguration) -> CGPoint {
        let evenColumnCount = configuration.columnCount
        let rowOriginX = -CGFloat(evenColumnCount - 1) * horizontalPitch / 2

        var x = rowOriginX + CGFloat(position.col) * horizontalPitch
        if !position.row.isMultiple(of: 2) {
            x += horizontalPitch / 2
        }

        let y = -CGFloat(position.row) * rowStep
        return CGPoint(x: topCenter.x + x, y: topCenter.y + y)
    }
}
