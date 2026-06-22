//
//  SettingsView.swift
//  BubbleShooter
//

import UIKit

/// Audio and haptics preferences — persisted via `GameSettings`.
final class SettingsView: ModalCardOverlayView {

    var onClose: (() -> Void)?

    private let titleLabel = ArcadeLabel("Settings", style: .headline)
    private let closeButton = ArcadeButton(title: "Done", style: .primary)

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

    override init(frame: CGRect) {
        super.init(frame: frame)
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

    // MARK: - Private

    private func configureContent() {
        titleLabel.textAlignment = .center

        closeButton.addAction(UIAction { [weak self] _ in
            self?.onClose?()
        }, for: .touchUpInside)

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(soundRow)
        contentStack.addArrangedSubview(musicRow)
        contentStack.addArrangedSubview(hapticsRow)
        contentStack.addArrangedSubview(closeButton)
        contentStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: hapticsRow)
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
