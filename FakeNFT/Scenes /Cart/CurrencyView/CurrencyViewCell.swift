import UIKit

class CurrencyViewCell: UICollectionViewCell {
    
    let currencyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyRegular
        label.textColor = .segmentActive
        return label
    }()
    
    let shortTitleLabel: UILabel = {
       let label = UILabel()
        label.font = .bodyRegular
        label.textColor = .greenUniversal
        return label
    }()
    
    let vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fillEqually
        return stack
    }()

    var isChecked: Bool = false {
        didSet {
            layer.borderWidth = isChecked ? 1 : 0
            layer.borderColor = isChecked ? UIColor.black.cgColor : UIColor.clear.cgColor
            layer.cornerRadius = 12
            clipsToBounds = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        contentView.backgroundColor = .segmentInactive
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(shortTitleLabel)
        contentView.addSubviews(currencyImageView,vStack)
        
        NSLayoutConstraint.activate([
            currencyImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            currencyImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            currencyImageView.widthAnchor.constraint(equalToConstant: 36),
            currencyImageView.heightAnchor.constraint(equalToConstant: 36),
            
            vStack.leadingAnchor.constraint(equalTo: currencyImageView.trailingAnchor, constant: 4),
            vStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
}
