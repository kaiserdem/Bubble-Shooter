//
//  GlassPanelView.swift
//  BubbleShooter
//

import UIKit

/// Frosted glass chrome — blurs content behind the panel (e.g. match wallpaper).
final class GlassPanelView: UIView {

    var cornerRadius: CGFloat = Theme.Metrics.cornerRadiusMedium {
        didSet { setNeedsLayout() }
    }

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
        let radius = cornerRadius
        layer.cornerRadius = radius
        blurView.layer.cornerRadius = radius
        tintOverlay.layer.cornerRadius = radius

        borderLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: Theme.Metrics.borderWidth / 2, dy: Theme.Metrics.borderWidth / 2),
            cornerRadius: radius
        ).cgPath
        borderLayer.frame = bounds
    }

    private func configure() {
        isOpaque = false
        backgroundColor = .clear
        clipsToBounds = true

        addSubview(blurView)
        addSubview(tintOverlay)

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            tintOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            tintOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            tintOverlay.topAnchor.constraint(equalTo: topAnchor),
            tintOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = Theme.Surface.border.cgColor
        borderLayer.lineWidth = Theme.Metrics.borderWidth
        layer.addSublayer(borderLayer)
    }
}
