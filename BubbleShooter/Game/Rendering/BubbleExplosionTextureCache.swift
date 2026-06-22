//
//  BubbleExplosionTextureCache.swift
//  BubbleShooter
//

import SpriteKit

enum BubbleExplosionTextureCache {

    private static var frameCache: [BubbleColor: [SKTexture]] = [:]
    private static let lock = NSLock()

    static func frames(for color: BubbleColor) -> [SKTexture]? {
        lock.lock()
        defer { lock.unlock() }

        if let cached = frameCache[color] {
            return cached.isEmpty ? nil : cached
        }

        guard let names = color.explosionFrameNames else {
            frameCache[color] = []
            return nil
        }

        let textures = names.map { SKTexture(imageNamed: $0) }.filter { $0.size() != .zero }
        frameCache[color] = textures
        return textures.count == names.count ? textures : nil
    }

    static func preload() {
        BubbleColor.allCases.forEach { _ = frames(for: $0) }
    }
}
