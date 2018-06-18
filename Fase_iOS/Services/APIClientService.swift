//
//  APIClientService.swift
//  TestJsonIOS
//
//  Created by Alexey Bidnyk on 3/6/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import Foundation

typealias CompletionBlock = (Response?, Error?) -> Void

class APIClientService {
    
    static var isSessionInfoExist: Bool {
        get {
            return (APIClient.shared.sessionInfo != nil) ? true : false
        }
    }
    
    static func getServices(for device: Device, completion: @escaping CompletionBlock) {
        let apiClient = APIClient.shared
        var deviceData = Data()
        
        let jsonData = Data.jsonToData(json: device.toJSON() as JSON)
        if let data = jsonData {
            deviceData = data
        }
        
        apiClient.getService(paramsData: deviceData,
                             handler: { (json, error) in
                                if let json = json?.toString() {
                                    let response = Response(JSONString: json)
                                    apiClient.sessionInfo = response?.sessionInfo
                                    
                                    completion(response, nil)
                                } else {
                                    completion(nil, error)
                                }
        })
    }
    
    static func getScreen(for device: Device, completion: @escaping CompletionBlock) {
        let apiClient = APIClient.shared
        var deviceData = Data()
        
        let jsonData = Data.jsonToData(json: device.toJSON() as JSON)
        if let data = jsonData {
            deviceData = data
        }
        
        apiClient.getScreen(paramsData: deviceData,
                            handler: { (json, error) in
                                if let json = json?.toString() {
                                    let response = Response(JSONString: json)
                                    apiClient.sessionInfo = response?.sessionInfo
                                    
                                    completion(response, nil)
                                } else {
                                    completion(nil, error)
                                }
        })
    }
    
    static func elementCallback(for elementCallback: ElementCallback, screenId: String, completion: @escaping CompletionBlock) {
        let apiClient = APIClient.shared
        var callbackData = Data()
        
        let jsonData = Data.jsonToData(json: elementCallback.toJSON() as JSON)
        if let data = jsonData {
            callbackData = data
        }
        
        apiClient.elementCallback(screenId: screenId, paramsData: callbackData, handler: { (json, error) in
            if let json = json?.toString() {
                let response = Response(JSONString: json)
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        })
    }
    
    static func screenUpdate(for screenUpdate: ScreenUpdate, screenId: String, completion: @escaping CompletionBlock) {
        let apiClient = APIClient.shared
        var updateData = Data()
        
        let jsonData = Data.jsonToData(json: screenUpdate.toJSON() as JSON)
        if let data = jsonData {
            updateData = data
        }
        
        apiClient.screenUpdate(screenId: screenId, paramsData: updateData) { (json, error) in
            if let json = json?.toString() {
                let response = Response(JSONString: json)
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
        
    }
    
    static func saveNewSessionInfo(sessionInfo: SessionInfo) {
        APIClient.shared.sessionInfo = sessionInfo
    }
    
    static func saveNewVersionInfo(versionInfo: VersionInfo) {
        APIClient.shared.versionInfo = versionInfo
    }
    
    // MARK: -
    
    static func performRetryApiCall(apiCall: ApiCall) {
        let apiClient = APIClient.shared
        
        switch apiCall.path {
        case .getService:
            if let paramsData = apiCall.parametersData {
                apiClient.getService(paramsData: paramsData, handler: apiCall.handler)
            }
            break
            
        case .getScreen:
            if let paramsData = apiCall.parametersData {
                apiClient.getScreen(paramsData: paramsData, handler: apiCall.handler)
            }
            break
            
        case .elementCallback:
            if let screenId = apiCall.headers["screen-id"], let paramsData = apiCall.parametersData {
                apiClient.elementCallback(screenId: screenId, paramsData: paramsData, handler: apiCall.handler)
            }
            break
            
        default:
            break
        }
    }
    
}

