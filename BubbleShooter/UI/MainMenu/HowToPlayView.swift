//
//  HowToPlayView.swift
//  BubbleShooter
//

import UIKit

/// Rules and tips overlay — shown from the main menu before a match.
final class HowToPlayView: ModalCardOverlayView {

    var onClose: (() -> Void)?

    private let titleLabel = ArcadeLabel("How to Play", style: .headline)
    private let closeButton = ArcadeButton(title: "Got it", style: .primary)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func configureContent() {
        titleLabel.textAlignment = .center

        closeButton.addAction(UIAction { [weak self] _ in
            self?.onClose?()
        }, for: .touchUpInside)

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        let rulesStack = UIStackView()
        rulesStack.axis = .vertical
        rulesStack.spacing = Theme.Metrics.spacingMedium
        rulesStack.translatesAutoresizingMaskIntoConstraints = false

        for rule in Self.rules {
            rulesStack.addArrangedSubview(RuleRow(icon: rule.icon, title: rule.title, detail: rule.detail))
        }

        scrollView.addSubview(rulesStack)

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(scrollView)
        contentStack.addArrangedSubview(closeButton)
        contentStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: scrollView)

        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(lessThanOrEqualToConstant: 320),

            rulesStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            rulesStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            rulesStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            rulesStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            rulesStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
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

// MARK: - RuleRow

private final class RuleRow: UIView {

    init(icon: String, title: String, detail: String) {
        super.init(frame: .zero)
        configure(icon: icon, title: title, detail: detail)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(icon: String, title: String, detail: String) {
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
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.topAnchor.constraint(equalTo: topAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
