//
//  ElementMappingService.swift
//  TestJsonIOS
//
//  Created by Aleksey on 3/10/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import Foundation
import ObjectMapper

class ElementMappingService {
    static func mapElement(with map: Map) -> Element? {
        let elementTypeString = map.JSON["__class__"] as? String
        let elementType = ElementType(with: elementTypeString)
        
        switch elementType {
        case .label:
            return Label.init(map: map)
            
        case .text:
            return Text.init(map: map)
            
        case .switchElement:
            return Switch.init(map: map)
            
        case .select:
            return Select.init(map: map)
            
        case .image:
            return Image.init(map: map)
            
        case .button:
            return Button.init(map: map)
            
        case .navigation:
            return ElementContainer.init(map: map)
            
        case .frame:
            return Frame.init(map: map)
            
        case .menu:
            return Menu.init(map: map)
            
        case .menuItem:
            return MenuItem.init(map: map)
            
        case .alert:
            return Alert.init(map: map)
            
        case .dateTimePicker:
            return DateTimePicker.init(map: map)
            
        case .placePicker:
            return PlacePicker.init(map: map)
            
        case .contactPicker:
            return ContactPicker.init(map: map)
            
        case .slider:
            return Slider.init(map: map)
            
        case .web:
            return Web.init(map: map)
            
        case .separator:
            return Separator.init(map: map)
            
        default:
            return nil
        }
    }
    
}

