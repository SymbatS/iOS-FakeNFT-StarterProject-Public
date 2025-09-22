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
        guard newIDs != self.nftIDs else {
            return
        }
        
        self.nftIDs = newIDs
        handler.updateNftIDs(newIDs)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if newIDs.isEmpty {
                self.showEmptyLabel()
            } else {
                self.emptyLabel.isHidden = true
                self.collectionView.isHidden = false
                self.collectionView.alpha = 1
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
        
        animatedRemoveNft(withID: id)
        
        delegate.didUpdateLikes(updatedLikes) { [weak self] updatedProfile in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let profile = updatedProfile {
                    
                    if Set(profile.likes) != Set(updatedLikes) {
                        self.updateNftIDs(profile.likes)
                    }
                } else {
                    self.updateNftIDs(currentLikes)
                }
            }
        }
    }
    
    private func animatedRemoveNft(withID id: String) {
        guard let removedIndex = handler.removeNft(withID: id) else {
            return
        }
        
        
        collectionView.performBatchUpdates({
            let indexPath = IndexPath(item: removedIndex, section: 0)
            collectionView.deleteItems(at: [indexPath])
        }) { [weak self] finished in
            guard let self = self, finished else { return }
            
            if self.handler.numberOfItems == 0 {
                self.showEmptyLabelAnimated()
            }
        }
    }
    
    private func showEmptyLabelAnimated() {
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.alpha = 0
        }) { _ in
            self.collectionView.isHidden = true
            self.emptyLabel.isHidden = false
            self.emptyLabel.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                self.emptyLabel.alpha = 1
                self.collectionView.alpha = 1
            }
        }
    }
    
    
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
