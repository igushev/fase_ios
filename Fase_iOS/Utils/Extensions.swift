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

extension Screen {
    func hasNavigationElement() -> Bool {
        var hasNavigation = false
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let element = tuple[1] as! Element
            
            if element is ElementContainer {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.navigation {
                    hasNavigation = true
                }
            }
        }
        return hasNavigation
    }
    
    func mainButton() -> Button? {
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let element = tuple[1] as! Element
            
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.button {
                return element as? Button
            }
        }
        return nil
    }
    
    func navigationElement() -> ElementContainer? {
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let element = tuple[1] as! Element
            
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.navigation {
                return element as? ElementContainer
            }
        }
        return nil
    }
    
    func navigationElementButtonsCount() -> Int {
        for tuple in self.idElementList {
            if tuple.count == 1{
                break
            }
            let element = tuple[1] as! Element
            
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.navigation {
                return (element as! ElementContainer).idElementList.count
            }
        }
        return 0
    }
    
    func navigationElementButtons() -> Array<Button>? {
        var navButtons: Array<Button> = []
        
        for tuple in self.idElementList {
            if tuple.count == 1{
                break
            }
            let element = tuple[1] as! Element
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.navigation {
                for buttonElement in (element as! ElementContainer).idElementList {
                    let button = buttonElement[1] as! Element
                    let elementTypeString = button.`class`
                    let elementType = ElementType(with: elementTypeString)
                    
                    if elementType == ElementType.button {
                        navButtons.append(button as! Button)
                    }
                }
            }
        }
        return navButtons
    }
    
}

extension UIButton {
    func alignVertical(spacing: CGFloat = 6.0) {
        guard let imageSize = self.imageView?.image?.size,
            let text = self.titleLabel?.text,
            let font = self.titleLabel?.font
            else { return }
        self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0.0)
        let labelString = NSString(string: text)
        let titleSize = labelString.size(withAttributes: [NSAttributedStringKey.font: font])
        self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
        self.contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
    }
}


