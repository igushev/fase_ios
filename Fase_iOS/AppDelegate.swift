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
        // setup push notifications
        // NotificationService.instance.registerForRemoteNotifications()
        
        // setup app
        if let window = self.window {
            self.router = Router(with: window)
        }
        
        self.setupStartScreen()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationService.instance.deviceToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
    }

    func setupStartScreen() {
        let device = Device.currentDevice()
        
//        self.router?.displayEmptyViewController()
        
        if APIClientService.isSessionInfoExist == true {
            APIClientService.getScreen(for: device, completion: { [weak self] (response, error) in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.router?.processResponse(response: response, error: error, for: nil, retryApiCall: APIClient.shared.lastCalledApiFunc)
            })
        } else {
            APIClientService.getServices(for: device, completion: { [weak self] (response, error) in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.router?.processResponse(response: response, error: error, for: nil, retryApiCall: APIClient.shared.lastCalledApiFunc)
            })
        }
    }
    
}

