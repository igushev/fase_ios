//
//  AppDelegate.swift
//  Fase_iOS
//
//  Created by Aleksey on 3/6/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var router: Router?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // setup app
        if let window = self.window {
            self.router = Router(with: window)
        }
        
        self.setupStartScreen()
        
        return true
    }
    
    func setupStartScreen() {
        var uuid = ""
        if let currentUUID = UIDevice.current.identifierForVendor?.uuidString {
            uuid = currentUUID
        }
        let type = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        let device = Device(type: type, token: uuid)
        
        APIClientService.getServices(for: device) { [weak self] (response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let screen = response?.screen {
                    let viewModel = FaseViewModel(with: screen)
                    viewModel.router = self?.router
                    self?.router?.displayViewController(with: viewModel)
                }
                if let resources = response?.resources {
                    ResourcesService.saveResources(resources)
                }
            }
        }
    }
    
}

