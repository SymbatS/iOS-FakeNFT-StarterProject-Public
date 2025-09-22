import UIKit

protocol ProfileInteractionDelegate: AnyObject {
    func didUpdateProfile(with updatedProfile: Profile)
    func didUpdateLikes(_ likes: [String], completion: ((Profile?) -> Void)?)
    func isNftLiked(_ nftID: String) -> Bool
}

final class ProfileViewController: UIViewController, LoadingView {
    //MARK: UI
    private lazy var profileCardView: ProfileCardView = {
        let view = ProfileCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.onLinkTapped = { [weak self] in
            guard let self = self, let websiteString = self.profile?.website, let url = URL(string: websiteString) else {
                return
            }
            let webVC = WebViewController(urlString: websiteString)
            self.navigationController?.pushViewController(webVC, animated: true)
        }
        
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorColor = .clear
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    internal lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    //MARK: Properties
    private let servicesAssembly: ServicesAssembly
    private let profileService: ProfileService
    private var profile: Profile?
    
    
    //MARK: Init
    init (servicesAssembly: ServicesAssembly, profileService: ProfileService){
        self.servicesAssembly = servicesAssembly
        self.profileService = profileService
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadProfile()
    }
    
    private func setupUI() {
        view.addSubviews(profileCardView, tableView, activityIndicator)
        
        NSLayoutConstraint.activate([
            profileCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.spacingXXL),
            profileCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: profileCardView.bottomAnchor, constant: LayoutConstants.spacingExtreme),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: LayoutConstants.rowHeight * 2 ),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)
        
        
        
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func loadProfile() {
        showLoading()
        
        profileCardView.isHidden = true
        tableView.isHidden = true
        
        profileService.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let profile):
                    self.hideLoading() 
                    self.profileCardView.isHidden = false
                    self.tableView.isHidden = false
                    
                    self.profile = profile
                    self.profileCardView.configure(with: profile)
                    self.tableView.reloadData()
                    print("success fetching profile")
                case .failure(let error):
                    //TODO: Show alert to user
                    print("Error fetching profile: \(error)")
                }
            }
        }
    }
    
    @objc
    private func editButtonTapped() {
        //todo
        guard let profile else { return }
        let editVC = EditProfileViewController(profile: profile, profileService: profileService)
        editVC.delegate = self
        editVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
}

//MARK: TableView methods
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ProfileAction.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LayoutConstants.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        let action = ProfileAction.allCases[indexPath.row]
        
        let title = action.localizedTitle
        var subtitle = ""
        
        if let profile = self.profile, let count = action.count(from: profile) {
            subtitle = " (\(count))"
        }
        
        cell.textLabel?.text = title + subtitle
        cell.textLabel?.textColor = .label
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .label
        cell.accessoryView = chevron
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let action = ProfileAction.allCases[indexPath.row]
        
        guard let profile = self.profile else { return }
        
        if let viewControllerToPresent = action.makeViewController(profile: profile, servicesAssembly: servicesAssembly) {
            if let favNftVC = viewControllerToPresent as? FavoritesNftViewController {
                favNftVC.delegate = self
            }
            if let myNftVC = viewControllerToPresent as? MyNftViewController {
                myNftVC.delegate = self
            }
            self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
        }
    }
    
}


extension ProfileViewController: ProfileInteractionDelegate {
    func didUpdateLikes(_ likes: [String], completion: ((Profile?) -> Void)?) {
            let previousLikes = profile?.likes ?? []
            profile?.likes = Array(Set(likes)) // optimistic update + dedupe
            
            // Update UI immediately
            profileCardView.configure(with: profile!)
            tableView.reloadData()
            
            profileService.updateProfile(
                name: nil,
                avatar: nil,
                description: nil,
                website: nil,
                likes: likes
            ) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let updatedProfile):
                        self.profile = updatedProfile
                        self.profileCardView.configure(with: updatedProfile)
                        self.tableView.reloadData()
                        completion?(updatedProfile)
                        
                    case .failure:
                        // Revert on failure
                        self.profile?.likes = previousLikes
                        self.profileCardView.configure(with: self.profile!)
                        self.tableView.reloadData()
                        completion?(nil)
                    }
                }
            }
        }
    
    func isNftLiked(_ nftID: String) -> Bool {
        profile?.likes.contains(nftID) ?? false
    }
    
    func didUpdateProfile(with updatedProfile: Profile) {
        self.profile = updatedProfile
        
        profileCardView.configure(with: updatedProfile)
        tableView.reloadData()
    }
}
