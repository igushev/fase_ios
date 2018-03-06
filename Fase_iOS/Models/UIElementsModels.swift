//
//  UIElements.swift
//  TestJson
//
//  Created by Alexey Bidnyk on 3/1/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import Foundation

class Element { }

typealias ElementTuple = (String, Element)

class ElementContainer: Element {
    var idElementList: Array<ElementTuple>!
}

class VisualElement: ElementContainer {
    var isDisplayed: Bool!
    var locale: Locale!
    var isRequestLocale: Bool!
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
    var onClick: (() -> ())!
    var align: Align!
    var font: Float!
    var size: Size!
    var text: String!
    
    enum CodingKeys: String, CodingKey {
        case onClick = "on_click"
        case align = "align"
        case font = "font"
        case isDisplayed = "displayed"
        case locale = "locale"
        case size = "size"
        case text = "text"
        case isRequestLocale = "request_locale"
        case idElementList = "id_element_list"
    }
}

class Text: VisualElement {
    var size: Size!
    var hint: String!
    
    enum CodingKeys: String, CodingKey {
        case isDisplayed = "displayed"
        case hint = "hint"
        case locale = "locale"
        case size = "size"
        case text = "text"
        case type = "type"
        case isRequestLocale = "request_locale"
        case idElementList = "id_element_list"
    }
}

class Switch: VisualElement {
    var align: Align!
    var text: String!
    var value: Bool!
    
    enum CodingKeys: String, CodingKey {
        case align = "align"
        case isDisplayed = "displayed"
        case locale = "locale"
        case text = "text"
        case value = "value"
        case isRequestLocale = "request_locale"
        case idElementList = "id_element_list"
    }
}

class Select: VisualElement {
    var items: Array<String>!
    var align: Align!
    var value: String!
    var hint: String!
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
        case align = "align"
        case value = "value"
        case hint = "hint"
        case isDisplayed = "displayed"
        case locale = "locale"
        case isRequestLocale = "request_locale"
        case idElementList = "id_element_list"
    }
}

class Image: VisualElement {
    var image: String!
    
    enum CodingKeys: String, CodingKey {
        case image = "image"
        case isDisplayed = "displayed"
        case locale = "locale"
        case isRequestLocale = "request_locale"
        case idElementList = "id_element_list"
    }
}

class MenuItem: VisualElement {
    var text: String!
}

class Button: VisualElement {
    var onClick: (() -> ())!
    var image: String!
    var text: String!
    
    enum CodingKeys: String, CodingKey {
        case onClick = "on_click"
        case isDisplayed = "displayed"
        case locale = "locale"
        case image = "image"
        case text = "text"
        case isRequestLocale = "request_locale"
        case idElementList = "id_element_list"
    }
}

class ButtonBar: VisualElement {
    enum CodingKeys: String, CodingKey {
        case idElementList = "id_element_list"
    }
}

class ContactPicker: VisualElement {
    var contact: Contact!
    var onPick: (() -> ())!
    var hint: String!
}

enum DateTimePickerType: Int {
    case date = 1
    case time
    case datetime
}

class DateTimePicker: VisualElement {
    var datetime: Date!
    var size: Size!
    var type: DateTimePickerType!
    var hint: String!
    
}

enum PlacePickerType: Int {
    case city = 1
}

class PlacePicker: VisualElement {
    var place: Place!
    var size: Size!
    var type: PlacePickerType!
    var hint: String!
}

enum FrameType: Int {
    case vertical = 1
    case horizontal
}

class Frame: VisualElement {
    var onClick: (() -> ())!
    var orientation: FrameType!
    var border: Bool!
    var size: Size!
}

class Alert: VisualElement {
    var text: String!
    
    enum CodingKeys: String, CodingKey {
        case test = "text"
        case idElementList = "id_element_list"
    }
}

class BaseElementsContainer: VisualElement { }

class Screen: BaseElementsContainer {
    var onRefresh: (() -> ())!
    var onMore: (() -> ())!
    var title: String!
    var screenId: String!
    var scrollable: Bool!
    
    enum CodingKeys: String, CodingKey {
        case onRefresh = "on_refresh"
        case onMore = "on_more"
        case title = "title"
        case screenId = "screen_id"
        case scrollable = "scrollable"
        case isDisplayed = "displayed"
        case isRequestLocale = "request_locale"
        case locale = "locale"
        case idElementList = "id_element_list"
    }
}








