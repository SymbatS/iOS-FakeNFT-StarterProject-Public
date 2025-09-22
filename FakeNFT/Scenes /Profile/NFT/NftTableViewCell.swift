import UIKit
import Kingfisher

final class NftTableViewCell: UITableViewCell {
    static let identifier = "NftCell"
    
    var onLikeTapped: (() -> Void)?
    
    private weak var delegate: ProfileInteractionDelegate?
    
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

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .textPrimary
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .textPrimary
        label.text = NSLocalizedString("MyNftViewController.cellPrice", comment: "")
        return label
    }()

    private lazy var price: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .textPrimary
        return label
    }()

    private lazy var ratingView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = LayoutConstants.starSpacing
        
        return stack
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, ratingView, authorLabel])
        stack.axis = .vertical
        stack.spacing = LayoutConstants.spacingXS
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var priceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [priceLabel, price])
        stack.axis = .vertical
        stack.spacing = LayoutConstants.spacingXS
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupCell() {
        selectionStyle = .none
        contentView.backgroundColor = .background

        contentView.addSubview(nftImageView)
        nftImageView.addSubview(likeButton)
        
        contentView.addSubview(textStack)
        contentView.addSubview(priceStack)

        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.horizontalPadding),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),

            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 42),
            likeButton.heightAnchor.constraint(equalToConstant: 40),

            textStack.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: LayoutConstants.spacingXXL),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.widthAnchor.constraint(equalToConstant: 78),

            priceStack.leadingAnchor.constraint(equalTo: textStack.trailingAnchor, constant: 39),
            priceStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -39)
        ])
    }

    // MARK: - Configuration

//    func configure(with nft: Nft, delegate: ProfileInteractionDelegate?) {
//        nameLabel.text = nft.title
//        let authrorText = "\(NSLocalizedString("MyNftViewController.by", comment: "")) \(nft.title)"
//        authorLabel.attributedText = .withLetterSpacing(authrorText)
//
//        price.text = String(format: "%.2f ETH", nft.price)
//
//        if let firstImageURL = nft.imagesUrl.first {
//            nftImageView.kf.setImage(with: firstImageURL)
//        }
//
//        let isLiked = delegate?.isNftLiked(nft.id) ?? false
//        likeButton.setImage(UIImage(named: isLiked ? "heart_pressed" : "heart"), for: .normal)
//
//        ratingView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//
//        (1...5).forEach { index in
//            let isActive = index <= Int(nft.rating)
//            let image = UIImage(named: isActive ? "stars_active" : "stars_no_active")
//
//            let starImageView = UIImageView(image: image)
//            starImageView.contentMode = .scaleAspectFit
//            starImageView.tintColor = isActive ? .segmentInactive : nil
//
//            ratingView.addArrangedSubview(starImageView)
//        }
//    }
    
    // In NftTableViewCell.swift - update the configure method

    func configure(with nft: Nft, delegate: ProfileInteractionDelegate?) {
        self.delegate = delegate
        
        nameLabel.text = nft.title
        let authorText = "\(NSLocalizedString("MyNftViewController.by", comment: "")) \(nft.author)" // Fix: use nft.author, not nft.title
        authorLabel.attributedText = .withLetterSpacing(authorText)
        
        price.text = String(format: "%.2f ETH", nft.price)
        
        if let firstImageURL = nft.imagesUrl.first {
            nftImageView.kf.setImage(with: firstImageURL)
        }
        
        // Set heart state based on current likes
        let isLiked = delegate?.isNftLiked(nft.id) ?? false
        likeButton.setImage(UIImage(named: isLiked ? "heart_pressed" : "heart"), for: .normal)
        
        // Rating stars setup (keep existing code)
        ratingView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        (1...5).forEach { index in
            let isActive = index <= Int(nft.rating)
            let image = UIImage(named: isActive ? "stars_active" : "stars_no_active")
            let starImageView = UIImageView(image: image)
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = isActive ? .segmentInactive : nil
            ratingView.addArrangedSubview(starImageView)
        }
    }
    
//    private func isLiked(){
//        let isLiked =
//    }
    
    @objc func likeTapped() {
        onLikeTapped?()
    }
}
