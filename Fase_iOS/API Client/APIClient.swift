//
//  APIClient.swift
//  TestJsonIOS
//
//  Created by Alexey Bidnyk on 3/2/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import Foundation
import Alamofire

enum BaseURL: String {
    case helloWorld = "http://hello-world-fase-env-test1.us-west-2.elasticbeanstalk.com/"
    case notes = "http://notes-fase-env-test1.us-west-2.elasticbeanstalk.com/"
    case karmaCounter = "http://karmacounter-fase-env-test1.us-west-2.elasticbeanstalk.com/"
    case test = "http://fase-test-fase-env-test1.us-west-2.elasticbeanstalk.com/"
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
    //    static let shared = APIClient()
    static let shared = APIClient(with: URL(string: BaseURL.karmaCounter.rawValue)!)
    
    var baseURL: URL!
    var sessionInfo: SessionInfo? {
        get {
            if let data = UserDefaults.standard.value(forKey: "sessionInfo") as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? SessionInfo
            }
            return nil
        }
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue as Any)
            UserDefaults.standard.setValue(data, forKey: "sessionInfo")
        }
    }
    var versionInfo: VersionInfo? {
        get {
            if let data = UserDefaults.standard.value(forKey: "versionInfo") as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? VersionInfo
            }
            return nil
        }
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue as Any)
            UserDefaults.standard.setValue(data, forKey: "versionInfo")
        }
    }
    var lastCalledApiFunc: ApiCall?
    
    
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
    
    func getScreen(paramsData: Data, handler: @escaping ResponseHandler) {
        if let sessionId = self.sessionInfo?.sessionId, let version = self.versionInfo?.version {
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "session-id": sessionId,
                "version": version
            ]
            self.post(headers: headers, path: .getScreen, parametersData: paramsData, handler: handler)
        }
    }
    
    func getResource(with name: String, handler: @escaping ResponseHandler) {
        let urlString = URLPath.getResource.rawValue.appending(name)
        self.download(from: urlString, handler: handler)
    }
    
    func screenUpdate(screenId: String, paramsData: Data, handler: @escaping ResponseHandler) {
        if let sessionId = self.sessionInfo?.sessionId, let version = self.versionInfo?.version {
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "session-id": sessionId,
                "screen-id": screenId,
                "version": version
            ]
            self.post(headers: headers, path: .screenUpdate, parametersData: paramsData, handler: handler)
        }
    }
    
    func elementCallback(screenId: String, paramsData: Data, handler: @escaping ResponseHandler) {
        if let sessionId = self.sessionInfo?.sessionId, let version = self.versionInfo?.version {
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "session-id": sessionId,
                "screen-id": screenId,
                "version": version
            ]
            self.post(headers: headers, path: .elementCallback, parametersData: paramsData, handler: handler)
        }
    }
    
    
    // MARK: - Private
    
    init(with url: URL) {
        self.baseURL = url
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
                    #if DEBUG
                        print("JSON: \(json)") // serialized json response
                    #endif
                    
                    completion(json as? Data, nil)
                }
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    #if DEBUG
                        print("Data: \(utf8Text)") // original server data as UTF8 string
                    #endif
                }
        }
    }
    
    private func post(headers: Dictionary<String, String> = ["Content-Type": "application/json"], path: URLPath, parametersData: Data?, handler: @escaping ResponseHandler) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if path == .getService || path == .getScreen || path == .elementCallback {
            self.lastCalledApiFunc = ApiCall(headers: headers, path: path, parametersData: parametersData, handler: handler)
        }
        
        var request = URLRequest(url: URL(string: self.baseURL.absoluteString + path.rawValue)!)
        request.httpMethod = HTTPMethod.post.rawValue
        headers.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = parametersData
        
        Alamofire.request(request).responseJSON { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if (response.error != nil) || response.response?.statusCode != 200 {
                var error = response.error
                if let code = response.response?.statusCode {
                    error = NSError(domain: "Server.error.domain", code: code, userInfo: ["localizedDescription": "Error"])
                }
                handler(nil, error)
                return
            }
            
            if let json = response.result.value as JSON? {
                #if DEBUG
                    print("JSON: \(json)") // serialized json response
                #endif
                
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

struct ApiCall {
    var screenId: String?
    var headers: Dictionary<String, String>
    var path: URLPath
    var parametersData: Data?
    var handler: ResponseHandler
    
    init(headers: Dictionary<String, String>, path: URLPath, parametersData: Data?, handler: @escaping ResponseHandler) {
        self.headers = headers
        self.path = path
        self.parametersData = parametersData
        self.handler = handler
    }
}

