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
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // MARK: - Private Methods
    
    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        // Trending Tab
        let trendingVC = TrendingViewController()
        let trendingNav = UINavigationController(rootViewController: trendingVC)
        trendingNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("В тренде", comment: ""),
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis.fill")
        )
        
        // Now Playing Tab
        let nowPlayingVC = NowPlayingViewController()
        let nowPlayingNav = UINavigationController(rootViewController: nowPlayingVC)
        nowPlayingNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("В кино", comment: ""),
            image: UIImage(systemName: "play.circle"),
            selectedImage: UIImage(systemName: "play.circle.fill")
        )
        
        // Upcoming Tab
        let upcomingVC = UpcomingViewController()
        let upcomingNav = UINavigationController(rootViewController: upcomingVC)
        upcomingNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Скоро", comment: ""),
            image: UIImage(systemName: "calendar.badge.clock"),
            selectedImage: UIImage(systemName: "calendar.badge.clock")
        )
        
        tabBarController.viewControllers = [trendingNav, nowPlayingNav, upcomingNav]
        
        // Appearance customization
        setupTabBarAppearance(tabBarController)
        setupNavigationBarAppearance()
        
        return tabBarController
    }
    
    private func setupTabBarAppearance(_ tabBarController: UITabBarController) {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.darkBlue.withAlphaComponent(0.95)
        
        // Selected item appearance
        appearance.stackedLayoutAppearance.selected.iconColor = .primaryPurple
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.primaryPurple,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        
        // Normal item appearance  
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
