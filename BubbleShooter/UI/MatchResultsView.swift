//
//  MatchResultsView.swift
//  BubbleShooter
//

import UIKit

/// Fullscreen overlay shown when a match ends.
final class MatchResultsView: UIView {

    var onContinue: (() -> Void)?

    private let dimOverlay = UIView()
    private let card = GlassCardView()
    private let titleLabel = ArcadeLabel("MATCH COMPLETE", style: .headline)
    private let scoreLabel = ArcadeLabel("0", style: .title)
    private let newBestBadge = BadgeView(text: "NEW BEST", tint: Theme.Accent.gold)
    private let popRow = BreakdownRow(title: "Pop")
    private let dropRow = BreakdownRow(title: "Drop")
    private let timeBonusRow = BreakdownRow(title: "Time bonus")
    private let continueButton = ArcadeButton(title: "Continue", style: .primary)

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

        dimOverlay.backgroundColor = Theme.Background.deep.withAlphaComponent(0.90)
        dimOverlay.translatesAutoresizingMaskIntoConstraints = false

        card.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.backgroundColor = Theme.Background.deep.withAlphaComponent(0.72)
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

        addSubview(dimOverlay)
        addSubview(card)
        card.contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            dimOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimOverlay.topAnchor.constraint(equalTo: topAnchor),
            dimOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),

            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 360),

            contentStack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),

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
        let prefix = value >= 0 ? "+" : ""
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        valueLabel.text = "\(prefix)\(formatted)"
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
