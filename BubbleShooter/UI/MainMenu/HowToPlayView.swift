//
//  HowToPlayView.swift
//  BubbleShooter
//

import UIKit

/// Full-screen rules and tips — shown from the main menu before a match.
final class HowToPlayView: LobbyScreenView {

    private let introLabel = ArcadeLabel(
        "Quick guide for your first matches and Skillz tournaments.",
        style: .body
    )

    init() {
        super.init(screenTitle: "How to Play")
        configureContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func configureContent() {
        introLabel.textAlignment = .left
        introLabel.textColor = Theme.Text.secondary

        scrollStack.addArrangedSubview(introLabel)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: introLabel)

        for rule in Self.rules {
            scrollStack.addArrangedSubview(
                RuleCard(icon: rule.icon, title: rule.title, detail: rule.detail)
            )
        }
    }

    private static let rules: [(icon: String, title: String, detail: String)] = [
        ("🎯", "Aim & shoot", "Drag from the cannon to aim. Bubbles bounce off side walls until they stick to the grid."),
        ("💥", "Pop groups", "Match 3 or more bubbles of the same color. Each popped bubble adds +10 points."),
        ("⬇️", "Drop clusters", "Bubbles not connected to the ceiling fall away. Each dropped bubble adds +10 points."),
        ("⏱", "Beat the clock", "Score as much as you can before time runs out. Leftover seconds can add a time bonus."),
        ("⚠️", "Danger line", "If bubbles cross the red line at the bottom, the match ends early."),
        ("🏆", "Win on Skillz", "Everyone plays the same board. Highest score wins the tournament."),
    ]
}

// MARK: - RuleCard

private final class RuleCard: UIView {

    init(icon: String, title: String, detail: String) {
        super.init(frame: .zero)
        configure(icon: icon, title: title, detail: detail)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(icon: String, title: String, detail: String) {
        backgroundColor = Theme.Surface.fillStrong
        layer.cornerRadius = Theme.Metrics.cornerRadiusMedium
        layer.borderWidth = Theme.Metrics.borderWidth
        layer.borderColor = Theme.Surface.borderSubtle.cgColor

        let iconLabel = ArcadeLabel(icon, style: .headline)
        iconLabel.textAlignment = .center
        iconLabel.setContentHuggingPriority(.required, for: .horizontal)

        let titleLabel = ArcadeLabel(title, style: .body)
        titleLabel.textAlignment = .left
        titleLabel.textColor = Theme.Text.primary

        let detailLabel = ArcadeLabel(detail, style: .caption)
        detailLabel.textAlignment = .left
        detailLabel.textColor = Theme.Text.secondary

        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading

        let row = UIStackView(arrangedSubviews: [iconLabel, textStack])
        row.axis = .horizontal
        row.spacing = Theme.Metrics.spacingMedium
        row.alignment = .top
        row.translatesAutoresizingMaskIntoConstraints = false

        addSubview(row)
        NSLayoutConstraint.activate([
            iconLabel.widthAnchor.constraint(equalToConstant: 36),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.spacingMedium),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.spacingMedium),
            row.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.spacingMedium),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.spacingMedium),
        ])
    }
}
