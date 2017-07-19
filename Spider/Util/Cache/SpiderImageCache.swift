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
    
    let cacheImageQueue = DispatchQueue(label: "ImageCacheQueue", attributes: [])
    
    func imageWith(_ info: PicInfo, completion: @escaping (_ key: String, _ image: UIImage?) -> Void) {
        
        let imageKey = info.id
        
        let options: KingfisherOptionsInfo = [
            .callbackDispatchQueue(cacheImageQueue),
            .scaleFactor(UIScreen.main.scale),
        ]
        ImageCache.default.retrieveImage(forKey: imageKey, options: options) { (image, cacheType) in
            
            if let image = image {
                
                DispatchQueue.main.async(execute: { 
                    completion(imageKey, image)
                })
                
            }
            else {
                
                guard let imageURL = info.url else {
                    return
                }
                ImageDownloader.default.downloadImage(with: imageURL, retrieveImageTask: nil, options: options, progressBlock: { (receivedSize, totalSize) in
                }, completionHandler: { (image, error, imageURL, originalData) in
                    
                    if let image = image {
                        ImageCache.default.store(image, original: originalData, forKey: imageKey, processorIdentifier: imageKey, cacheSerializer: image as! CacheSerializer, toDisk: true, completionHandler: {
                            
                            DispatchQueue.main.async(execute: { 
                                completion(imageKey, image)
                            })
                        })
                        
                    } else {
                        
                        DispatchQueue.main.async(execute: {
                            completion(imageKey, nil)
                        })
                    }
                })
            }
        }
    }
}
