//
//  Extensions.swift
//  TestJsonIOS
//
//  Created by Alexey Bidnyk on 3/8/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import Foundation
import ObjectMapper

// MARK: - Foundation extensions

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

// MARK: - UIKit extensions

private var faseElementIdAssociationKey: UInt8 = 0
private var faseNavigationElementIdAssociationKey: UInt8 = 0
private var scrollViewAssociationKey: UInt8 = 0

extension UIView {
    // This var stores fase element id for convenience. Element id is in the same array that element
    var faseElementId: String! {
        get {
            return objc_getAssociatedObject(self, &faseElementIdAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &faseElementIdAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    // This var stores navigation element id for convenience.
    var navigationElementId: String? {
        get {
            return objc_getAssociatedObject(self, &faseNavigationElementIdAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &faseNavigationElementIdAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var scrollView: UIScrollView? {
        get {
            return objc_getAssociatedObject(self, &scrollViewAssociationKey) as? UIScrollView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &scrollViewAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}

extension UIBarButtonItem {
    var faseElementId: String! {
        get {
            return objc_getAssociatedObject(self, &faseElementIdAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &faseElementIdAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIButton {
    func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
                return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height - padding / 2),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: 0.0,//titleLabelSize.height,
            right: 0.0
        )
    }
}

extension UIImage {
    func resizedImageForNavBarItem() -> UIImage? {
        var image: UIImage? = nil
        let targetSize = CGSize(width: 24, height: 24)
        
        UIGraphicsBeginImageContext(targetSize)
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        self.draw(in: rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK: - Fase extensions

extension Frame {
    func frameTotalHeight() -> CGFloat {
        var height: CGFloat = 0
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let element = tuple[1] as! Element
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.frame {
                height += (element as! Frame).frameTotalHeight()
            } else if elementType == ElementType.label {
                height += 30
            } else if elementType == ElementType.button {
                height += 30
            } else if elementType == ElementType.text {
                height += 30
            }
        }
        
        return height
    }
}

extension VisualElement {
    // This extension allow to store element_id for custom tab bar button
    var faseElementId: String? {
        get {
            return objc_getAssociatedObject(self, &faseElementIdAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &faseElementIdAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension Button {
    func imageElement() -> Image? {
        var image: Image? = nil
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let element = tuple[1] as! Element
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.image {
                image = element as? Image
            }
        }
        
        return image
    }
    
    func contextMenu() -> Menu? {
        var menu: Menu? = nil
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let id = tuple[0] as! String
            let element = tuple[1] as! Element
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.menu {
                menu = element as? Menu
                menu?.faseElementId = id
            }
        }
        
        return menu
    }
    
    func menuItems() -> Array<MenuItem>? {
        var navButtons: Array<MenuItem> = []
        
        for tuple in self.idElementList {
            if tuple.count == 1{
                break
            }
            let element = tuple[1] as! Element
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.menu {
                for menuItemElement in (element as! ElementContainer).idElementList {
                    let itemId = menuItemElement[0] as! String
                    let menuItem = menuItemElement[1] as! MenuItem
                    let elementTypeString = menuItem.`class`
                    let elementType = ElementType(with: elementTypeString)
                    
                    if elementType == ElementType.menuItem {
                        menuItem.faseElementId = itemId
                        navButtons.append(menuItem)
                    }
                }
            }
        }
        return navButtons
    }
}

extension ElementContainer {
    // This var stores navigation element id for convenience.
    var navigationElementId: String? {
        get {
            return objc_getAssociatedObject(self, &faseNavigationElementIdAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &faseNavigationElementIdAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension Device {
    static func currentDevice() -> Device {
        var uuid = ""
        if let currentUUID = UIDevice.current.identifierForVendor?.uuidString {
            uuid = currentUUID
        }
        let type = UIDevice.current.systemName// + " " + UIDevice.current.systemVersion
        
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
    
    func hasFrameElements() -> Bool {
        var hasElements = false
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let element = tuple[1] as! ElementContainer
            
            if element is BaseElementsContainer {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.frame {
                    if element.idElementList.count > 0 {
                        hasElements = true
                        break
                    }
                }
            }
        }
        return hasElements
    }
    
    func mainButton() -> Button? {
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! Element
            
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.button && elementId == FaseElementsId.mainButton.rawValue {
                (element as! Button).faseElementId = elementId
                return element as? Button
            }
        }
        return nil
    }
    
    func previousButton() -> Button? {
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! Element
            
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.button && elementId == FaseElementsId.previousButton.rawValue {
                (element as! Button).faseElementId = elementId
                return element as? Button
            }
        }
        return nil
    }
    
    func nextButton() -> Button? {
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! Element
            
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.button && elementId == FaseElementsId.nextButton.rawValue {
                (element as! Button).faseElementId = elementId
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
            let elementId = tuple[0] as! String
            let element = tuple[1] as! Element
            
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.navigation {
                (element as! ElementContainer).navigationElementId = elementId
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
                    let buttonId = buttonElement[0] as! String
                    let button = buttonElement[1] as! Element
                    let elementTypeString = button.`class`
                    let elementType = ElementType(with: elementTypeString)
                    
                    if elementType == ElementType.button {
                        (button as! Button).faseElementId = buttonId
                        navButtons.append(button as! Button)
                    }
                }
            }
        }
        return navButtons
    }
    
    func alertElement() -> Alert? {
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! Element
            
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.alert {
                (element as! Alert).faseElementId = elementId
                return (element as! Alert)
            }
        }
        
        return nil
    }
    
}

private var nestedElemetsIdsAssociationKey: UInt8 = 0

extension MenuItem {
    // This extension allow to store element ids for nested elements
    var nestedElemetsIds: [String] {
        get {
            return objc_getAssociatedObject(self, &nestedElemetsIdsAssociationKey) as! [String]
        }
        set(newValue) {
            objc_setAssociatedObject(self, &nestedElemetsIdsAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}



