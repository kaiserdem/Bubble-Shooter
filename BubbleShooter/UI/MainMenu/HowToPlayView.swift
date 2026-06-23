//
//  HowToPlayView.swift
//  BubbleShooter
//

import UIKit

/// Full-screen guide — gameplay, Skillz, shop, achievements, and settings.
final class HowToPlayView: LobbyScreenView {

    private let introLabel = ArcadeLabel(
        """
        Everything you can do in Bubble Shooter — from your first match to unlocking cosmetics and achievements.
        """,
        style: .body
    )

    init() {
        super.init(screenTitle: "How to Play")
        configureContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func configureContent() {
        introLabel.textAlignment = .left
        introLabel.numberOfLines = 0
        Theme.Text.applyHUDLegibility(to: introLabel, color: Theme.Text.secondary)

        scrollStack.addArrangedSubview(introLabel)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: introLabel)

        for (index, section) in Self.sections.enumerated() {
            scrollStack.addArrangedSubview(
                GuideSectionHeader(title: section.title, iconName: section.iconName)
            )

            for item in section.items {
                scrollStack.addArrangedSubview(
                    RuleCard(
                        title: item.title,
                        detail: item.detail,
                        previewImageNames: item.previewImageNames
                    )
                )
            }

            if index < Self.sections.count - 1 {
                scrollStack.setCustomSpacing(
                    Theme.Metrics.spacingLarge,
                    after: scrollStack.arrangedSubviews.last!
                )
            }
        }
    }

    private struct GuideItem {
        let title: String
        let detail: String
        let previewImageNames: [String]?
    }

    private struct GuideSection {
        let title: String
        let iconName: String?
        let items: [GuideItem]
    }

    private static let coinReward = PlayerProgressionState.matchCoinReward
    private static let startingCoins = PlayerProgressionState.startingCoins

    private static let sections: [GuideSection] = [
        GuideSection(
            title: "Main menu",
            iconName: nil,
            items: [
                GuideItem(
                    title: "Play",
                    detail: "Opens Skillz tournaments. Pick a match, play your board, and submit your score.",
                    previewImageNames: nil
                ),
                GuideItem(
                    title: "Shop",
                    detail: "Spend coins on bubble styles and cannon skins. Equipped looks apply on the next match.",
                    previewImageNames: nil
                ),
                GuideItem(
                    title: "Achievements",
                    detail: "Track 12 goals — earn bonus coins and exclusive cosmetics as you play.",
                    previewImageNames: nil
                ),
                GuideItem(
                    title: "Settings",
                    detail: "Toggle sound effects, background music, and haptic feedback.",
                    previewImageNames: nil
                ),
            ]
        ),
        GuideSection(
            title: "Gameplay",
            iconName: nil,
            items: [
                GuideItem(
                    title: "Aim & shoot",
                    detail: "Drag from the cannon to aim. Bubbles bounce off the side walls until they stick to the hex grid.",
                    previewImageNames: [
                        "Collection1/Ruby-1",
                        "Collection1/Aqua-1",
                        "Collection1/Lime-1",
                    ]
                ),
                GuideItem(
                    title: "Pop groups",
                    detail: "Match 3 or more bubbles of the same color. Each popped bubble adds +10 points.",
                    previewImageNames: nil
                ),
                GuideItem(
                    title: "Drop clusters",
                    detail: "Bubbles that are no longer connected to the ceiling fall away. Each dropped bubble also adds +10 points.",
                    previewImageNames: nil
                ),
                GuideItem(
                    title: "Beat the clock",
                    detail: "Score as much as you can before time runs out. Leftover seconds add a time bonus at the end.",
                    previewImageNames: nil
                ),
                GuideItem(
                    title: "Danger line",
                    detail: "If bubbles cross the red line near the bottom, the match ends early — keep the stack high on the board.",
                    previewImageNames: nil
                ),
            ]
        ),
        GuideSection(
            title: "Skillz tournaments",
            iconName: nil,
            items: [
                GuideItem(
                    title: "Fair competition",
                    detail: "Everyone in a tournament plays the same board seed. Highest score wins.",
                    previewImageNames: nil
                ),
                GuideItem(
                    title: "Submit your score",
                    detail: "When the match ends, your result is sent to Skillz. Check the tournament screen for placement and prizes.",
                    previewImageNames: nil
                ),
            ]
        ),
        GuideSection(
            title: "Shop & coins",
            iconName: Theme.Asset.Shop.coin2,
            items: [
                GuideItem(
                    title: "Earn coins",
                    detail: "You start with \(startingCoins) coins. Finish any match to earn \(coinReward) more. Achievements grant bonus coins too.",
                    previewImageNames: nil
                ),
                GuideItem(
                    title: "Bubble styles",
                    detail: "Classic is free. Unlock 5 paid packs — Ribbon, Shimmer, Planet, Glossy, and Inner Glow — then tap Equip.",
                    previewImageNames: nil
                ),
                GuideItem(
                    title: "Cannon skins",
                    detail: "Twilight Glass is free. Eight premium cannons are available — from Copper Tide to Cosmic Gold.",
                    previewImageNames: ["gun-1"]
                ),
            ]
        ),
        GuideSection(
            title: "Achievements",
            iconName: Theme.Asset.Shop.gift2,
            items: [
                GuideItem(
                    title: "Play & improve",
                    detail: "Goals include finishing matches, popping bubbles, clearing the board, and hitting high scores.",
                    previewImageNames: nil
                ),
                GuideItem(
                    title: "Rewards",
                    detail: "Bronze and silver tiers pay coins or unlock shop cosmetics. Gold achievements award exclusive bubble packs and cannons.",
                    previewImageNames: nil
                ),
            ]
        ),
    ]
}

