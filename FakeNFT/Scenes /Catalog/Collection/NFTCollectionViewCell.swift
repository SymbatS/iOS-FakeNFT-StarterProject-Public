import UIKit
import Kingfisher

protocol NFTCollectionViewCellDelegate: AnyObject {
    func nftCell(_ cell: NFTCollectionViewCell, didToggleFavorite nft: Nft)
    func nftCell(_ cell: NFTCollectionViewCell, didToggleBasket nft: Nft)
}

final class NFTCollectionViewCell: UICollectionViewCell, ReuseIdentifying {
    
    static var defaultReuseIdentifier: String { "NFTCollectionViewCell" }
    
    weak var delegate: NFTCollectionViewCellDelegate?
    private var nft: Nft?
    
    private let nftImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.kf.indicatorType = .activity
        return iv
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .like), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let basketButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupActions() {
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        basketButton.addTarget(self, action: #selector(didTapBasket), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        titleLabel.text = nil
        priceLabel.text = nil
        starsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        nft = nil
    }
    
    private func setupLayout() {
        contentView.addSubview(nftImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(basketButton)
        contentView.addSubview(starsStack)
        
        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImageView.heightAnchor.constraint(equalTo: nftImageView.widthAnchor),
            
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 4),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: -4),
            
            starsStack.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 8),
            starsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            starsStack.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: starsStack.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: basketButton.leadingAnchor, constant: -4),
            
            basketButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            basketButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            basketButton.widthAnchor.constraint(equalToConstant: 40),
            basketButton.heightAnchor.constraint(equalToConstant: 40),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -4),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    func configure(with nft: Nft) {
        self.nft = nft
        titleLabel.text = nft.title
        priceLabel.text = "\(nft.price) ETH"
        updateLikeButton()
        updateBasketButton()
        updateStars(rating: nft.rating)
        
        if let url = nft.imagesUrl.first {
            nftImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.3))]
            )
        } else {
            nftImageView.image = UIImage(systemName: "photo")
        }
    }
    
    // MARK: - Button Actions
    @objc private func didTapLike() {
        guard var nft = nft else { return }
        nft.isFavorite.toggle()
        self.nft = nft
        updateLikeButton()
        delegate?.nftCell(self, didToggleFavorite: nft)
    }
    
    @objc private func didTapBasket() {
        guard var nft = nft else { return }
        nft.isInBasket.toggle()
        self.nft = nft
        updateBasketButton()
        delegate?.nftCell(self, didToggleBasket: nft)
    }
    
    // MARK: - Update UI
    private func updateLikeButton() {
        guard let nft = nft else { return }
        let image = nft.isFavorite ? UIImage(resource: .likeActive) : UIImage(resource: .like)
        likeButton.setImage(image, for: .normal)
    }
    
    private func updateBasketButton() {
        guard let nft = nft else { return }
        let image = nft.isInBasket ? UIImage(resource: .delete) : UIImage(resource: .add)
        basketButton.setImage(image, for: .normal)
    }
    
    private func updateStars(rating: Double) {
        starsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let fullStars = Int(rating)
        for i in 0..<5 {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFit
            iv.widthAnchor.constraint(equalToConstant: 16).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 16).isActive = true
            iv.image = i < fullStars ? UIImage(resource: .starActive) : UIImage(resource: .star)
            starsStack.addArrangedSubview(iv)
        }
    }
}
