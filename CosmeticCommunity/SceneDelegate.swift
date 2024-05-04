//
//  SceneDelegate.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/12.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        let tabBarvc = CustomTabBarViewController()
        var tabBarItems = tabBarvc.tabBar.items ?? []
        
        let firstNav = UINavigationController(rootViewController: RegisterViewController())
        let secondNav = UINavigationController(rootViewController: ViewController())
        let thirdNav = UINavigationController(rootViewController: SaveViewController())
        
        firstNav.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
        // 두 번째 버튼 숨기기
        let uploadTabBarItem = UITabBarItem(title: nil, image: nil, tag: 1)
        uploadTabBarItem.isEnabled = false
        secondNav.tabBarItem = uploadTabBarItem
        
        thirdNav.tabBarItem = UITabBarItem(title: "보관함", image: UIImage(systemName: "folder"), tag: 2)
        tabBarvc.tabBar.tintColor = Constants.Color.point
        tabBarvc.tabBar.barTintColor = .white
        tabBarvc.viewControllers = [firstNav, secondNav, thirdNav]
        
        window?.rootViewController = tabBarvc
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


}

