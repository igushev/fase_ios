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
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // setup app
        self.getService()
        
        return true
    }
    
    func getService() {
        var uuid = ""
        if let currentUUID = UIDevice.current.identifierForVendor?.uuidString {
            uuid = currentUUID
        }
        let type = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        let device = Device(type: type, token: uuid)
        
        APIClientService.getServices(for: device) { (response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                
            }
        }
    }
    
}
