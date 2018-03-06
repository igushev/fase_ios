//
//  ServiceModels.swift
//  TestJson
//
//  Created by Alexey Bidnyk on 3/1/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import Foundation

struct Device: Codable {
    var deviceType: String
    var deviceToken: String
    
    enum CodingKeys: String, CodingKey {
        case deviceType = "device_type"
        case deviceToken = "device_token"
    }
    
    init(type: String, token: String) {
        self.deviceType = type
        self.deviceToken = token
    }
}

struct SessionInfo {
    var sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
    }
    
    init(sessionId: String) {
        self.sessionId = sessionId
    }
}

struct ScreenInfo {
    var screenId: String
    
    enum CodingKeys: String, CodingKey {
        case screenId = "screen_id"
    }
    
    init(screenId: String) {
        self.screenId = screenId
    }
}

// Explore what entity is it
struct ElementsUpdate {
    var valueArray: Array<String>
    var arrayArrayIds: Array<Array<String>>
    
    enum CodingKeys: String, CodingKey {
        case valueArray = "value_list"
        case arrayArrayIds = "id_list_list"
    }
}

struct ScreenUpdate {
    var elementsUpdate: ElementsUpdate
    var device: Device
    
    enum CodingKeys: String, CodingKey {
        case elementsUpdate = "elements_update"
        case device = "device"
    }
}

struct ElementCallback {
    var elementsUpdate: ElementsUpdate
    var arrayIds: Array<String>
    var method: String
    var locale: Locale
    var device: Device
    
    enum CodingKeys: String, CodingKey {
        case elementsUpdate = "elements_update"
        case arrayIds = "id_list"
        case method = "method"
        case locale = "locale"
        case device = "device"
    }
}

struct ScreenProg {
    var screen: Screen
    var recentDevice: Device
    var elementsUpdate: ElementsUpdate
    var sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case screen = "screen"
        case device = "device"
        case elementsUpdate = "elements_update"
        case sessionId = "session_id"
    }
}

struct Response {
    var elementsUpdate: ElementsUpdate
    var screenInfo: ScreenInfo
    var sessionInfo: SessionInfo
    var screen: Screen
    
    enum CodingKeys: String, CodingKey {
        case elementsUpdate = "elements_update"
        case screenInfo = "screen_info"
        case sessionInfo = "session_info"
        case screen = "screen"
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
