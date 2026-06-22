//
//  ShotSimulator.swift
//  BubbleShooter
//

import CoreGraphics

struct ShotHit: Equatable, Sendable {
    enum Target: Equatable, Sendable {
        case leftWall
        case rightWall
        case ceiling
        case bubble(GridPosition)
    }

    let point: CGPoint
    let target: Target
}

struct ShotPath: Equatable, Sendable {
    let points: [CGPoint]
    let hit: ShotHit
}

enum ShotSimulator {

    static let maxWallBounces = 10
    private static let epsilon: CGFloat = 0.5
    /// Extra reach so grazing shots still register bubble contact.
    private static let collisionSlop: CGFloat = 3

    static func simulate(
        ray: ShotRay,
        playBounds: CGRect,
        occupiedBubbles: [(position: GridPosition, center: CGPoint)],
        bubbleRadius: CGFloat
    ) -> ShotPath {
        var points: [CGPoint] = [ray.origin]
        var origin = ray.origin
        var direction = normalize(ray.direction)
        var bounces = 0

        while bounces <= maxWallBounces {
            let hit = nearestHit(
                from: origin,
                direction: direction,
                playBounds: playBounds,
                occupiedBubbles: occupiedBubbles,
                bubbleRadius: bubbleRadius
            )

            points.append(hit.point)

            switch hit.target {
            case .bubble, .ceiling:
                return ShotPath(points: points, hit: hit)

            case .leftWall, .rightWall:
                origin = offset(from: hit.point, direction: direction, distance: epsilon)
                direction = CGVector(dx: -direction.dx, dy: direction.dy)
                bounces += 1
            }
        }

        let fallback = ShotHit(point: origin, target: .ceiling)
        return ShotPath(points: points, hit: fallback)
    }

    // MARK: - Private

    private static func nearestHit(
        from origin: CGPoint,
        direction: CGVector,
        playBounds: CGRect,
        occupiedBubbles: [(position: GridPosition, center: CGPoint)],
        bubbleRadius: CGFloat
    ) -> ShotHit {
        var bestDistance = CGFloat.greatestFiniteMagnitude
        var bestHit = ShotHit(point: origin, target: .ceiling)

        if direction.dx < 0 {
            let t = (playBounds.minX - origin.x) / direction.dx
            if let hit = candidateHit(origin: origin, direction: direction, t: t, target: .leftWall, best: bestDistance) {
                bestDistance = hit.distance
                bestHit = hit.hit
            }
        } else if direction.dx > 0 {
            let t = (playBounds.maxX - origin.x) / direction.dx
            if let hit = candidateHit(origin: origin, direction: direction, t: t, target: .rightWall, best: bestDistance) {
                bestDistance = hit.distance
                bestHit = hit.hit
            }
        }

        if direction.dy > 0 {
            let t = (playBounds.maxY - origin.y) / direction.dy
            if let hit = candidateHit(origin: origin, direction: direction, t: t, target: .ceiling, best: bestDistance) {
                bestDistance = hit.distance
                bestHit = hit.hit
            }
        }

        let combinedRadius = bubbleRadius * 2 + collisionSlop
        for bubble in occupiedBubbles {
            if let t = rayCircleIntersection(
                origin: origin,
                direction: direction,
                center: bubble.center,
                radius: combinedRadius
            ) {
                if t > epsilon, t < bestDistance {
                    bestDistance = t
                    let point = pointOnRay(origin: origin, direction: direction, t: t)
                    bestHit = ShotHit(point: point, target: .bubble(bubble.position))
                }
            }
        }

        return bestHit
    }

    private struct Candidate {
        let distance: CGFloat
        let hit: ShotHit
    }

    private static func candidateHit(
        origin: CGPoint,
        direction: CGVector,
        t: CGFloat,
        target: ShotHit.Target,
        best: CGFloat
    ) -> Candidate? {
        guard t > epsilon, t < best else { return nil }
        let point = pointOnRay(origin: origin, direction: direction, t: t)
        return Candidate(distance: t, hit: ShotHit(point: point, target: target))
    }

    private static func pointOnRay(origin: CGPoint, direction: CGVector, t: CGFloat) -> CGPoint {
        CGPoint(x: origin.x + direction.dx * t, y: origin.y + direction.dy * t)
    }

    private static func offset(from point: CGPoint, direction: CGVector, distance: CGFloat) -> CGPoint {
        CGPoint(x: point.x + direction.dx * distance, y: point.y + direction.dy * distance)
    }

    private static func normalize(_ vector: CGVector) -> CGVector {
        let length = hypot(vector.dx, vector.dy)
        guard length > 0 else { return CGVector(dx: 0, dy: 1) }
        return CGVector(dx: vector.dx / length, dy: vector.dy / length)
    }

    /// Smallest positive `t` where the ray hits the circle, if any.
    private static func rayCircleIntersection(
        origin: CGPoint,
        direction: CGVector,
        center: CGPoint,
        radius: CGFloat
    ) -> CGFloat? {
        let fx = origin.x - center.x
        let fy = origin.y - center.y

        let a = direction.dx * direction.dx + direction.dy * direction.dy
        let b = 2 * (fx * direction.dx + fy * direction.dy)
        let c = fx * fx + fy * fy - radius * radius

        let discriminant = b * b - 4 * a * c
        guard discriminant >= 0 else { return nil }

        let sqrtD = sqrt(discriminant)
        let t1 = (-b - sqrtD) / (2 * a)
        let t2 = (-b + sqrtD) / (2 * a)

        let candidates = [t1, t2].filter { $0 > epsilon }
        return candidates.min()
    }
}
