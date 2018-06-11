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
    
    let googleAPIKey = "AIzaSyCu1UzB1uv73-108iQMJgUFHmYedscHnT4"
    
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
        let type = UIDevice.current.systemName
        let device = Device(type: type, token: uuid)
        
        if APIClientService.isSessionInfoExist == true {
            APIClientService.getScreen(for: device, completion: { [weak self] (response, error) in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.router?.processResponse(response: response, error: error, for: nil)
            })
        } else {
            APIClientService.getServices(for: device, completion: { [weak self] (response, error) in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.router?.processResponse(response: response, error: error, for: nil)
            })
        }
    }
    
}

