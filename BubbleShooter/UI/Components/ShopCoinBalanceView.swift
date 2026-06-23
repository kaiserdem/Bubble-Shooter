//
//  ShopCoinBalanceView.swift
//  BubbleShooter
//

import UIKit

/// Compact coin icon + balance for shop category headers.
final class ShopCoinBalanceView: UIView {

    private let coinView = UIImageView()
    private let balanceLabel = ArcadeLabel("", style: .headline, color: Theme.Accent.gold)

    private let balanceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(balance: Int) {
        balanceLabel.text = balanceFormatter.string(from: NSNumber(value: balance)) ?? "\(balance)"
    }

    // MARK: - Private

    private func configure() {
        isUserInteractionEnabled = false

        coinView.image = UIImage(named: Theme.Asset.Shop.coin2)
        coinView.contentMode = .scaleAspectFit
        coinView.translatesAutoresizingMaskIntoConstraints = false

        balanceLabel.textAlignment = .left
        Theme.Text.applyHUDLegibility(to: balanceLabel, color: Theme.Accent.gold)

        let stack = UIStackView(arrangedSubviews: [coinView, balanceLabel])
        stack.axis = .horizontal
        stack.spacing = Theme.Metrics.spacingSmall
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            coinView.widthAnchor.constraint(equalToConstant: 28),
            coinView.heightAnchor.constraint(equalToConstant: 28),

            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
