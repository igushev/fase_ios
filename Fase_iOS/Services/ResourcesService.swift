//
//  ResourcesService.swift
//  Fase_iOS
//
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit

class ResourcesService {
    
    static func resetResources() {
        let fileManager = FileManager.default
        if let folderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            guard let items = try? fileManager.contentsOfDirectory(atPath: folderPath) else { return }
            
            for item in items {
                let completePath = folderPath.appending("/").appending(item)
                try? FileManager.default.removeItem(atPath: completePath)
            }
        }
    }
    
    static func saveResources(_ resources: Resources) {
        resources.resourceList.forEach { (resource) in
            let resourceName = resource.fileName.components(separatedBy: "/").last!
            
            if let _ = getResource(by: resourceName) {
                return
            }
            
            let stringUrl = APIClient.shared.baseURL.absoluteString.appending(URLPath.getResource.rawValue).appending(resource.fileName)
            let url = URL(string: stringUrl)!
            
            if let data = try? Data(contentsOf: url) {
                self.saveResource(data, name: resourceName)
            }
        }
    }
    
    static func getResource(by name: String) -> Data? {
        let resourceName = name.components(separatedBy: "/").last!
        let fileManager = FileManager.default
        let fileName = self.getDocumentsDirectory().appendingPathComponent(resourceName)
        if fileManager.fileExists(atPath: fileName.path) {
            return try? Data(contentsOf: URL(fileURLWithPath: fileName.path))
        }
        return nil
    }
    
    // MARK: - Private
    
    static private func saveResource(_ data: Data?, name: String) {
        if let resourceData = data {
            let fileName = self.getDocumentsDirectory().appendingPathComponent(name)
            try? resourceData.write(to: fileName)
        }
    }
    
    static private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

