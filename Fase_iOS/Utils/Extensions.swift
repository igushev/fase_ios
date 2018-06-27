//
//  Extensions.swift
//  TestJsonIOS
//
//  Created by Alexey Bidnyk on 3/8/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import Foundation
import ObjectMapper
import GooglePlaces

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

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

extension String {
    func textHeight(with font: UIFont) -> CGFloat {
        return self.height(withWidth: UIElementsWidth.label.rawValue, font: font)
    }
    
    func height(withWidth width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [.font : font], context: nil)
        return actualSize.height
    }
}

// MARK: - UIKit extensions

private var faseElementIdAssociationKey: UInt8 = 0
private var faseNavigationElementIdAssociationKey: UInt8 = 0
private var scrollViewAssociationKey: UInt8 = 0

extension UIView {
    // This var stores fase element id for convenience. Element id is in the same array that element
    var faseElementId: String? {
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
    
    // Needs to enable user interaction in superviews to enable on_click in frames
    func enableUserInteractionForSuperviews() {
        var view = self
        while let superview = view.superview {
            view = superview
            view.isUserInteractionEnabled = true
        }
    }
    
    func nestedElementsIds() -> [String] {
        var iDs: [String] = [self.faseElementId!]
        var view = self
        
        while let superview = view.superview, let id = superview.faseElementId, id != FaseElementsId.scrollView.rawValue, id != FaseElementsId.substrateView.rawValue {
            view = superview
            iDs.insert(id, at: 0)
        }
        return iDs
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
            left: (self.frame.width - imageViewSize.width) / 2,
            bottom: 0.0,
            right: (self.frame.width - imageViewSize.width) / 2
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

enum FaseImageWidth: Int {
    case navigationItem = 24
    case tabBarItem = 32
}

extension UIImage {
    func resizedImage(with size: CGSize) -> UIImage? {
        var image: UIImage? = nil
        
        UIGraphicsBeginImageContext(size)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.draw(in: rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIColor {
    struct FaseColors {
        static var navBarColor = UIColor(red: 66/255, green: 143/255, blue: 245/255, alpha: 1.0)
        static var navBarItemsColor = UIColor.white
        static var backgroundColor = UIColor.white //UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1.0)
        static var textFieldBackgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        static var textColor = UIColor.black
        static var buttonTextColor = UIColor.black
        static var borderColor = UIColor(red: 226/255, green: 226/255, blue: 226/255, alpha: 1.0)
        static var placeholderColor = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1.0)
        static var tabBarBackgroundColor = UIColor(red: 198/256, green: 198/256, blue: 198/256, alpha: 1.0)
    }
}

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: self],
            context: nil).size
    }
}

// MARK: - Fase extensions

extension Frame {
    func frameTotalHeight() -> CGFloat {
        return self.orientation == FrameType.vertical ? self.verticalFrameTotalHeight() : self.horizontalFrameTotalHeight()
    }
    
    func verticalFrameTotalHeight() -> CGFloat {
        var height: CGFloat = 0
        var count: CGFloat = 0
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            
            // Unnecessary if stack view has layout margins
            if count >= 1 {
                height += UIElementsHeight.verticalSpace.rawValue
            }
            
            let element = tuple[1] as! Element
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.frame {
                height += (element as! Frame).frameTotalHeight()
            } else if elementType == ElementType.label {
                height += UIElementsHeight.label.rawValue
                // TODO: - Count label height depend on text size
                //                let font = UIFont.systemFont(ofSize: (element as! Label).font.appFontSize)
                //                height += (element as! Label).text.textHeight(with: font)
            } else if elementType == ElementType.button {
                height += UIElementsHeight.button.rawValue
            } else if elementType == ElementType.text {
                height += (element as! Text).multiline == true ? UIElementsHeight.textView.rawValue : UIElementsHeight.textField.rawValue
            } else if elementType == ElementType.dateTimePicker {
                height += UIElementsHeight.textField.rawValue
            } else if elementType == ElementType.placePicker {
                height += UIElementsHeight.textField.rawValue
            }
            
            count += 1
        }
        
        return height
    }
    
