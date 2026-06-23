//
//  BubblePopPreviewOverlay.swift
//  BubbleShooter
//

import SpriteKit
import UIKit

/// SpriteKit overlay for bubble-skin shop previews — reuses in-game pop effects.
final class BubblePopPreviewOverlay: UIView {

    private enum Timing {
        static let popFrameDuration: TimeInterval = 0.10
        static let bubbleHideDuration: TimeInterval = 0.08
        static let gapBetweenBubbles: TimeInterval = 0.04
        static let restoreDuration: TimeInterval = 0.32
    }

    private typealias BubbleItem = (view: UIView, color: BubbleColor)

    private let skView = SKView()
    private let scene = SKScene()
    private var isPlaying = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false

        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.allowsTransparency = true
        skView.isUserInteractionEnabled = false
        skView.isOpaque = false
        skView.backgroundColor = .clear
        addSubview(skView)

        scene.backgroundColor = .clear
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)

        NSLayoutConstraint.activate([
            skView.leadingAnchor.constraint(equalTo: leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: trailingAnchor),
            skView.topAnchor.constraint(equalTo: topAnchor),
            skView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func play(
        anchorViews: [UIView],
        colors: [BubbleColor],
        bubbleDiameter: CGFloat,
        completion: (() -> Void)? = nil
    ) {
        guard !isPlaying, anchorViews.count == colors.count, !anchorViews.isEmpty else {
            completion?()
            return
        }

        layoutIfNeeded()
        guard skView.bounds.width > 0, skView.bounds.height > 0 else {
            completion?()
            return
        }

        isPlaying = true
        scene.removeAllChildren()
        scene.size = skView.bounds.size

        let ordered: [BubbleItem] = zip(anchorViews, colors)
            .map { (view: $0.0, color: $0.1) }
            .sorted { bubbleX($0.view) > bubbleX($1.view) }

        anchorViews.forEach {
            $0.layer.removeAllAnimations()
            $0.alpha = 1
            $0.transform = .identity
        }

        playBubbleSequence(
            ordered: ordered,
            index: 0,
            bubbleDiameter: bubbleDiameter
        ) { [weak self] in
            self?.restoreBubbles(anchorViews) {
                self?.isPlaying = false
                completion?()
            }
        }
    }

    // MARK: - Private

    private func playBubbleSequence(
        ordered: [BubbleItem],
        index: Int,
        bubbleDiameter: CGFloat,
        completion: @escaping () -> Void
    ) {
        guard index < ordered.count else {
            completion()
            return
        }

        let item = ordered[index]

        UIView.animate(
            withDuration: Timing.bubbleHideDuration,
            delay: 0,
            options: [.curveEaseOut, .beginFromCurrentState],
            animations: {
                item.view.alpha = 0
            }
        )

        SpriteBubblePopEffect.play(
            at: scenePoint(for: item.view),
            color: item.color,
            diameter: bubbleDiameter,
            delay: 0,
            in: scene,
            frameDuration: Timing.popFrameDuration
        )

        let step = Self.popDuration(for: item.color) + Timing.gapBetweenBubbles
        DispatchQueue.main.asyncAfter(deadline: .now() + step) { [weak self] in
            self?.playBubbleSequence(
                ordered: ordered,
                index: index + 1,
                bubbleDiameter: bubbleDiameter,
                completion: completion
            )
        }
    }

    private func bubbleX(_ view: UIView) -> CGFloat {
        view.convert(CGPoint(x: view.bounds.midX, y: view.bounds.midY), to: skView).x
    }

    private func restoreBubbles(_ views: [UIView], completion: (() -> Void)? = nil) {
        views.forEach { $0.layer.removeAllAnimations() }
        UIView.animate(
            withDuration: Timing.restoreDuration,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.2,
            options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
            animations: {
                views.forEach {
                    $0.alpha = 1
                    $0.transform = .identity
                }
            },
            completion: { _ in completion?() }
        )
    }

    private func scenePoint(for view: UIView) -> CGPoint {
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let inSKView = view.convert(center, to: skView)
        return CGPoint(x: inSKView.x, y: skView.bounds.height - inSKView.y)
    }

    private static func popDuration(for color: BubbleColor) -> TimeInterval {
        let frameCount = BubbleExplosionTextureCache.frames(for: color)?.count ?? 2
        return TimeInterval(frameCount) * Timing.popFrameDuration
    }
}
