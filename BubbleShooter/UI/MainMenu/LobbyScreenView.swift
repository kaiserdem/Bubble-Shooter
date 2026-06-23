//
//  LobbyScreenView.swift
//  BubbleShooter
//

import UIKit

/// Full-screen pre-game surface: lobby wallpaper, back navigation, and a scrollable glass content card.
class LobbyScreenView: UIView {

    var onBack: (() -> Void)?

    let scrollView = UIScrollView()
    let scrollStack = UIStackView()

    private let backgroundView = ImageBackgroundView(named: Theme.Asset.Background.lobby)
    private let backButton = ArcadeButton(title: "Back", style: .ghost, size: .compact)
    private let titleLabel: ArcadeLabel
    private let card = GlassCardView()

    init(screenTitle: String) {
        titleLabel = ArcadeLabel(screenTitle, style: .title)
        super.init(frame: .zero)
        configureChrome()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present(animated: Bool = true) {
        isHidden = false
        isUserInteractionEnabled = true

        guard animated else {
            alpha = 1
            transform = .identity
            return
        }

        alpha = 1
        let travel = resolvedTransitionDistance
        transform = CGAffineTransform(translationX: travel, y: 0)
        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.35
        ) {
            self.transform = .identity
        }
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        let finish = {
            self.isHidden = true
            self.isUserInteractionEnabled = false
            self.transform = .identity
            completion?()
        }

        guard animated else {
            finish()
            return
        }

        let travel = resolvedTransitionDistance
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                self.transform = CGAffineTransform(translationX: travel, y: 0)
            },
            completion: { _ in
                finish()
            }
        )
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, isUserInteractionEnabled else { return nil }
        return super.hitTest(point, with: event)
    }

    // MARK: - Private

    private var resolvedTransitionDistance: CGFloat {
        bounds.width > 1 ? bounds.width : UIScreen.main.bounds.width
    }

    private func configureChrome() {
        isHidden = true
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.textAlignment = .left
        Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.primary)

        backButton.addAction(UIAction { [weak self] _ in
            self?.onBack?()
        }, for: .touchUpInside)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear

        scrollStack.axis = .vertical
        scrollStack.spacing = Theme.Metrics.spacingMedium
        scrollStack.alignment = .fill
        scrollStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(scrollStack)

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundView)
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(card)
        card.contentView.addSubview(scrollView)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            backButton.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: Theme.Metrics.contentPadding
            ),
            backButton.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: Theme.Metrics.spacingSmall
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: Theme.Metrics.contentPadding
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -Theme.Metrics.contentPadding
            ),
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: Theme.Metrics.spacingMedium),

            card.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: Theme.Metrics.contentPadding
            ),
            card.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -Theme.Metrics.contentPadding
            ),
            card.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.Metrics.spacingLarge),
            card.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -Theme.Metrics.spacingMedium
            ),

            scrollView.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),

            scrollStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }
}
