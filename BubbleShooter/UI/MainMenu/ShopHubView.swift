//
//  ShopHubView.swift
//  BubbleShooter
//

import UIKit

/// Shop entry — balance and category tiles for bubble and cannon cosmetics.
final class ShopHubView: LobbyScreenView {

    var onOpenBubbleStyles: (() -> Void)?
    var onOpenCannonStyles: (() -> Void)?

    private let balanceLabel = ArcadeLabel("", style: .headline)
    private let balanceCaption = ArcadeLabel("Your balance", style: .caption)
    private let footnoteLabel = ArcadeLabel(
        "Pick a category. Changes apply on the next match.",
        style: .caption
    )

    init() {
        super.init(screenTitle: "Shop")
        configureContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadFromProgression() {
        let state = SkillzProgressionService.shared.state
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        balanceLabel.text = "\(formatter.string(from: NSNumber(value: state.softCurrency)) ?? "0") coins"
    }

    override func present(animated: Bool = true) {
        SkillzProgressionService.shared.refresh { [weak self] _ in
            DispatchQueue.main.async {
                self?.reloadFromProgression()
            }
        }
        super.present(animated: animated)
    }

    // MARK: - Private

    private func configureContent() {
        balanceCaption.textAlignment = .center
        balanceLabel.textAlignment = .center
        balanceLabel.textColor = Theme.Accent.gold
        Theme.Text.applyHUDLegibility(to: balanceCaption, color: Theme.Text.muted)

        footnoteLabel.textAlignment = .center
        footnoteLabel.numberOfLines = 0
        Theme.Text.applyHUDLegibility(to: footnoteLabel, color: Theme.Text.muted)

        let balanceStack = UIStackView(arrangedSubviews: [balanceCaption, balanceLabel])
        balanceStack.axis = .vertical
        balanceStack.spacing = 4
        balanceStack.alignment = .center

        let bubbleTile = ShopCategoryTile(
            title: "Bubble Style",
            subtitle: "\(BubbleSkinPack.allCases.count) collections",
            previewImageNames: BubbleColor.allCases.map {
                BubbleSkinPack.classic.spriteName(for: $0)
            },
            previewIconSize: 44
        )
        bubbleTile.addAction(UIAction { [weak self] _ in
            self?.onOpenBubbleStyles?()
        }, for: .touchUpInside)

        let cannonTile = ShopCategoryTile(
            title: "Cannon Style",
            subtitle: "\(CannonSkin.allCases.count) cannons",
            previewImageNames: [CannonSkin.standard.spriteName],
            previewIconSize: 144
        )
        cannonTile.addAction(UIAction { [weak self] _ in
            self?.onOpenCannonStyles?()
        }, for: .touchUpInside)

        scrollStack.addArrangedSubview(balanceStack)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: balanceStack)
        scrollStack.addArrangedSubview(bubbleTile)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingMedium, after: bubbleTile)
        scrollStack.addArrangedSubview(cannonTile)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: cannonTile)
        scrollStack.addArrangedSubview(footnoteLabel)
    }
}

// MARK: - ShopCategoryTile

private final class ShopCategoryTile: UIControl {

    init(
        title: String,
        subtitle: String,
        previewImageNames: [String],
        previewIconSize: CGFloat
    ) {
        super.init(frame: .zero)
        configure(
            title: title,
            subtitle: subtitle,
            previewImageNames: previewImageNames,
            previewIconSize: previewIconSize
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func configure(
        title: String,
        subtitle: String,
        previewImageNames: [String],
        previewIconSize: CGFloat
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = Theme.Surface.fillStrong
        layer.cornerRadius = Theme.Metrics.cornerRadiusSmall
        layer.borderWidth = Theme.Metrics.borderWidth
        layer.borderColor = Theme.Surface.borderSubtle.cgColor

        let titleLabel = ArcadeLabel(title, style: .headline)
        titleLabel.textAlignment = .left
        titleLabel.isUserInteractionEnabled = false
        Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.primary)

        let subtitleLabel = ArcadeLabel(subtitle, style: .caption)
        subtitleLabel.textAlignment = .left
        subtitleLabel.isUserInteractionEnabled = false
        Theme.Text.applyHUDLegibility(to: subtitleLabel, color: Theme.Text.muted)

        let chevron = ArcadeLabel("›", style: .title)
        chevron.textAlignment = .center
        chevron.isUserInteractionEnabled = false
        Theme.Text.applyHUDLegibility(to: chevron, color: Theme.Accent.secondary)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        textStack.isUserInteractionEnabled = false

        let header = UIStackView(arrangedSubviews: [textStack, chevron])
        header.axis = .horizontal
        header.alignment = .center
        header.distribution = .equalSpacing
        header.isUserInteractionEnabled = false
        header.translatesAutoresizingMaskIntoConstraints = false

        let previewStack = UIStackView()
        previewStack.axis = .horizontal
        previewStack.spacing = 4
        previewStack.alignment = .center
        previewStack.isUserInteractionEnabled = false
        previewStack.translatesAutoresizingMaskIntoConstraints = false

        for name in previewImageNames.prefix(6) {
            let imageView = UIImageView(image: UIImage(named: name))
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: previewIconSize),
                imageView.heightAnchor.constraint(equalToConstant: previewIconSize),
            ])
            previewStack.addArrangedSubview(imageView)
        }

        addSubview(header)
        addSubview(previewStack)

        let previewHeight = previewIconSize + Theme.Metrics.spacingSmall

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.spacingMedium),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.spacingMedium),
            header.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.spacingMedium),

            previewStack.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: Theme.Metrics.spacingMedium
            ),
            previewStack.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor,
                constant: -Theme.Metrics.spacingMedium
            ),
            previewStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            previewStack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: Theme.Metrics.spacingSmall),
            previewStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.spacingMedium),
            previewStack.heightAnchor.constraint(equalToConstant: previewHeight),

            heightAnchor.constraint(greaterThanOrEqualToConstant: previewIconSize + 72),
        ])
    }
}
