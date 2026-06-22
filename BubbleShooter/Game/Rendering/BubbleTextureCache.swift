//
//  BubbleTextureCache.swift
//  BubbleShooter
//

import SpriteKit

enum BubbleTextureCache {

    private static var textures: [BubbleColor: SKTexture] = [:]
    private static let lock = NSLock()

    static func texture(for color: BubbleColor) -> SKTexture {
        lock.lock()
        defer { lock.unlock() }

        if let cached = textures[color] {
            return cached
        }

        let texture = SKTexture(imageNamed: color.spriteName)
        textures[color] = texture
        return texture
    }

    static func preload() {
        BubbleColor.allCases.forEach { _ = texture(for: $0) }
        BubbleExplosionTextureCache.preload()
    }
}
