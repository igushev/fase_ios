//
//  Router.swift
//  TestJsonIOS
//
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit

class Router {
    
    var window: UIWindow
    
    init(with window: UIWindow) {
        self.window = window
    }
    
    func displayEmptyViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()
        
        DispatchQueue.main.async {
            self.window.rootViewController = viewController
        }
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
    
    func showErrorAlert(title: String, message: String, retryApiCall: ApiCall?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let skipAction = UIAlertAction(title: "Skip", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let restartButtonTitle = (retryApiCall == nil) ? "Restart" : "Retry"
        
        let restartAction = UIAlertAction(title: restartButtonTitle, style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
            
            var uuid = ""
            if let currentUUID = UIDevice.current.identifierForVendor?.uuidString {
                uuid = currentUUID
            }
            let type = UIDevice.current.systemName
            let device = Device(type: type, token: uuid)
            
            if let retryApiCall = retryApiCall {
                APIClientService.performRetryApiCall(apiCall: retryApiCall)
            } else {
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
            
        }
        alertController.addAction(skipAction)
        alertController.addAction(restartAction)
        
        self.presentViewController(viewController: alertController)
    }
    
    func processResponse(response: Response?, error: Error?, for viewModel: FaseViewModel?, retryApiCall: ApiCall?) {
        if let error = error {
            print(error.localizedDescription)
            if error.code == 500 {
                self.showErrorAlert(title: "Server error", message: "Internal server error", retryApiCall: nil)
            } else if error.code == -1009 {
                self.showErrorAlert(title: "Error", message: "No internet connection", retryApiCall: retryApiCall)
            }
        } else if let response = response {
            if let resources = response.resources {
                if resources.resetResources == true {
                    ResourcesService.resetResources()
                }
                ResourcesService.saveResources(resources)
            }
            if let screen = response.screen, let sessionInfo = response.sessionInfo {
                APIClientService.saveNewSessionInfo(sessionInfo: sessionInfo)
                if let vM = viewModel {
                    vM.screenUpdateTimer.invalidate()
                }
                
                let viewModel = FaseViewModel(with: screen)
                viewModel.router = self
                self.displayViewController(with: viewModel)
            } else if let elementsUpdate = response.elementsUpdate, let viewModel = viewModel {
                viewModel.updateScreen(with: elementsUpdate)
            }
            if let versionInfo = response.versionInfo {
                APIClientService.saveNewVersionInfo(versionInfo: versionInfo)
            }
        }
    }
    
    // MARK: - Private
    
    func rootViewController() -> UIViewController? {
        let rootViewController = self.window.rootViewController
        
        if let navController = rootViewController as? UINavigationController {
            return navController.topViewController as? FaseViewController
        } else {
            return rootViewController
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

