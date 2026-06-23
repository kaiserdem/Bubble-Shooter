//
//  CosmeticStyleRow.swift
//  BubbleShooter
//

import UIKit

/// One cosmetic in a scrollable shop list — preview plus explicit Equip / Buy actions.
final class CosmeticStyleRow: UIView {

    enum PreviewLayout {
        /// Six bubbles in a row — widths scale to fit the card.
        case bubbleStrip
        /// One centered asset with a fixed size (cannons).
        case singleCentered
    }

    var onEquipTapped: (() -> Void)?
    var onBuyTapped: ((CosmeticShopItem) -> Void)?

    private let titleLabel = ArcadeLabel("", style: .headline)
    private let statusLabel = ArcadeLabel("", style: .body)
    private let previewContainer = UIView()
    private let previewStack = UIStackView()
    private let actionContainer = UIView()
    private let equipButton = ArcadeButton(title: "Equip", style: .secondary, size: .compact)
    private let buyButton = ArcadeButton(title: "Buy", style: .gold, size: .compact)
    private let equippedBadge = BadgeView(text: "EQUIPPED", tint: Theme.Accent.primary)
    private var shopItem: CosmeticShopItem?
    private let previewLayout: PreviewLayout
    private let previewIconSize: CGFloat

    init(previewLayout: PreviewLayout, previewIconSize: CGFloat) {
        self.previewLayout = previewLayout
        self.previewIconSize = previewIconSize
        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, alpha > 0.01, isUserInteractionEnabled else { return nil }
        guard bounds.contains(point) else { return nil }
        return actionContainer.hitTest(convert(point, to: actionContainer), with: event)
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
            statusLabel.text = "Active on next match"
            statusLabel.textColor = Theme.Accent.primary
        } else if isOwned {
            statusLabel.text = "Owned"
            statusLabel.textColor = Theme.Text.secondary
        } else if let shopItem {
            statusLabel.text = "\(shopItem.price) coins"
            statusLabel.textColor = canAfford ? Theme.Accent.gold : Theme.Accent.danger
        } else {
            statusLabel.text = "Locked"
            statusLabel.textColor = Theme.Text.muted
        }

        equippedBadge.isHidden = !isSelected
        equipButton.isHidden = !isOwned || isSelected

        let showBuy = !isOwned && shopItem != nil
        buyButton.isHidden = !showBuy
        buyButton.isEnabled = canAfford

        actionContainer.isHidden = equippedBadge.isHidden
            && equipButton.isHidden
            && buyButton.isHidden

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
        isUserInteractionEnabled = true

