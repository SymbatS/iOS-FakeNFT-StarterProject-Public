import UIKit

final class PaymentViewController: UIViewController {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .success)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let completionLabel: UILabel = {
        let label = UILabel()
        label.text = "Успех! Оплата прошла, поздравляем с покупкой!"
        label.numberOfLines = 2
        label.font = .headline3
        label.textColor = .segmentActive
        label.textAlignment = .center
        return label
    }()
    
    let backToCartButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вернуться в корзину", for: .normal)
        button.setTitleColor(.textOnPrimary, for: .normal)
        button.titleLabel?.font = .bodyBold
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.backgroundColor = .black
        return button
    }()
    let vstack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    var onPaymentSuccess: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        backToCartButton.addTarget(self, action: #selector(backToCart), for: .touchUpInside)
        view.addSubviews(vstack,backToCartButton)
        vstack.addArrangedSubview(imageView)
        vstack.addArrangedSubview(completionLabel)
        NSLayoutConstraint.activate([
            vstack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vstack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            imageView.heightAnchor.constraint(equalToConstant: 278),
            imageView.widthAnchor.constraint(equalToConstant: 278),
            
            backToCartButton.heightAnchor.constraint(equalToConstant: 60),
            backToCartButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16),
            backToCartButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -16),
            backToCartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    @objc private func backToCart() {
        onPaymentSuccess?()
        navigationController?.popToRootViewController(animated: true)
    }
}
