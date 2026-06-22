//
//  ImageBackgroundView.swift
//  BubbleShooter
//

import UIKit

/// Full-screen asset-backed background (aspect fill).
final class ImageBackgroundView: UIView {

    private let imageView = UIImageView()

    init(named imageName: String) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
