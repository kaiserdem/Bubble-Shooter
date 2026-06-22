//
//  SandboxLobbyView.swift
//  BubbleShooter
//

import UIKit

#if DEBUG
/// Debug sandbox menu — demonstrates the Cosmic Pop design system.
final class SandboxLobbyView: UIView {

    var onLaunchSkillz: (() -> Void)?
    var onStartSandboxMatch: (() -> Void)?
    var onStartDeterminismTest: (() -> Void)?
    var onOpenDesignPreview: (() -> Void)?

    private let backgroundView = GradientBackgroundView()
    private let card = GlassCardView()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        card.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundView)
        addSubview(card)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 360),
        ])

        stackView.axis = .vertical
        stackView.spacing = Theme.Metrics.spacingMedium
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let title = ArcadeLabel("Bubble Shooter", style: .title)
        let badge = BadgeView(text: "SANDBOX", tint: Theme.Accent.secondary)
        let subtitle = ArcadeLabel(
            "Skillz SDK не підключено — тестуйте матч локально",
            style: .body
        )

        let launchButton = ArcadeButton(title: "Launch Skillz", style: .ghost)
        launchButton.addAction(UIAction { [weak self] _ in self?.onLaunchSkillz?() }, for: .touchUpInside)

        let matchButton = ArcadeButton(title: "Start Match", style: .primary)
        matchButton.addAction(UIAction { [weak self] _ in self?.onStartSandboxMatch?() }, for: .touchUpInside)

        let testButton = ArcadeButton(title: "Determinism Test", style: .secondary)
        testButton.addAction(UIAction { [weak self] _ in self?.onStartDeterminismTest?() }, for: .touchUpInside)

        let popEffectLabel = ArcadeLabel("Pop effect", style: .caption)
        let popEffectControl = UISegmentedControl(
            items: BubblePopEffectStyle.allCases.map(\.displayName)
        )
        popEffectControl.selectedSegmentIndex = BubblePopEffectStyle.allCases.firstIndex(
            of: BubblePopEffectPlayer.style
        ) ?? 0
        popEffectControl.addAction(UIAction { _ in
            let index = popEffectControl.selectedSegmentIndex
            guard index >= 0, index < BubblePopEffectStyle.allCases.count else { return }
            BubblePopEffectPlayer.style = BubblePopEffectStyle.allCases[index]
        }, for: .valueChanged)

        let designButton = ArcadeButton(title: "Design Preview", style: .ghost)
        designButton.addAction(UIAction { [weak self] _ in self?.onOpenDesignPreview?() }, for: .touchUpInside)

        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(badge)
        stackView.addArrangedSubview(subtitle)
        stackView.setCustomSpacing(Theme.Metrics.spacingLarge, after: subtitle)
        stackView.addArrangedSubview(launchButton)
        stackView.addArrangedSubview(matchButton)
        stackView.addArrangedSubview(testButton)
        stackView.addArrangedSubview(popEffectLabel)
        stackView.addArrangedSubview(popEffectControl)
        stackView.addArrangedSubview(designButton)

        card.contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            launchButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            matchButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            testButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            popEffectControl.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            designButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ])
    }
}
#endif
