//
//  MatchIntroOverlayView.swift
//  BubbleShooter
//

import UIKit

/// Full-screen frosted glass overlay with a 3-2-1 countdown before the match starts.
final class MatchIntroOverlayView: UIView {

    private let glassPanel = GlassPanelView()
    private let messageLabel = ArcadeLabel("3", style: .title)

    private var countdownTimer: Timer?
    private var countdownIndex = 0
    private var completionHandler: (() -> Void)?

    private let countdownSteps = ["3", "2", "1"]
    private let stepDuration: TimeInterval = 0.65

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
        isUserInteractionEnabled = true

        glassPanel.translatesAutoresizingMaskIntoConstraints = false
        glassPanel.style = .veil
        glassPanel.cornerRadius = 0
        glassPanel.showsBorder = false

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        Theme.Text.applyHUDLegibility(to: messageLabel)

        addSubview(glassPanel)
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            glassPanel.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassPanel.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassPanel.topAnchor.constraint(equalTo: topAnchor),
            glassPanel.bottomAnchor.constraint(equalTo: bottomAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
        ])
    }

    private func scheduleNextStep() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: false) { [weak self] _ in
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
        messageLabel.text = countdownSteps[countdownIndex]
        messageLabel.font = Theme.Typography.title(74)
        Theme.Text.applyHUDLegibility(to: messageLabel)

        guard animated else { return }

        messageLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        messageLabel.alpha = 0
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            self.messageLabel.transform = .identity
            self.messageLabel.alpha = 1
        }
    }

    private func finishCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil

        UIView.animate(withDuration: 0.28, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
            self.completionHandler?()
            self.completionHandler = nil
        })
    }
}
