//
//  SpiderImageCache.swift
//  Spider
//
//  Created by ooatuoo on 16/8/8.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation
import Kingfisher

final class SpiderImageCache {
    
    static let sharedInstance = SpiderImageCache()
    
    let cacheImageQueue = dispatch_queue_create("ImageCacheQueue", DISPATCH_QUEUE_SERIAL)
    
    func imageWith(info: PicInfo, completion: (key: String, image: UIImage?) -> Void) {
        
        let imageKey = info.id
        
        let options: KingfisherOptionsInfo = [
            .CallbackDispatchQueue(cacheImageQueue),
            .ScaleFactor(UIScreen.mainScreen().scale),
        ]
        
        Kingfisher.ImageCache.defaultCache.retrieveImageForKey(imageKey, options: options) { (image, cacheType) in
            
            if let image = image {
                
                dispatch_async(dispatch_get_main_queue(), { 
                    completion(key: imageKey, image: image)
                })
                
            } else {
                
                guard let imageURL = info.url else {
                    return
                }
                
                ImageDownloader.defaultDownloader.downloadImageWithURL(imageURL, options: options, progressBlock: { (receivedSize, totalSize) in
                }, completionHandler: { (image, error, imageURL, originalData) in
                    
                    if let image = image {
                        
                        Kingfisher.ImageCache.defaultCache.storeImage(image, originalData: originalData, forKey: imageKey, toDisk: true, completionHandler: {
                            
                            dispatch_async(dispatch_get_main_queue(), { 
                                completion(key: imageKey, image: image)
                            })
                        })
                        
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(key: imageKey, image: nil)
                        })
                    }
                })
            }
        }
    }
}