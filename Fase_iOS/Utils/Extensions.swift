//
//  Extensions.swift
//  TestJsonIOS
//
//  Created by Alexey Bidnyk on 3/8/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import Foundation
import ObjectMapper

extension Data {
    static func dataToJSON(data: Data) -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as JSON
        } catch let error {
            print("Data to json conversion error: \(error)")
        }
        return nil
    }
    
    static func jsonToData(json: JSON) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) as Data
        } catch let error {
            print("Json to data conversion error: \(error)")
        }
        return nil;
    }
    
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}


private var faseElementIdAssociationKey: UInt8 = 0

extension UIControl {
    // This var stores fase element id for convenience. Element id is in the same array that element
    var faseElementId: String! {
        get {
            return objc_getAssociatedObject(self, &faseElementIdAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &faseElementIdAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension Device {
    static func currentDevice() -> Device {
        var uuid = ""
        if let currentUUID = UIDevice.current.identifierForVendor?.uuidString {
            uuid = currentUUID
        }
        let type = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        
        return Device(type: type, token: uuid)
    }
}