    func horizontalFrameTotalHeight() -> CGFloat {
        var height: CGFloat = 0
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            
            let element = tuple[1] as! Element
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.frame {
                height = max(height, (element as! Frame).frameTotalHeight())
            } else if elementType == ElementType.label {
                height = max(height, UIElementsHeight.label.rawValue)
            } else if elementType == ElementType.button {
                height = max(height, UIElementsHeight.button.rawValue)
            } else if elementType == ElementType.text {
                height = (element as! Text).multiline == true ? max(height, UIElementsHeight.textView.rawValue) : max(height, UIElementsHeight.textField.rawValue)
            } else if elementType == ElementType.dateTimePicker {
                height = max(height, UIElementsHeight.textField.rawValue)
            } else if elementType == ElementType.placePicker {
                height = max(height, UIElementsHeight.textField.rawValue)
            }
            
        }
        
        return height
    }
    
    func dateTimePickerElements() -> [DateTimePicker]? {
        var elements: [DateTimePicker] = []
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! ElementContainer
            
            if element is VisualElement {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.dateTimePicker {
                    (element as? DateTimePicker)?.faseElementId = elementId
                    elements.append(element as! DateTimePicker)
                }
                if elementType == ElementType.frame {
                    if let datePickers = (element as! Frame).dateTimePickerElements() {
                        elements = elements + datePickers
                    }
                }
            }
        }
        return elements
    }
    
    func placePickerElements() -> [PlacePicker]? {
        var elements: [PlacePicker] = []
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! ElementContainer
            
            if element is VisualElement {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.placePicker {
                    (element as? PlacePicker)?.faseElementId = elementId
                    elements.append(element as! PlacePicker)
                }
                if elementType == ElementType.frame {
                    if let datePickers = (element as! Frame).placePickerElements() {
                        elements = elements + datePickers
                    }
                }
            }
        }
        return elements
    }
    
    func selectElements() -> [Select]? {
        var elements: [Select] = []
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! ElementContainer
            
            if element is VisualElement {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.select {
                    (element as? Select)?.faseElementId = elementId
                    elements.append(element as! Select)
                }
                if elementType == ElementType.frame {
                    if let selects = (element as! Frame).selectElements() {
                        elements = elements + selects
                    }
                }
            }
        }
        return elements
    }
    
    func contactPickerElements() -> [ContactPicker]? {
        var elements: [ContactPicker] = []
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! ElementContainer
            
            if element is VisualElement {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.contactPicker {
                    (element as? ContactPicker)?.faseElementId = elementId
                    elements.append(element as! ContactPicker)
                }
                if elementType == ElementType.frame {
                    if let selects = (element as! Frame).contactPickerElements() {
                        elements = elements + selects
                    }
                }
            }
        }
        return elements
    }
    
    func hasMaxElements() -> Bool {
        
        for tuple in idElementList {
            if tuple.count == 1 {
                break
            }
            
            let element = tuple[1] as! ElementContainer
            
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            switch elementType {
            case .text:
                if (element as! Text).size == .max {
                    return true
                }
                break
                
            case .web:
                if (element as! Web).size == .max {
                    return true
                }
                break
                
            case .label:
                if (element as! Label).size == .max {
                    return true
                }
                break
                
            default:
                break
            }
            
        }
        
        return false
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
    
    func hasElementWithMaxSize() -> Bool {
        var has = false
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let element = tuple[1] as! Element
            
            if element is ElementContainer {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.frame {
                    if (element as! Frame).size == .max {
                        has = true
                    }
                }
                if elementType == ElementType.text {
                    if (element as! Text).size == .max {
                        has = true
                    }
                }
            }
        }
        return has
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
}

extension Device {
    static func currentDevice() -> Device {
        var uuid = ""
        if let currentUUID = UIDevice.current.identifierForVendor?.uuidString {
            uuid = currentUUID
        }
        let type = UIDevice.current.systemName
        
        return Device(type: type, token: uuid)
    }
}

extension Screen {
    
