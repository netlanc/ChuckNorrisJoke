//
//  TabBarController.swift
//  ChuckNorrisJoke
//
//  Created by netlanc on 17.02.2024.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создаем словарь с информацией о контроллерах
        let controllersInfo: [[String: Any]] = [
            ["controller": JokeViewController(), "title": "Новая шутка", "imageName": "smiley"],
            ["controller": JokeListViewController(category: nil), "title": "Шутки юмора :)", "imageName": "list.bullet.rectangle"],
            ["controller": CategoriesViewController(), "title": "Категории", "imageName": "folder"]
        ]
        
        // Создаем и настраиваем каждый UINavigationController
        var navigationControllers = [UINavigationController]()
        for info in controllersInfo {
            guard let controller = info["controller"] as? UIViewController,
                  let title = info["title"] as? String,
                  let imageName = info["imageName"] as? String else {
                continue
            }
            
            let navController = UINavigationController(rootViewController: controller)
            navController.navigationBar.prefersLargeTitles = true
            navController.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: imageName), tag: navigationControllers.count)
            //navController.navigationBar.layer.cornerRadius = 15
            navigationControllers.append(navController)
        }
        
        // Устанавливаем контроллеры в TabBarController
        viewControllers = navigationControllers
    }
}
