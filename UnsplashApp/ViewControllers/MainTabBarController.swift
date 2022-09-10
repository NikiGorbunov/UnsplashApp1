//
//  MainTabBarController.swift
//  UnsplashApp
//
//  Created by Никита Горбунов on 05.09.2022.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        tabBar.isTranslucent = true
        let searchPhotoVC = SearchPhotoViewController()
        let favoritesVC = FavoriteViewController()
        let photosImage = UIImage(systemName: "photo.fill.on.rectangle.fill") ?? UIImage()
        let heartImage = UIImage(systemName: "heart.fill") ?? UIImage()
        
        viewControllers = [
            generateNavigationController(rootViewController: searchPhotoVC, title: "Photo", image: photosImage),
            generateNavigationController(rootViewController: favoritesVC, title: "Favorite", image: heartImage),
        ]
    }
    
    private func generateNavigationController(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        navigationVC.setNavigationBarHidden(true, animated: true)
        return navigationVC
    }
}
