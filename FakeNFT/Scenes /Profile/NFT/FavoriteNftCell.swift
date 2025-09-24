import UIKit
import Kingfisher


final class NftCollectionViewCell: UICollectionViewCell {
    static let identifier = "NftCollectionViewCell"
    
    var onLikeTapped: (() -> Void)?

    // MARK: - UI Elements
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = LayoutConstants.cornerRadiusSmall
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear

        let imageView = UIImageView(image: UIImage(named: "heart_pressed"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        
        button.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        
        button.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 21),
            imageView.heightAnchor.constraint(equalToConstant: 18)
        ])

        return button
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .textPrimary
        return label
    }()

    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = LayoutConstants.starSpacing
        stack.alignment = .center
        return stack
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        return label
    }()

    private lazy var infoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, ratingStackView, priceLabel])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setCustomSpacing(LayoutConstants.spacingXS, after: nameLabel)
        stack.setCustomSpacing(LayoutConstants.spacingM, after: ratingStackView)
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupLayout() {
        contentView.backgroundColor = .background

        contentView.addSubview(nftImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(infoStack)

        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.imageSizeSmall),
            nftImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.imageSizeSmall),

            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonSizeSmall),
            likeButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonSizeSmall),

            infoStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.spacingS),
            infoStack.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: LayoutConstants.spacingL),
            infoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            infoStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -LayoutConstants.spacingS)
        ])
    }

    // MARK: - Configure

    func configure(with nft: Nft) {
        nameLabel.text = nft.title
        let priceLabelText = String(format: "%.2f ETH", nft.price)
        priceLabel.attributedText = NSAttributedString.withLetterSpacing(priceLabelText, font: .caption1, spacing: -0.24)

        if let firstImageURL = nft.imagesUrl.first {
            nftImageView.kf.setImage(with: firstImageURL)
        }

        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for index in 1...5 {
            let imageName = index <= Int(nft.rating) ? "stars_active" : "stars_no_active"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.heightAnchor.constraint(equalToConstant: LayoutConstants.starSize).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: LayoutConstants.starSize).isActive = true
            ratingStackView.addArrangedSubview(imageView)
        }
    }
    
    @objc private func likeTapped() {
        onLikeTapped?()
        print("favorie like tapped")
    }
}
