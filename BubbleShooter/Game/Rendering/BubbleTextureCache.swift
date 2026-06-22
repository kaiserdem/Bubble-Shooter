//
//  BubbleTextureCache.swift
//  BubbleShooter
//

import SpriteKit

enum BubbleTextureCache {

    private static var textures: [String: SKTexture] = [:]
    private static let lock = NSLock()

    static func texture(for color: BubbleColor) -> SKTexture {
        let imageName = color.spriteName
        lock.lock()
        defer { lock.unlock() }

        if let cached = textures[imageName] {
            return cached
        }

        let texture = SKTexture(imageNamed: imageName)
        textures[imageName] = texture
        return texture
    }

    static func invalidate() {
        lock.lock()
        textures.removeAll()
        lock.unlock()
    }

    static func preload() {
        BubbleColor.allCases.forEach { _ = texture(for: $0) }
        BubbleExplosionTextureCache.preload()
        CannonSkin.allCases.forEach { _ = SKTexture(imageNamed: $0.spriteName) }
    }
}