        titleLabel.textAlignment = .left
        Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.primary)
        statusLabel.textAlignment = .left

        previewContainer.isUserInteractionEnabled = false
        previewContainer.translatesAutoresizingMaskIntoConstraints = false

        previewStack.axis = .horizontal
        previewStack.spacing = previewLayout == .bubbleStrip ? 6 : 0
        previewStack.alignment = .center
        previewStack.distribution = previewLayout == .bubbleStrip ? .fillEqually : .fill
        previewStack.isUserInteractionEnabled = false
        previewStack.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.addSubview(previewStack)

        equippedBadge.isHidden = true

        equipButton.addAction(UIAction { [weak self] _ in
            self?.onEquipTapped?()
        }, for: .touchUpInside)

        buyButton.addAction(UIAction { [weak self] _ in
            guard let self, let shopItem = self.shopItem else { return }
            self.onBuyTapped?(shopItem)
        }, for: .touchUpInside)

        actionContainer.translatesAutoresizingMaskIntoConstraints = false
        configureActions()

        let padding = Theme.Metrics.spacingMedium
        let previewHeight = previewIconSize + Theme.Metrics.spacingMedium

        switch previewLayout {
        case .bubbleStrip:
            configureBubbleLayout(padding: padding, previewHeight: previewHeight)
        case .singleCentered:
            configureCannonLayout(padding: padding, previewHeight: previewHeight)
        }
    }

    private func configureActions() {
        actionContainer.subviews.forEach { $0.removeFromSuperview() }

        switch previewLayout {
        case .bubbleStrip:
            let buttons = UIStackView(arrangedSubviews: [equippedBadge, equipButton, buyButton])
            buttons.axis = .horizontal
            buttons.spacing = Theme.Metrics.spacingSmall
            buttons.alignment = .center
            buttons.distribution = .fillEqually
            buttons.translatesAutoresizingMaskIntoConstraints = false
            actionContainer.addSubview(buttons)
            NSLayoutConstraint.activate([
                buttons.leadingAnchor.constraint(equalTo: actionContainer.leadingAnchor),
                buttons.trailingAnchor.constraint(equalTo: actionContainer.trailingAnchor),
                buttons.topAnchor.constraint(equalTo: actionContainer.topAnchor),
                buttons.bottomAnchor.constraint(equalTo: actionContainer.bottomAnchor),
                actionContainer.heightAnchor.constraint(equalToConstant: 40),
            ])

        case .singleCentered:
            let buttons = UIStackView(arrangedSubviews: [equippedBadge, equipButton, buyButton])
            buttons.axis = .vertical
            buttons.spacing = Theme.Metrics.spacingSmall
            buttons.alignment = .trailing
            buttons.translatesAutoresizingMaskIntoConstraints = false
            actionContainer.addSubview(buttons)
            NSLayoutConstraint.activate([
                buttons.leadingAnchor.constraint(equalTo: actionContainer.leadingAnchor),
                buttons.trailingAnchor.constraint(equalTo: actionContainer.trailingAnchor),
                buttons.topAnchor.constraint(equalTo: actionContainer.topAnchor),
                buttons.bottomAnchor.constraint(equalTo: actionContainer.bottomAnchor),
            ])
        }
    }

    private func configureBubbleLayout(padding: CGFloat, previewHeight: CGFloat) {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        textStack.isUserInteractionEnabled = false
        textStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(textStack)
        addSubview(previewContainer)
        addSubview(actionContainer)

        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            textStack.topAnchor.constraint(equalTo: topAnchor, constant: padding),

            previewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            previewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            previewContainer.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: Theme.Metrics.spacingSmall),
            previewContainer.heightAnchor.constraint(equalToConstant: previewHeight),

            actionContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            actionContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            actionContainer.topAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: Theme.Metrics.spacingMedium),
            actionContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),

            previewStack.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            previewStack.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),
            previewStack.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            previewStack.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),
        ])
    }

    private func configureCannonLayout(padding: CGFloat, previewHeight: CGFloat) {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        textStack.isUserInteractionEnabled = false

        let header = UIStackView(arrangedSubviews: [textStack, actionContainer])
        header.axis = .horizontal
        header.alignment = .center
        header.distribution = .equalSpacing
        header.isUserInteractionEnabled = false
        header.translatesAutoresizingMaskIntoConstraints = false

        addSubview(header)
        addSubview(previewContainer)

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            header.topAnchor.constraint(equalTo: topAnchor, constant: padding),

            previewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            previewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            previewContainer.topAnchor.constraint(equalTo: header.bottomAnchor, constant: Theme.Metrics.spacingSmall),
            previewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            previewContainer.heightAnchor.constraint(equalToConstant: previewHeight),

            previewStack.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            previewStack.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),
            previewStack.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            previewStack.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),
        ])
    }

    private func rebuildPreview(names: [String]) {
        previewStack.arrangedSubviews.forEach {
            previewStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        previewContainer.subviews
            .filter { $0 !== previewStack }
            .forEach { $0.removeFromSuperview() }

        switch previewLayout {
        case .bubbleStrip:
            previewStack.isHidden = false
            for name in names {
                let imageView = UIImageView(image: UIImage(named: name))
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.heightAnchor.constraint(equalToConstant: previewIconSize),
                ])
                previewStack.addArrangedSubview(imageView)
            }

        case .singleCentered:
            previewStack.isHidden = true
            let imageView = UIImageView(image: UIImage(named: names.first ?? ""))
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            previewContainer.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: previewIconSize),
                imageView.heightAnchor.constraint(equalToConstant: previewIconSize),
                imageView.centerXAnchor.constraint(equalTo: previewContainer.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: previewContainer.centerYAnchor),
            ])
        }
    }
}
