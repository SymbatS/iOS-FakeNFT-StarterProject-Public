import UIKit
import Kingfisher

class CurrencyViewContreller: UIViewController {
    let currencyService: CurrencyService
    var servicesAssembly: ServicesAssembly
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 7
        layout.minimumInteritemSpacing = 7
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    let bottomView = CurrencyBottomView()
    
    var currency: [Currency] = []
    
    let reuseIdentifier = "Cell"
    
    var checkedCellIndex = IndexPath(item: 0, section: 0)
    
    init(currencyService: CurrencyService,servicesAssembly: ServicesAssembly) {
        self.currencyService = currencyService
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCurrency()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func loadCurrency(){
        currencyService.fetchCurrency(){ [weak self] result in
            switch result{
            case .success(let currency):
                self?.currency = currency
                self?.collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setupUI(){
        setupNavBar()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CurrencyViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        view.addSubviews(collectionView,bottomView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            
            bottomView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 186)
        ])
    }
    
    private func setupNavBar(){
        title = "Выберите способ оплаты"
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.bodyBold
        ]
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .black
    }
}

extension CurrencyViewContreller: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currency.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CurrencyViewCell else {
            assertionFailure("no cell for CurrencyViewCell")
            return UICollectionViewCell()
        }
        configCell(for: cell, with: indexPath)
        return cell
    }
}
extension CurrencyViewContreller {
    func configCell(for cell: CurrencyViewCell, with indexPath: IndexPath) {
        if currency.isEmpty { return }
        let currency = currency[indexPath.row]
        cell.currencyImageView.kf.setImage(with: URL(string: currency.image))
        cell.shortTitleLabel.text = currency.name
        cell.titleLabel.text = currency.title
        cell.isChecked = indexPath == checkedCellIndex
    }
}

extension CurrencyViewContreller: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 7
        let availableWidth = collectionView.bounds.width - padding
        let itemWidth = availableWidth / 2
        return CGSize(width: itemWidth, height: 46)
    }
}

extension CurrencyViewContreller: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousChecked = checkedCellIndex
        checkedCellIndex = indexPath
        collectionView.reloadItems(at: [previousChecked])
        collectionView.reloadItems(at: [checkedCellIndex])
    }
}
