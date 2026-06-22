//
//  AimController.swift
//  BubbleShooter
//

import CoreGraphics

/// Computes clamped shot angle from cannon position to touch point.
struct AimController: Equatable, Sendable {

    let cannonPosition: CGPoint
    let minAngle: CGFloat
    let maxAngle: CGFloat

    static let defaultMinDegrees: CGFloat = 15
    static let defaultMaxDegrees: CGFloat = 165

    init(
        cannonPosition: CGPoint,
        minDegrees: CGFloat = Self.defaultMinDegrees,
        maxDegrees: CGFloat = Self.defaultMaxDegrees
    ) {
        self.cannonPosition = cannonPosition
        minAngle = minDegrees * .pi / 180
        maxAngle = maxDegrees * .pi / 180
    }

    func clampedAngle(toward target: CGPoint) -> CGFloat {
        let dx = target.x - cannonPosition.x
        let dy = target.y - cannonPosition.y
        guard dx != 0 || dy != 0 else { return .pi / 2 }

        let angle = atan2(dy, dx)
        return min(max(angle, minAngle), maxAngle)
    }

    func unitDirection(for angle: CGFloat) -> CGVector {
        CGVector(dx: cos(angle), dy: sin(angle))
    }

    func shotRay(toward target: CGPoint) -> ShotRay {
        let angle = clampedAngle(toward: target)
        return ShotRay(origin: cannonPosition, direction: unitDirection(for: angle))
    }
}

struct ShotRay: Equatable, Sendable {
    let origin: CGPoint
    let direction: CGVector
}
