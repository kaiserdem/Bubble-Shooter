//
//  AchievementUnlockedOverlayView.swift
//  BubbleShooter
//

import UIKit

/// Celebrates a newly unlocked achievement with its reward.
final class AchievementUnlockedOverlayView: ModalCardOverlayView {

    var onDismiss: (() -> Void)?

    private let badge = BadgeView(text: "BONUS", tint: Theme.Accent.gold)
    private let titleLabel = ArcadeLabel("", style: .title)
    private let detailLabel = ArcadeLabel("", style: .body)
    private let rewardIconView = UIImageView()
    private let rewardLabel = ArcadeLabel("", style: .headline, color: Theme.Accent.gold)
    private let actionButton = ArcadeButton(title: "Collect", style: .primary)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(definition: AchievementDefinition) {
        if definition.id == .shopper {
            badge.text = "BONUS"
            titleLabel.text = "First Purchase Bonus!"
            detailLabel.text = "You received a bonus for your first shop purchase."
        } else {
            badge.text = "ACHIEVEMENT"
            titleLabel.text = "Achievement Unlocked!"
            detailLabel.text = definition.title
        }

        rewardIconView.image = UIImage(named: AchievementRewardArt.previewIconName(for: definition))
        rewardLabel.text = rewardDescription(for: definition.reward)
    }

    // MARK: - Private

    private func rewardDescription(for reward: AchievementReward) -> String {
        switch reward {
        case .coins(let amount):
            "\(amount) bonus coins"
        case .cosmetic(let item):
            item.displayName
        }
    }

    private func configureContent() {
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = Theme.Text.primary

        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        detailLabel.textColor = Theme.Text.secondary

        rewardIconView.contentMode = .scaleAspectFit
        rewardIconView.translatesAutoresizingMaskIntoConstraints = false

        rewardLabel.textAlignment = .center
        rewardLabel.numberOfLines = 0
        rewardLabel.textColor = Theme.Accent.gold

        actionButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.onDismiss?()
            }
        }, for: .touchUpInside)

        let badgeRow = UIStackView(arrangedSubviews: [badge, UIView()])
        badgeRow.axis = .horizontal
        badgeRow.alignment = .center

        let rewardStack = UIStackView(arrangedSubviews: [rewardIconView, rewardLabel])
        rewardStack.axis = .vertical
        rewardStack.spacing = Theme.Metrics.spacingSmall
        rewardStack.alignment = .center

        contentStack.addArrangedSubview(badgeRow)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(detailLabel)
        contentStack.addArrangedSubview(rewardStack)
        contentStack.addArrangedSubview(actionButton)

        NSLayoutConstraint.activate([
            rewardIconView.widthAnchor.constraint(equalToConstant: 88),
            rewardIconView.heightAnchor.constraint(equalToConstant: 88),
            actionButton.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
        ])
    }
}
