//
//  CannonStyleListView.swift
//  BubbleShooter
//

import UIKit

/// Scrollable list of cannon skins — equip owned styles or buy locked ones.
final class CannonStyleListView: LobbyScreenView {

    var onPurchaseFailed: ((String) -> Void)?
    var onPurchaseSucceeded: (([AchievementID]) -> Void)?

    private let footnoteLabel = ArcadeLabel(
        "Earn \(PlayerProgressionState.matchCoinReward) coins after each match.",
        style: .caption
    )
    private let itemsStack = UIStackView()
    private var itemRows: [CosmeticStyleRow] = []
    private let displayedSkins = CannonSkin.shopDisplayOrder

    init() {
        super.init(screenTitle: "Cannon Style", headerLayout: .shop)
        configureContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadFromStorage() {
        let state = SkillzProgressionService.shared.state
        updateShopBalance(state.softCurrency)
        let selected = CosmeticSettings.cannonSkin

        for (row, skin) in zip(itemRows, displayedSkins) {
            let isOwned = CosmeticUnlockPolicy.isOwned(skin, progression: state)
            let shopItem = CosmeticUnlockPolicy.shopItem(for: skin)
            row.configure(
                title: skin.displayName,
                previewImageNames: [skin.spriteName],
                isSelected: skin == selected,
                isOwned: isOwned,
                shopItem: shopItem,
                canAfford: shopItem.map { state.softCurrency >= $0.price } ?? false
            )
        }
    }

    override func present(animated: Bool = true) {
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
        itemsStack.spacing = Theme.Metrics.spacingMedium
        itemsStack.translatesAutoresizingMaskIntoConstraints = false

        for skin in displayedSkins {
            let row = CosmeticStyleRow(previewLayout: .singleCentered, previewIconSize: 124)
            row.onEquipTapped = { [weak self] in
                guard CosmeticUnlockPolicy.canEquip(skin) else { return }
                self?.equip(skin)
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

    private func equip(_ skin: CannonSkin) {
        guard CosmeticUnlockPolicy.canEquip(skin) else { return }
        CosmeticSettings.cannonSkin = skin
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
