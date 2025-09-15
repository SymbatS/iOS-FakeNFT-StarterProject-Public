import UIKit

final class EditProfileViewController: UIViewController {
    //MARK: Properites
    weak var delegate: ProfileInteractionDelegate?
    
    private var currentProfile: Profile?
    //MARK: UI
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private lazy var cameraIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "camera.fill"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .gray.withAlphaComponent(0.7)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Edit.name",comment: "")
        label.font = .headline3
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = TextFieldInsets(inset: LayoutConstants.textFieldInset)
        textField.font = .bodyRegular
        textField.layer.cornerRadius = LayoutConstants.cornerRadiusSmall
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .secondarySystemBackground
        textField.textColor = .textPrimary
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
        
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Edit.description",comment: "")
        label.font = .headline3
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .bodyRegular
        textView.layer.cornerRadius = LayoutConstants.cornerRadiusSmall
        textView.backgroundColor = .secondarySystemBackground
        textView.textColor = .textPrimary
        textView.textContainerInset = LayoutConstants.textFieldInset
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var websiteLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Edit.website",comment: "")
        label.font = .headline3
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var websiteTextField: UITextField = {
        let textField = TextFieldInsets(inset: LayoutConstants.textFieldInset)
        textField.font = .bodyRegular
        textField.layer.cornerRadius = LayoutConstants.cornerRadiusSmall
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .secondarySystemBackground
        textField.textColor = .textPrimary
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    //MARK: init
    init(profile: Profile) {
        super.init(nibName: nil, bundle: nil)
        self.currentProfile = profile
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fillData()
        view.backgroundColor = .systemBackground
    }
    
    private func setupUI() {
        
        let nameStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [nameLabel, nameTextField])
            stackView.axis = .vertical
            stackView.spacing = LayoutConstants.spacingM
            return stackView
        }()
        
        let descriptionStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [descriptionLabel, descriptionTextView])
            stackView.axis = .vertical
            stackView.spacing = LayoutConstants.spacingM
            return stackView
        }()
        
        let websiteStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [websiteLabel, websiteTextField])
            stackView.axis = .vertical
            stackView.spacing = LayoutConstants.spacingM
            return stackView
        }()
        
        let mainStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [nameStackView, descriptionStackView, websiteStackView])
            stackView.axis = .vertical
            stackView.spacing = LayoutConstants.spacingHuge
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        view.addSubview(avatarImageView)
        view.addSubview(cameraIconImageView)
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70), // Примерный размер
            avatarImageView.heightAnchor.constraint(equalToConstant: 70), // Примерный размер
            
            cameraIconImageView.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            cameraIconImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            cameraIconImageView.widthAnchor.constraint(equalToConstant: 20),
            cameraIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            mainStackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 24),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nameTextField.heightAnchor.constraint(equalToConstant: LayoutConstants.rowHeight),
            descriptionTextView.heightAnchor.constraint(equalToConstant: LayoutConstants.descriptionHeight),
            websiteTextField.heightAnchor.constraint(equalToConstant: LayoutConstants.rowHeight),
        ])
        
    }
    
    private func fillData() {
        guard let currentProfile else { return }

        nameTextField.text = currentProfile.name
        descriptionTextView.text = currentProfile.description ?? ""
        websiteTextField.text = currentProfile.website ?? ""

        if let url = URL(string: currentProfile.avatar) {
            avatarImageView.kf.setImage(with: url)
        }
    }
    
    @objc
    private func didTapAvatar() {
        
    }
}
