//
//  ArcadeLabel.swift
//  BubbleShooter
//

import UIKit

enum ArcadeLabelStyle {
    case title
    case headline
    case body
    case caption
}

/// Typography-aligned label for menus and HUD.
final class ArcadeLabel: UILabel {

    init(_ text: String, style: ArcadeLabelStyle = .body, color: UIColor? = nil) {
        super.init(frame: .zero)
        self.text = text
        apply(style: style, color: color)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func apply(style: ArcadeLabelStyle, color: UIColor?) {
        numberOfLines = 0
        textAlignment = .center

        switch style {
        case .title:
            font = Theme.Typography.title()
            textColor = color ?? Theme.Text.primary
        case .headline:
            font = Theme.Typography.headline()
            textColor = color ?? Theme.Text.primary
        case .body:
            font = Theme.Typography.body()
            textColor = color ?? Theme.Text.secondary
        case .caption:
            font = Theme.Typography.caption()
            textColor = color ?? Theme.Text.muted
        }
    }
}
