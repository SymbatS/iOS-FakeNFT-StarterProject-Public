import UIKit

final class FavoritesNftViewController: UIViewController {
    weak var delegate: ProfileInteractionDelegate?
    
    private let servicesAssembly: ServicesAssembly
    private var nftIDs: [String]
    
    private lazy var handler: NftHandler = {
        NftHandler(
            view: self,
            services: servicesAssembly,
            nftIDs: nftIDs
        )
    }()
    
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = LayoutConstants.spacingL
        layout.minimumLineSpacing = LayoutConstants.spacingXXL
        layout.estimatedItemSize = .zero
        layout.sectionInset = UIEdgeInsets(
            top: LayoutConstants.spacingXXL,
            left: LayoutConstants.horizontalPadding,
            bottom: LayoutConstants.spacingXXL,
            right: LayoutConstants.horizontalPadding
        )
        
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(NftCollectionViewCell.self, forCellWithReuseIdentifier: NftCollectionViewCell.identifier)
        cv.backgroundColor = .background
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("FavoritesViewController.placeholder", comment: "")
        label.textAlignment = .center
        label.textColor = .textPrimary
        label.font = .bodyBold
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Init
    
    init(servicesAssembly: ServicesAssembly, nftIDs: [String]) {
        self.servicesAssembly = servicesAssembly
        self.nftIDs = nftIDs
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        navigationItem.title = NSLocalizedString("FavoritesViewController.title",comment: "")
        
        setupBackButton()
        setupUI()
        
        if nftIDs.isEmpty {
            showEmptyLabel()
        } else {
            handler.viewDidLoad()
        }
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstants.horizontalPadding),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstants.horizontalPadding)
        ])
    }
    
    func updateNftIDs(_ newIDs: [String]) {
        print("🔄 FavoritesNftViewController.updateNftIDs called with: \(newIDs)")
        print("📋 Previous nftIDs: \(self.nftIDs)")
        
        self.nftIDs = newIDs
        handler.updateNftIDs(newIDs)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if newIDs.isEmpty {
                print("📭 Showing empty label")
                self.showEmptyLabel()
            } else {
                print("📋 Showing collection view with \(newIDs.count) items")
                self.emptyLabel.isHidden = true
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
            }
        }
    }
    
    private func showEmptyLabel() {
        emptyLabel.isHidden = false
        collectionView.isHidden = true
    }
    
    private func setupBackButton() {
        guard let backImage = UIImage(systemName: "chevron.left") else { return }
        let backButton = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(backButtonTapped))
        
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func removeLike(withID id: String) {
        guard let delegate = delegate else { return }
        let currentLikes = delegate.getCurrentLikes()
        
        var updatedLikes = currentLikes
        updatedLikes.removeAll { $0 == id }
        
        print("🗑️ Removing like for ID: \(id)")
        print("📝 Current likes: \(currentLikes)")
        print("📝 Updated likes: \(updatedLikes)")
        
        // ✅ НЕ обновляем UI сразу, ждем ответа сервера
        delegate.didUpdateLikes(updatedLikes) { [weak self] updatedProfile in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let profile = updatedProfile {
                    print("✅ Server confirmed. Final likes: \(profile.likes)")
                    self.updateNftIDs(profile.likes)
                } else {
                    print("❌ Server failed. Reverting to: \(currentLikes)")
                    // При ошибке возвращаем старое состояние
                    self.updateNftIDs(currentLikes)
                }
            }
        }
    }

    
//    private func removeLike(withID id: String) {
//        guard let delegate = delegate else { return }
//        let currentLikes = delegate.getCurrentLikes()
//        
//        var updatedLikes = currentLikes
//        updatedLikes.removeAll { $0 == id }
//        
//        updateNftIDs(updatedLikes)
//        
//        delegate.didUpdateLikes(updatedLikes) { [weak self] updatedProfile in
//            guard let self = self else { return }
//            
//            let finalLikes = updatedProfile?.likes ?? currentLikes
//            if finalLikes != updatedLikes {
//                self.updateNftIDs(finalLikes)
//            }
//        }
//    }
    
    @objc private func backButtonTapped() {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension FavoritesNftViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        handler.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NftCollectionViewCell.identifier,
            for: indexPath
        ) as? NftCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let nft = handler.item(at: indexPath.row)
        cell.configure(with: nft)
        
        cell.onLikeTapped = { [weak self] in
            self?.removeLike(withID: nft.id)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FavoritesNftViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing = LayoutConstants.spacingL
        let inset = LayoutConstants.horizontalPadding
        let numberOfColumns = 2
        
        let totalSpacing = (numberOfColumns - 1) * 12
        let totalInsets = inset * 2
        let availableWidth = collectionView.bounds.width - CGFloat(totalInsets) - CGFloat(totalSpacing)
        let itemWidth = floor(availableWidth / CGFloat(numberOfColumns))
        let itemHeight = LayoutConstants.imageSizeSmall
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

// MARK: - MyNftView
extension FavoritesNftViewController: NftView {
    func reloadData() {
        collectionView.reloadData()
    }
}
