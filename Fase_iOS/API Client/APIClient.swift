//
//  APIClient.swift
//  TestJsonIOS
//
//  Created by Alexey Bidnyk on 3/2/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import Foundation
import Alamofire

enum BaseURL: String {
    case helloworld = "http://hello-world-fase-env-test1.us-west-2.elasticbeanstalk.com/"
    case notes = "http://notes-fase-env-test1.us-west-2.elasticbeanstalk.com/"
}

enum URLPath: String {
    case sendInternalCommand = "sendinternalcommand"
    case sendServiceCommand = "sendservicecommand"
    case getService = "getservice"
    case getScreen = "getscreen"
    case screenUpdate = "screenupdate"
    case elementCallback = "elementcallback"
    case getResource = "getresource/filename/path:filename" // ??
}

typealias ResponseHandler = (Data?, Error?) -> Void
typealias JSON = AnyObject

class APIClient {
    static let shared = APIClient(with: URL(string: BaseURL.helloworld.rawValue)!)
    
    var baseURL: URL!
    
    // MARK: - API methods
    
    func sendInternalCommand(paramsData: Data, handler: @escaping ResponseHandler) {
        self.post(path: .sendInternalCommand, parametersData: paramsData, handler: handler)
    }
    
    func sendServiceCommand(paramsData: Data, handler: @escaping ResponseHandler) {
        self.post(path: .sendServiceCommand, parametersData: paramsData, handler: handler)
    }
    
    func getService(paramsData: Data, handler: @escaping ResponseHandler) {
        self.post(path: .getService, parametersData: paramsData, handler: handler)
    }
    
    func getScreen(paramsData: Data, handler: @escaping ResponseHandler) {
        self.post(path: .getScreen, parametersData: paramsData, handler: handler)
    }
    
    func screenUpdate(paramsData: Data, handler: @escaping ResponseHandler) {
        self.post(path: .screenUpdate, parametersData: paramsData, handler: handler)
    }
    
    func elementCallback(paramsData: Data, handler: @escaping ResponseHandler) {
        self.post(path: .elementCallback, parametersData: paramsData, handler: handler)
    }
    
    func getResource(handler: @escaping ResponseHandler) {
        self.get(path: .getResource, parameters: nil, completion: handler)
    }
    
    // MARK: - Private
    
    private init(with baseUrl: URL) {
        self.baseURL = baseUrl
    }
    
    private func get(path: URLPath, parameters: Dictionary<String, Any>?, completion: @escaping ResponseHandler) {
        let url = URL(string: self.baseURL.absoluteString + path.rawValue)!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
            .responseJSON { response in
                if let error = response.error {
                    completion(nil, error)
                }
                if let json = response.result.value {
                    print("JSON: \(json)") // serialized json response
                    completion(json as? Data, nil)
                }
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)") // original server data as UTF8 string
                }
        }
    }
    
    private func post(path: URLPath, parametersData: Data?, handler: @escaping ResponseHandler) {
        var request = URLRequest(url: URL(string: self.baseURL.absoluteString + path.rawValue)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = parametersData
        
        Alamofire.request(request).responseJSON { (response) in
            if let error = response.error {
                handler(nil, error)
                return
            }
            
            if let json = response.result.value as JSON? {
                print("JSON: \(json)") // serialized json response
                let jsonData = Data.jsonToData(json: json)
                handler(jsonData, nil)
            }                        
            
        }
    }
    
}

