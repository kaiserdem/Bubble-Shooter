//
//  Theme.swift
//  BubbleShooter
//
//  Design system: "Cosmic Pop Twilight" — суміш темного космосу й світлого неба.
//

import UIKit
import SpriteKit

enum Theme {

    // MARK: - Brand

    enum Brand {
        static let name = "Cosmic Pop"
        static let variant = "Twilight"
    }

    // MARK: - Assets

    enum Asset {
        enum Background {
            static let lobby = "lobby background"
            static let game = "game background"
        }
    }

    // MARK: - Backgrounds

    enum Background {
        static let deep = UIColor(hex: 0x243558)
        static let mid = UIColor(hex: 0x2E4268)
        static let elevated = UIColor(hex: 0x3A5080)

        static var gradientTop: UIColor { UIColor(hex: 0x3D5288) }
        static var gradientBottom: UIColor { UIColor(hex: 0x1A2648) }
    }

    // MARK: - Accents

    enum Accent {
        static let primary = UIColor(hex: 0x468AFF)
        static let primaryGlow = UIColor(hex: 0x7358FF)
        static let secondary = UIColor(hex: 0x00DDE0)
        static let gold = UIColor(hex: 0xFFC44B)
        static let danger = UIColor(hex: 0xFF4C6B)
    }

    // MARK: - Text

    enum Text {
        static let onLight = UIColor(hex: 0x1B2D4F)
        static let onDark = UIColor(hex: 0xFFFFFF)

        static let primary = UIColor(hex: 0xEAF0FF)
        static let secondary = UIColor(hex: 0xA8B8D8)
        static let muted = UIColor(hex: 0x7A8AAA)

        /// White HUD text with a dark drop shadow for legibility on glass backgrounds.
        static func applyHUDLegibility(to label: UILabel, color: UIColor = onDark) {
            label.textColor = color
            label.shadowColor = UIColor.black.withAlphaComponent(0.82)
            label.shadowOffset = CGSize(width: 0, height: 1)
        }
    }

    // MARK: - Surfaces (glass)

    enum Surface {
        static let fill = UIColor.white.withAlphaComponent(0.12)
        static let fillStrong = UIColor.white.withAlphaComponent(0.20)
        static let border = UIColor.white.withAlphaComponent(0.32)
        static let borderSubtle = UIColor.white.withAlphaComponent(0.16)
        static let shadow = UIColor(hex: 0x000000, alpha: 0.32)
    }

    // MARK: - Bubble palette (gameplay)

    enum Bubble {
        static let ruby = UIColor(hex: 0xFF3D62)
        static let amber = UIColor(hex: 0xFFAB2B)
        static let lime = UIColor(hex: 0x72E763)
        static let aqua = UIColor(hex: 0x22D4FF)
        static let violet = UIColor(hex: 0xB460F8)
        static let rose = UIColor(hex: 0xFF5299)

        static let all: [UIColor] = [ruby, amber, lime, aqua, violet, rose]

        static func uiColor(at index: Int) -> UIColor {
            all[index % all.count]
        }

        static func skColor(at index: Int) -> SKColor {
            SKColor(cgColor: uiColor(at: index).cgColor)
        }
    }

    // MARK: - Metrics

    enum Metrics {
        static let cornerRadiusLarge: CGFloat = 24
        static let cornerRadiusMedium: CGFloat = 16
        static let cornerRadiusSmall: CGFloat = 12
        static let borderWidth: CGFloat = 1.5
        static let borderWidthGlow: CGFloat = 2
        static let contentPadding: CGFloat = 20
        static let buttonHeight: CGFloat = 52
        static let buttonMinWidth: CGFloat = 240
        static let spacingSmall: CGFloat = 8
        static let spacingMedium: CGFloat = 16
        static let spacingLarge: CGFloat = 24
    }

    // MARK: - Typography

    enum Typography {
        /// PostScript name inside `boinklet.ttf` (Boink LET Plain).
        static let postScriptName = "BoinkLET-Plain"

        static func title(_ size: CGFloat = 28) -> UIFont {
            font(size: size)
        }

        static func headline(_ size: CGFloat = 20) -> UIFont {
            font(size: size)
        }

        static func body(_ size: CGFloat = 16) -> UIFont {
            font(size: size)
        }

        static func caption(_ size: CGFloat = 13) -> UIFont {
            font(size: size)
        }

        static func skTitle(_ size: CGFloat = 28) -> String {
            postScriptName
        }

        static func skBody(_ size: CGFloat = 16) -> String {
            postScriptName
        }

        private static func font(size: CGFloat) -> UIFont {
            UIFont(name: postScriptName, size: size)
                ?? .systemFont(ofSize: size, weight: .bold)
        }
    }

    // MARK: - SpriteKit

    enum SK {
        static var backgroundDeep: SKColor { SKColor(cgColor: Background.deep.cgColor) }
        static var textPrimary: SKColor { SKColor(cgColor: Text.primary.cgColor) }
        static var accentGold: SKColor { SKColor(cgColor: Accent.gold.cgColor) }
        static var accentCyan: SKColor { SKColor(cgColor: Accent.secondary.cgColor) }
    }
}

// MARK: - UIColor hex

extension UIColor {

    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

