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
    private let styles = StylesView()

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

        for child in [mainMenu, howToPlay, settings, styles] {
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

        mainMenu.onStyles = { [weak self] in
            guard let self else { return }
            self.styles.reloadFromStorage()
            self.openScreen(self.styles)
        }

        howToPlay.onBack = { [weak self] in
            self?.closeScreen(self?.howToPlay, returnTo: self?.mainMenu)
        }

        settings.onBack = { [weak self] in
            self?.closeScreen(self?.settings, returnTo: self?.mainMenu)
        }

        styles.onBack = { [weak self] in
            self?.closeScreen(self?.styles, returnTo: self?.mainMenu)
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
