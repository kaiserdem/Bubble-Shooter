//
//  GlassCardView.swift
//  BubbleShooter
//

import UIKit

/// Frosted glass panel with luminous border — container for menus and HUD blocks.
final class GlassCardView: UIView {

  /// Host for screen content — lives inside the visual effect view on iOS 26.
  let contentView = UIView()

  private let material: LiquidGlassMaterial = .card
  private let roundedContainer = UIView()
  private let effectView = UIVisualEffectView()
  private let tintOverlay = UIView()
  private let borderLayer = CAShapeLayer()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
    applyMaterial()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let radius = Theme.Metrics.cornerRadiusLarge
    roundedContainer.layer.cornerRadius = radius

    if #available(iOS 26.0, *) {
      effectView.cornerConfiguration = .uniformCorners(radius: .fixed(radius))
    } else {
      effectView.layer.cornerRadius = radius
    }

    if material.usesLegacyTintOverlay {
      tintOverlay.layer.cornerRadius = radius
    }

    layer.shadowPath = UIBezierPath(
      roundedRect: bounds,
      cornerRadius: radius
    ).cgPath

    borderLayer.path = UIBezierPath(
      roundedRect: roundedContainer.bounds.insetBy(
        dx: Theme.Metrics.borderWidth / 2,
        dy: Theme.Metrics.borderWidth / 2
      ),
      cornerRadius: radius
    ).cgPath
    borderLayer.frame = roundedContainer.bounds
  }

  private func configure() {
    isOpaque = false
    backgroundColor = .clear
    clipsToBounds = false

    layer.shadowColor = Theme.Surface.shadow.cgColor
    layer.shadowOpacity = 1
    layer.shadowRadius = 18
    layer.shadowOffset = CGSize(width: 0, height: 9)

    roundedContainer.translatesAutoresizingMaskIntoConstraints = false
    roundedContainer.clipsToBounds = true
    roundedContainer.backgroundColor = .clear

    effectView.translatesAutoresizingMaskIntoConstraints = false
    effectView.clipsToBounds = true

    tintOverlay.translatesAutoresizingMaskIntoConstraints = false
    tintOverlay.isUserInteractionEnabled = false

    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.backgroundColor = .clear

    addSubview(roundedContainer)
    roundedContainer.addSubview(effectView)
    roundedContainer.addSubview(tintOverlay)
    effectView.contentView.addSubview(contentView)
    roundedContainer.layer.addSublayer(borderLayer)

    NSLayoutConstraint.activate([
      roundedContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
      roundedContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
      roundedContainer.topAnchor.constraint(equalTo: topAnchor),
      roundedContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

      effectView.leadingAnchor.constraint(equalTo: roundedContainer.leadingAnchor),
      effectView.trailingAnchor.constraint(equalTo: roundedContainer.trailingAnchor),
      effectView.topAnchor.constraint(equalTo: roundedContainer.topAnchor),
      effectView.bottomAnchor.constraint(equalTo: roundedContainer.bottomAnchor),

      tintOverlay.leadingAnchor.constraint(equalTo: roundedContainer.leadingAnchor),
      tintOverlay.trailingAnchor.constraint(equalTo: roundedContainer.trailingAnchor),
      tintOverlay.topAnchor.constraint(equalTo: roundedContainer.topAnchor),
      tintOverlay.bottomAnchor.constraint(equalTo: roundedContainer.bottomAnchor),

      contentView.leadingAnchor.constraint(equalTo: effectView.contentView.leadingAnchor, constant: Theme.Metrics.contentPadding),
      contentView.trailingAnchor.constraint(equalTo: effectView.contentView.trailingAnchor, constant: -Theme.Metrics.contentPadding),
      contentView.topAnchor.constraint(equalTo: effectView.contentView.topAnchor, constant: Theme.Metrics.contentPadding),
      contentView.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor, constant: -Theme.Metrics.contentPadding),
    ])

    borderLayer.fillColor = UIColor.clear.cgColor
    borderLayer.strokeColor = Theme.Surface.border.cgColor
    borderLayer.lineWidth = Theme.Metrics.borderWidth
  }

  private func applyMaterial() {
    if material.prefersDarkAppearance {
      roundedContainer.overrideUserInterfaceStyle = .dark
    }

    effectView.effect = material.makeEffect()
    effectView.alpha = material.legacyBlurAlpha

    let usesTint = material.usesLegacyTintOverlay
    tintOverlay.isHidden = !usesTint
    tintOverlay.backgroundColor = material.legacyTintColor
  }
}
