import UIKit
import Kingfisher

final class EditProfileViewController: UIViewController, LoadingView {
    //MARK: Properites
    weak var delegate: ProfileInteractionDelegate?
    
    private let profileService: ProfileServiceProtocol
    
    private let currentProfile: Profile
    private var initialAvatarURL: String
    private var currentAvatarURL: String
    private var initialName: String
    private var initialDescription: String
    private var initialWebsite: String
    
    private var isDataChanged: Bool {
        let nameChanged = nameTextField.text != initialName
        let descriptionChanged = descriptionTextView.text != initialDescription
        let websiteChanged = websiteTextField.text != initialWebsite
        let avatarChanged = currentAvatarURL != initialAvatarURL
        return nameChanged || descriptionChanged || websiteChanged || avatarChanged
    }
    
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
        imageView.tintColor = .black
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.0)
        imageView.layer.cornerRadius = 25 / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Edit.name", comment: "")
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
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Edit.description", comment: "")
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
        textView.delegate = self
        return textView
    }()
    
    private lazy var websiteLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Edit.website", comment: "")
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
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Edit.save", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .label
        button.titleLabel?.font = .bodyBold
        button.layer.cornerRadius = LayoutConstants.cornerRadiusSmall
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    internal lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    //MARK: init
    init(profile: Profile, profileService: ProfileServiceProtocol) {
        self.profileService = profileService
        
        self.currentProfile = profile
        self.initialAvatarURL = profile.avatar
        self.currentAvatarURL = profile.avatar
        self.initialName = profile.name
        self.initialDescription = profile.description ?? ""
        self.initialWebsite = profile.website ?? ""
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationController()
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
        view.addSubview(saveButton)
        view.bringSubviewToFront(cameraIconImageView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            cameraIconImageView.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            cameraIconImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            cameraIconImageView.widthAnchor.constraint(equalToConstant: 25),
            cameraIconImageView.heightAnchor.constraint(equalToConstant: 25),
            
            mainStackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 24),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nameTextField.heightAnchor.constraint(equalToConstant: LayoutConstants.rowHeight),
            descriptionTextView.heightAnchor.constraint(equalToConstant: LayoutConstants.descriptionHeight),
            websiteTextField.heightAnchor.constraint(equalToConstant: LayoutConstants.rowHeight),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: LayoutConstants.rowHeight),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ])
    }
    
    private func setupNavigationController() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func fillData() {
        nameTextField.text = initialName
        descriptionTextView.text = initialDescription
        websiteTextField.text = initialWebsite
        
        if let url = URL(string: initialAvatarURL) {
            avatarImageView.kf.setImage(with: url)
        }
    }
    
    private func showChangePhotoAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Edit.changePhotoTitle", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        let changePhotoAction = UIAlertAction(title: NSLocalizedString("Edit.changePhotoAction", comment: ""), style: .default) { [weak self] _ in
            self?.showURLInputDialog()
        }
        let deletePhotoAction = UIAlertAction(title: NSLocalizedString("Edit.deletePhotoAction", comment: ""), style: .destructive) { [weak self] _ in
            self?.currentAvatarURL = ""
            self?.avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
            self?.avatarImageView.tintColor = .systemGray
        }
        
        
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Common.cancel", comment: ""), style: .cancel)
        
        alert.addAction(changePhotoAction)
        alert.addAction(deletePhotoAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showURLInputDialog() {
        let alert = UIAlertController(title: NSLocalizedString("Edit.photoLink", comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField { [weak self] textField in
            textField.placeholder = "http://www.example.com"
            textField.text = self?.currentAvatarURL
        }
        
        let saveAction = UIAlertAction(title: NSLocalizedString("Common.save", comment: ""), style: .default) { [weak self] _ in
            guard let urlString = alert.textFields?.first?.text,
                  let url = URL(string: urlString) else { return }
            
            self?.avatarImageView.kf.setImage(with: url)
            self?.currentAvatarURL = urlString
            self?.updateSaveButtonState()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Common.cancel", comment: ""), style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func saveChanges() {
        showLoading()
        let updatedProfile = Profile(
            id: currentProfile.id,
            name: nameTextField.text ?? "",
            avatar: currentAvatarURL,
            description: descriptionTextView.text,
            website: websiteTextField.text,
            nfts: currentProfile.nfts,
            likes: currentProfile.likes
        )
        
        profileService.updateProfile(with: updatedProfile) { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.didUpdateProfile(with: updatedProfile)
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                // Обработка ошибки, например, показать алерт
                print("Ошибка обновления: \(error)")
            }
        }
        
    }
    
    private func updateSaveButtonState() {
        saveButton.isEnabled = isDataChanged
        saveButton.backgroundColor = isDataChanged ? .black : .gray
    }
    
    //MARK: - Actions
    @objc
    private func didTapAvatar() {
        showChangePhotoAlert()
    }
    
    @objc
    private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func didTapSaveButton() {
        saveChanges()
    }
    
    @objc
    private func textFieldDidChange() {
        updateSaveButtonState()
    }
}

//MARK: - UITextViewDelegate
extension EditProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
    }
}
