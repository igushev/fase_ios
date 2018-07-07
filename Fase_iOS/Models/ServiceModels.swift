//
//  ServiceModels.swift
//  TestJson
//
//  Copyright © 2018 Fase. All rights reserved.
//

import Foundation
import ObjectMapper

struct Device: Mappable {
    var deviceType: String?
    var deviceId: String?
    var deviceToken: String?
    var pixelDensity: CGFloat?
    
    init(deviceType: String, deviceId: String, deviceToken: String, pixelDensity: CGFloat) {
        self.deviceType = deviceType
        self.deviceId = deviceId
        self.deviceToken = deviceToken
        self.pixelDensity = pixelDensity
    }
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        deviceType <- map["device_type"]
        deviceId <- map["device_id"]
        deviceToken <- map["device_token"]
        pixelDensity <- map["pixel_density"]
    }
}

class SessionInfo: NSObject, Mappable, NSCoding {
    var sessionId: String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        sessionId <- map["session_id"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.sessionId = aDecoder.decodeObject(forKey: "sessionId") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sessionId, forKey: "sessionId")
    }
}

struct ScreenInfo: Mappable {
    var screenId: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        screenId <- map["screen_id"]
    }
}

class VersionInfo: NSObject, Mappable, NSCoding {
    var version: String?
    
    init(version: String) {
        self.version = version
    }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        version <- map["version"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.version = aDecoder.decodeObject(forKey: "version") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(version, forKey: "version")
    }
}

struct ElementsUpdate: Mappable {
    var valueArray: Array<String>?
    var arrayArrayIds: Array<Array<String>>?
    
    init?(map: Map) { }
    init() {
        valueArray = []
        arrayArrayIds = []
    }
    
    mutating func mapping(map: Map) {
        valueArray <- map["value_list"]
        arrayArrayIds <- map["id_list_list"]
    }
}

struct ScreenUpdate: Mappable {
    var elementsUpdate: ElementsUpdate?
    var device: Device?
    
    init?(map: Map) { }
    
    init?(elementsUpdate: ElementsUpdate?, device: Device) {
        self.elementsUpdate = elementsUpdate
        self.device = device
    }
    
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
    
    init?(elementsUpdate: ElementsUpdate?, elementIds: Array<String>?, method: String?, locale: Locale?, device: Device) {
        self.elementsUpdate = elementsUpdate
        self.arrayIds = elementIds
        self.method = method
        self.locale = locale
        self.device = device
    }
    
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
    var versionInfo: VersionInfo?
    var elementsUpdate: ElementsUpdate?
    var resources: Resources?
    var screenInfo: ScreenInfo?
    var sessionInfo: SessionInfo?
    var screen: Screen?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        versionInfo <- map["version_info"]
        elementsUpdate <- map["elements_update"]
        resources <- map["resources"]
        screenInfo <- map["screen_info"]
        sessionInfo <- map["session_info"]
        screen <- map["screen"]
    }
}

struct Method: Mappable {
    var method: String!
    
    init?(map: Map) {
        method = try! map.value("method")
    }
    
    mutating func mapping(map: Map) {
        method <- map["method"]
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

struct Resource: Mappable {
    var fileName: String
    
    init?(map: Map) {
        fileName = try! map.value("filename")
    }
    
    mutating func mapping(map: Map) {
        fileName <- map["filename"]
    }
}

struct Resources: Mappable {
    var resourceList: Array<Resource>
    var resetResources: Bool
    
    init?(map: Map) {
        resourceList = try! map.value("resource_list")
        resetResources = try! map.value("reset_resources")
    }
    
    mutating func mapping(map: Map) {
        resourceList <- map["resource_list"]
        resetResources <- map["reset_resources"]
    }
}

