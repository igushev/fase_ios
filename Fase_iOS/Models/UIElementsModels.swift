//
//  UIElements.swift
//  TestJson
//
//  Created by Alexey Bidnyk on 3/1/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import Foundation
import ObjectMapper

// tuple replacement. Nested array consist of elementId and element
typealias ElementTuple = Array<ElementTupleValue>

enum ElementType: String {
    typealias RawValue = String
    
    case label = "label"
    case text = "text"
    case switchElement = "switch"
    case select = "select"
    case image = "image"
    case button = "button"
    case buttonBar = "buttonBar"
    case menuItem = "menuItem"
    case contactPicker = "contactPicker"
    case dateTimePicker = "dateTimePicker"
    case placePicker = "placePicker"
    case alert = "alert"
    case unknown = "unknown"
    
    init(with string: String?) {
        self = ElementType(rawValue: (string?.lowercased())!) ?? .unknown
    }
}

enum ElementTupleValue : Mappable {
    case string(String)
    case element(Element)
    
    init?(map: Map) {
        let value = map.currentValue
        
        self = .string(" ")
    }
    
    mutating func mapping(map: Map) {
        let value = map.currentValue
        print(value)
        //        switch self {
        //        case .string(value):
        //            <#code#>
        //        default:
        //            <#code#>
        //        }
    }
    
    
}


class Element: Mappable {
    var `class`: String!
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        `class` <- map["__class__"]
    }
}

class ElementContainer: Element {
    var idElementList: Array<ElementTuple>!
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        let transform = TransformOf<Array<ElementTuple>, Array<Array<AnyObject>>>(fromJSON: { (values: Array<Array<AnyObject>>?) -> Array<ElementTuple>? in
            var elements: Array<ElementTuple> = []
            
            if let values = values {
                for value in values {
                    var elementTuple: ElementTuple = []
                    
                    // Map ui element id
                    let elementId = String(describing: value[0])
                    elementTuple.append(ElementTupleValue.string(elementId))
                    
                    // Map ui element
                    let elementMap = Map(mappingType: .fromJSON, JSON: value[1] as! [String : Any])
                    if let element = ElementMappingService.mapElement(with: elementMap) {
                        elementTuple.append(ElementTupleValue.element(element))
                    }
                    
                    elements.append(elementTuple)
                }
                
                return elements
            }
            
            return nil
        }, toJSON: { (value: Array<ElementTuple>?) -> Array<Array<AnyObject>>? in
            print(value)
            return nil
        })
        
        idElementList <- (map["id_element_list"], transform)
    }
}

class VisualElement: ElementContainer {
    var isDisplayed: Bool!
    var locale: Locale?
    var isRequestLocale: Bool!
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        isDisplayed <- map["displayed"]
        locale <- map["locale"]
        isRequestLocale <- map["request_locale"]
    }
}

enum Align: Int {
    case left = 1
    case right
    case center
}

enum Size: Int {
    case min = 1
    case max = 2
}

class Label: VisualElement {
    var type: ElementType!
    var onClick: Bool!
    var align: Align!
    var font: Float!
    var size: Size!
    var text: String!
    
    required init?(map: Map) {
        super.init(map: map)
        
        type = try? map.value("__class__")
        onClick = try? map.value("on_click")
        align = try? map.value("align")
        font = try? map.value("font")
        size = try? map.value("size")
        text = try? map.value("text")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type <- map["__class__"]
        onClick <- map["on_click"]
        align <- map["align"]
        font <- map["font"]
        size <- map["size"]
        text <- map["text"]
    }
}

class Text: VisualElement {
    var type: ElementType!
    var size: Size!
    var hint: String!
    var text: String!
    
    required init?(map: Map) {
        super.init(map: map)
        
        type = try? map.value("__class__")
        size = try? map.value("size")
        hint = try? map.value("hint")
        text = try? map.value("text")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type <- map["__class__"]
        size <- map["size"]
        hint <- map["hint"]
        text <- map["text"]
    }
}

class Switch: VisualElement {
    var type: ElementType!
    var align: Align!
    var text: String!
    var value: Bool!
    
    required init?(map: Map) {
        super.init(map: map)
        
        type = try? map.value("__class__")
        align = try? map.value("align")
        text = try? map.value("text")
        value = try? map.value("value")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type <- map["__class__"]
        align <- map["align"]
        text <- map["text"]
        value <- map["value"]
    }
}

class Select: VisualElement {
    var type: ElementType!
    var items: Array<String>!
    var align: Align!
    var value: String!
    var hint: String!
    
    required init?(map: Map) {
        super.init(map: map)
        
        type = try? map.value("__class__")
        items = try? map.value("items")
        align = try? map.value("align")
        value = try? map.value("value")
        hint = try? map.value("hint")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type <- map["__class__"]
        items <- map["items"]
        align <- map["align"]
        value <- map["value"]
        hint <- map["hint"]
    }
}

class Image: VisualElement {
    var type: ElementType!
    var url: String!
    var fileName: String!
    
    required init?(map: Map) {
        super.init(map: map)
        
        type = try? map.value("__class__")
        url = try? map.value("url")
        fileName = try? map.value("filename") // maybe file_name? check response
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type <- map["__class__"]
        url <- map["url"]
        fileName <- map["filename"]
    }
}

class MenuItem: VisualElement {
    var type: ElementType!
    var onClick: Bool!
    var image: String!
    var text: String!
}

class Menu: VisualElement {
    var text: String!
}

class Button: VisualElement {
    var type: ElementType!
    var onClick: Bool!
    var image: String!
    var text: String!
    
    required init?(map: Map) {
        super.init(map: map)
        
        type = try? map.value("__class__")
        onClick = try? map.value("on_click")
        image = try? map.value("image")
        text = try? map.value("text")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type <- map["__class__"]
        onClick <- map["on_click"]
        image <- map["image"]
        text <- map["text"]
    }
}

class ButtonBar: VisualElement {
    var type: ElementType!
    
    enum CodingKeys: String, CodingKey {
        case idElementList = "id_element_list"
    }
}

class ContactPicker: VisualElement {
    var type: ElementType!
    var contact: Contact!
    var onPick: Bool!
    var hint: String!
    var size: Size!
}

enum DateTimePickerType: Int {
    case date = 1
    case time
    case datetime
}

class DateTimePicker: VisualElement {
    var type: ElementType!
    var datetime: Date!
    var size: Size!
    var pickerType: DateTimePickerType!
    var hint: String!
    
}

enum PlacePickerType: Int {
    case city = 1
}

class PlacePicker: VisualElement {
    var type: ElementType!
    var place: Place!
    var size: Size!
    var pickerType: PlacePickerType!
    var hint: String!
}

enum FrameType: Int {
    case vertical = 1
    case horizontal
}

class Frame: BaseElementsContainer {
    var type: ElementType!
    var onClick: Bool!
    var orientation: FrameType!
    var border: Bool!
    var size: Size!
}

class Alert: VisualElement {
    var type: ElementType!
    var text: String!
    
    enum CodingKeys: String, CodingKey {
        case test = "text"
        case idElementList = "id_element_list"
    }
}

class Slider: VisualElement {
    var type: ElementType!
}

class BaseElementsContainer: VisualElement { }

class Screen: BaseElementsContainer {
    var onRefresh: Bool!
    var onMore: Bool!
    var title: String?
    var screenId: String?
    var scrollable: Bool?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        onRefresh <- map["on_refresh"]
        onMore <- map["on_more"]
        title <- map["title"]
        screenId <- map["_screen_id"]
        scrollable <- map["scrollable"]
    }
}

