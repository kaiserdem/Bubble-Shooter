//
//  GameHUDView.swift
//  BubbleShooter
//

import UIKit

/// Compact stats bar above the playfield — score, next bubble, timer.
final class GameHUDView: UIView {

    private let scoreCaptionLabel = ArcadeLabel("SCORE", style: .caption)
    private let scoreValueLabel = ArcadeLabel("0", style: .title)
    private let nextCaptionLabel = ArcadeLabel("NEXT", style: .caption)
    private let nextBubbleImageView = UIImageView()
    private let timerCaptionLabel = ArcadeLabel("TIME", style: .caption)
    private let timerValueLabel = ArcadeLabel("0:00", style: .headline)

    private let scoreFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with state: MatchHUDState) {
        scoreValueLabel.text = scoreFormatter.string(from: NSNumber(value: state.score)) ?? "\(state.score)"
        scoreValueLabel.textColor = state.score >= 10_000 ? Theme.Accent.gold : Theme.Text.primary

        timerValueLabel.text = Self.formatTime(state.timeRemainingSeconds)
        timerValueLabel.textColor = state.timeRemainingSeconds <= 10
            ? Theme.Accent.danger
            : Theme.Text.primary

        nextBubbleImageView.image = UIImage(named: state.nextBubble.spriteName)
    }

    // MARK: - Private

    private func configure() {
        isUserInteractionEnabled = true
        backgroundColor = Theme.Background.elevated.withAlphaComponent(0.55)
        layer.cornerRadius = Theme.Metrics.cornerRadiusMedium
        layer.borderWidth = Theme.Metrics.borderWidth
        layer.borderColor = Theme.Surface.borderSubtle.cgColor

        scoreCaptionLabel.textAlignment = .left
        scoreValueLabel.textAlignment = .left
        nextCaptionLabel.textAlignment = .center
        timerCaptionLabel.textAlignment = .right
        timerValueLabel.textAlignment = .right

        nextBubbleImageView.contentMode = .scaleAspectFit
        nextBubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        nextBubbleImageView.layer.cornerRadius = 16
        nextBubbleImageView.clipsToBounds = true

        let scoreColumn = UIStackView(arrangedSubviews: [scoreCaptionLabel, scoreValueLabel])
        scoreColumn.axis = .vertical
        scoreColumn.spacing = 2
        scoreColumn.alignment = .leading

        let nextColumn = UIStackView(arrangedSubviews: [nextCaptionLabel, nextBubbleImageView])
        nextColumn.axis = .vertical
        nextColumn.spacing = 4
        nextColumn.alignment = .center

        let timerColumn = UIStackView(arrangedSubviews: [timerCaptionLabel, timerValueLabel])
        timerColumn.axis = .vertical
        timerColumn.spacing = 2
        timerColumn.alignment = .trailing

        let statsRow = UIStackView(arrangedSubviews: [scoreColumn, nextColumn, timerColumn])
        statsRow.axis = .horizontal
        statsRow.alignment = .center
        statsRow.distribution = .fillEqually
        statsRow.translatesAutoresizingMaskIntoConstraints = false

        addSubview(statsRow)

        NSLayoutConstraint.activate([
            statsRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.contentPadding),
            statsRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.contentPadding),
            statsRow.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.spacingMedium),
            statsRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.spacingMedium),

            nextBubbleImageView.widthAnchor.constraint(equalToConstant: 32),
            nextBubbleImageView.heightAnchor.constraint(equalToConstant: 32),
        ])
    }

    private static func formatTime(_ totalSeconds: Int) -> String {
        let clamped = max(0, totalSeconds)
        let minutes = clamped / 60
        let seconds = clamped % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
