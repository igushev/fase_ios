//
//  NotificationService.swift
//  Fase_iOS
//
//  Created by Eduard Igushev on 7/5/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class NotificationService {
    static let instance = NotificationService()
    
    var deviceToken = ""
    
    func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted == true
            {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
    }
}
