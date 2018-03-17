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
        var callbackData = Data()
        
        let jsonData = Data.jsonToData(json: screenUpdate.toJSON() as JSON)
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
    
    //    static func getResource(_ resource: Resource, handler: @escaping ResponseHandler) {
    //        let apiClient = APIClient.shared
    //        apiClient.getResource(with: resource.fileName, handler: handler)
    //    }
}

