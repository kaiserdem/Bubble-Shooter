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
    private let bubblePopOverlay = BubblePopPreviewOverlay()
    private let actionsRow = UIStackView()
    private let actionContainer = UIView()
    private let equipButton = ArcadeButton(
        title: "Equip",
        style: .secondary,
        size: .compact,
        contentHorizontalPadding: ActionSlotMetrics.shopActionHorizontalPadding
    )
    private let buyButton = ArcadeButton(title: "Buy", style: .gold, size: .compact)
    private let tryButton = ArcadeButton(title: "Try", style: .violet, size: .compact)
    private let equippedBadge = BadgeView(text: "EQUIPPED", tint: Theme.Accent.primary)
    private var shopItem: CosmeticShopItem?
    private var previewBubbleViews: [UIImageView] = []
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
        return actionsRow.hitTest(convert(point, to: actionsRow), with: event)
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

        tryButton.addAction(UIAction { [weak self] _ in
            self?.playBubblePopPreview()
        }, for: .touchUpInside)

        actionContainer.translatesAutoresizingMaskIntoConstraints = false
        configureActions()

        switch previewLayout {
        case .bubbleStrip:
            previewContainer.clipsToBounds = true
            bubblePopOverlay.translatesAutoresizingMaskIntoConstraints = false
            previewContainer.addSubview(bubblePopOverlay)

            let padding = Theme.Metrics.spacingMedium
            let previewHeight = previewIconSize + Theme.Metrics.spacingMedium
            configureBubbleLayout(padding: padding, previewHeight: previewHeight)
        case .singleCentered:
            configureCannonLayout()
        }
    }

    private enum ActionSlotMetrics {
        static let height = Theme.Metrics.compactButtonHeight
        static let shopActionHorizontalPadding: CGFloat = 8
        /// Fits "Equip", "Buy", and "EQUIPPED" in the cannon row header.
        static let cannonWidth: CGFloat = 96
    }

    private func configureActions() {
        actionContainer.subviews.forEach { $0.removeFromSuperview() }

        switch previewLayout {
        case .bubbleStrip:
            configureActionSlot(fixedWidth: nil)
        case .singleCentered:
            configureActionSlot(fixedWidth: ActionSlotMetrics.cannonWidth)
        }
    }

    private func configureActionSlot(fixedWidth: CGFloat?) {
        let slot = UIView()
        slot.translatesAutoresizingMaskIntoConstraints = false
        slot.isUserInteractionEnabled = true

        equippedBadge.translatesAutoresizingMaskIntoConstraints = false
        equipButton.translatesAutoresizingMaskIntoConstraints = false
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        equippedBadge.setContentHuggingPriority(.defaultLow, for: .horizontal)
        equipButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        buyButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        equippedBadge.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        equipButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        buyButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        slot.addSubview(equipButton)
        slot.addSubview(buyButton)
        slot.addSubview(equippedBadge)
        actionContainer.addSubview(slot)

        let pinToSlot = { (view: UIView) in
            [
                view.leadingAnchor.constraint(equalTo: slot.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: slot.trailingAnchor),
                view.topAnchor.constraint(equalTo: slot.topAnchor),
                view.bottomAnchor.constraint(equalTo: slot.bottomAnchor),
            ]
        }

        var constraints =
            pinToSlot(equipButton)
            + pinToSlot(buyButton)
            + pinToSlot(equippedBadge)
            + [
                slot.topAnchor.constraint(equalTo: actionContainer.topAnchor),
                slot.bottomAnchor.constraint(equalTo: actionContainer.bottomAnchor),
                slot.heightAnchor.constraint(equalToConstant: ActionSlotMetrics.height),
            ]

        if let fixedWidth {
            constraints += [
                slot.leadingAnchor.constraint(equalTo: actionContainer.leadingAnchor),
                slot.trailingAnchor.constraint(equalTo: actionContainer.trailingAnchor),
                slot.widthAnchor.constraint(equalToConstant: fixedWidth),
                actionContainer.widthAnchor.constraint(equalToConstant: fixedWidth),
            ]
        } else {
            constraints += [
                slot.leadingAnchor.constraint(equalTo: actionContainer.leadingAnchor),
                slot.trailingAnchor.constraint(equalTo: actionContainer.trailingAnchor),
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func configureBubbleLayout(padding: CGFloat, previewHeight: CGFloat) {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        textStack.isUserInteractionEnabled = false
        textStack.translatesAutoresizingMaskIntoConstraints = false

        actionsRow.axis = .horizontal
        actionsRow.spacing = Theme.Metrics.spacingSmall
        actionsRow.alignment = .fill
        actionsRow.distribution = .fill
        actionsRow.translatesAutoresizingMaskIntoConstraints = false
        actionsRow.isUserInteractionEnabled = true
        actionsRow.addArrangedSubview(tryButton)
        actionsRow.addArrangedSubview(actionContainer)

        tryButton.setContentHuggingPriority(.required, for: .horizontal)
        tryButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        tryButton.widthAnchor.constraint(equalToConstant: ActionSlotMetrics.cannonWidth).isActive = true

        addSubview(textStack)
        addSubview(previewContainer)
        addSubview(actionsRow)

        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            textStack.topAnchor.constraint(equalTo: topAnchor, constant: padding),

            previewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            previewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            previewContainer.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: Theme.Metrics.spacingSmall),
            previewContainer.heightAnchor.constraint(equalToConstant: previewHeight),

            actionsRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            actionsRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            actionsRow.topAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: Theme.Metrics.spacingMedium),
            actionsRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),

            previewStack.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            previewStack.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),
            previewStack.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            previewStack.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),

            bubblePopOverlay.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            bubblePopOverlay.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),
            bubblePopOverlay.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            bubblePopOverlay.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),
        ])
    }

    private func configureCannonLayout() {
        let padding = Theme.Metrics.spacingSmall
        let headerPreviewGap: CGFloat = 4

        let textStack = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        textStack.isUserInteractionEnabled = false

        actionsRow.axis = .horizontal
        actionsRow.spacing = Theme.Metrics.spacingSmall
        actionsRow.alignment = .center
        actionsRow.distribution = .fill
        actionsRow.isUserInteractionEnabled = true
        actionsRow.addArrangedSubview(actionContainer)

        let header = UIStackView(arrangedSubviews: [textStack, actionsRow])
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
            previewContainer.topAnchor.constraint(equalTo: header.bottomAnchor, constant: headerPreviewGap),
            previewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            previewContainer.heightAnchor.constraint(equalToConstant: previewIconSize),

            previewStack.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            previewStack.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),
            previewStack.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            previewStack.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),
        ])
    }

    private func playBubblePopPreview() {
        guard previewLayout == .bubbleStrip, !previewBubbleViews.isEmpty else { return }
        tryButton.isEnabled = false
        bubblePopOverlay.play(
            anchorViews: previewBubbleViews,
            colors: BubbleColor.allCases,
            bubbleDiameter: previewIconSize
        ) { [weak self] in
            self?.tryButton.isEnabled = true
        }
    }

    private func rebuildPreview(names: [String]) {
        previewBubbleViews = []
        previewStack.arrangedSubviews.forEach {
            previewStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        previewContainer.subviews
            .filter { $0 !== previewStack && $0 !== bubblePopOverlay }
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
                previewBubbleViews.append(imageView)
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
