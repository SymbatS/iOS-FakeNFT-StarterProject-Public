 import UIKit

class CurrencyBottomView: UIView { 
    let agreementText: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = []
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let text = "Совершая покупку, вы соглашаетесь с условиями Пользовательского соглашения"
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.caption2,
            .foregroundColor: UIColor.segmentActive
        ])

        if let range = text.range(of: "Пользовательского соглашения") {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.link, value: termsURL, range: nsRange)
        }
        textView.attributedText = attributedString
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    let payButton: UIButton = {
        let button = UIButton()
        button.setTitle("Оплатить", for: .normal)
        button.setTitleColor(.textOnPrimary, for: .normal)
        button.titleLabel?.font = .bodyBold
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.backgroundColor = .black
        return button
    }()
    static let termsURL = "https://yandex.ru/legal/practicum_termsofuse"
    weak var delegate: CurrencyBottomViewDelegate?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        backgroundColor = .segmentInactive
        layer.cornerRadius = 12
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        self.addSubviews(payButton,agreementText)
        NSLayoutConstraint.activate([
            agreementText.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            agreementText.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            agreementText.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 16),
            
            payButton.topAnchor.constraint(equalTo: agreementText.bottomAnchor, constant: 16),
            payButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            payButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    @objc private func payButtonTapped(){
        delegate?.didTapPayButton()
    }
}
