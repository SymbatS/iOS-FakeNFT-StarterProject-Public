import UIKit
import Kingfisher

final class CartViewController: UIViewController, LoadingView, ErrorView{
    
    var servicesAssembly: ServicesAssembly
    let cartService: CartService
    
    let tableview: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let bottomView = BottomCartView()
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.text = "Корзина пуста"
        label.textColor = .segmentActive
        return label
    }()
    
    var nfts: [CartNfts] = []
    
    var totalSum: Float = 0
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(servicesAssembly: ServicesAssembly, cartService: CartService) {
        self.servicesAssembly = servicesAssembly
        self.cartService = cartService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        loadCart()
        setupUI()
        
    }
    
    private func loadCart(){
        showLoading()
        cartService.fetchCart(orderId: "1") { [weak self] result in
            switch result {
            case .success(let nfts):
                self?.hideLoading()
                let mapped: [CartNfts] = nfts.map {
                    CartNfts(
                        id: $0.id,
                        name: $0.name,
                        image: $0.images.first ?? "",
                        price: $0.price,
                        rating: Int($0.rating)
                    )
                }
                self?.totalSum = 0
                nfts.forEach { self?.totalSum += $0.price }
                
                DispatchQueue.main.async {
                    self?.nfts = mapped
                    let isNftsEmpty = nfts.isEmpty
                    self?.isCartEmpty(isNftsEmpty)
                    self?.tableview.reloadData()
                    self?.bottomViewUpadte()
                    self?.view.layoutIfNeeded()
                }
            case .failure(let error):
                print(error)
                self?.hideLoading()
                self?.repeatCartRequest(error)
            }
        }
    }
    func repeatCartRequest(_ error: Error){
        let error = ErrorModel(message: NSLocalizedString("Error.title", comment: ""),
                               actionText: error.localizedDescription,
                               action: { [weak self] in
            self?.loadCart()
        })
        showError(error)
    }
    private func setupActivityIndicator(){
        view.addSubviews(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        navigationItem.backButtonTitle = ""
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(CartCell.self, forCellReuseIdentifier: "cell")
        bottomView.delegate = self
        bottomViewUpadte()
        view.addSubviews(tableview,bottomView,emptyLabel)
        [tableview, bottomView, emptyLabel].forEach { $0.isHidden = true }
        view.bringSubviewToFront(activityIndicator)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 76),
            bottomView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            tableview.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            tableview.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
    
    private func isCartEmpty(_ isEmpty: Bool){
        tableview.isHidden = isEmpty
        bottomView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
        setupNavBar(isEmpty)
    }
    
    private func setupNavBar(_ isEmpty: Bool){
        let sortButton = UIBarButtonItem(
            image: UIImage(resource: .sort),
            style: .plain,
            target: self,
            action: #selector(didTapSortButton))
        sortButton.tintColor = .black
        let emptyButton = UIBarButtonItem(image: nil, style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = isEmpty ? emptyButton : sortButton
    }
    
    @objc private func didTapSortButton(){
        let alert = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        let sortByPrice = UIAlertAction(title: "По цене", style: .default) { [weak self] _ in
            self?.sort(by: .price)
        }
        let sortByRating = UIAlertAction(title: "По рейтингу", style: .default){ [weak self] _ in
            self?.sort(by: .rating)
        }
        let sortByName = UIAlertAction(title: "По названию", style: .default){ [weak self] _ in
            self?.sort(by: .name)
        }
        let abortAction = UIAlertAction(title: "Закрыть", style: .cancel){ [weak self] _ in
            self?.dismiss(animated: true)
        }
        [sortByPrice,sortByRating,sortByName,abortAction].forEach({
            alert.addAction($0)
        })
        present(alert, animated: true)
    }
    
    private func sort(by: Sort){
        
        switch by {
        case .name:
            nfts.sort { $0.name < $1.name }
        case .price:
            nfts.sort { $0.price < $1.price }
        case .rating:
            nfts.sort { $0.rating > $1.rating }
        }
        tableview.reloadData()
    }
    
    private func bottomViewUpadte(){
        bottomView.nftCount = nfts.count
        bottomView.totalSum = totalSum
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
}
extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nfts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as? CartCell else { assertionFailure("no cell at CartCel")
            return UITableViewCell()
        }
        configCell(for: cell, with: indexPath)
        return cell
    }
}
extension CartViewController {
    func configCell(for cell: CartCell, with indexPath: IndexPath) {
        if nfts.isEmpty { return }
        let nft = nfts[indexPath.row]
        cell.nftImageView.kf.setImage(with: URL(string: nft.image))
        cell.nftPriceLabel.text = "\(nft.price) ETH"
        cell.nftNameLabel.text = nft.name
        cell.starRating.rating = Double(nft.rating)
        cell.delegate = self
        bottomViewUpadte()
    }
}
extension CartViewController: CartCellDelegate {
    func cellDidTapDelete(cell: CartCell) {
        guard let indexPath = tableview.indexPath(for: cell) else { return }
        let nftToDelete = nfts[indexPath.row]
        let deleteAlert = DeleteAlertView()
        guard let url = URL(string: nftToDelete.image) else { return }
        
        deleteAlert.show(on: self, with: view.frame.height, image: url) { [weak self] in
            guard let self else { return }
            totalSum -= nftToDelete.price
            self.nfts.remove(at: indexPath.row)
            self.tableview.deleteRows(at: [indexPath], with: .automatic)
            let isNftsEmpty = nfts.isEmpty
            self.isCartEmpty(isNftsEmpty)
            view.layoutIfNeeded()
            self.bottomViewUpadte()
            
            let remainingIds = self.nfts.map { $0.id }
            self.cartService.updateNfts(orderId: "1", nfts: remainingIds) { result in
                switch result {
                case .success(let response):
                    print("Cart updated: \(response)")
                case .failure(let error):
                    print("Error updating cart: \(error)")
                }
            }
        }
    }
}
extension CartViewController: BottomCartViewDelegate{
    
    func didTapCartButton() {
        let vc = CurrencyViewContreller(currencyService: servicesAssembly.currencyService, servicesAssembly: servicesAssembly, paymentService: servicesAssembly.paymentService)
        vc.hidesBottomBarWhenPushed = true
        vc.onPaymentSuccess = { [weak self] in
            self?.loadCart()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
