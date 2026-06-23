//
//  LobbyScreenView.swift
//  BubbleShooter
//

import UIKit

/// Full-screen pre-game surface: lobby wallpaper, back navigation, and a scrollable glass content card.
class LobbyScreenView: UIView {

    enum HeaderLayout {
        /// Back on top, title on the next line.
        case stacked
        /// Back and title share one horizontal row.
        case inline
        /// Back on the left, coin balance centered on the same row.
        case shop
    }

    var onBack: (() -> Void)?

    let scrollView = UIScrollView()
    let scrollStack = UIStackView()

    private let backgroundView = ImageBackgroundView(named: Theme.Asset.Background.lobby)
    private let backButton = ArcadeButton(title: "Back", style: .ghost, size: .compact)
    private let shopBalanceView: ShopCoinBalanceView?
    private let titleLabel: ArcadeLabel
    private let card = GlassCardView()
    private let headerLayout: HeaderLayout
    private var cardTopToHeaderConstraint: NSLayoutConstraint?

    init(screenTitle: String, headerLayout: HeaderLayout = .stacked) {
        self.headerLayout = headerLayout
        shopBalanceView = headerLayout == .shop ? ShopCoinBalanceView() : nil
        titleLabel = ArcadeLabel(screenTitle, style: .title)
        super.init(frame: .zero)
        configureChrome()
    }

    func updateShopBalance(_ balance: Int) {
        shopBalanceView?.update(balance: balance)
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

        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
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
        if let shopBalanceView {
            shopBalanceView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(shopBalanceView)
        }
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

            titleLabel.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -Theme.Metrics.contentPadding
            ),

            card.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: Theme.Metrics.contentPadding
            ),
            card.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -Theme.Metrics.contentPadding
            ),
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

        applyHeaderLayoutConstraints()
    }

    private func applyHeaderLayoutConstraints() {
        switch headerLayout {
        case .stacked:
            titleLabel.textAlignment = .left
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.leadingAnchor,
                    constant: Theme.Metrics.contentPadding
                ),
                titleLabel.topAnchor.constraint(
                    equalTo: backButton.bottomAnchor,
                    constant: Theme.Metrics.spacingMedium
                ),
            ])
            cardTopToHeaderConstraint = card.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Theme.Metrics.spacingLarge
            )

        case .inline:
            titleLabel.textAlignment = .right
            NSLayoutConstraint.activate([
                titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
                titleLabel.leadingAnchor.constraint(
                    greaterThanOrEqualTo: backButton.trailingAnchor,
                    constant: Theme.Metrics.spacingSmall
                ),
            ])
            cardTopToHeaderConstraint = card.topAnchor.constraint(
                equalTo: backButton.bottomAnchor,
                constant: Theme.Metrics.spacingLarge
            )

        case .shop:
            titleLabel.textAlignment = .left
            if let shopBalanceView {
                NSLayoutConstraint.activate([
                    shopBalanceView.centerXAnchor.constraint(equalTo: centerXAnchor),
                    shopBalanceView.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
                    shopBalanceView.leadingAnchor.constraint(
                        greaterThanOrEqualTo: backButton.trailingAnchor,
                        constant: Theme.Metrics.spacingSmall
                    ),
                ])
            }
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.leadingAnchor,
                    constant: Theme.Metrics.contentPadding
                ),
                titleLabel.topAnchor.constraint(
                    equalTo: backButton.bottomAnchor,
                    constant: Theme.Metrics.spacingMedium
                ),
            ])
            cardTopToHeaderConstraint = card.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Theme.Metrics.spacingLarge
            )
        }

        cardTopToHeaderConstraint?.isActive = true
    }
}
