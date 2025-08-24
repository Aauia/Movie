import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = createTabBarController()
        window?.makeKeyAndVisible()
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
    }
    
    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let trendingVC = TrendingViewController()
        let trendingNav = UINavigationController(rootViewController: trendingVC)
        trendingNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("В тренде", comment: ""),
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis.fill")
        )
        
        let nowPlayingVC = NowPlayingViewController()
        let nowPlayingNav = UINavigationController(rootViewController: nowPlayingVC)
        nowPlayingNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("В кино", comment: ""),
            image: UIImage(systemName: "play.circle"),
            selectedImage: UIImage(systemName: "play.circle.fill")
        )
        
        let upcomingVC = UpcomingViewController()
        let upcomingNav = UINavigationController(rootViewController: upcomingVC)
        upcomingNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Скоро", comment: ""),
            image: UIImage(systemName: "calendar.badge.clock"),
            selectedImage: UIImage(systemName: "calendar.badge.clock")
        )
        
        tabBarController.viewControllers = [trendingNav, nowPlayingNav, upcomingNav]
        
        setupTabBarAppearance(tabBarController)
        setupNavigationBarAppearance()
        
        return tabBarController
    }
    
    private func setupTabBarAppearance(_ tabBarController: UITabBarController) {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.darkBlue.withAlphaComponent(0.95)
        
        appearance.stackedLayoutAppearance.selected.iconColor = .primaryPurple
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.primaryPurple,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = .secondaryText
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryText,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.tintColor = .primaryPurple
        tabBarController.tabBar.unselectedItemTintColor = .secondaryText
        tabBarController.tabBar.barTintColor = .darkBlue
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.primaryText,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.primaryText,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .primaryPurple
        UINavigationBar.appearance().prefersLargeTitles = false
    }
}
