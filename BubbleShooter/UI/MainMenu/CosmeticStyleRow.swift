//
//  CosmeticStyleRow.swift
//  BubbleShooter
//

import UIKit

/// One cosmetic in a scrollable shop list — preview, equip, and optional purchase.
final class CosmeticStyleRow: UIControl {

    var onBuyTapped: ((CosmeticShopItem) -> Void)?

    private let titleLabel = ArcadeLabel("", style: .headline)
    private let statusLabel = ArcadeLabel("", style: .body)
    private let previewStack = UIStackView()
    private let buyButton = ArcadeButton(title: "Buy", style: .gold, size: .compact)
    private let equippedBadge = BadgeView(text: "EQUIPPED", tint: Theme.Accent.primary)
    private var shopItem: CosmeticShopItem?
    private let previewIconSize: CGFloat

    init(previewIconSize: CGFloat) {
        self.previewIconSize = previewIconSize
        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        title: String,
        previewImageNames: [String],
        isSelected: Bool,
        isOwned: Bool,
        shopItem: CosmeticShopItem?,
        canAfford: Bool
    ) {
        self.shopItem = shopItem
        titleLabel.text = title
        rebuildPreview(names: previewImageNames)

        if isSelected {
            statusLabel.text = "Equipped"
            statusLabel.textColor = Theme.Accent.primary
            equippedBadge.isHidden = false
        } else if isOwned {
            statusLabel.text = "Tap to equip"
            statusLabel.textColor = Theme.Text.secondary
            equippedBadge.isHidden = true
        } else if let shopItem {
            statusLabel.text = "\(shopItem.price) coins"
            statusLabel.textColor = canAfford ? Theme.Accent.gold : Theme.Accent.danger
            equippedBadge.isHidden = true
        } else {
            statusLabel.text = "Locked"
            statusLabel.textColor = Theme.Text.muted
            equippedBadge.isHidden = true
        }

        let showBuy = !isOwned && shopItem != nil
        buyButton.isHidden = !showBuy
        buyButton.isEnabled = canAfford

        isEnabled = isOwned ? !isSelected : true
        alpha = isOwned || shopItem != nil ? 1 : 0.72

        layer.borderColor = isSelected
            ? Theme.Accent.primary.cgColor
            : Theme.Surface.borderSubtle.cgColor
        layer.borderWidth = isSelected ? 2 : Theme.Metrics.borderWidth
    }

    // MARK: - Private

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = Theme.Surface.fillStrong
        layer.cornerRadius = Theme.Metrics.cornerRadiusSmall

        titleLabel.textAlignment = .left
        titleLabel.isUserInteractionEnabled = false
        Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.primary)

        statusLabel.textAlignment = .left
        statusLabel.isUserInteractionEnabled = false

        previewStack.axis = .horizontal
        previewStack.spacing = 6
        previewStack.alignment = .center
        previewStack.isUserInteractionEnabled = false
        previewStack.translatesAutoresizingMaskIntoConstraints = false

        equippedBadge.isHidden = true
        equippedBadge.isUserInteractionEnabled = false

        buyButton.addAction(UIAction { [weak self] _ in
            guard let self, let shopItem = self.shopItem else { return }
            self.onBuyTapped?(shopItem)
        }, for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        textStack.isUserInteractionEnabled = false

        let actionStack = UIStackView(arrangedSubviews: [equippedBadge, buyButton])
        actionStack.axis = .vertical
        actionStack.alignment = .trailing
        actionStack.isUserInteractionEnabled = false

        let header = UIStackView(arrangedSubviews: [textStack, actionStack])
        header.axis = .horizontal
        header.alignment = .center
        header.distribution = .equalSpacing
        header.isUserInteractionEnabled = false
        header.translatesAutoresizingMaskIntoConstraints = false

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
        ])
    }

    private func rebuildPreview(names: [String]) {
        previewStack.arrangedSubviews.forEach {
            previewStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for name in names {
            let imageView = UIImageView(image: UIImage(named: name))
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: previewIconSize),
                imageView.heightAnchor.constraint(equalToConstant: previewIconSize),
            ])
            previewStack.addArrangedSubview(imageView)
        }
    }
}
