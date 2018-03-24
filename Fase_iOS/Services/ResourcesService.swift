//
//  ResourcesService.swift
//  Fase_iOS
//
//  Created by Alexey Bidnyk on 3/16/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import UIKit

class ResourcesService {
    static func saveResources(_ resources: Resources) {
        resources.resourceList.forEach { (resource) in
            let imageName = resource.fileName.components(separatedBy: "/").last!
            let stringUrl = APIClient.shared.baseURL.absoluteString.appending(URLPath.getResource.rawValue).appending(resource.fileName)
            let url = URL(string: stringUrl)!
            
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                self.saveImage(image, name: imageName)
            }
        }
    }
    
    static func getImage(by name: String) -> UIImage? {
        let imageName = name.components(separatedBy: "/").last!
        let fileManager = FileManager.default
        let fileName = self.getDocumentsDirectory().appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: fileName.path) {
            return UIImage(contentsOfFile: fileName.path)
        }
        return nil
    }
    
    // MARK: - Private
    
    static private func saveImage(_ image: UIImage, name: String) {
        if let data = UIImagePNGRepresentation(image) {
            let fileName = self.getDocumentsDirectory().appendingPathComponent(name)
            try? data.write(to: fileName)
        }
    }
    
    static private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

