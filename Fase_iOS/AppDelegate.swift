//
//  AppDelegate.swift
//  Fase_iOS
//
//  Created by Aleksey on 3/6/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var router: Router?
    
    let googleAPIKey = "AIzaSyDOvC4C4LK7BGDw90LVTzdN4Qc_t3N_TLY"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // setup google place picker
        GMSPlacesClient.provideAPIKey(googleAPIKey)
        
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
        
        if APIClientService.isSessionInfoExist == true {
            APIClientService.getScreen(for: device, completion: { [weak self] (response, error) in
                guard let strongSelf = self else {
                    return
                }
                
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let screen = response?.screen {
                        let viewModel = FaseViewModel(with: screen)
                        viewModel.router = strongSelf.router
                        strongSelf.router?.displayViewController(with: viewModel)
                    }
                    if let resources = response?.resources {
                        ResourcesService.saveResources(resources)
                    }
                }
            })
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
                        viewModel.router = strongSelf.router
                        strongSelf.router?.displayViewController(with: viewModel)
                    }
                    if let resources = response?.resources {
                        ResourcesService.saveResources(resources)
                    }
                }
            })
        }
        
    }
    
    //    public override preferredStatusBarStyle() {
    //        return UIStatusBarStyle.LightContent; //Or Default/Black/etc.
    //    }
    
    
}

