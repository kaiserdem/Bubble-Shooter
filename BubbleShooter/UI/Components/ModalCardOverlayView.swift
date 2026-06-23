//
//  ModalCardOverlayView.swift
//  BubbleShooter
//

import UIKit

/// Fullscreen modal with blurred backdrop and a centered results-style card.
class ModalCardOverlayView: UIView {

    let cardPanel = UIView()
    let contentStack = UIStackView()

    private let backdropBlur = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemThinMaterialDark)
    )
    private let backdropTint = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureChrome()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present(animated: Bool = true) {
        isHidden = false
        isUserInteractionEnabled = true
        alpha = animated ? 0 : 1
        guard animated else { return }

        UIView.animate(withDuration: 0.35) {
            self.alpha = 1
        }
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        let finish = {
            self.isHidden = true
            self.isUserInteractionEnabled = false
            completion?()
        }

        guard animated else {
            alpha = 0
            finish()
            return
        }

        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }, completion: { _ in
            finish()
        })
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, isUserInteractionEnabled, alpha > 0.01 else { return nil }
        return super.hitTest(point, with: event)
    }

    // MARK: - Private

    private func configureChrome() {
        isHidden = true
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        backdropBlur.translatesAutoresizingMaskIntoConstraints = false
        backdropBlur.overrideUserInterfaceStyle = .dark
        backdropBlur.alpha = 0.78

        backdropTint.translatesAutoresizingMaskIntoConstraints = false
        backdropTint.isUserInteractionEnabled = false
        backdropTint.backgroundColor = Theme.Background.deep.withAlphaComponent(0.20)

        cardPanel.translatesAutoresizingMaskIntoConstraints = false
        cardPanel.backgroundColor = Theme.Background.elevated.withAlphaComponent(0.97)
        cardPanel.layer.cornerRadius = Theme.Metrics.cornerRadiusLarge
        cardPanel.layer.borderWidth = Theme.Metrics.borderWidth
        cardPanel.layer.borderColor = Theme.Surface.border.cgColor
        cardPanel.layer.shadowColor = Theme.Surface.shadow.cgColor
        cardPanel.layer.shadowOpacity = 1
        cardPanel.layer.shadowRadius = 18
        cardPanel.layer.shadowOffset = CGSize(width: 0, height: 9)

        contentStack.axis = .vertical
        contentStack.spacing = Theme.Metrics.spacingMedium
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backdropBlur)
        addSubview(backdropTint)
        addSubview(cardPanel)
        cardPanel.addSubview(contentStack)

        let padding = Theme.Metrics.contentPadding

        NSLayoutConstraint.activate([
            backdropBlur.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdropBlur.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdropBlur.topAnchor.constraint(equalTo: topAnchor),
            backdropBlur.bottomAnchor.constraint(equalTo: bottomAnchor),

            backdropTint.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdropTint.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdropTint.topAnchor.constraint(equalTo: topAnchor),
            backdropTint.bottomAnchor.constraint(equalTo: bottomAnchor),

            cardPanel.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardPanel.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardPanel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            cardPanel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            cardPanel.widthAnchor.constraint(lessThanOrEqualToConstant: 360),

            contentStack.leadingAnchor.constraint(equalTo: cardPanel.leadingAnchor, constant: padding),
            contentStack.trailingAnchor.constraint(equalTo: cardPanel.trailingAnchor, constant: -padding),
            contentStack.topAnchor.constraint(equalTo: cardPanel.topAnchor, constant: padding),
            contentStack.bottomAnchor.constraint(equalTo: cardPanel.bottomAnchor, constant: -padding),
        ])
    }
}
