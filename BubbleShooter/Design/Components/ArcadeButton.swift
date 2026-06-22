//
//  ArcadeButton.swift
//  BubbleShooter
//

import UIKit

/// Reusable CTA button with gradient fill, glow border, and press animation.
final class ArcadeButton: UIControl {

    enum Style {
        case primary
        case secondary
        case ghost
        case danger
    }

    private let gradientLayer = CAGradientLayer()
    private let borderLayer = CAShapeLayer()
    private let titleLabel = UILabel()
    private let style: Style

    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    init(title: String, style: Style = .primary) {
        self.style = style
        super.init(frame: .zero)
        titleLabel.text = title
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet { updateHighlight(animated: true) }
    }

    override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1 : 0.45 }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = Theme.Metrics.cornerRadiusMedium

        let inset = Theme.Metrics.borderWidthGlow / 2
        borderLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: inset, dy: inset),
            cornerRadius: Theme.Metrics.cornerRadiusMedium
        ).cgPath
        borderLayer.frame = bounds
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: Theme.Metrics.buttonMinWidth, height: Theme.Metrics.buttonHeight)
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = Theme.Metrics.cornerRadiusMedium
        layer.masksToBounds = false
        layer.shadowColor = glowColor.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)

        applyStyle()

        titleLabel.font = Theme.Typography.body(17)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isUserInteractionEnabled = false

        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Theme.Metrics.buttonHeight),
            widthAnchor.constraint(greaterThanOrEqualToConstant: Theme.Metrics.buttonMinWidth),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
        ])

        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = Theme.Metrics.borderWidthGlow
        layer.insertSublayer(gradientLayer, at: 0)
        layer.addSublayer(borderLayer)

        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }

    private func applyStyle() {
        switch style {
        case .primary:
            gradientLayer.colors = [
                Theme.Accent.primary.cgColor,
                Theme.Accent.primaryGlow.cgColor,
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            borderLayer.strokeColor = Theme.Accent.primary.withAlphaComponent(0.9).cgColor
            titleLabel.textColor = Theme.Text.onDark

        case .secondary:
            gradientLayer.colors = [
                Theme.Accent.secondary.withAlphaComponent(0.42).cgColor,
                Theme.Accent.primary.withAlphaComponent(0.38).cgColor,
            ]
            borderLayer.strokeColor = Theme.Accent.secondary.cgColor
            titleLabel.textColor = Theme.Text.onDark

        case .ghost:
            gradientLayer.colors = [
                Theme.Surface.fill.cgColor,
                Theme.Surface.fillStrong.cgColor,
            ]
            borderLayer.strokeColor = Theme.Surface.border.cgColor
            titleLabel.textColor = Theme.Text.primary

        case .danger:
            gradientLayer.colors = [
                Theme.Accent.danger.cgColor,
                UIColor(hex: 0xFF3D5A).cgColor,
            ]
            borderLayer.strokeColor = Theme.Accent.danger.cgColor
            titleLabel.textColor = Theme.Text.onDark
        }
    }

    private var glowColor: UIColor {
        switch style {
        case .primary: Theme.Accent.primary
        case .secondary: Theme.Accent.secondary
        case .ghost: Theme.Surface.border
        case .danger: Theme.Accent.danger
        }
    }

    private func updateHighlight(animated: Bool) {
        let scale: CGFloat = isHighlighted ? 0.96 : 1
        let alpha: CGFloat = isHighlighted ? 0.88 : 1
        let changes = {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.alpha = self.isEnabled ? alpha : 0.45
        }
        if animated {
            UIView.animate(withDuration: 0.12, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: changes)
        } else {
            changes()
        }
    }

    @objc private func touchDown() { isHighlighted = true }
    @objc private func touchUp() { isHighlighted = false }
}
