//
//  NSFileManager+Spider.swift
//  Spider
//
//  Created by ooatuoo on 16/8/2.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation
import Kingfisher

public enum FileExtension: String {
    case JPEG = "jpg"
    case MP4 = "mp4"
    case M4A = "m4a"
    
    public var mimeType: String {
        switch self {
        case .JPEG:
            return "image/jpeg"
        case .MP4:
            return "video/mp4"
        case .M4A:
            return "audio/m4a"
        }
    }
}

extension FileManager {
    
    class func spiderImageURLWithID(_ id: String) -> URL? {
        if let urlString = AppUtility.instance?.imageFilePath(),
           let imageCacheURL = URL(string: urlString) {
            return imageCacheURL.appendingPathComponent("\(id).\(FileExtension.JPEG.rawValue)")
        }
        
        return nil
    }
    
    class func savePic(_ imageData: Data) -> String? {
        let id = UUID().uuidString
        if let imageURL = spiderImageURLWithID(id),
           let imagePath = imageURL.path {
            if `default`.createFile(atPath: imagePath, contents: imageData, attributes: nil) {
                return id
            }
        }
        
        return nil
    }
    
    public class func getPic(withID id: String) -> UIImage? {
        if let imageURL = spiderImageURLWithID(id),
            let imagePath = imageURL.path {
            return UIImage(contentsOfFile: imagePath)
        }
        
        return nil
    }
    
    public class func diskExistAudio(withID id: String) -> URL? {
        guard let url = URL(string: APP_UTILITY.voiceFilePath()) else { return nil }
        
        let audioURL = url.appendingPathComponent("\(id).\(FileExtension.M4A.rawValue)")
        
        if `default`.fileExists(atPath: audioURL!.path!) {
            return audioURL
        } else {
            return nil
        }
    }
}

extension UIImage {
    public func saveToCache() -> String? {
        if let imageData = UIImageJPEGRepresentation(self, 0.0),
           let id = FileManager.savePic(imageData) {
            return id
        }
        
        return nil
    }
    
    public func saveToDisk(withid id: String) {
        if let imageData = UIImageJPEGRepresentation(self, 1.0) {
            Kingfisher.ImageCache.defaultCache.storeImage(self, originalData: imageData, forKey: id, toDisk: true, completionHandler: { 
                
            })
        }
    }
}
