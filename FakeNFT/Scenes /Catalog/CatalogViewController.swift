import UIKit

final class CatalogViewController: UIViewController {
    
    // MARK: - UI
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .systemBackground
        return tv
    }()
    
    private let activity = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Data
    private var categories: [Category] = []
    private var sort: SortOption = .byNftCount
    
    let servicesAssembly: ServicesAssembly
    
    // MARK: - Init
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTable()
        setupNavBar()
        setupActivity()
        restoreSort()
        fetchCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySortAndReload()
    }
    
    // MARK: - Setup
    private func setupTable() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource   = self
        tableView.delegate     = self
        tableView.register(CatalogCell.self)
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavBar() {
        let image = UIImage(resource: .sort)
        let item = UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(tapOnFilter))
        item.tintColor = .black
        navigationItem.rightBarButtonItem = item
    }
    
    private func setupActivity() {
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.hidesWhenStopped = true
        view.addSubview(activity)
        NSLayoutConstraint.activate([
            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Loading
    private func fetchCategories() {
        activity.startAnimating()
        tableView.backgroundView = nil
        
        servicesAssembly.catalogService.fetchCollections { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.activity.stopAnimating()
                self.refreshControl.endRefreshing()
                
                switch result {
                case .success(let items):
                    self.categories = items
                    self.applySortAndReload()
                    
                case .failure:
                    self.categories = []
                    self.tableView.reloadData()
                    self.tableView.backgroundView = self.makeEmptyView(
                        text: "Не удалось загрузить.\nПопробуйте ещё раз.",
                        withRetry: true
                    )
                }
            }
        }
    }
    
    @objc private func handleRefresh() {
        fetchCategories()
    }
    
    // MARK: - Empty view
    private func makeEmptyView(text: String, withRetry: Bool = false) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        
        stack.addArrangedSubview(label)
        
        if withRetry {
            let button = UIButton(type: .system)
            button.setTitle("Повторить", for: .normal)
            button.addTarget(self, action: #selector(retry), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
        
        let container = UIView(frame: view.bounds)
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }
    
    @objc private func retry() {
        tableView.backgroundView = nil
        fetchCategories()
    }
    
    // MARK: - Sorting
    enum SortOption: String {
        case byNftCount
        case byTitle
    }
    
    private func applySortAndReload() {
        switch sort {
        case .byNftCount:
            categories.sort { $0.count > $1.count }
        case .byTitle:
            categories.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
        tableView.reloadData()
        saveSort()
    }
    
    private func saveSort() {
        UserDefaults.standard.set(sort.rawValue, forKey: "catalog.sort")
    }
    
    private func restoreSort() {
        if let raw = UserDefaults.standard.string(forKey: "catalog.sort"),
           let s = SortOption(rawValue: raw) {
            sort = s
        }
    }
    
    // MARK: - Actions
    @objc private func tapOnFilter(_ sender: UIBarButtonItem) {
        let sheet = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "По названию", style: .default, handler: { [weak self] _ in
            self?.sort = .byTitle
            self?.applySortAndReload()
        }))
        sheet.addAction(UIAlertAction(title: "По количеству NFT", style: .default, handler: { [weak self] _ in
            self?.sort = .byNftCount
            self?.applySortAndReload()
        }))
        sheet.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        
        if let pop = sheet.popoverPresentationController { pop.barButtonItem = sender }
        present(sheet, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CatalogCell.defaultReuseIdentifier,
            for: indexPath
        ) as? CatalogCell else {
            return UITableViewCell()
        }
        cell.provide(category: categories[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = CollectionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
