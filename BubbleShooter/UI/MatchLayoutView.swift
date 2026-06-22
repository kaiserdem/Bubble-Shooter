//
//  MatchLayoutView.swift
//  BubbleShooter
//

import UIKit
import SpriteKit

/// Full-screen match chrome: stats HUD on top, bordered playfield below.
final class MatchLayoutView: UIView {

    let hudView = GameHUDView()
    let gameFieldContainer = GameFieldContainerView()

    var gameSKView: SKView { gameFieldContainer.gameView }

    private let backgroundView = ImageBackgroundView(named: Theme.Asset.Background.game)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with state: MatchHUDState) {
        hudView.update(with: state)
    }

    // MARK: - Private

    private func configure() {
        isOpaque = false
        backgroundColor = .clear
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        hudView.translatesAutoresizingMaskIntoConstraints = false
        gameFieldContainer.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundView)
        addSubview(hudView)
        addSubview(gameFieldContainer)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            hudView.leadingAnchor.constraint(equalTo: gameFieldContainer.leadingAnchor),
            hudView.trailingAnchor.constraint(equalTo: gameFieldContainer.trailingAnchor),
            hudView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),

            gameFieldContainer.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: Theme.Metrics.contentPadding
            ),
            gameFieldContainer.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -Theme.Metrics.contentPadding
            ),
            gameFieldContainer.topAnchor.constraint(
                equalTo: hudView.bottomAnchor,
                constant: Theme.Metrics.spacingMedium
            ),
            gameFieldContainer.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -Theme.Metrics.spacingSmall
            ),
        ])
    }
}
