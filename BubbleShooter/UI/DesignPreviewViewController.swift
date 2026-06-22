//
//  DesignPreviewViewController.swift
//  BubbleShooter
//

import UIKit

#if DEBUG
/// Gallery screen for the Cosmic Pop Twilight design system.
final class DesignPreviewViewController: UIViewController {

  var onClose: (() -> Void)?

  private let backgroundView = GradientBackgroundView()
  private let scrollView = UIScrollView()
  private let stackView = UIStackView()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureLayout()
    populateSections()
  }

  override var prefersStatusBarHidden: Bool {
    true
  }

  private func configureLayout() {
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    stackView.translatesAutoresizingMaskIntoConstraints = false

    stackView.axis = .vertical
    stackView.spacing = Theme.Metrics.spacingLarge
    stackView.alignment = .fill

    view.addSubview(backgroundView)
    view.addSubview(scrollView)
    scrollView.addSubview(stackView)

    NSLayoutConstraint.activate([
      backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
      stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
      stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
      stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
      stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48),
    ])
  }

  private func populateSections() {
    stackView.addArrangedSubview(makeHeader())
    stackView.addArrangedSubview(makeSection(
      title: "Glass Card",
      subtitle: "Скляна панель з blur і світним контуром"
    ) {
      self.makeGlassCardSample()
    })
    stackView.addArrangedSubview(makeSection(
      title: "Arcade Buttons",
      subtitle: "Primary, secondary, ghost, danger"
    ) {
      self.makeButtonRow()
    })
    stackView.addArrangedSubview(makeSection(
      title: "Badges",
      subtitle: "Теги статусу та режимів"
    ) {
      self.makeBadgeRow()
    })
    stackView.addArrangedSubview(makeSection(
      title: "Bubble Palette",
      subtitle: "Фіксований порядок кольорів геймплею"
    ) {
      self.makeBubblePalette()
    })

    let closeButton = ArcadeButton(title: "Закрити", style: .ghost)
    closeButton.addAction(UIAction { [weak self] _ in
      self?.onClose?()
    }, for: .touchUpInside)
    stackView.addArrangedSubview(closeButton)
  }

  private func makeHeader() -> UIView {
    let title = ArcadeLabel("Design Preview", style: .title)
    let subtitle = ArcadeLabel("Cosmic Pop Twilight", style: .body)
    let badge = BadgeView(text: Theme.Brand.variant.uppercased(), tint: Theme.Accent.gold)

    let stack = UIStackView(arrangedSubviews: [title, badge, subtitle])
    stack.axis = .vertical
    stack.spacing = Theme.Metrics.spacingSmall
    stack.alignment = .center
    return stack
  }

  private func makeSection(title: String, subtitle: String, content: () -> UIView) -> UIView {
    let sectionStack = UIStackView()
    sectionStack.axis = .vertical
    sectionStack.spacing = Theme.Metrics.spacingMedium

    let titleLabel = ArcadeLabel(title, style: .headline)
    titleLabel.textAlignment = .left
    let subtitleLabel = ArcadeLabel(subtitle, style: .caption)
    subtitleLabel.textAlignment = .left

    sectionStack.addArrangedSubview(titleLabel)
    sectionStack.addArrangedSubview(subtitleLabel)
    sectionStack.addArrangedSubview(content())
    return sectionStack
  }

  private func makeGlassCardSample() -> UIView {
    let card = GlassCardView()
    card.translatesAutoresizingMaskIntoConstraints = false
    card.heightAnchor.constraint(equalToConstant: 140).isActive = true

    let label = ArcadeLabel("Score: 12,450", style: .headline)
    label.textAlignment = .center
    let caption = ArcadeLabel("HUD / меню / діалоги", style: .caption)
    caption.textAlignment = .center

    let inner = UIStackView(arrangedSubviews: [label, caption])
    inner.axis = .vertical
    inner.spacing = Theme.Metrics.spacingSmall
    inner.translatesAutoresizingMaskIntoConstraints = false
    card.contentView.addSubview(inner)
    NSLayoutConstraint.activate([
      inner.centerXAnchor.constraint(equalTo: card.contentView.centerXAnchor),
      inner.centerYAnchor.constraint(equalTo: card.contentView.centerYAnchor),
      inner.leadingAnchor.constraint(greaterThanOrEqualTo: card.contentView.leadingAnchor),
      inner.trailingAnchor.constraint(lessThanOrEqualTo: card.contentView.trailingAnchor),
    ])

    return card
  }

  private func makeButtonRow() -> UIView {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = Theme.Metrics.spacingMedium

    let styles: [(String, ArcadeButton.Style)] = [
      ("Play Match", .primary),
      ("Secondary", .secondary),
      ("Ghost", .ghost),
      ("Abort", .danger),
    ]

    for (title, style) in styles {
      let button = ArcadeButton(title: title, style: style)
      button.isUserInteractionEnabled = false
      stack.addArrangedSubview(button)
    }

    return stack
  }

  private func makeBadgeRow() -> UIView {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = Theme.Metrics.spacingSmall
    stack.distribution = .fillEqually

    stack.addArrangedSubview(BadgeView(text: "PvP", tint: Theme.Accent.secondary))
    stack.addArrangedSubview(BadgeView(text: "LIVE", tint: Theme.Accent.danger))
    stack.addArrangedSubview(BadgeView(text: "x2", tint: Theme.Accent.gold))

    return stack
  }

  private func makeBubblePalette() -> UIView {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = Theme.Metrics.spacingSmall
    stack.distribution = .fillEqually
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.heightAnchor.constraint(equalToConstant: 44).isActive = true

    for index in 0..<Theme.Bubble.all.count {
      let swatch = UIView()
      swatch.backgroundColor = Theme.Bubble.uiColor(at: index)
      swatch.layer.cornerRadius = 22
      swatch.layer.borderWidth = 1.5
      swatch.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
      stack.addArrangedSubview(swatch)
    }

    return stack
  }
}
#endif
