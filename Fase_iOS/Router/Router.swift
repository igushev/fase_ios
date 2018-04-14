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
        let viewController = FaseViewController(with: viewModel)
        
        DispatchQueue.main.async {
            self.show(viewController: viewController)
        }
    }
    
    func presentViewController(viewController: UIViewController) {
        self.rootViewController()?.present(viewController, animated: true, completion: nil)
    }
    
    func showServerErrorAlert() {
        let alertController = UIAlertController(title: "Server error", message: "Sorry, server error occured", preferredStyle: .alert)
        let skipAction = UIAlertAction(title: "Skip", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        let restartAction = UIAlertAction(title: "Restart", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
            
            var uuid = ""
            if let currentUUID = UIDevice.current.identifierForVendor?.uuidString {
                uuid = currentUUID
            }
            let type = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
            let device = Device(type: type, token: uuid)
            
            APIClientService.getServices(for: device, completion: { [weak self] (response, error) in
                guard let strongSelf = self else {
                    return
                }
                
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let screen = response?.screen {
                        let viewModel = FaseViewModel(with: screen)
                        viewModel.router = strongSelf
                        strongSelf.displayViewController(with: viewModel)
                    }
                    if let resources = response?.resources {
                        ResourcesService.saveResources(resources)
                    }
                }
            })
            
        }
        alertController.addAction(skipAction)
        alertController.addAction(restartAction)
        
        self.presentViewController(viewController: alertController)
        
        //
    }
    
    func processResponse(response: Response?, error: Error?,for viewModel: FaseViewModel?) {
        if let error = error {
            print(error.localizedDescription)
            if error.code == 500 {
                self.showServerErrorAlert()
            }
        } else if let response = response {
            if let elementsUpdate = response.elementsUpdate, let viewModel = viewModel {
                viewModel.updateScreen(with: elementsUpdate)
            }
            if let screen = response.screen, let sessionInfo = response.sessionInfo {
                APIClientService.saveNewSessionInfo(sessionInfo: sessionInfo)
                
                let viewModel = FaseViewModel(with: screen)
                viewModel.router = self
                self.displayViewController(with: viewModel)
            }
            if let resources = response.resources {
                ResourcesService.saveResources(resources)
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

