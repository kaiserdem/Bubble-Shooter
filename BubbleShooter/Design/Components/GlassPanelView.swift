//
//  GlassPanelView.swift
//  BubbleShooter
//

import UIKit

/// Frosted glass chrome — blurs content behind the panel (e.g. match wallpaper).
final class GlassPanelView: UIView {

  enum Style {
    /// Playfield and HUD blocks.
    case panel
    /// Full-screen overlays — countdown / loading veil.
    case veil
  }

  var style: Style = .panel {
    didSet { applyStyle() }
  }

  var cornerRadius: CGFloat = Theme.Metrics.cornerRadiusMedium {
    didSet { setNeedsLayout() }
  }

  var showsBorder: Bool = true {
    didSet { borderLayer.isHidden = !showsBorder }
  }

  private let roundedContainer = UIView()
  private let effectView = UIVisualEffectView()
  private let tintOverlay = UIView()
  private let borderLayer = CAShapeLayer()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
    applyStyle()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let radius = cornerRadius
    roundedContainer.layer.cornerRadius = radius

    if #available(iOS 26.0, *) {
      effectView.cornerConfiguration = .uniformCorners(radius: .fixed(radius))
    } else {
      effectView.layer.cornerRadius = radius
    }

    if currentMaterial.usesLegacyTintOverlay {
      tintOverlay.layer.cornerRadius = radius
    }

    borderLayer.path = UIBezierPath(
      roundedRect: roundedContainer.bounds.insetBy(
        dx: Theme.Metrics.borderWidth / 2,
        dy: Theme.Metrics.borderWidth / 2
      ),
      cornerRadius: radius
    ).cgPath
    borderLayer.frame = roundedContainer.bounds
  }

  private var currentMaterial: LiquidGlassMaterial {
    switch style {
    case .panel: .panel
    case .veil: .overlay
    }
  }

  private func configure() {
    isOpaque = false
    backgroundColor = .clear
    clipsToBounds = false

    roundedContainer.translatesAutoresizingMaskIntoConstraints = false
    roundedContainer.clipsToBounds = true
    roundedContainer.backgroundColor = .clear

    effectView.translatesAutoresizingMaskIntoConstraints = false
    effectView.clipsToBounds = true

    tintOverlay.translatesAutoresizingMaskIntoConstraints = false
    tintOverlay.isUserInteractionEnabled = false

    addSubview(roundedContainer)
    roundedContainer.addSubview(effectView)
    roundedContainer.addSubview(tintOverlay)
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
    ])

    borderLayer.fillColor = UIColor.clear.cgColor
    borderLayer.strokeColor = Theme.Surface.border.cgColor
    borderLayer.lineWidth = Theme.Metrics.borderWidth
  }

  private func applyStyle() {
    let material = currentMaterial

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
