import UIKit

final class TabBarController: UITabBarController {
    private enum TabBarItem: Int {
        case profile
        case catalog
        case basket
        case stats
        
        var title: String {
            switch self {
            case .profile:
                return "Профиль"
            case .catalog:
                return "Каталог"
            case .basket:
                return "Корзина"
            case .stats:
                return "Статистика"
            }
            
        }
        var iconName: String {
            switch self {
            case .profile:
                return "Profile"
            case .catalog:
                return "Catalog"
            case .basket:
                return "Basket"
            case .stats:
                return "Stats"
            }
        }
    }
    
    private let servicesAssembly: ServicesAssembly
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarItems()
    }
    
    private func setupTabBarItems() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .black
        let profileVC = ProfileViewController()
        let catalogVC = CatalogViewController(servicesAssembly: servicesAssembly)
        let basketVC = BasketViewController()
        let statsVC = StatsViewController()
        
        viewControllers = [
            wrappedInNavigationController(with: profileVC),
            wrappedInNavigationController(with: catalogVC),
            wrappedInNavigationController(with: basketVC),
            wrappedInNavigationController(with: statsVC)
        ]
        
        viewControllers?.enumerated().forEach {
            guard let item = TabBarItem(rawValue: $0) else { return }
            let controller = $1
            controller.tabBarItem.title = item.title
            controller.tabBarItem.image = UIImage(named: item.iconName)
        }
    }
    
    private func wrappedInNavigationController(with: UIViewController) -> UINavigationController {
        return UINavigationController(rootViewController: with)
    }
}
