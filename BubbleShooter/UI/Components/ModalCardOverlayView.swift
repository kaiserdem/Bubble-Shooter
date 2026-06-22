//
//  ModalCardOverlayView.swift
//  BubbleShooter
//

import UIKit

/// Reusable dimmed full-screen overlay with a centered glass card.
class ModalCardOverlayView: UIView {

    let card = GlassCardView()
    let contentStack = UIStackView()

    private let dimView = UIView()

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
        guard animated else {
            alpha = 1
            card.transform = .identity
            return
        }

        alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.86,
            initialSpringVelocity: 0.4
        ) {
            self.alpha = 1
            self.card.transform = .identity
        }
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        let finish = {
            self.isHidden = true
            self.isUserInteractionEnabled = false
            self.card.transform = .identity
            completion?()
        }

        guard animated else {
            alpha = 0
            finish()
            return
        }

        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.card.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
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

        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.45)

        card.translatesAutoresizingMaskIntoConstraints = false
        card.isUserInteractionEnabled = true

        contentStack.axis = .vertical
        contentStack.spacing = Theme.Metrics.spacingMedium
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(dimView)
        addSubview(card)
        card.contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),

            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 360),

            contentStack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
        ])
    }
}
