//
//  SettingsView.swift
//  BubbleShooter
//

import UIKit

/// Full-screen audio and haptics preferences.
final class SettingsView: LobbyScreenView {

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
    }

    override func present(animated: Bool = true) {
        reloadFromStorage()
        super.present(animated: animated)
    }

    // MARK: - Private

    private func configureContent() {
        let audioHeader = SettingsSectionHeader(title: "Audio & feedback")

        scrollStack.addArrangedSubview(audioHeader)
        scrollStack.addArrangedSubview(soundRow)
        scrollStack.addArrangedSubview(musicRow)
        scrollStack.addArrangedSubview(hapticsRow)
    }
}

// MARK: - SettingsSectionHeader

private final class SettingsSectionHeader: UIView {

    private let label = ArcadeLabel("", style: .headline)

    init(title: String) {
        super.init(frame: .zero)
        label.text = title
        label.textAlignment = .left
        Theme.Text.applyHUDLegibility(to: label, color: Theme.Accent.secondary)
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
        Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Text.primary)
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

            toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            toggle.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggle.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            toggle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }
}
