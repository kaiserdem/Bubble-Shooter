//
//  ShopFlowView.swift
//  BubbleShooter
//

import UIKit

/// Full shop navigation: hub → bubble or cannon list screens.
final class ShopFlowView: UIView {

    var onBack: (() -> Void)?
    var onPurchaseFailed: ((String) -> Void)?

    private let shopHub = ShopHubView()
    private let bubbleStyleList = BubbleStyleListView()
    private let cannonStyleList = CannonStyleListView()
    private let achievementOverlay = AchievementUnlockedOverlayView()
    private var pendingAchievementPresentations: [AchievementID] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present(animated: Bool = true) {
        shopHub.reloadFromProgression()
        bringSubviewToFront(shopHub)
        shopHub.present(animated: animated)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        for screen in [cannonStyleList, bubbleStyleList, shopHub] {
            screen.isHidden = true
            screen.isUserInteractionEnabled = false
            screen.transform = .identity
        }
        completion?()
    }

    // MARK: - Private

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false

        for child in [shopHub, bubbleStyleList, cannonStyleList, achievementOverlay] {
            child.translatesAutoresizingMaskIntoConstraints = false
            addSubview(child)
            NSLayoutConstraint.activate([
                child.leadingAnchor.constraint(equalTo: leadingAnchor),
                child.trailingAnchor.constraint(equalTo: trailingAnchor),
                child.topAnchor.constraint(equalTo: topAnchor),
                child.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }

        shopHub.onBack = { [weak self] in
            self?.onBack?()
        }

        shopHub.onOpenBubbleStyles = { [weak self] in
            guard let self else { return }
            self.bubbleStyleList.reloadFromStorage()
            self.openScreen(self.bubbleStyleList)
        }

        shopHub.onOpenCannonStyles = { [weak self] in
            guard let self else { return }
            self.cannonStyleList.reloadFromStorage()
            self.openScreen(self.cannonStyleList)
        }

        bubbleStyleList.onBack = { [weak self] in
            self?.closeScreen(self?.bubbleStyleList, returnTo: self?.shopHub) {
                self?.shopHub.reloadFromProgression()
                SkillzProgressionService.shared.refresh { _ in
                    DispatchQueue.main.async {
                        self?.shopHub.reloadFromProgression()
                    }
                }
            }
        }

        cannonStyleList.onBack = { [weak self] in
            self?.closeScreen(self?.cannonStyleList, returnTo: self?.shopHub) {
                self?.shopHub.reloadFromProgression()
                SkillzProgressionService.shared.refresh { _ in
                    DispatchQueue.main.async {
                        self?.shopHub.reloadFromProgression()
                    }
                }
            }
        }

        bubbleStyleList.onPurchaseFailed = { [weak self] message in
            self?.onPurchaseFailed?(message)
        }

        cannonStyleList.onPurchaseFailed = { [weak self] message in
            self?.onPurchaseFailed?(message)
        }

        let purchaseSucceeded: ([AchievementID]) -> Void = { [weak self] unlocked in
            self?.presentUnlockedAchievements(unlocked)
        }
        bubbleStyleList.onPurchaseSucceeded = purchaseSucceeded
        cannonStyleList.onPurchaseSucceeded = purchaseSucceeded
    }

    private func presentUnlockedAchievements(_ ids: [AchievementID]) {
        guard !ids.isEmpty else { return }
        pendingAchievementPresentations = ids
        presentNextAchievement()
    }

    private func presentNextAchievement() {
        guard let id = pendingAchievementPresentations.first else { return }

        let definition = AchievementDefinition.definition(for: id)
        bringSubviewToFront(achievementOverlay)
        achievementOverlay.configure(definition: definition)
        achievementOverlay.onDismiss = { [weak self] in
            guard let self else { return }
            self.pendingAchievementPresentations.removeFirst()
            if self.pendingAchievementPresentations.isEmpty {
                self.shopHub.reloadFromProgression()
                self.bubbleStyleList.reloadFromStorage()
                self.cannonStyleList.reloadFromStorage()
            } else {
                self.presentNextAchievement()
            }
        }
        achievementOverlay.present()
    }

    private func openScreen(_ screen: LobbyScreenView) {
        layoutIfNeeded()
        bringSubviewToFront(screen)
        screen.present()
    }

    private func closeScreen(
        _ screen: LobbyScreenView?,
        returnTo: UIView?,
        completion: (() -> Void)? = nil
    ) {
        screen?.dismiss {
            completion?()
            if let returnTo {
                self.bringSubviewToFront(returnTo)
            }
        }
    }
}
