//
//  SettingsView.swift
//  BubbleShooter
//

import UIKit

/// Full-screen audio, haptics, and cosmetic preferences.
final class SettingsView: LobbyScreenView {

    private let footnoteLabel = ArcadeLabel("Styles apply on the next match.", style: .caption)

    private let soundRow = SettingsToggleRow(
        title: "Sound effects",
        get: { GameSettings.isSoundEnabled },
        set: { GameSettings.isSoundEnabled = $0 }
    )
    private let musicRow = SettingsToggleRow(
        title: "Music",
        get: { GameSettings.isMusicEnabled },
        set: { GameSettings.isMusicEnabled = $0 }
    )
    private let hapticsRow = SettingsToggleRow(
        title: "Haptics",
        get: { GameSettings.isHapticsEnabled },
        set: { GameSettings.isHapticsEnabled = $0 }
    )

    private var bubbleStyleRow: SettingsOptionRow!
    private var cannonStyleRow: SettingsOptionRow!

    init() {
        super.init(screenTitle: "Settings")
        configureContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadFromStorage() {
        soundRow.reload()
        musicRow.reload()
        hapticsRow.reload()
        bubbleStyleRow.reload()
        cannonStyleRow.reload()
    }

    override func present(animated: Bool = true) {
        reloadFromStorage()
        super.present(animated: animated)
    }

    // MARK: - Private

    private func configureContent() {
        footnoteLabel.textAlignment = .center
        footnoteLabel.textColor = Theme.Text.muted

        bubbleStyleRow = SettingsOptionRow(
            title: "Bubble style",
            getTitle: { CosmeticSettings.bubbleSkinPack.displayName },
            makeMenu: { [weak self] in
                UIMenu(children: BubbleSkinPack.allCases.map { pack in
                    UIAction(
                        title: pack.displayName,
                        state: pack == CosmeticSettings.bubbleSkinPack ? .on : .off
                    ) { _ in
                        CosmeticSettings.bubbleSkinPack = pack
                        self?.reloadFromStorage()
                    }
                })
            }
        )

        cannonStyleRow = SettingsOptionRow(
            title: "Cannon style",
            getTitle: { CosmeticSettings.cannonSkin.displayName },
            makeMenu: { [weak self] in
                UIMenu(children: CannonSkin.allCases.map { skin in
                    UIAction(
                        title: skin.displayName,
                        state: skin == CosmeticSettings.cannonSkin ? .on : .off
                    ) { _ in
                        CosmeticSettings.cannonSkin = skin
                        self?.reloadFromStorage()
                    }
                })
            }
        )

        let audioHeader = SettingsSectionHeader(title: "Audio & feedback")
        let styleHeader = SettingsSectionHeader(title: "Cosmetics")

        scrollStack.addArrangedSubview(audioHeader)
        scrollStack.addArrangedSubview(soundRow)
        scrollStack.addArrangedSubview(musicRow)
        scrollStack.addArrangedSubview(hapticsRow)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: hapticsRow)
        scrollStack.addArrangedSubview(styleHeader)
        scrollStack.addArrangedSubview(bubbleStyleRow)
        scrollStack.addArrangedSubview(cannonStyleRow)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: cannonStyleRow)
        scrollStack.addArrangedSubview(footnoteLabel)
    }
}

// MARK: - SettingsSectionHeader

private final class SettingsSectionHeader: UIView {

    private let label = ArcadeLabel("", style: .headline)

    init(title: String) {
        super.init(frame: .zero)
        label.text = title
        label.textAlignment = .left
        label.textColor = Theme.Accent.secondary
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SettingsToggleRow

private final class SettingsToggleRow: UIView {

    private let titleLabel = ArcadeLabel("", style: .body)
    private let toggle = UISwitch()
    private let getValue: () -> Bool
    private let setValue: (Bool) -> Void

    init(title: String, get: @escaping () -> Bool, set: @escaping (Bool) -> Void) {
        getValue = get
        setValue = set
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.textColor = Theme.Text.primary
        configure()
        reload()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reload() {
        toggle.isOn = getValue()
    }

    private func configure() {
        toggle.onTintColor = Theme.Accent.primary
        toggle.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.setValue(self.toggle.isOn)
        }, for: .valueChanged)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggle.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(toggle)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -12),

            toggle.trailingAnchor.constraint(equalTo: trailingAnchor),
            toggle.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggle.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            toggle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }
}

// MARK: - SettingsOptionRow

private final class SettingsOptionRow: UIView {

    private let titleLabel = ArcadeLabel("", style: .body)
    private let valueButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = Theme.Accent.secondary
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 0)
        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .trailing
        return button
    }()

    private let getTitle: () -> String
    private let makeMenu: () -> UIMenu

    init(title: String, getTitle: @escaping () -> String, makeMenu: @escaping () -> UIMenu) {
        self.getTitle = getTitle
        self.makeMenu = makeMenu
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.textColor = Theme.Text.primary
        configure()
        reload()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reload() {
        valueButton.configuration?.title = getTitle()
        valueButton.menu = makeMenu()
        valueButton.showsMenuAsPrimaryAction = true
    }

    private func configure() {
        valueButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(valueButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueButton.leadingAnchor, constant: -8),

            valueButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueButton.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            valueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }
}
