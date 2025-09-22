import UIKit

final class MyNftViewController: UIViewController, NftView {
    weak var delegate: ProfileInteractionDelegate?
    
    private let servicesAssembly: ServicesAssembly
    
    // MARK: - Properties
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let nftIDs: [String]
    private var profile: Profile?
    private let profileService: ProfileService
    
    private lazy var handler: NftHandler = {
        NftHandler(
            view: self,
            services: servicesAssembly,
            nftIDs: nftIDs
        )
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString(
            "MyNftViewController.emptyLabel",
            comment: ""
        )
        label.textAlignment = .center
        label.textColor = .textPrimary
        label.font = .bodyBold
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Init
    init(servicesAssembly: ServicesAssembly, nftIDs: [String],profile: Profile) {
        self.servicesAssembly = servicesAssembly
        self.profileService = servicesAssembly.profileService
        self.nftIDs = nftIDs
        self.profile = profile
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
        navigationItem.title = NSLocalizedString("MyNftViewController.title", comment: "")
        
        setupTableView()
        setupBackButton()
        setupSortButton()
        setupEmptyLabel()
        
        if nftIDs.isEmpty {
            showEmptyLabel()
        } else {
            handler.viewDidLoad()
        }
    }
    
    // MARK: - MyNFTView
    func reloadData() {
        tableView.reloadData()
    }
    
    // MARK: - UI Setup
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .background
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(NftTableViewCell.self, forCellReuseIdentifier: NftTableViewCell.identifier)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEmptyLabel() {
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstants.horizontalPadding),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstants.horizontalPadding)
        ])
    }
    
    private func showEmptyLabel() {
        emptyLabel.isHidden = false
        tableView.isHidden = true
        navigationItem.rightBarButtonItem = nil
    }
    
    private func setupBackButton() {
        guard let backImage = UIImage(systemName: "chevron.left") else { return }
        let backButton = UIBarButtonItem(image: backImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped))
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupSortButton() {
        guard let sortImage = UIImage(systemName: "line.horizontal.3.decrease") else { return }
        let sortButton = UIBarButtonItem(
            image: sortImage,
            style: .plain,
            target: self,
            action: #selector(showSortMenu)
        )
        sortButton.tintColor = .label
        navigationItem.rightBarButtonItem = sortButton
    }
    
    @objc private func backButtonTapped() {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func showSortMenu() {
        let alert = UIAlertController(
            title: NSLocalizedString("MyNftViewController.sortMenuTitle", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("MyNftViewController.sortMenuName", comment: ""),
            style: .default
        ) { _ in self.handler.sort(by: .name) })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("MyNftViewController.sortMenuPrice", comment: ""),
            style: .default
        ) { _ in self.handler.sort(by: .price) })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("MyNftViewController.sortMenuRating", comment: ""),
            style: .default
        ) { _ in self.handler.sort(by: .rating) })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("MyNftViewController.sortMenuCancel", comment: ""),
            style: .cancel
        ))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension MyNftViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        handler.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NftTableViewCell.identifier, for: indexPath) as? NftTableViewCell else {
            return UITableViewCell()
        }
        
        let nft = handler.item(at: indexPath.row)
        cell.configure(with: nft, delegate: delegate)
        
        cell.onLikeTapped = { [weak self] in
            guard let self = self else { return }
            let currentlyLiked = self.delegate?.isNftLiked(nft.id) ?? false
            
            guard let delegate = self.delegate else { return }
            let currentLikes = delegate.getCurrentLikes()
            
            var newLikes = currentLikes
            if currentlyLiked {
                newLikes.removeAll { $0 == nft.id }
            } else {
                if !newLikes.contains(nft.id) {
                    newLikes.append(nft.id)
                }
            }
            
            delegate.didUpdateLikes(newLikes) { [weak self] _ in
                guard let self = self else { return }
                if let visibleIndexPaths = self.tableView.indexPathsForVisibleRows,
                   visibleIndexPaths.contains(indexPath) {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MyNftViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

