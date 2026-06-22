//
//  LiquidGlassMaterial.swift
//  BubbleShooter
//

import UIKit

/// Shared glass materials — Liquid Glass on iOS 26+, blur fallback on earlier OS versions.
enum LiquidGlassMaterial {

    case card
    case panel
    /// Match playfield — milkier glass so bubbles read clearly on wallpaper.
    case playfield
    case overlay
    /// Post-match results card — full-bleed rounded fill, no inset square backdrop.
    case results
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
        showsTintOverlay
    }

    /// Tint layer on top of blur — always on for playfield; legacy-only for other styles.
    var showsTintOverlay: Bool {
        switch self {
        case .playfield, .results: return true
        default:
            if #available(iOS 26.0, *) {
                return false
            }
            return true
        }
    }

    var legacyTintColor: UIColor {
        tintOverlayColor
    }

    var tintOverlayColor: UIColor {
        switch self {
        case .card:
            Theme.Background.deep.withAlphaComponent(0.22)
        case .panel:
            UIColor.white.withAlphaComponent(0.05)
        case .playfield:
            UIColor.white.withAlphaComponent(0.10)
        case .overlay:
            Theme.Background.deep.withAlphaComponent(0.28)
        case .results:
            Theme.Background.deep.withAlphaComponent(0.62)
        case .navigation:
            Theme.Background.deep.withAlphaComponent(0.52)
        }
    }

    var legacyBlurAlpha: CGFloat {
        1
    }

    private var legacyBlurStyle: UIBlurEffect.Style {
        switch self {
        case .card, .panel, .playfield:
            .systemChromeMaterialDark
        case .overlay, .navigation, .results:
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
        case .playfield:
            let effect = UIGlassEffect(style: .clear)
            effect.tintColor = UIColor.white.withAlphaComponent(0.07)
            return effect
        case .overlay:
            return UIGlassEffect(style: .regular)
        case .results:
            let effect = UIGlassEffect(style: .regular)
            effect.tintColor = Theme.Background.deep.withAlphaComponent(0.42)
            return effect
        case .navigation:
            let effect = UIGlassEffect(style: .regular)
            effect.tintColor = Theme.Background.deep.withAlphaComponent(0.35)
            return effect
        }
    }
}
