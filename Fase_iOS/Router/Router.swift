//
//  Router.swift
//  TestJsonIOS
//
//  Created by Alexey Bidnyk on 3/2/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import UIKit

class Router {
    
    var window: UIWindow
    
    init(with window: UIWindow) {
        self.window = window
    }
    
    func displayViewController(with viewModel: FaseViewModel) {
        if viewModel.isNeedTabBar == true {
            let tabBarController = FaseTabBarController(with: viewModel)
            
            
            DispatchQueue.main.async {
                self.show(tabBarController: tabBarController)
            }
        } else {
            let viewController = FaseViewController(with: viewModel)
            
            DispatchQueue.main.async {
                self.show(viewController: viewController)
            }
        }
    }
    
    // MARK: - Private
    
    func rootViewController() -> FaseViewController? {
        let rootViewController = self.window.rootViewController
        
        if let navController = rootViewController as? UINavigationController {
            return navController.topViewController as? FaseViewController
        } else {
            return rootViewController as? FaseViewController
        }
    }
    
    func show(viewController: UIViewController) {
        //        if let topVC = self.rootViewController() {
        //            topVC.show(viewController, sender: topVC)
        //        } else {
        let navigationController = UINavigationController(rootViewController: viewController)
        self.window.rootViewController = navigationController
        //        }
    }
    
    func show(tabBarController: UITabBarController) {
        self.window.rootViewController = tabBarController
    }
    
}

