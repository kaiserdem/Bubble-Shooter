//
//  MatchResultsView.swift
//  BubbleShooter
//

import UIKit

/// Fullscreen overlay shown when a match ends.
final class MatchResultsView: UIView {

    var onContinue: (() -> Void)?

    private let backdropBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let backdropTint = UIView()
    private let cardPanel = UIView()
    private let titleLabel = ArcadeLabel("MATCH COMPLETE", style: .headline)
    private let scoreLabel = ArcadeLabel("0", style: .title)
    private let newBestBadge = BadgeView(text: "NEW BEST", tint: Theme.Accent.gold)
    private let popRow = BreakdownRow(title: "Pop")
    private let dropRow = BreakdownRow(title: "Drop")
    private let timeBonusRow = BreakdownRow(title: "Time bonus")
    private let continueButton = ArcadeButton(title: "Submit Score", style: .primary)

    private let scoreFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private var displayedScore = 0
    private var scoreAnimationDisplayLink: CADisplayLink?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        scoreAnimationDisplayLink?.invalidate()
    }

    func present(with state: MatchResultsState, animated: Bool = true) {
        isHidden = false
        titleLabel.text = Self.title(for: state)
        titleLabel.textColor = state.didLoseOnDanger ? Theme.Accent.danger : Theme.Text.primary

        newBestBadge.isHidden = !state.isNewBest
        popRow.setValue(state.popPoints, formatter: scoreFormatter)
        dropRow.setValue(state.dropPoints, formatter: scoreFormatter)
        timeBonusRow.setValue(state.timeBonus, formatter: scoreFormatter)

        scoreLabel.text = "0"
        displayedScore = 0
        startScoreAnimation(to: state.finalScore)

        alpha = animated ? 0 : 1
        guard animated else { return }
        UIView.animate(withDuration: 0.35) {
            self.alpha = 1
        }
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        scoreAnimationDisplayLink?.invalidate()
        scoreAnimationDisplayLink = nil

        let hide = {
            self.isHidden = true
            completion?()
        }

        guard animated else {
            hide()
            return
        }

        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }, completion: { _ in hide() })
    }

    // MARK: - Private

    private func configure() {
        isHidden = true
        backgroundColor = .clear

        backdropBlur.translatesAutoresizingMaskIntoConstraints = false
        backdropBlur.overrideUserInterfaceStyle = .dark
        backdropBlur.alpha = 0.78

        backdropTint.translatesAutoresizingMaskIntoConstraints = false
        backdropTint.isUserInteractionEnabled = false
        backdropTint.backgroundColor = Theme.Background.deep.withAlphaComponent(0.20)

        cardPanel.translatesAutoresizingMaskIntoConstraints = false
        cardPanel.backgroundColor = Theme.Background.elevated.withAlphaComponent(0.97)
        cardPanel.layer.cornerRadius = Theme.Metrics.cornerRadiusLarge
        cardPanel.layer.borderWidth = Theme.Metrics.borderWidth
        cardPanel.layer.borderColor = Theme.Surface.border.cgColor
        cardPanel.layer.shadowColor = Theme.Surface.shadow.cgColor
        cardPanel.layer.shadowOpacity = 1
        cardPanel.layer.shadowRadius = 18
        cardPanel.layer.shadowOffset = CGSize(width: 0, height: 9)

        titleLabel.textAlignment = .center
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = Theme.Accent.gold
        newBestBadge.isHidden = true

        let breakdownStack = UIStackView(arrangedSubviews: [popRow, dropRow, timeBonusRow])
        breakdownStack.axis = .vertical
        breakdownStack.spacing = Theme.Metrics.spacingSmall

        let contentStack = UIStackView(arrangedSubviews: [
            titleLabel,
            newBestBadge,
            scoreLabel,
            breakdownStack,
            continueButton,
        ])
        contentStack.axis = .vertical
        contentStack.spacing = Theme.Metrics.spacingMedium
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        continueButton.addAction(UIAction { [weak self] _ in
            self?.onContinue?()
        }, for: .touchUpInside)

        addSubview(backdropBlur)
        addSubview(backdropTint)
        addSubview(cardPanel)
        cardPanel.addSubview(contentStack)

        let padding = Theme.Metrics.contentPadding

        NSLayoutConstraint.activate([
            backdropBlur.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdropBlur.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdropBlur.topAnchor.constraint(equalTo: topAnchor),
            backdropBlur.bottomAnchor.constraint(equalTo: bottomAnchor),

            backdropTint.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdropTint.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdropTint.topAnchor.constraint(equalTo: topAnchor),
            backdropTint.bottomAnchor.constraint(equalTo: bottomAnchor),

            cardPanel.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardPanel.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardPanel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            cardPanel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            cardPanel.widthAnchor.constraint(lessThanOrEqualToConstant: 360),

            contentStack.leadingAnchor.constraint(equalTo: cardPanel.leadingAnchor, constant: padding),
            contentStack.trailingAnchor.constraint(equalTo: cardPanel.trailingAnchor, constant: -padding),
            contentStack.topAnchor.constraint(equalTo: cardPanel.topAnchor, constant: padding),
            contentStack.bottomAnchor.constraint(equalTo: cardPanel.bottomAnchor, constant: -padding),

            continueButton.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
        ])
    }

    private func startScoreAnimation(to target: Int) {
        scoreAnimationDisplayLink?.invalidate()

        let startTime = CACurrentMediaTime()
        let duration: TimeInterval = 0.8

        let link = CADisplayLink(target: ScoreAnimationTarget { [weak self] in
            guard let self else { return }
            let elapsed = CACurrentMediaTime() - startTime
            let progress = min(1, elapsed / duration)
            let eased = 1 - pow(1 - progress, 3)
            let value = Int(Double(target) * eased)
            if value != self.displayedScore {
                self.displayedScore = value
                self.scoreLabel.text = self.scoreFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
            }
            if progress >= 1 {
                self.scoreLabel.text = self.scoreFormatter.string(from: NSNumber(value: target)) ?? "\(target)"
                self.scoreAnimationDisplayLink?.invalidate()
                self.scoreAnimationDisplayLink = nil
            }
        }, selector: #selector(ScoreAnimationTarget.tick))
        link.add(to: .main, forMode: .common)
        scoreAnimationDisplayLink = link
    }

    private static func title(for state: MatchResultsState) -> String {
        if state.didLoseOnDanger { return "DANGER!" }
        if state.didClearBoard { return "MATCH COMPLETE" }
        return "TIME'S UP"
    }
}

// MARK: - Breakdown Row

private final class BreakdownRow: UIView {

    private let titleLabel = ArcadeLabel("", style: .caption)
    private let valueLabel = ArcadeLabel("0", style: .body)

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.textAlignment = .left
        valueLabel.textAlignment = .right

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValue(_ value: Int, formatter: NumberFormatter) {
        valueLabel.text = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        valueLabel.textColor = value > 0 ? Theme.Accent.secondary : Theme.Text.muted
    }
}

// MARK: - Display Link Helper

private final class ScoreAnimationTarget {

    private let block: () -> Void

    init(block: @escaping () -> Void) {
        self.block = block
    }

    @objc func tick() {
        block()
    }
}
