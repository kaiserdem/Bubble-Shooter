//
//  BubbleStyleListView.swift
//  BubbleShooter
//

import UIKit

/// Scrollable list of bubble skin packs — equip owned styles or buy locked ones.
final class BubbleStyleListView: LobbyScreenView {

    var onPurchaseFailed: ((String) -> Void)?
    var onPurchaseSucceeded: (([AchievementID]) -> Void)?

    private let footnoteLabel = ArcadeLabel(
        "Earn \(PlayerProgressionState.matchCoinReward) coins after each match.",
        style: .caption
    )
    private let itemsStack = UIStackView()
    private var itemRows: [CosmeticStyleRow] = []

    init() {
        super.init(screenTitle: "Bubble Style")
        configureContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadFromStorage() {
        let state = SkillzProgressionService.shared.state
        let selected = CosmeticSettings.bubbleSkinPack

        for (row, pack) in zip(itemRows, BubbleSkinPack.allCases) {
            let isOwned = CosmeticUnlockPolicy.isOwned(pack, progression: state)
            let shopItem = CosmeticUnlockPolicy.shopItem(for: pack)
            row.configure(
                title: pack.displayName,
                previewImageNames: BubbleColor.allCases.map { pack.spriteName(for: $0) },
                isSelected: pack == selected,
                isOwned: isOwned,
                shopItem: shopItem,
                canAfford: shopItem.map { state.softCurrency >= $0.price } ?? false
            )
        }
    }

    override func present(animated: Bool = true) {
        BubbleExplosionTextureCache.preload()
        reloadFromStorage()
        SkillzProgressionService.shared.refresh { [weak self] _ in
            DispatchQueue.main.async {
                self?.reloadFromStorage()
            }
        }
        super.present(animated: animated)
    }

    // MARK: - Private

    private func configureContent() {
        footnoteLabel.textAlignment = .center
        footnoteLabel.numberOfLines = 0
        Theme.Text.applyHUDLegibility(to: footnoteLabel, color: Theme.Text.muted)

        itemsStack.axis = .vertical
        itemsStack.spacing = Theme.Metrics.spacingLarge
        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        for pack in BubbleSkinPack.allCases {
            let row = CosmeticStyleRow(previewLayout: .bubbleStrip, previewIconSize: 56)
            row.onEquipTapped = { [weak self] in
                guard CosmeticUnlockPolicy.canEquip(pack) else { return }
                self?.equip(pack)
            }
            row.onBuyTapped = { [weak self] item in
                self?.purchase(item)
            }
            itemRows.append(row)
            itemsStack.addArrangedSubview(row)
        }

        scrollStack.addArrangedSubview(itemsStack)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: itemsStack)
        scrollStack.addArrangedSubview(footnoteLabel)
    }

    private func equip(_ pack: BubbleSkinPack) {
        guard CosmeticUnlockPolicy.canEquip(pack) else { return }
        CosmeticSettings.bubbleSkinPack = pack
        reloadFromStorage()
    }

    private func purchase(_ item: CosmeticShopItem) {
        SkillzProgressionService.shared.purchase(item) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let purchaseResult):
                    item.applyEquippedCosmetic()
                    self.reloadFromStorage()
                    self.onPurchaseSucceeded?(purchaseResult.unlockedAchievements)
                case .failure(let error):
                    self.onPurchaseFailed?(error.localizedDescription)
                }
            }
        }
    }
}
