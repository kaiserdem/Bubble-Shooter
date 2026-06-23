//
//  MainMenuContainerView.swift
//  BubbleShooter
//

import UIKit

/// Hosts the main menu and full-screen pre-game screens.
final class MainMenuContainerView: UIView {

    var onPlay: (() -> Void)?

    private let mainMenu = MainMenuView()
    private let howToPlay = HowToPlayView()
    private let settings = SettingsView()
    private let shopFlow = ShopFlowView()
    private let achievementsList = AchievementsListView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false

        for child in [mainMenu, howToPlay, settings, shopFlow, achievementsList] {
            child.translatesAutoresizingMaskIntoConstraints = false
            addSubview(child)
            NSLayoutConstraint.activate([
                child.leadingAnchor.constraint(equalTo: leadingAnchor),
                child.trailingAnchor.constraint(equalTo: trailingAnchor),
                child.topAnchor.constraint(equalTo: topAnchor),
                child.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }

        bringSubviewToFront(mainMenu)

        mainMenu.onPlay = { [weak self] in
            self?.onPlay?()
        }

        mainMenu.onHowToPlay = { [weak self] in
            self?.openScreen(self?.howToPlay)
        }

        mainMenu.onSettings = { [weak self] in
            self?.openScreen(self?.settings)
        }

        mainMenu.onShop = { [weak self] in
            guard let self else { return }
            self.bringSubviewToFront(self.shopFlow)
            self.shopFlow.present()
        }

        mainMenu.onAchievements = { [weak self] in
            guard let self else { return }
            self.bringSubviewToFront(self.achievementsList)
            self.achievementsList.present()
        }

        howToPlay.onBack = { [weak self] in
            self?.closeScreen(self?.howToPlay, returnTo: self?.mainMenu)
        }

        settings.onBack = { [weak self] in
            self?.closeScreen(self?.settings, returnTo: self?.mainMenu)
        }

        achievementsList.onBack = { [weak self] in
            self?.closeScreen(self?.achievementsList, returnTo: self?.mainMenu)
        }

        shopFlow.onBack = { [weak self] in
            self?.shopFlow.dismiss {
                self?.bringSubviewToFront(self?.mainMenu ?? UIView())
            }
        }

        shopFlow.onPurchaseFailed = { message in
            #if DEBUG
            print("[Shop] Purchase failed: \(message)")
            #endif
        }
    }

    private func openScreen(_ screen: LobbyScreenView?) {
        guard let screen else { return }
        layoutIfNeeded()
        bringSubviewToFront(screen)
        screen.present()
    }

    private func closeScreen(
        _ screen: LobbyScreenView?,
        returnTo: UIView? = nil,
        completion: (() -> Void)? = nil
    ) {
        screen?.dismiss {
            completion?()
            if let returnTo {
                self.bringSubviewToFront(returnTo)
            } else if completion == nil {
                self.bringSubviewToFront(self.mainMenu)
            }
        }
    }
}
