//
//  MatchIntroOverlayView.swift
//  BubbleShooter
//

import UIKit

/// Fullscreen countdown overlay shown before match input is unlocked.
final class MatchIntroOverlayView: UIView {

    private let backgroundView = GradientBackgroundView()
    private let dimOverlay = UIView()
    private let card = GlassCardView()
    private let messageLabel = ArcadeLabel("GET READY", style: .title)

    private var countdownTimer: Timer?
    private var countdownIndex = 0
    private var completionHandler: (() -> Void)?

    private let countdownSteps = ["GET READY", "3", "2", "1", "GO!"]
    private let stepDurations: [TimeInterval] = [0.6, 0.7, 0.7, 0.7, 0.5]

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        countdownTimer?.invalidate()
    }

    func playCountdown(completion: @escaping () -> Void) {
        completionHandler = completion
        countdownIndex = 0
        isHidden = false
        alpha = 1
        showStep(animated: false)
        scheduleNextStep()
    }

    // MARK: - Private

    private func configure() {
        backgroundColor = .clear
        isHidden = true

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        dimOverlay.translatesAutoresizingMaskIntoConstraints = false
        dimOverlay.backgroundColor = Theme.Background.deep.withAlphaComponent(0.55)

        card.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundView)
        addSubview(dimOverlay)
        addSubview(card)
        card.contentView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            dimOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimOverlay.topAnchor.constraint(equalTo: topAnchor),
            dimOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),

            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            card.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
            card.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),

            messageLabel.centerXAnchor.constraint(equalTo: card.contentView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: card.contentView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: card.contentView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.contentView.trailingAnchor),
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
        ])
    }

    private func scheduleNextStep() {
        countdownTimer?.invalidate()
        let duration = stepDurations[min(countdownIndex, stepDurations.count - 1)]

        countdownTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.advanceCountdown()
        }
    }

    private func advanceCountdown() {
        countdownIndex += 1

        if countdownIndex >= countdownSteps.count {
            finishCountdown()
            return
        }

        showStep(animated: true)
        scheduleNextStep()
    }

    private func showStep(animated: Bool) {
        let text = countdownSteps[countdownIndex]
        let isGo = text == "GO!"
        messageLabel.text = text
        messageLabel.textColor = isGo ? Theme.Accent.gold : Theme.Text.primary
        messageLabel.font = isGo
            ? Theme.Typography.title(36)
            : (text.count == 1 ? Theme.Typography.title(48) : Theme.Typography.title())

        guard animated else { return }

        messageLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        messageLabel.alpha = 0
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.4
        ) {
            self.messageLabel.transform = .identity
            self.messageLabel.alpha = 1
        }
    }

    private func finishCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil

        UIView.animate(withDuration: 0.35, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
            self.completionHandler?()
            self.completionHandler = nil
        })
    }
}
