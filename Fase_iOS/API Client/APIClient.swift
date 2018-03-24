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
    case getResource = "getresource/filename/"
}

typealias ResponseHandler = (Data?, Error?) -> Void
typealias ResourceHandler = (Data?, Error?) -> Void
typealias JSON = AnyObject

class APIClient {
    static let shared = APIClient(with: URL(string: BaseURL.notes.rawValue)!)
    
    var baseURL: URL!
    var sessionInfo: SessionInfo!
    
    
    // MARK: - API methods
    
    //    func sendInternalCommand(paramsData: Data, handler: @escaping ResponseHandler) {
    //        self.post(path: .sendInternalCommand, parametersData: paramsData, handler: handler)
    //    }
    //
    //    func sendServiceCommand(paramsData: Data, handler: @escaping ResponseHandler) {
    //        self.post(path: .sendServiceCommand, parametersData: paramsData, handler: handler)
    //    }
    
    func getService(paramsData: Data, handler: @escaping ResponseHandler) {
        self.post(path: .getService, parametersData: paramsData, handler: handler)
    }
    
    //    func getScreen(paramsData: Data, handler: @escaping ResponseHandler) {
    //        self.post(path: .getScreen, parametersData: paramsData, handler: handler)
    //    }
    //
    //    func screenUpdate(paramsData: Data, handler: @escaping ResponseHandler) {
    //        self.post(path: .screenUpdate, parametersData: paramsData, handler: handler)
    //    }
    
    func elementCallback(screenId: String, paramsData: Data, handler: @escaping ResponseHandler) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "session-id": self.sessionInfo.sessionId!,
            "screen-id": screenId
        ]
        self.post(headers: headers, path: .elementCallback, parametersData: paramsData, handler: handler)
    }
    
    func getResource(with name: String, handler: @escaping ResponseHandler) {
        let urlString = URLPath.getResource.rawValue.appending(name)
        self.download(from: urlString, handler: handler)
    }
    
    // MARK: - Private
    
    private init(with baseUrl: URL) {
        self.baseURL = baseUrl
    }
    
    private func get(path: String, parameters: Dictionary<String, Any>?, completion: @escaping ResponseHandler) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = URL(string: self.baseURL.absoluteString + path)!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
            .responseJSON { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
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
    
    private func post(headers: Dictionary<String, String> = ["Content-Type": "application/json"], path: URLPath, parametersData: Data?, handler: @escaping ResponseHandler) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var request = URLRequest(url: URL(string: self.baseURL.absoluteString + path.rawValue)!)
        request.httpMethod = HTTPMethod.post.rawValue
        headers.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = parametersData
        
        Alamofire.request(request).responseJSON { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
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
    
    private func download(from path: String, handler: @escaping ResponseHandler) {
        Alamofire.download(path).responseData { (response) in
            if let data = response.result.value {
                handler(data, nil)
            }
        }
    }
    
}

