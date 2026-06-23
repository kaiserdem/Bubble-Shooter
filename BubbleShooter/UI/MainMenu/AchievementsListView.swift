//
//  AchievementsListView.swift
//  BubbleShooter
//

import UIKit

/// Scrollable list of player achievements with progress and rewards.
final class AchievementsListView: LobbyScreenView {

    private let summaryLabel = ArcadeLabel("", style: .body)
    private let introLabel = ArcadeLabel(
        "Complete goals to earn coins and exclusive cosmetics.",
        style: .caption
    )
    private let itemsStack = UIStackView()
    private var itemRows: [AchievementRowCard] = []

    init() {
        super.init(screenTitle: "Achievements")
        configureContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadFromStorage() {
        let progress = AchievementService.shared.progress
        let progression = SkillzProgressionService.shared.state
        let completed = AchievementDefinition.all.filter { progress.isClaimed($0.id) }.count
        summaryLabel.text = "\(completed) of \(AchievementDefinition.all.count) completed"

        for (row, definition) in zip(itemRows, AchievementDefinition.all) {
            row.configure(
                definition: definition,
                progress: progress,
                progression: progression
            )
        }
    }

    override func present(animated: Bool = true) {
        reloadFromStorage()
        AchievementService.shared.refresh { [weak self] in
            DispatchQueue.main.async {
                self?.reloadFromStorage()
            }
        }
        super.present(animated: animated)
    }

    // MARK: - Private

    private func configureContent() {
        summaryLabel.textAlignment = .center
        summaryLabel.textColor = Theme.Accent.gold
        Theme.Text.applyHUDLegibility(to: summaryLabel, color: Theme.Accent.gold)

        introLabel.textAlignment = .center
        introLabel.numberOfLines = 0
        Theme.Text.applyHUDLegibility(to: introLabel, color: Theme.Text.muted)

        itemsStack.axis = .vertical
        itemsStack.spacing = Theme.Metrics.spacingMedium
        itemsStack.translatesAutoresizingMaskIntoConstraints = false

        for _ in AchievementDefinition.all {
            let row = AchievementRowCard()
            itemRows.append(row)
            itemsStack.addArrangedSubview(row)
        }

        scrollStack.addArrangedSubview(summaryLabel)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingSmall, after: summaryLabel)
        scrollStack.addArrangedSubview(introLabel)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: introLabel)
        scrollStack.addArrangedSubview(itemsStack)
    }
}

// MARK: - AchievementRowCard

private final class AchievementRowCard: UIView {

