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
typealias ElementTupleValue = AnyObject // String or Element

enum ElementType: String {
    typealias RawValue = String
    
    case label = "label"
    case text = "text"
    case switchElement = "switch"
    case select = "select"
    case image = "image"
    case button = "button"
    case buttonBar = "buttonbar"
    case menu = "menu"
    case menuItem = "menuitem"
    case contactPicker = "contactpicker"
    case dateTimePicker = "datetimepicker"
    case placePicker = "placepicker"
    case alert = "alert"
    case slider = "slider"
    case frame = "frame"
    case separator = "separator"
    case navigation = "navigation"
    case web = "web"
    case unknown = "unknown"
    
    init(with string: String?) {
        self = ElementType(rawValue: (string?.lowercased())!) ?? .unknown
    }
}

class Element: Mappable {
    var `class`: String!
    
    required init?(map: Map) {
        `class` = try? map.value("__class__")
    }
    
    func mapping(map: Map) {
        `class` <- map["__class__"]
    }
}

class ElementContainer: Element {
    var idElementList: Array<ElementTuple>!
    
    required init?(map: Map) {
        super.init(map: map)
        //        idElementList = try? map.value("id_element_list")
        let transform = TransformOf<Array<ElementTuple>, Array<Array<AnyObject>>>(fromJSON: { (values: Array<Array<AnyObject>>?) -> Array<ElementTuple>? in
            var elements: Array<ElementTuple> = []
            
            if let values = values {
                for value in values {
                    var elementTuple: ElementTuple = []
                    
                    // Map ui element id
                    let elementId = value[0]// String(describing: value[0])
                    elementTuple.append(elementId)
                    
                    // Map ui element
                    if let elementJSON = value[1] as? [String : Any] {
                        let elementMap = Map(mappingType: .fromJSON, JSON: elementJSON)
                        if let element = ElementMappingService.mapElement(with: elementMap) {
                            elementTuple.append(element)
                        }
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
        
        idElementList = try? map.value("id_element_list", using: transform)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        let transform = TransformOf<Array<ElementTuple>, Array<Array<AnyObject>>>(fromJSON: { (values: Array<Array<AnyObject>>?) -> Array<ElementTuple>? in
            var elements: Array<ElementTuple> = []
            
            if let values = values {
                for value in values {
                    var elementTuple: ElementTuple = []
                    
                    // Map ui element id
                    let elementId = value[0]// String(describing: value[0])
                    elementTuple.append(elementId)
                    
                    // Map ui element
                    let elementMap = Map(mappingType: .fromJSON, JSON: value[1] as! [String : Any])
                    if let element = ElementMappingService.mapElement(with: elementMap) {
                        elementTuple.append(element)
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
    var isRequestLocale: Bool!
    var locale: Locale?
    
    required init?(map: Map) {
        super.init(map: map)
        
        isDisplayed = try? map.value("displayed")
        isRequestLocale = try? map.value("request_locale")
        locale = try? map.value("locale")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        isDisplayed <- map["displayed"]
        isRequestLocale <- map["request_locale"]
        locale <- map["locale"]
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

enum FaseFontSize: CGFloat {
    case extraLarge = 1.5
    case large = 1.25
    case medium = 1
    case small = 0.75
    case extraSmall = 0.5
    case unknown = 0
    
    var appFontSize: CGFloat {
        switch self {
        case .extraLarge: return 20
        case .large: return 17
        case .medium: return 14
        case .small: return 12
        case .extraSmall: return 9
        case .unknown: return 14
        }
    }
}

class Label: VisualElement {
    var text: String!
    var font: FaseFontSize!
    var size: Size!
    var align: Align!
    var onClick: Method!
    
    required init?(map: Map) {
        super.init(map: map)
        
        text = try? map.value("text")
        font = try? map.value("font")
        size = try? map.value("size")
        align = try? map.value("align")
        onClick = try? map.value("on_click")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        text <- map["text"]
        font <- map["font"]
        size <- map["size"]
        align <- map["align"]
        onClick <- map["on_click"]
    }
}

enum TextType: Int {
    case digits = 1
    case phone
    case email
}

class Text: VisualElement {
    var type: TextType!
    var size: Size!
    var hint: String!
    var text: String!
    var multiline: Bool!
    
    required init?(map: Map) {
        super.init(map: map)
        
        type = try? map.value("type")
        size = try? map.value("size")
        hint = try? map.value("hint")
        text = try? map.value("text")
        multiline = try? map.value("multiline")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type <- map["type"]
        size <- map["size"]
        hint <- map["hint"]
        text <- map["text"]
        multiline <- map["multiline"]
    }
}

class Switch: VisualElement {
    var value: Bool!
    var text: String?
    var align: Align?
    
    required init?(map: Map) {
        super.init(map: map)
        
        value = try? map.value("value")
        text = try? map.value("text")
        align = try? map.value("align")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        value <- map["value"]
        text <- map["text"]
        align <- map["align"]
    }
}

class Select: VisualElement {
    var value: String?
    var items: Array<String>?
    var hint: String!
    var align: Align!
    
    required init?(map: Map) {
        super.init(map: map)
        
        value = try? map.value("value")
        items = try? map.value("items")
        hint = try? map.value("hint")
        align = try? map.value("align")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        value <- map["value"]
        items <- map["items"]
        hint <- map["hint"]
        align <- map["align"]
    }
}

class Slider: VisualElement {
    var value: Float!
    var minValue: Float!
    var maxValue: Float!
    var step: Float!
    
    required init?(map: Map) {
        super.init(map: map)
        
        value = try? map.value("value")
        minValue = try? map.value("min_value")
        maxValue = try? map.value("max_value")
        step = try? map.value("step")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        value <- map["value"]
        minValue <- map["min_value"]
        maxValue <- map["max_value"]
        step <- map["step"]
    }
}

class Image: VisualElement {
    var fileName: String!
    var url: String?
    var onClick: Method!
    var align: Align!
    
    required init?(map: Map) {
        super.init(map: map)
        
        fileName = try? map.value("filename") // maybe file_name? check response
        url = try? map.value("url")
        onClick = try? map.value("on_click")
        align = try? map.value("align")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        fileName <- map["filename"]
        url <- map["url"]
        onClick <- map["on_click"]
        align <- map["align"]
    }
}

class MenuItem: VisualElement {
    var text: String!
    var onClick: Method!
    var image: Image!
    
    required init?(map: Map) {
        super.init(map: map)
        
        text = try? map.value("text")
        onClick = try? map.value("on_click")
        image = try? map.value("image")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        text <- map["text"]
        onClick <- map["on_click"]
        image <- map["image"]
    }
}

class Menu: VisualElement {
    var text: String!
    
    required init?(map: Map) {
        super.init(map: map)
        
        text = try? map.value("text")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        text <- map["text"]
    }
}

class Button: VisualElement {
    var text: String!
    var onClick: Method!
    var align: Align!
    
    required init?(map: Map) {
        super.init(map: map)
        
        text = try? map.value("text")
        onClick = try? map.value("on_click")
        align = try? map.value("align")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        text <- map["text"]
        onClick <- map["on_click"]
        align <- map["align"]
    }
}

class ButtonBar: VisualElement {
    
}

class ContactPicker: VisualElement {
    var contact: Contact?
    var hint: String!
    var size: Size!
    var onPick: Method!
    
    required init?(map: Map) {
        super.init(map: map)
        
        contact = try? map.value("contact")
        hint = try? map.value("hint")
        size = try? map.value("size")
        onPick = try? map.value("on_pick")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        contact <- map["contact"]
        hint <- map["hint"]
        size <- map["size"]
        onPick <- map["on_pick"]
    }
}

enum DateTimePickerType: Int {
    case date = 1
    case time
    case datetime
}

class DateTimePicker: VisualElement {
    var datetime: Date?
    var type: DateTimePickerType!
    var hint: String!
    var size: Size!
    
    required init?(map: Map) {
        super.init(map: map)
        
        datetime = try? map.value("datetime")
        type = try? map.value("type")
        hint = try? map.value("hint")
        size = try? map.value("size")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        datetime <- map["datetime"]
        type <- map["type"]
        hint <- map["hint"]
        size <- map["size"]
    }
}

enum PlacePickerType: Int {
    case city = 1
}

class PlacePicker: VisualElement {
    var place: Place?
    var type: PlacePickerType!
    var hint: String!
    var size: Size!
    
    required init?(map: Map) {
        super.init(map: map)
        
        place = try? map.value("place")
        type = try? map.value("type")
        hint = try? map.value("hint")
        size = try? map.value("size")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        place <- map["place"]
        type <- map["type"]
        hint <- map["hint"]
        size <- map["size"]
    }
}

class Separator: VisualElement {
    
}

class Web: VisualElement {
    var size: Size!
}

enum FrameType: Int {
    case none = 0
    case vertical
    case horizontal
}

class Frame: BaseElementsContainer {
    var orientation: FrameType!
    var size: Size!
    var onClick: Method?
    var border: Bool!
    
    required init?(map: Map) {
        super.init(map: map)
        
        orientation = try? map.value("orientation")
        size = try? map.value("size")
        onClick = try? map.value("on_click")
        border = try? map.value("border")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        orientation <- map["orientation"]
        size <- map["size"]
        onClick <- map["on_click"]
        border <- map["border"]
    }
}

class Alert: VisualElement {
    var text: String!
    
    required init?(map: Map) {
        super.init(map: map)
        
        text = try? map.value("text")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        text <- map["text"]
    }
}

class BaseElementsContainer: VisualElement { }

class Screen: BaseElementsContainer {
    var screenId: String?
    var scrollable: Bool?
    var title: String?
    var onRefresh: Bool!
    var onMore: Bool!
    
    required init?(map: Map) {
        super.init(map: map)
        
        screenId = try? map.value("_screen_id")
        scrollable = try? map.value("scrollable")
        title = try? map.value("title")
        onRefresh = try? map.value("on_refresh")
        onMore = try? map.value("on_more")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        screenId <- map["_screen_id"]
        scrollable <- map["scrollable"]
        title <- map["title"]
        onRefresh <- map["on_refresh"]
        onMore <- map["on_more"]
    }
}

