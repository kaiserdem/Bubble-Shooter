//
//  HexLayout.swift
//  BubbleShooter
//

import CoreGraphics

/// Converts hex grid coordinates to scene positions (odd-row offset / honeycomb layout).
struct HexLayout: Equatable, Sendable {

    /// Base center-to-center pitch derived from screen width.
    let gridPitch: CGFloat
    /// Horizontal center distance after tightening.
    let horizontalPitch: CGFloat
    /// Rendered bubble diameter.
    let bubbleVisualDiameter: CGFloat
    /// Raycast radius — slightly larger than sprite so shots cannot thread visible gaps.
    let bubbleCollisionRadius: CGFloat
    let topCenter: CGPoint

    private let rowStep: CGFloat

    private static let hexRowStepRatio = sqrt(3) / 2
    private static let visualDiameterRatio: CGFloat = 0.94
    /// Pull bubble centers closer on both axes (points).
    private static let spacingTighten: CGFloat = 3

    init(sceneSize: CGSize, columnCount: Int, topPadding: CGFloat = 96) {
        let horizontalPadding: CGFloat = 24
        let availableWidth = sceneSize.width - horizontalPadding * 2
        let pitch = floor(availableWidth / CGFloat(columnCount))
        gridPitch = pitch
        horizontalPitch = pitch - Self.spacingTighten
        rowStep = pitch * Self.hexRowStepRatio - Self.spacingTighten
        bubbleVisualDiameter = floor(horizontalPitch * Self.visualDiameterRatio) + Self.spacingTighten
        bubbleCollisionRadius = max(
            bubbleVisualDiameter / 2,
            gridPitch / 2 - 0.5
        )
        topCenter = CGPoint(x: 0, y: sceneSize.height / 2 - topPadding)
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
