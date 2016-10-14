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

extension NSFileManager {
    
    class func spiderImageURLWithID(id: String) -> NSURL? {
        if let urlString = AppUtility.instance?.imageFilePath(),
           let imageCacheURL = NSURL(string: urlString) {
            return imageCacheURL.URLByAppendingPathComponent("\(id).\(FileExtension.JPEG.rawValue)")
        }
        
        return nil
    }
    
    class func savePic(imageData: NSData) -> String? {
        let id = NSUUID().UUIDString
        if let imageURL = spiderImageURLWithID(id),
           let imagePath = imageURL.path {
            if defaultManager().createFileAtPath(imagePath, contents: imageData, attributes: nil) {
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
    
    public class func diskExistAudio(withID id: String) -> NSURL? {
        guard let url = NSURL(string: APP_UTILITY.voiceFilePath()) else { return nil }
        
        let audioURL = url.URLByAppendingPathComponent("\(id).\(FileExtension.M4A.rawValue)")
        
        if defaultManager().fileExistsAtPath(audioURL!.path!) {
            return audioURL
        } else {
            return nil
        }
    }
}

extension UIImage {
    public func saveToCache() -> String? {
        if let imageData = UIImageJPEGRepresentation(self, 0.0),
           let id = NSFileManager.savePic(imageData) {
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
