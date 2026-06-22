//
//  GameFieldContainerView.swift
//  BubbleShooter
//

import UIKit
import SpriteKit

/// Bordered playfield frame — frosted glass over the match wallpaper, bubbles in `gameView`.
final class GameFieldContainerView: UIView {

    private let glassPanel = GlassPanelView()

    let gameView: SKView = {
        let view = SKView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.ignoresSiblingOrder = true
        view.clipsToBounds = true
        view.layer.cornerRadius = Theme.Metrics.cornerRadiusMedium - 2
        view.allowsTransparency = true
        view.backgroundColor = .clear
        view.isOpaque = false
        view.layer.isOpaque = false
        view.showsFPS = false
        view.showsNodeCount = false
        return view
    }()

    private let borderGlowLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderGlowLayer.frame = bounds.insetBy(dx: -1, dy: -1)
        borderGlowLayer.cornerRadius = layer.cornerRadius + 1
    }

    // MARK: - Private

    private func configure() {
        isOpaque = false
        backgroundColor = .clear
        clipsToBounds = false
        layer.cornerRadius = Theme.Metrics.cornerRadiusMedium
        layer.borderWidth = Theme.Metrics.borderWidthGlow
        layer.borderColor = Theme.Surface.border.cgColor

        glassPanel.translatesAutoresizingMaskIntoConstraints = false
        glassPanel.cornerRadius = Theme.Metrics.cornerRadiusMedium
        glassPanel.clipsToBounds = true

        borderGlowLayer.shadowColor = Theme.Accent.primaryGlow.cgColor
        borderGlowLayer.shadowOpacity = 0.35
        borderGlowLayer.shadowRadius = 14
        borderGlowLayer.shadowOffset = .zero
        borderGlowLayer.backgroundColor = UIColor.clear.cgColor
        layer.insertSublayer(borderGlowLayer, at: 0)

        addSubview(glassPanel)
        addSubview(gameView)
        NSLayoutConstraint.activate([
            glassPanel.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassPanel.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassPanel.topAnchor.constraint(equalTo: topAnchor),
            glassPanel.bottomAnchor.constraint(equalTo: bottomAnchor),

            gameView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gameView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gameView.topAnchor.constraint(equalTo: topAnchor),
            gameView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
