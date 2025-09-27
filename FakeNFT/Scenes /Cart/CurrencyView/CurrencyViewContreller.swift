import UIKit
import Kingfisher

class CurrencyViewContreller: UIViewController, LoadingView, ErrorView {
    let currencyService: CurrencyService
    var servicesAssembly: ServicesAssembly
    let paymentService: PaymentService
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 7
        layout.minimumInteritemSpacing = 7
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    let bottomView = CurrencyBottomView()
    
    static let reuseIdentifier = "Cell"
    
    var currency: [Currency] = []
    
    var checkedCellIndex = IndexPath(item: 0, section: 0)
    
    var checkedCurrencyId: String?
    
    var onPaymentSuccess: (() -> Void)?
    
    init(currencyService: CurrencyService,servicesAssembly: ServicesAssembly, paymentService: PaymentService) {
        self.currencyService = currencyService
        self.servicesAssembly = servicesAssembly
        self.paymentService = paymentService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupActivityIndicator()
        loadCurrency()
        setupUI()
    }
    
    private func loadCurrency(){
        showLoading()
        currencyService.fetchCurrency(){ [weak self] result in
            switch result{
            case .success(let currency):
                self?.currency = currency
                self?.checkedCurrencyId = currency[0].id
                self?.collectionView.reloadData()
                self?.hideLoading()
            case .failure(let error):
                print(error)
                self?.hideLoading()
                self?.repeatRequest(type:.currency)
            }
        }
    }
    
    private func repeatRequest(type:ErrorType){
        let message = NSLocalizedString("Error.title", comment: "")
        let actionText = NSLocalizedString("Error.repeat", comment: "")
        let action: (() -> Void) = { [weak self] in
            switch type{
            case .currency:
                self?.loadCurrency()
            case .payment:
                self?.didTapPayButton()
            }
        }
        
        let error = ErrorModel(message: message, actionText: actionText, action: action)
        showError(error)
    }
    
    private func setupActivityIndicator(){
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupUI(){
        setupNavBar()
        bottomView.agreementText.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        bottomView.delegate = self
        collectionView.register(CurrencyViewCell.self, forCellWithReuseIdentifier: CurrencyViewContreller.reuseIdentifier)
        view.addSubviews(collectionView,bottomView)
        let safeArea = view.safeAreaLayoutGuide
        view.bringSubviewToFront(activityIndicator)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyViewContreller.reuseIdentifier, for: indexPath) as? CurrencyViewCell else {
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
        checkedCurrencyId = currency[indexPath.row].id
        collectionView.reloadItems(at: [previousChecked])
        collectionView.reloadItems(at: [checkedCellIndex])
    }
}

extension CurrencyViewContreller: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let vc = WebViewController(urlString: URL.absoluteString)
        navigationController?.pushViewController(vc, animated: true)
        return false
    }
}

extension CurrencyViewContreller: CurrencyBottomViewDelegate {
    func didTapPayButton() {
        showLoading()
        guard let checkedId = checkedCurrencyId else { return }
        paymentService.tryPayment(currencyId: checkedId){ [weak self] result in
            switch result {
            case .success(let payment):
                print(payment)
                self?.hideLoading()
                payment.success ? self?.pushResultScreen() : self?.showPaymentError()
            case .failure(let error):
                print(error)
                self?.hideLoading()
                self?.repeatRequest(type: .payment)
            }
        }
    }
    
    func pushResultScreen(){
        let vc = PaymentViewController()
        vc.onPaymentSuccess = { [weak self] in
            self?.onPaymentSuccess?()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    func showPaymentError() {
        let alert = UIAlertController(title: "Не удалось произвести оплату", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        let repeatAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
            self?.didTapPayButton()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(repeatAction)
        alert.preferredAction = repeatAction
        present(alert, animated: true)
    }
}
