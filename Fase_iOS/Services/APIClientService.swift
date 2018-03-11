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
                                    completion(response, nil)                                    
                                } else {
                                    completion(nil, error)
                                }
        })
    }
}