    func screenContentHeight() -> CGFloat {
        var height: CGFloat = 0
        var count: CGFloat = 0
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            
            let elementId = tuple[0] as! String
            let element = tuple[1] as! Element
            let elementTypeString = element.`class`
            let elementType = ElementType(with: elementTypeString)
            
            if elementType == ElementType.frame {
                height += (element as! Frame).frameTotalHeight()
            } else if elementType == ElementType.label {
                height += UIElementsHeight.label.rawValue
                // TODO: - Count label height depend on text size
                //                let font = UIFont.systemFont(ofSize: (element as! Label).font.appFontSize)
                //                height += (element as! Label).text.textHeight(with: font)
            } else if elementType == ElementType.button &&
                elementId != FaseElementsId.mainButton.rawValue &&
                elementId != FaseElementsId.previousButton.rawValue {
                height += UIElementsHeight.button.rawValue
            } else if elementType == ElementType.text {
                height += (element as! Text).multiline == true ? UIElementsHeight.textView.rawValue : UIElementsHeight.textField.rawValue
            } else if elementType == ElementType.dateTimePicker {
                height += UIElementsHeight.textField.rawValue
            } else if elementType == ElementType.placePicker {
                height += UIElementsHeight.textField.rawValue
            } else if elementType == ElementType.select {
                height += UIElementsHeight.textField.rawValue
            }
            
            height += UIElementsHeight.verticalSpace.rawValue
            
            count += 1
        }
        
