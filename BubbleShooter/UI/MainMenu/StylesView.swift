//
//  StylesView.swift
//  BubbleShooter
//

import UIKit

/// Bubble and cannon cosmetic picks — applied on the next match.
final class StylesView: LobbyScreenView {

    private let footnoteLabel = ArcadeLabel("Styles apply on the next match.", style: .caption)
    private let bubbleSection = CosmeticSegmentSection(
        title: "Bubble style",
        items: BubbleSkinPack.allCases.map(\.displayName),
        iconSize: 40,
        previewImageNames: { index in
            guard let pack = BubbleSkinPack.allCases[safe: index] else { return [] }
            return BubbleColor.allCases.map { pack.spriteName(for: $0) }
        }
    )
    private let cannonSection = CosmeticSegmentSection(
        title: "Cannon style",
        items: CannonSkin.allCases.map(\.displayName),
        iconSize: 141,
        previewImageNames: { index in
            guard let skin = CannonSkin.allCases[safe: index] else { return [] }
            return [skin.spriteName]
        }
    )

    init() {
        super.init(screenTitle: "Styles")
        configureContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadFromStorage() {
        bubbleSection.select(index: Self.index(of: CosmeticSettings.bubbleSkinPack))
        cannonSection.select(index: Self.index(of: CosmeticSettings.cannonSkin))
    }

    override func present(animated: Bool = true) {
        reloadFromStorage()
        super.present(animated: animated)
    }

    // MARK: - Private

    private func configureContent() {
        footnoteLabel.textAlignment = .center
        Theme.Text.applyHUDLegibility(to: footnoteLabel, color: Theme.Text.muted)

        bubbleSection.onSelectionChanged = { index in
            guard let pack = BubbleSkinPack.allCases[safe: index] else { return }
            CosmeticSettings.bubbleSkinPack = pack
        }

        cannonSection.onSelectionChanged = { index in
            guard let skin = CannonSkin.allCases[safe: index] else { return }
            CosmeticSettings.cannonSkin = skin
        }

        scrollStack.addArrangedSubview(bubbleSection)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: bubbleSection)
        scrollStack.addArrangedSubview(cannonSection)
        scrollStack.setCustomSpacing(Theme.Metrics.spacingLarge, after: cannonSection)
        scrollStack.addArrangedSubview(footnoteLabel)
    }

    private static func index(of pack: BubbleSkinPack) -> Int {
        BubbleSkinPack.allCases.firstIndex(of: pack) ?? 0
    }

    private static func index(of skin: CannonSkin) -> Int {
        CannonSkin.allCases.firstIndex(of: skin) ?? 0
    }
}

// MARK: - CosmeticSegmentSection

private final class CosmeticSegmentSection: UIView {

    var onSelectionChanged: ((Int) -> Void)?

    private let titleLabel = ArcadeLabel("", style: .headline)
    private let segmentedControl = UISegmentedControl()
    private let previewPanel = UIView()
    private let previewStack = UIStackView()
    private let previewImageNames: (Int) -> [String]
    private let iconSize: CGFloat
    private var previewImageViews: [UIImageView] = []

    init(
        title: String,
        items: [String],
        iconSize: CGFloat,
        previewImageNames: @escaping (Int) -> [String]
    ) {
        self.iconSize = iconSize
        self.previewImageNames = previewImageNames
        super.init(frame: .zero)
        titleLabel.text = title
        for (index, item) in items.enumerated() {
            segmentedControl.insertSegment(withTitle: item, at: index, animated: false)
        }
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func select(index: Int) {
        guard segmentedControl.numberOfSegments > index else { return }
        segmentedControl.selectedSegmentIndex = index
        refreshPreview(for: index)
    }

    // MARK: - Private

    private func configure() {
        titleLabel.textAlignment = .left
        Theme.Text.applyHUDLegibility(to: titleLabel, color: Theme.Accent.secondary)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.apportionsSegmentWidthsByContent = true
        segmentedControl.selectedSegmentTintColor = Theme.Accent.primary
        segmentedControl.backgroundColor = Theme.Surface.fillStrong
        segmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: Theme.Text.primary,
                .font: Theme.Typography.caption(16),
            ],
            for: .normal
        )
        segmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: Theme.Text.onDark,
                .font: Theme.Typography.body(16),
            ],
            for: .selected
        )
        segmentedControl.addAction(UIAction { [weak self] _ in
            guard let self, self.segmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment else { return }
            let index = self.segmentedControl.selectedSegmentIndex
            self.refreshPreview(for: index)
            self.onSelectionChanged?(index)
        }, for: .valueChanged)

        previewPanel.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.backgroundColor = Theme.Surface.fillStrong
        previewPanel.layer.cornerRadius = Theme.Metrics.cornerRadiusSmall
        previewPanel.layer.borderWidth = Theme.Metrics.borderWidth
        previewPanel.layer.borderColor = Theme.Surface.borderSubtle.cgColor

        previewStack.translatesAutoresizingMaskIntoConstraints = false
        previewStack.axis = .horizontal
        previewStack.alignment = .center
        previewStack.distribution = .equalSpacing
        previewStack.spacing = Theme.Metrics.spacingSmall

        previewPanel.addSubview(previewStack)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(segmentedControl)
        addSubview(previewPanel)

        let previewPadding = Theme.Metrics.spacingMedium
        let previewHeight = iconSize + previewPadding * 2

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),

            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.Metrics.spacingSmall),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),

            previewPanel.leadingAnchor.constraint(equalTo: leadingAnchor),
            previewPanel.trailingAnchor.constraint(equalTo: trailingAnchor),
            previewPanel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: Theme.Metrics.spacingMedium),
            previewPanel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            previewPanel.heightAnchor.constraint(equalToConstant: previewHeight),

            previewStack.leadingAnchor.constraint(
                greaterThanOrEqualTo: previewPanel.leadingAnchor,
                constant: previewPadding
            ),
            previewStack.trailingAnchor.constraint(
                lessThanOrEqualTo: previewPanel.trailingAnchor,
                constant: -previewPadding
            ),
            previewStack.centerXAnchor.constraint(equalTo: previewPanel.centerXAnchor),
            previewStack.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor),
        ])
    }

    private func refreshPreview(for index: Int) {
        let names = previewImageNames(index)

        while previewImageViews.count > names.count {
            let imageView = previewImageViews.removeLast()
            previewStack.removeArrangedSubview(imageView)
            imageView.removeFromSuperview()
        }

        while previewImageViews.count < names.count {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.setContentHuggingPriority(.required, for: .horizontal)
            imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: iconSize),
                imageView.heightAnchor.constraint(equalToConstant: iconSize),
            ])
            previewImageViews.append(imageView)
            previewStack.addArrangedSubview(imageView)
        }

        for (imageView, name) in zip(previewImageViews, names) {
            imageView.image = UIImage(named: name)
        }
    }
}

// MARK: - Safe collection access

private extension Collection {

    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
