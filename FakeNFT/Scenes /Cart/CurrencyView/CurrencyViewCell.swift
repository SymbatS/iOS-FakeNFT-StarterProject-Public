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
        label.textColor = .green
        return label
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
        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.spacing = 1
        vstack.distribution = .fillEqually
        vstack.addArrangedSubview(titleLabel)
        vstack.addArrangedSubview(shortTitleLabel)
        contentView.addSubviews(currencyImageView,vstack)
        
        NSLayoutConstraint.activate([
            currencyImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            currencyImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            currencyImageView.widthAnchor.constraint(equalToConstant: 36),
            currencyImageView.heightAnchor.constraint(equalToConstant: 36),
            
            vstack.leadingAnchor.constraint(equalTo: currencyImageView.trailingAnchor, constant: 4),
            vstack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
