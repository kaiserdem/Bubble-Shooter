//
//  AchievementsListView.swift
//  BubbleShooter
//

import UIKit

/// Scrollable list of player achievements with progress and rewards.
final class AchievementsListView: LobbyScreenView {

    private let summaryLabel = ArcadeLabel("", style: .body)
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
        Theme.Text.applyHUDLegibility(to: summaryLabel, color: Theme.Text.secondary)

        itemsStack.axis = .vertical
        itemsStack.spacing = Theme.Metrics.spacingMedium
        itemsStack.translatesAutoresizingMaskIntoConstraints = false

        for definition in AchievementDefinition.all {
            let row = AchievementRowCard()
            itemRows.append(row)
            itemsStack.addArrangedSubview(row)
        }

        scrollStack.addArrangedSubview(summaryLabel)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: summaryLabel)
        scrollStack.addArrangedSubview(itemsStack)
    }
}

// MARK: - AchievementRowCard

private final class AchievementRowCard: UIView {

    private let tierBadge = BadgeView(text: "BRONZE", tint: Theme.Accent.secondary)
    private let titleLabel = ArcadeLabel("", style: .headline)
    private let detailLabel = ArcadeLabel("", style: .caption)
    private let progressLabel = ArcadeLabel("", style: .caption)
    private let rewardLabel = ArcadeLabel("", style: .body)
    private let progressTrack = UIView()
    private let progressFill = UIView()
    private var progressWidthConstraint: NSLayoutConstraint?
    private var storedProgressFraction: Float = 0

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
        rewardLabel.text = "Reward: \(definition.reward.displayText)"
        progressLabel.text = isClaimed ? "Claimed" : definition.progressText(
            progress: progress,
            progression: progression
        )

        switch definition.tier {
        case .bronze:
            tierBadge.text = "BRONZE"
        case .silver:
            tierBadge.text = "SILVER"
        case .gold:
            tierBadge.text = "GOLD"
        }

        storedProgressFraction = isClaimed ? 1 : definition.progressFraction(
            progress: progress,
            progression: progression
        )
        updateProgressBar(fraction: storedProgressFraction)

        if isClaimed {
            progressLabel.textColor = Theme.Accent.primary
            rewardLabel.textColor = Theme.Accent.gold
            layer.borderColor = Theme.Accent.primary.withAlphaComponent(0.45).cgColor
        } else if isComplete {
            progressLabel.textColor = Theme.Accent.gold
            rewardLabel.textColor = Theme.Text.secondary
            layer.borderColor = Theme.Accent.gold.withAlphaComponent(0.35).cgColor
        } else {
            progressLabel.textColor = Theme.Text.muted
            rewardLabel.textColor = Theme.Text.secondary
            layer.borderColor = Theme.Surface.borderSubtle.cgColor
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
        rewardLabel.textAlignment = .left

        Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.primary)
        Theme.Text.applyHUDLegibility(to: detailLabel, color: Theme.Text.secondary)
        Theme.Text.applyHUDLegibility(to: rewardLabel, color: Theme.Text.secondary)

        progressTrack.backgroundColor = Theme.Surface.fill
        progressTrack.layer.cornerRadius = 3
        progressTrack.translatesAutoresizingMaskIntoConstraints = false

        progressFill.backgroundColor = Theme.Accent.primary
        progressFill.layer.cornerRadius = 3
        progressFill.translatesAutoresizingMaskIntoConstraints = false

        progressTrack.addSubview(progressFill)

        let header = UIStackView(arrangedSubviews: [tierBadge, titleLabel])
        header.axis = .horizontal
        header.spacing = Theme.Metrics.spacingSmall
        header.alignment = .center

        let stack = UIStackView(arrangedSubviews: [
            header,
            detailLabel,
            progressTrack,
            progressLabel,
            rewardLabel,
        ])
        stack.axis = .vertical
        stack.spacing = Theme.Metrics.spacingSmall
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        let widthConstraint = progressFill.widthAnchor.constraint(equalToConstant: 0)
        progressWidthConstraint = widthConstraint

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.spacingMedium),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.spacingMedium),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.spacingMedium),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.spacingMedium),

            progressTrack.heightAnchor.constraint(equalToConstant: 6),
            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            widthConstraint,
        ])
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
