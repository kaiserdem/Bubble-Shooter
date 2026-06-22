//
//  GameFieldContainerView.swift
//  BubbleShooter
//

import UIKit
import SpriteKit

/// Bordered playfield frame — lobby-style glass card over the match wallpaper, bubbles in `gameView`.
final class GameFieldContainerView: UIView {

    private let card = GlassCardView(material: .playfield)

    let gameView: SKView = {
        let view = SKView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.ignoresSiblingOrder = true
        view.clipsToBounds = true
        view.layer.cornerRadius = Theme.Metrics.cornerRadiusLarge
        view.allowsTransparency = true
        view.backgroundColor = .clear
        view.isOpaque = false
        view.layer.isOpaque = false
        view.showsFPS = false
        view.showsNodeCount = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func configure() {
        isOpaque = false
        backgroundColor = .clear
        clipsToBounds = false

        card.translatesAutoresizingMaskIntoConstraints = false

        addSubview(card)
        addSubview(gameView)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.topAnchor.constraint(equalTo: topAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),

            gameView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gameView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gameView.topAnchor.constraint(equalTo: topAnchor),
            gameView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
