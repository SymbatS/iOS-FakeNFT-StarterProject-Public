import UIKit

final class CatalogCell: UITableViewCell, ReuseIdentifying {
    
    static var defaultReuseIdentifier: String { "CatalogCell" }
    
    // MARK: - UI
    private let iconImageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 12
        v.isAccessibilityElement = true
        return v
    }()
    
    private let categoryNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .headline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .label
        return l
    }()
    
    private let placeholderImage = UIImage(systemName: "photo")
    
    // MARK: - State
    private var task: URLSessionDataTask?
    private var currentImageURL: URL?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        currentImageURL = nil
        iconImageView.image = placeholderImage
        categoryNameLabel.text = nil
    }
    
    // MARK: - Public
    func provide(category: Category) {
        categoryNameLabel.text = "\(category.title) (\(category.count))"
        iconImageView.image = placeholderImage
        
        currentImageURL = category.image
        guard let url = currentImageURL else { return }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let self = self else { return }
            guard self.currentImageURL == url, let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                if self.currentImageURL == url {
                    self.iconImageView.image = img
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(categoryNameLabel)
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 140),
            
            categoryNameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            categoryNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            categoryNameLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}
