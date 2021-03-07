import UIKit

extension UINavigationController: SetupRootProtocol {
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var router: RouterService?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        let router = RouterService(builder: ResultBuilder(root: navigationController), root: navigationController)
        router.execute()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        let storageService = StorageService()
        storageService.saveContext()
    }
}

