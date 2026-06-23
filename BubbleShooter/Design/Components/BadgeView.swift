//
//  BadgeView.swift
//  BubbleShooter
//

import UIKit

/// Small pill badge for scores, tags, and status chips.
final class BadgeView: UIView {

    private let label = ArcadeLabel("", style: .caption)

    init(text: String, tint: UIColor = Theme.Accent.gold) {
        super.init(frame: .zero)
        label.text = text
        label.textColor = Theme.Text.primary
        configure(tint: tint)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }

    private func configure(tint: UIColor) {
        backgroundColor = tint.withAlphaComponent(0.22)
        layer.cornerRadius = Theme.Metrics.cornerRadiusSmall
        layer.borderWidth = Theme.Metrics.borderWidth
        layer.borderColor = tint.withAlphaComponent(0.55).cgColor

        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
}
