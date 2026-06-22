//
//  GradientBackgroundView.swift
//  BubbleShooter
//

import UIKit

/// Full-screen cosmic gradient used behind menus and overlays.
final class GradientBackgroundView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        configureGradient()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private func configureGradient() {
        gradientLayer.colors = [
            Theme.Background.gradientTop.cgColor,
            Theme.Background.mid.cgColor,
            Theme.Background.gradientBottom.cgColor,
        ]
        gradientLayer.locations = [0, 0.55, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