        return height
    }
    
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
    
    func datePickerElements() -> [DateTimePicker]? {
        var elements: [DateTimePicker] = []
        
        for tuple in self.idElementList {
            
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! ElementContainer
            
            if element is VisualElement {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.dateTimePicker {
                    (element as? DateTimePicker)?.faseElementId = elementId
                    elements.append(element as! DateTimePicker)
                }
                if elementType == ElementType.frame {
                    if let dateTimePickers = (element as! Frame).dateTimePickerElements() {
                        elements = elements + dateTimePickers
                    }
                }
            }
        }
        return elements
    }
    
    func datePickerElement(elementId: String) -> DateTimePicker? {
        if let datePickerElements = self.datePickerElements() {
            for datePickerElement in datePickerElements {
                if datePickerElement.faseElementId == elementId {
                    return datePickerElement
                }
            }
        }
        return nil
    }
    
    func placePickerElements() -> [PlacePicker]? {
        var elements: [PlacePicker] = []
        
        for tuple in self.idElementList {
            
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! ElementContainer
            
            if element is VisualElement {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.placePicker {
                    (element as? PlacePicker)?.faseElementId = elementId
                    elements.append(element as! PlacePicker)
                }
                if elementType == ElementType.frame {
                    if let placePickers = (element as! Frame).placePickerElements() {
                        elements = elements + placePickers
                    }
                }
            }
        }
        return elements
    }
    
    func placePickerElement(elementId: String) -> PlacePicker? {
        if let placePickerElements = self.placePickerElements() {
            for placePickerElement in placePickerElements {
                if placePickerElement.faseElementId == elementId {
                    return placePickerElement
                }
            }
        }
        return nil
    }
    
    func selectElements() -> [Select]? {
        var elements: [Select] = []
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! ElementContainer
            
            if element is VisualElement {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.select {
                    (element as? Select)?.faseElementId = elementId
                    elements.append(element as! Select)
                }
                if elementType == ElementType.frame {
                    if let selects = (element as! Frame).selectElements() {
                        elements = elements + selects
                    }
                }
            }
        }
        return elements
    }
    
    func selectElement(elementId: String) -> Select? {
        if let selectElements = self.selectElements() {
            for selectElement in selectElements {
                if selectElement.faseElementId == elementId {
                    return selectElement
                }
            }
        }
        return nil
    }
    
    func contactPickerElements() -> [ContactPicker]? {
        var elements: [ContactPicker] = []
        
        for tuple in self.idElementList {
            if tuple.count == 1 {
                break
            }
            let elementId = tuple[0] as! String
            let element = tuple[1] as! ElementContainer
            
            if element is VisualElement {
                let elementTypeString = element.`class`
                let elementType = ElementType(with: elementTypeString)
                
                if elementType == ElementType.contactPicker {
                    (element as? ContactPicker)?.faseElementId = elementId
                    elements.append(element as! ContactPicker)
                }
                if elementType == ElementType.frame {
                    if let contactPickers = (element as! Frame).contactPickerElements() {
                        elements = elements + contactPickers
                    }
                }
            }
        }
        return elements
    }
    
    func contactPickerElement(elementId: String) -> ContactPicker? {
        if let contactPickersElements = self.contactPickerElements() {
            for contactPickersElement in contactPickersElements {
                if contactPickersElement.faseElementId == elementId {
                    return contactPickersElement
                }
            }
        }
        return nil
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

extension Place {
    func placeString(for type: PlacePickerType) -> String? {
        if let _ = self.googlePlaceId, let city = self.city, let state = self.state, let country = self.country {
            var values: [String] = []
            
            if city.isEmpty == false, city != "-" {
                values.append(city)
            }
            if state.isEmpty == false, state != "-" {
                values.append(state)
            }
            if country.isEmpty == false, country != "-" {
                values.append(country)
            }
            return values.joined(separator: ", ")
        }
        return nil
    }
    
    static func place(with googlePlace: GMSPlace) -> Place {
        var place = Place(placeId: googlePlace.placeID, city: "-", state: "-", country: "-")
        
        if let addressComponents = googlePlace.addressComponents {
            for component in addressComponents {
                if component.type == "locality"  {
                    place.city = component.name
                }
                if component.type == "administrative_area_level_1" {
                    place.state = component.name
                }
                if component.type == "country" {
                    place.country = component.name
                }
            }
        }
        
        return place
    }
}

extension Contact {
    func contactString() -> String? {
        return self.displayName
    }
}

extension ElementsUpdate: Equatable {
    static func ==(lhs: ElementsUpdate, rhs: ElementsUpdate) -> Bool {
        if (lhs.valueArray?.count != rhs.valueArray?.count) || (lhs.arrayArrayIds?.count != rhs.arrayArrayIds?.count) {
            return false
        }
        
        if let lhsValueArray = lhs.valueArray, let rhsValueArray = rhs.valueArray {
            for i in 0...lhsValueArray.count - 1 {
                if lhsValueArray[i] != rhsValueArray[i] {
                    return false
                }
            }
        }
        
        return true
    }
    
    func differenceFrom(oldElementsUpdate: ElementsUpdate?) -> ElementsUpdate? {
        guard let oldElementsUpdate = oldElementsUpdate else {
            return self
        }
        
        if oldElementsUpdate == self {
            return nil
        }
        
        var newElementsUpdate = ElementsUpdate()
        
        if self.valueArray?.count != oldElementsUpdate.valueArray?.count {
            return self
        }
        
        for i in 0...(self.valueArray?.count)! - 1 {
            if self.valueArray![i] != oldElementsUpdate.valueArray![i] {
                newElementsUpdate.valueArray?.append(self.valueArray![i])
                newElementsUpdate.arrayArrayIds?.append(self.arrayArrayIds![i])
            }
        }
        
        return (newElementsUpdate.valueArray!.count > 0) ? newElementsUpdate : nil
    }
    
    mutating func update(with newElementsUpdate: ElementsUpdate) {
        for i in 0...(self.valueArray?.count)! - 1 {
            let idInOldElementsUpdate = self.arrayArrayIds?[i].first
            let idInNewElementsUpdate = newElementsUpdate.arrayArrayIds?.index(where: { (array) -> Bool in
                return array.first == idInOldElementsUpdate
            })
            
            if let index = idInNewElementsUpdate, let oldValue = self.valueArray?[i], let newValue = newElementsUpdate.valueArray?[index], oldValue != newValue {
                self.valueArray?[i] = newValue
            }
        }
    }
    
}


import GooglePlaces
import ContactsUI

// MARK: - Other extensions

extension CNContactPickerViewController {
    // This var stores fase element id for convenience. Element id is in the same array that element
    var faseElementId: String? {
        get {
            return objc_getAssociatedObject(self, &faseElementIdAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &faseElementIdAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension GMSAutocompleteViewController {
    // This var stores fase element id for convenience. Element id is in the same array that element
    var faseElementId: String? {
        get {
            return objc_getAssociatedObject(self, &faseElementIdAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &faseElementIdAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

