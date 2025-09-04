import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // MARK: - Dependencies
    private lazy var servicesAssembly: ServicesAssembly = {
        let networkClient = DefaultNetworkClient()
        let nftStorage    = NftStorageImpl()
        return ServicesAssembly(networkClient: networkClient, nftStorage: nftStorage)
    }()

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        let tabBar = TabBarController(servicesAssembly: servicesAssembly)
        window.rootViewController = tabBar
        window.makeKeyAndVisible()
        self.window = window
    }
}
