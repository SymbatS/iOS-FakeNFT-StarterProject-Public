import UIKit

final class MyNftViewController: UIViewController, LoadingView {
    weak var delegate: ProfileInteractionDelegate?
    
    // MARK: - Properties
    private let servicesAssembly: ServicesAssembly
    private let nftIDs: [String]
    private var nfts: [Nft] = []
    private var sortedNfts: [Nft] = []
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(NftTableViewCell.self, forCellReuseIdentifier: NftTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("myNFT.empty", comment: "У вас пока нет NFT")
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    internal lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
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
        setupUI()
        setupNavigationBar()
        
        if nftIDs.isEmpty {
            showEmptyState()
        } else {
            loadNfts()
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubviews(tableView, emptyLabel, activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = NSLocalizedString("myNFT.title", comment: "Мои NFT")
        
        // Кнопка назад
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
        
        // Кнопка сортировки
        if !nftIDs.isEmpty {
            let sortButton = UIBarButtonItem(
                image: UIImage(systemName: "arrow.up.arrow.down"),
                style: .plain,
                target: self,
                action: #selector(showSortMenu)
            )
            sortButton.tintColor = .label
            sortButton.isEnabled = false // будет включена после загрузки
            navigationItem.rightBarButtonItem = sortButton
        }
    }
    
    private func showEmptyState() {
        emptyLabel.isHidden = false
        tableView.isHidden = true
        navigationItem.rightBarButtonItem = nil
    }
    
    private func loadNfts() {
        showLoading()
        
        let nftService = servicesAssembly.nftService
        let group = DispatchGroup()
        var loadedNfts: [Nft] = []
        
        for nftId in nftIDs {
            group.enter()
            nftService.loadNft(id: nftId) { result in
                defer { group.leave() }
                switch result {
                case .success(let nft):
                    loadedNfts.append(nft)
                case .failure(let error):
                    print("Error loading NFT \(nftId): \(error)")
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.hideLoading()
            
            // Сортируем по порядку из nftIDs для сохранения исходного порядка
            self.nfts = self.nftIDs.compactMap { nftId in
                loadedNfts.first { $0.id == nftId }
            }
            
            self.sortedNfts = self.nfts
            self.tableView.isHidden = false
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.tableView.reloadData()
        }
    }
    
    private func sortNfts(by sortType: SortType) {
        switch sortType {
        case .name:
            sortedNfts.sort { $0.name < $1.name }
        case .price:
            sortedNfts.sort { $0.price < $1.price }
        case .rating:
            sortedNfts.sort { $0.rating > $1.rating }
        }
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func showSortMenu() {
        let alert = UIAlertController(
            title: NSLocalizedString("myNFT.sort.title", comment: "Сортировка"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("myNFT.sort.name", comment: "По названию"),
            style: .default
        ) { [weak self] _ in
            self?.sortNfts(by: .name)
        })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("myNFT.sort.price", comment: "По цене"),
            style: .default
        ) { [weak self] _ in
            self?.sortNfts(by: .price)
        })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("myNFT.sort.rating", comment: "По рейтингу"),
            style: .default
        ) { [weak self] _ in
            self?.sortNfts(by: .rating)
        })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("common.cancel", comment: "Отмена"),
            style: .cancel
        ))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension MyNftViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedNfts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NftTableViewCell.identifier,
            for: indexPath
        ) as? NftTableViewCell else {
            return UITableViewCell()
        }
        
        let nft = sortedNfts[indexPath.row]
        cell.configure(with: nft, delegate: delegate)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyNftViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

// MARK: - Sort Type Enum
enum SortType {
    case name
    case price
    case rating
}
