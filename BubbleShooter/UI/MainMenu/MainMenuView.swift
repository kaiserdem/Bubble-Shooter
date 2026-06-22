//
//  MainMenuView.swift
//  BubbleShooter
//

import UIKit

/// Home screen before a match — branding and navigation actions.
final class MainMenuView: UIView {

    var onPlay: (() -> Void)?
    var onHowToPlay: (() -> Void)?
    var onStyles: (() -> Void)?
    var onSettings: (() -> Void)?

    private let backgroundView = ImageBackgroundView(named: Theme.Asset.Background.lobby)
    private let card = GlassCardView()
    private let titleLabel = ArcadeLabel("Bubble Shooter", style: .title)
    private let subtitleLabel = ArcadeLabel(Theme.Brand.variant, style: .body)
    private let playButton = ArcadeButton(title: "Play", style: .primary)
    private let howToPlayButton = ArcadeButton(title: "How to Play", style: .secondary)
    private let stylesButton = ArcadeButton(title: "Styles", style: .gold)
    private let settingsButton = ArcadeButton(title: "Settings", style: .violet)

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
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        card.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = Theme.Text.secondary

        playButton.addAction(UIAction { [weak self] _ in
            self?.onPlay?()
        }, for: .touchUpInside)

        howToPlayButton.addAction(UIAction { [weak self] _ in
            self?.onHowToPlay?()
        }, for: .touchUpInside)

        stylesButton.addAction(UIAction { [weak self] _ in
            self?.onStyles?()
        }, for: .touchUpInside)

        settingsButton.addAction(UIAction { [weak self] _ in
            self?.onSettings?()
        }, for: .touchUpInside)

        let utilityRow = UIStackView(arrangedSubviews: [stylesButton, settingsButton])
        utilityRow.axis = .vertical
        utilityRow.spacing = Theme.Metrics.spacingMedium
        utilityRow.distribution = .fill
        utilityRow.alignment = .fill

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            playButton,
            howToPlayButton,
            utilityRow,
        ])
        stack.axis = .vertical
        stack.spacing = Theme.Metrics.spacingMedium
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setCustomSpacing(Theme.Metrics.spacingLarge, after: subtitleLabel)

        addSubview(backgroundView)
        addSubview(card)
        card.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 360),

            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
        ])
    }
}