// MARK: - GuideSectionHeader

private final class GuideSectionHeader: UIView {

    init(title: String, iconName: String?) {
        super.init(frame: .zero)
        configure(title: title, iconName: iconName)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(title: String, iconName: String?) {
        let label = ArcadeLabel(title, style: .headline)
        label.textAlignment = .left
        Theme.Text.applyHUDLegibility(to: label, color: Theme.Accent.secondary)

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = Theme.Metrics.spacingSmall
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        if let iconName, let image = UIImage(named: iconName) {
            let iconView = UIImageView(image: image)
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.widthAnchor.constraint(equalToConstant: 36),
                iconView.heightAnchor.constraint(equalToConstant: 36),
            ])
            row.addArrangedSubview(iconView)
        }

        row.addArrangedSubview(label)
        addSubview(row)

        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            row.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }
}

// MARK: - RuleCard

private final class RuleCard: UIView {

    init(title: String, detail: String, previewImageNames: [String]?) {
        super.init(frame: .zero)
        configure(title: title, detail: detail, previewImageNames: previewImageNames)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(title: String, detail: String, previewImageNames: [String]?) {
        backgroundColor = Theme.Surface.fillStrong
        layer.cornerRadius = Theme.Metrics.cornerRadiusMedium
        layer.borderWidth = Theme.Metrics.borderWidth
        layer.borderColor = Theme.Surface.borderSubtle.cgColor

        let titleLabel = ArcadeLabel(title, style: .body)
        titleLabel.textAlignment = .left
        Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.primary)

        let detailLabel = ArcadeLabel(detail, style: .caption)
        detailLabel.textAlignment = .left
        detailLabel.numberOfLines = 0
        Theme.Text.applyHUDLegibility(to: detailLabel, color: Theme.Text.secondary)

        var arrangedSubviews: [UIView] = []

        if let previewImageNames, !previewImageNames.isEmpty {
            let previewRow = UIStackView()
            previewRow.axis = .horizontal
            previewRow.spacing = 8
            previewRow.alignment = .center
            previewRow.distribution = .fillEqually

            for name in previewImageNames {
                let imageView = UIImageView(image: UIImage(named: name))
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.heightAnchor.constraint(equalToConstant: 40),
                ])
                previewRow.addArrangedSubview(imageView)
            }

            arrangedSubviews.append(previewRow)
        }

        arrangedSubviews.append(titleLabel)
        arrangedSubviews.append(detailLabel)

        let stack = UIStackView(arrangedSubviews: arrangedSubviews)
        stack.axis = .vertical
        stack.spacing = Theme.Metrics.spacingSmall
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.spacingMedium),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.spacingMedium),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.spacingMedium),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.spacingMedium),
        ])
    }
}
