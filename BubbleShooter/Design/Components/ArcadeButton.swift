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
        case gold
        case aqua
        case violet
        case ghost
        case danger
    }

    enum Size {
        case regular
        /// Inline navigation — fits label width with standard horizontal padding.
        case compact
    }

    private let gradientLayer = CAGradientLayer()
    private let borderLayer = CAShapeLayer()
    private let titleLabel = UILabel()
    private let glassHost = UIView()
    private let glassEffectView = UIVisualEffectView()
    private let glassTintOverlay = UIView()
    private let style: Style
    private let size: Size
    /// Overrides `Theme.Metrics.compactButtonHorizontalPadding` for this button only.
    private let contentHorizontalPadding: CGFloat?

    private var usesGlassBackground: Bool {
        style == .ghost && size == .compact
    }

    var title: String? {
        get { titleLabel.text }
        set {
            titleLabel.text = newValue
            invalidateIntrinsicContentSize()
        }
    }

    init(
        title: String,
        style: Style = .primary,
        size: Size = .regular,
        contentHorizontalPadding: CGFloat? = nil
    ) {
        self.style = style
        self.size = size
        self.contentHorizontalPadding = contentHorizontalPadding
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
        let radius = cornerRadius
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = radius

        if usesGlassBackground {
            glassHost.layer.cornerRadius = radius
            if #available(iOS 26.0, *) {
                glassEffectView.cornerConfiguration = .uniformCorners(radius: .fixed(radius))
            } else {
                glassEffectView.layer.cornerRadius = radius
            }
            glassTintOverlay.layer.cornerRadius = radius
        }

        let inset = Theme.Metrics.borderWidthGlow / 2
        borderLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: inset, dy: inset),
            cornerRadius: radius
        ).cgPath
        borderLayer.frame = bounds
    }

    override var intrinsicContentSize: CGSize {
        switch size {
        case .regular:
            return CGSize(width: Theme.Metrics.buttonMinWidth, height: Theme.Metrics.buttonHeight)
        case .compact:
            let labelSize = titleLabel.sizeThatFits(
                CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            )
            let width = labelSize.width + compactHorizontalPadding * 2
            return CGSize(width: width, height: Theme.Metrics.compactButtonHeight)
        }
    }

    private var compactHorizontalPadding: CGFloat {
        contentHorizontalPadding ?? Theme.Metrics.compactButtonHorizontalPadding
    }

    private var cornerRadius: CGFloat {
        size == .compact ? Theme.Metrics.cornerRadiusSmall : Theme.Metrics.cornerRadiusMedium
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowColor = glowColor.cgColor
        if style == .primary, size == .regular {
            layer.shadowOpacity = 0.78
            layer.shadowRadius = 18
        } else {
            layer.shadowOpacity = size == .compact ? 0.35 : 0.55
            layer.shadowRadius = size == .compact ? 8 : 12
        }
        layer.shadowOffset = CGSize(width: 0, height: size == .compact ? 2 : 4)

        applyStyle()

        if usesGlassBackground {
            installGlassBackground()
        }

        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isUserInteractionEnabled = false
        titleLabel.font = size == .compact
            ? Theme.Typography.body(17)
            : Theme.Typography.body(19)

        addSubview(titleLabel)

        switch size {
        case .regular:
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: Theme.Metrics.buttonHeight),
                widthAnchor.constraint(greaterThanOrEqualToConstant: Theme.Metrics.buttonMinWidth),
                titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            ])
        case .compact:
            setContentHuggingPriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .horizontal)
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: Theme.Metrics.compactButtonHeight),
                titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                titleLabel.leadingAnchor.constraint(
                    greaterThanOrEqualTo: leadingAnchor,
                    constant: compactHorizontalPadding
                ),
                titleLabel.trailingAnchor.constraint(
                    lessThanOrEqualTo: trailingAnchor,
                    constant: -compactHorizontalPadding
                ),
            ])
        }

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
            gradientLayer.isHidden = false
            gradientLayer.colors = [
                UIColor(hex: 0xFFE566).cgColor,
                UIColor(hex: 0xFF7A2F).cgColor,
                Theme.Accent.primaryGlow.cgColor,
            ]
            gradientLayer.locations = [0, 0.42, 1]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.35)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.65)
            borderLayer.strokeColor = UIColor(hex: 0xFFD84D).cgColor
            Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.onDark)

        case .secondary:
            gradientLayer.isHidden = false
            gradientLayer.locations = nil
            gradientLayer.colors = [
                Theme.Accent.secondary.cgColor,
                UIColor(hex: 0x00A8C8).cgColor,
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            borderLayer.strokeColor = Theme.Accent.secondary.cgColor
            Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.onDark)

        case .gold:
            gradientLayer.isHidden = false
            gradientLayer.locations = nil
            gradientLayer.colors = [
                Theme.Accent.gold.cgColor,
                UIColor(hex: 0xFF9A2E).cgColor,
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            borderLayer.strokeColor = Theme.Accent.gold.cgColor
            Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.onDark)

        case .aqua:
            gradientLayer.isHidden = false
            gradientLayer.locations = nil
            gradientLayer.colors = [
                UIColor(hex: 0x7AEE9A).cgColor,
                UIColor(hex: 0x2BBF9A).cgColor,
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            borderLayer.strokeColor = UIColor(hex: 0x4ADFB5).cgColor
            Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.onDark)

        case .violet:
            gradientLayer.isHidden = false
            gradientLayer.locations = nil
            gradientLayer.colors = [
                UIColor(hex: 0xB46CFF).withAlphaComponent(0.82).cgColor,
                UIColor(hex: 0x6B4DFF).withAlphaComponent(0.78).cgColor,
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            borderLayer.strokeColor = UIColor(hex: 0xD4B0FF).cgColor
            Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.onDark)

        case .ghost:
            if usesGlassBackground {
                gradientLayer.isHidden = true
                borderLayer.strokeColor = Theme.Surface.border.cgColor
                Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.onDark)
            } else {
                gradientLayer.isHidden = false
                gradientLayer.colors = [
                    Theme.Surface.fill.cgColor,
                    Theme.Surface.fillStrong.cgColor,
                ]
                borderLayer.strokeColor = Theme.Surface.border.cgColor
                Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.primary)
            }

        case .danger:
            gradientLayer.isHidden = false
            gradientLayer.locations = nil
            gradientLayer.colors = [
                Theme.Accent.danger.cgColor,
                UIColor(hex: 0xFF3D5A).cgColor,
            ]
            borderLayer.strokeColor = Theme.Accent.danger.cgColor
            Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.onDark)
        }
    }

    private var glowColor: UIColor {
        switch style {
        case .primary: UIColor(hex: 0xFF9A2E)
        case .secondary: Theme.Accent.secondary
        case .gold: Theme.Accent.gold
        case .aqua: UIColor(hex: 0x3DD4A0)
        case .violet: UIColor(hex: 0xB46CFF)
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

    private func installGlassBackground() {
        let material = LiquidGlassMaterial.navigation

        glassHost.translatesAutoresizingMaskIntoConstraints = false
        glassHost.clipsToBounds = true
        glassHost.isUserInteractionEnabled = false
        glassHost.overrideUserInterfaceStyle = .dark

        glassEffectView.translatesAutoresizingMaskIntoConstraints = false
        glassEffectView.clipsToBounds = true
        glassEffectView.effect = material.makeEffect()

        glassTintOverlay.translatesAutoresizingMaskIntoConstraints = false
        glassTintOverlay.isUserInteractionEnabled = false
        glassTintOverlay.isHidden = !material.usesLegacyTintOverlay
        glassTintOverlay.backgroundColor = material.legacyTintColor

        insertSubview(glassHost, at: 0)
        glassHost.addSubview(glassEffectView)
        glassHost.addSubview(glassTintOverlay)

        NSLayoutConstraint.activate([
            glassHost.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassHost.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassHost.topAnchor.constraint(equalTo: topAnchor),
            glassHost.bottomAnchor.constraint(equalTo: bottomAnchor),

            glassEffectView.leadingAnchor.constraint(equalTo: glassHost.leadingAnchor),
            glassEffectView.trailingAnchor.constraint(equalTo: glassHost.trailingAnchor),
            glassEffectView.topAnchor.constraint(equalTo: glassHost.topAnchor),
            glassEffectView.bottomAnchor.constraint(equalTo: glassHost.bottomAnchor),

            glassTintOverlay.leadingAnchor.constraint(equalTo: glassHost.leadingAnchor),
            glassTintOverlay.trailingAnchor.constraint(equalTo: glassHost.trailingAnchor),
            glassTintOverlay.topAnchor.constraint(equalTo: glassHost.topAnchor),
            glassTintOverlay.bottomAnchor.constraint(equalTo: glassHost.bottomAnchor),
        ])
    }
}
