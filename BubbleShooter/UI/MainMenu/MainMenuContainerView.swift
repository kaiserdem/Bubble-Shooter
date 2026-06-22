//
//  MainMenuContainerView.swift
//  BubbleShooter
//

import UIKit

/// Hosts the main menu and its modal children — keeps pre-game navigation out of `GameViewController`.
final class MainMenuContainerView: UIView {

    var onPlay: (() -> Void)?

    private let mainMenu = MainMenuView()
    private let howToPlay = HowToPlayView()
    private let settings = SettingsView()

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

        for child in [mainMenu, howToPlay, settings] {
            child.translatesAutoresizingMaskIntoConstraints = false
            addSubview(child)
            NSLayoutConstraint.activate([
                child.leadingAnchor.constraint(equalTo: leadingAnchor),
                child.trailingAnchor.constraint(equalTo: trailingAnchor),
                child.topAnchor.constraint(equalTo: topAnchor),
                child.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }

        mainMenu.onPlay = { [weak self] in
            self?.onPlay?()
        }

        mainMenu.onHowToPlay = { [weak self] in
            self?.howToPlay.present()
        }

        mainMenu.onSettings = { [weak self] in
            self?.settings.reloadFromStorage()
            self?.settings.present()
        }

        howToPlay.onClose = { [weak self] in
            self?.howToPlay.dismiss()
        }

        settings.onClose = { [weak self] in
            self?.settings.dismiss()
        }
    }
}
