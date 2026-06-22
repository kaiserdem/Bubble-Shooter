//
//  GlassCardView.swift
//  BubbleShooter
//

import UIKit

/// Frosted glass panel with luminous border — container for menus and HUD blocks.
final class GlassCardView: UIView {

    let contentView = UIView()

    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let tintOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.Surface.fill
        view.isUserInteractionEnabled = false
        return view
    }()

    private let borderLayer = CAShapeLayer()

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
        layer.cornerRadius = Theme.Metrics.cornerRadiusLarge
        blurView.layer.cornerRadius = Theme.Metrics.cornerRadiusLarge
        tintOverlay.layer.cornerRadius = Theme.Metrics.cornerRadiusLarge
        contentView.layer.cornerRadius = Theme.Metrics.cornerRadiusLarge

        borderLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: Theme.Metrics.borderWidth / 2, dy: Theme.Metrics.borderWidth / 2),
            cornerRadius: Theme.Metrics.cornerRadiusLarge
        ).cgPath
        borderLayer.frame = bounds
    }

    private func configure() {
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = Theme.Surface.shadow.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 9)

        addSubview(blurView)
        addSubview(tintOverlay)
        addSubview(contentView)

        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            tintOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            tintOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            tintOverlay.topAnchor.constraint(equalTo: topAnchor),
            tintOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.contentPadding),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.contentPadding),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.contentPadding),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.contentPadding),
        ])

        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = Theme.Surface.border.cgColor
        borderLayer.lineWidth = Theme.Metrics.borderWidth
        layer.addSublayer(borderLayer)
    }
}