    private let rewardPreview = AchievementRewardPreviewView()
    private let tierBadge = BadgeView(text: "BRONZE", tint: Theme.Accent.gold)
    private let titleLabel = ArcadeLabel("", style: .headline)
    private let detailLabel = ArcadeLabel("", style: .caption)
    private let progressLabel = ArcadeLabel("", style: .caption)
    private let rewardCaptionLabel = ArcadeLabel("Reward", style: .caption)
    private let rewardLabel = ArcadeLabel("", style: .body)
    private let claimedBadge = BadgeView(text: "CLAIMED", tint: Theme.Accent.primary)
    private let progressTrack = UIView()
    private let progressFill = UIView()
    private var progressWidthConstraint: NSLayoutConstraint?
    private var rewardPreviewWidthConstraint: NSLayoutConstraint?
    private var rewardPreviewHeightConstraint: NSLayoutConstraint?
    private var storedProgressFraction: Float = 0
    private var progressFillColor = Theme.Accent.primary

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureChrome()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        definition: AchievementDefinition,
        progress: AchievementProgressState,
        progression: PlayerProgressionState
    ) {
        let isClaimed = progress.isClaimed(definition.id)
        let isComplete = definition.isComplete(progress: progress, progression: progression)

        titleLabel.text = definition.title
        detailLabel.text = definition.detail
        rewardLabel.text = definition.reward.displayText
        progressLabel.text = isClaimed ? "Completed" : definition.progressText(
            progress: progress,
            progression: progression
        )

        rewardPreview.configure(definition: definition)
        updateRewardPreviewSize(for: definition.reward)

        switch definition.tier {
        case .bronze:
            tierBadge.text = "BRONZE"
            progressFillColor = Theme.Accent.gold.withAlphaComponent(0.85)
        case .silver:
            tierBadge.text = "SILVER"
            progressFillColor = Theme.Accent.secondary
        case .gold:
            tierBadge.text = "GOLD"
            progressFillColor = Theme.Accent.gold
        }
        progressFill.backgroundColor = progressFillColor

        claimedBadge.isHidden = !isClaimed

        storedProgressFraction = isClaimed ? 1 : definition.progressFraction(
            progress: progress,
            progression: progression
        )
        updateProgressBar(fraction: storedProgressFraction)

        if isClaimed {
            progressLabel.textColor = Theme.Accent.primary
            rewardLabel.textColor = Theme.Accent.gold
            layer.borderColor = Theme.Accent.primary.withAlphaComponent(0.5).cgColor
            alpha = 0.92
        } else if isComplete {
            progressLabel.textColor = Theme.Accent.gold
            rewardLabel.textColor = Theme.Text.primary
            layer.borderColor = Theme.Accent.gold.withAlphaComponent(0.45).cgColor
            alpha = 1
        } else {
            progressLabel.textColor = Theme.Text.muted
            rewardLabel.textColor = Theme.Text.secondary
            layer.borderColor = Theme.Surface.borderSubtle.cgColor
            alpha = 1
        }
    }

    // MARK: - Private

    private func configureChrome() {
        backgroundColor = Theme.Surface.fillStrong
        layer.cornerRadius = Theme.Metrics.cornerRadiusMedium
        layer.borderWidth = Theme.Metrics.borderWidth

        titleLabel.textAlignment = .left
        detailLabel.textAlignment = .left
        detailLabel.numberOfLines = 0
        progressLabel.textAlignment = .left
        rewardCaptionLabel.textAlignment = .left
        rewardLabel.textAlignment = .left

        Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.primary)
        Theme.Text.applyHUDLegibility(to: detailLabel, color: Theme.Text.secondary)
        Theme.Text.applyHUDLegibility(to: rewardCaptionLabel, color: Theme.Text.muted)
        Theme.Text.applyHUDLegibility(to: rewardLabel, color: Theme.Text.secondary)

        progressTrack.backgroundColor = Theme.Surface.fill
        progressTrack.layer.cornerRadius = 4
        progressTrack.translatesAutoresizingMaskIntoConstraints = false

        progressFill.backgroundColor = Theme.Accent.primary
        progressFill.layer.cornerRadius = 4
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressTrack.addSubview(progressFill)

        claimedBadge.isHidden = true

        let header = UIStackView(arrangedSubviews: [tierBadge, titleLabel, UIView()])
        header.axis = .horizontal
        header.spacing = Theme.Metrics.spacingSmall
        header.alignment = .center

        let topStack = UIStackView(arrangedSubviews: [
            header,
            detailLabel,
            progressTrack,
            progressLabel,
            claimedBadge,
        ])
        topStack.axis = .vertical
        topStack.spacing = Theme.Metrics.spacingSmall
        topStack.alignment = .fill
        topStack.translatesAutoresizingMaskIntoConstraints = false

        let rewardTextStack = UIStackView(arrangedSubviews: [rewardCaptionLabel, rewardLabel])
        rewardTextStack.axis = .vertical
        rewardTextStack.spacing = 2
        rewardTextStack.alignment = .leading
        rewardTextStack.translatesAutoresizingMaskIntoConstraints = false

        rewardPreview.translatesAutoresizingMaskIntoConstraints = false

        let rewardRow = UIStackView(arrangedSubviews: [rewardPreview, rewardTextStack])
        rewardRow.axis = .horizontal
        rewardRow.spacing = Theme.Metrics.spacingMedium
        rewardRow.alignment = .center
        rewardRow.translatesAutoresizingMaskIntoConstraints = false

        let cardStack = UIStackView(arrangedSubviews: [topStack, rewardRow])
        cardStack.axis = .vertical
        cardStack.spacing = Theme.Metrics.spacingMedium
        cardStack.alignment = .fill
        cardStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(cardStack)

        let widthConstraint = progressFill.widthAnchor.constraint(equalToConstant: 0)
        progressWidthConstraint = widthConstraint

        let rewardWidth = rewardPreview.widthAnchor.constraint(equalToConstant: RewardPreviewMetrics.giftSize)
        let rewardHeight = rewardPreview.heightAnchor.constraint(equalToConstant: RewardPreviewMetrics.giftSize)
        rewardPreviewWidthConstraint = rewardWidth
        rewardPreviewHeightConstraint = rewardHeight

        NSLayoutConstraint.activate([
            cardStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.spacingMedium),
            cardStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.spacingMedium),
            cardStack.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.spacingMedium),
            cardStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.spacingMedium),

            rewardWidth,
            rewardHeight,

            progressTrack.heightAnchor.constraint(equalToConstant: 8),
            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            widthConstraint,
        ])
    }

    private func updateRewardPreviewSize(for reward: AchievementReward) {
        let size: CGFloat
        switch reward {
        case .coins:
            size = RewardPreviewMetrics.coinSize
        case .cosmetic:
            size = RewardPreviewMetrics.giftSize
        }
        rewardPreviewWidthConstraint?.constant = size
        rewardPreviewHeightConstraint?.constant = size
    }

    private func updateProgressBar(fraction: Float) {
        layoutIfNeeded()
        let clamped = CGFloat(min(1, max(0, fraction)))
        progressWidthConstraint?.constant = progressTrack.bounds.width * clamped
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateProgressBar(fraction: storedProgressFraction)
    }
}

// MARK: - Reward preview sizing

private enum RewardPreviewMetrics {
    static let giftSize: CGFloat = 72
    static let coinSize: CGFloat = giftSize * 0.8
}

// MARK: - AchievementRewardPreviewView

private final class AchievementRewardPreviewView: UIView {

    private let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(definition: AchievementDefinition) {
        iconView.image = UIImage(named: AchievementRewardArt.previewIconName(for: definition))
    }

    // MARK: - Private

    private func configure() {
        backgroundColor = .clear

        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
