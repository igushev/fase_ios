//
//  ServiceModels.swift
//  TestJson
//
//  Created by Alexey Bidnyk on 3/1/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import Foundation
import ObjectMapper

struct Device: Mappable {
    var deviceType: String?
    var deviceToken: String?
    
    init(type: String, token: String) {
        self.deviceType = type
        self.deviceToken = token
    }
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        deviceType <- map["device_type"]
        deviceToken <- map["device_token"]
    }
}

struct SessionInfo: Mappable {
    var sessionId: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        sessionId <- map["session_id"]
    }
}

struct ScreenInfo: Mappable {
    var screenId: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        screenId <- map["screen_id"]
    }
}

struct ElementsUpdate: Mappable {
    var valueArray: Array<String>?
    var arrayArrayIds: Array<Array<String>>?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        valueArray <- map["value_list"]
        arrayArrayIds <- map["id_list_list"]
    }
}

struct ScreenUpdate: Mappable {
    var elementsUpdate: ElementsUpdate?
    var device: Device?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        elementsUpdate <- map["elements_update"]
        device <- map["device"]
    }
}

struct ElementCallback: Mappable {
    var elementsUpdate: ElementsUpdate?
    var arrayIds: Array<String>?
    var method: String?
    var locale: Locale?
    var device: Device?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        elementsUpdate <- map["elements_update"]
        arrayIds <- map["id_list"]
        method <- map["method"]
        locale <- map["locale"]
        device <- map["device"]
    }
}

struct ScreenProg: Mappable {
    var screen: Screen?
    var recentDevice: Device?
    var elementsUpdate: ElementsUpdate?
    var sessionId: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        screen <- map["screen"]
        recentDevice <- map["recent_device"]
        elementsUpdate <- map["elements_update"]
        sessionId <- map["session_id"]
    }
}

struct Response: Mappable {
    var elementsUpdate: ElementsUpdate?
    //    var resources: Resources?
    var screenInfo: ScreenInfo?
    var sessionInfo: SessionInfo?
    var screen: Screen?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        elementsUpdate <- map["elements_update"]
        //        resources <- map["resources"]
        screenInfo <- map["screen_info"]
        sessionInfo <- map["session_info"]
        screen <- map["screen"]
    }
}

struct Command {
    var command: String
}

protocol StatusProtocol {
    var message: String { get set }
}

struct Status: StatusProtocol {
    var message: String
}

struct BadRequest: StatusProtocol {
    var message: String
    var code: Int
}

struct Resource {
    var fileName: String
}

struct Resources {
    var resourceArray: Array<Resource>
}

