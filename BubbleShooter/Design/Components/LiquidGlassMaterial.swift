//
//  LiquidGlassMaterial.swift
//  BubbleShooter
//

import UIKit

/// Shared glass materials — Liquid Glass on iOS 26+, blur fallback on earlier OS versions.
enum LiquidGlassMaterial {

    case card
    case panel
    case overlay
    /// Compact navigation controls on busy wallpapers (e.g. Back).
    case navigation

    func makeEffect() -> UIVisualEffect {
        if #available(iOS 26.0, *) {
            return makeLiquidGlassEffect()
        }
        return UIBlurEffect(style: legacyBlurStyle)
    }

    /// Prefer dark glass on colorful backgrounds — avoids milky white adaptation.
    var prefersDarkAppearance: Bool {
        true
    }

    var usesLegacyTintOverlay: Bool {
        if #available(iOS 26.0, *) {
            return false
        }
        return true
    }

    var legacyTintColor: UIColor {
        switch self {
        case .card:
            Theme.Background.deep.withAlphaComponent(0.22)
        case .panel:
            UIColor.white.withAlphaComponent(0.05)
        case .overlay:
            Theme.Background.deep.withAlphaComponent(0.28)
        case .navigation:
            Theme.Background.deep.withAlphaComponent(0.52)
        }
    }

    var legacyBlurAlpha: CGFloat {
        1
    }

    private var legacyBlurStyle: UIBlurEffect.Style {
        switch self {
        case .card, .panel:
            .systemChromeMaterialDark
        case .overlay, .navigation:
            .systemMaterialDark
        }
    }

    @available(iOS 26.0, *)
    private func makeLiquidGlassEffect() -> UIVisualEffect {
        switch self {
        case .card:
            return UIGlassEffect(style: .clear)
        case .panel:
            let effect = UIGlassEffect(style: .clear)
            effect.tintColor = UIColor.white.withAlphaComponent(0.04)
            return effect
        case .overlay:
            return UIGlassEffect(style: .regular)
        case .navigation:
            let effect = UIGlassEffect(style: .regular)
            effect.tintColor = Theme.Background.deep.withAlphaComponent(0.35)
            return effect
        }
    }
}
