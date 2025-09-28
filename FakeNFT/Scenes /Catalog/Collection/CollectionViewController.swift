import UIKit
import Kingfisher
import SafariServices

final class CollectionViewController: UIViewController, UICollectionViewDataSource {
    
    private var category: Category?
    private var nfts: [Nft] = []
    
    private let service: NftService
    private let collectionService: CollectionService
    private let profileSerivce: ProfileService
    
    init(category: Category, service: NftService, collectionService: CollectionService,profileService: ProfileService) {
        self.category = category
        self.service = service
        self.collectionService = collectionService
        self.profileSerivce = profileService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nftCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            NFTCollectionViewCell.self,
            forCellWithReuseIdentifier: NFTCollectionViewCell.defaultReuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.accessibilityIdentifier = "NFTCollectionView"
        return collectionView
    }()
    
    private let categoryTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .black
        navigationItem.backButtonTitle = ""
        setupConstraints()
        configureWithCategory()
        loadNFTs()
    }
    
    private func configureWithCategory() {
        guard let category else { return }
        
        categoryTitle.text = category.title
        descriptionLabel.text = category.description
        
        if let url = category.image {
            coverImageView.kf.setImage(with: url)
        }
        
        let fullText = "Автор коллекции: \(category.author)"
        let attributed = NSMutableAttributedString(string: fullText)
        
        let range = (fullText as NSString).range(of: category.author)
        attributed.addAttributes([
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ], range: range)
        
        authorLabel.attributedText = attributed
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(authorTapped))
        authorLabel.addGestureRecognizer(tap)
    }
    
    private func loadNFTs() {
        guard let category else { return }
        service.loadNfts(for: category.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newNFTs):
                    self?.nfts = newNFTs
                    self?.nftCollectionView.reloadData()
                case .failure(let error):
                    print("Ошибка загрузки NFT: \(error)")
                }
            }
        }
    }
    
    private func presentWeb(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .black
        present(safariVC, animated: true)
    }
    
    // MARK: - Layout
    private func setupConstraints() {
        view.addSubview(coverImageView)
        view.addSubview(categoryTitle)
        view.addSubview(authorLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(nftCollectionView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: view.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 310),
            
            categoryTitle.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
            categoryTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            authorLabel.topAnchor.constraint(equalTo: categoryTitle.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nftCollectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            nftCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            nftCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            nftCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func authorTapped() {
        guard let url = category?.authorURL else { return }
        presentWeb(url: url)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        nfts.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NFTCollectionViewCell.defaultReuseIdentifier,
            for: indexPath
        ) as? NFTCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: nfts[indexPath.item])
        cell.delegate = self
        return cell
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let spacing: CGFloat = 8
        let totalSpacing = (itemsPerRow - 1) * spacing
        let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow
        return CGSize(width: width, height: width + 84)
    }
}

extension CollectionViewController: NFTCollectionViewCellDelegate {
    func nftCell(_ cell: NFTCollectionViewCell, didToggleFavorite nft: Nft) {
        guard let indexPath = nftCollectionView.indexPath(for: cell) else { return }
        nfts[indexPath.item] = nft
        print("NFT \(nft.title) favorite: \(nft.isFavorite)")
        var likes:[String] = [nft.id]
        profileSerivce.fetchProfile(){ [weak self] result in
            guard let self = self else { return }
            switch result{
            case .success(let profile):
                likes.append(contentsOf: profile.likes)
                self.profileSerivce.updateProfile(name: profile.name, avatar: profile.avatar, description: profile.description, website: profile.website, likes: likes){ result in
                    switch result {
                    case .success(_):
                        print("Successfully updated likes")
                    case .failure(let error):
                        print("Error updating likes:\(error)")
                    }
                }
            case .failure(let error):
                print("Error fetching profile\(error)")
            }
            
        }
    }
    
    func nftCell(_ cell: NFTCollectionViewCell, didToggleBasket nft: Nft) {
        guard let indexPath = nftCollectionView.indexPath(for: cell) else { return }
        nfts[indexPath.item] = nft
        print("NFT \(nft.title) in basket: \(nft.isInBasket)")
        collectionService.updateCart(nft: [nft.id], orderId: "1"){ result in
            switch result{
            case .success(_):
                print("Successfully updated cart")
            case .failure(let error):
                print("Error updating cart: \(error)")
            }
            
        }
    }
}

extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nft = nfts[indexPath.item]
        let input = NftDetailInput(id: nft.id)
        let presenter = NftDetailPresenterImpl(input: input, service: service)
        let detailVC = NftDetailViewController(presenter: presenter)
        presenter.view = detailVC
        detailVC.hidesBottomBarWhenPushed = true
        
        present(detailVC, animated: true)
    }
}


