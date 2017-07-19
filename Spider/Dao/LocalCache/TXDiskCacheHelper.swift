//
//  TXDiskCacheHelper.swift
//  Spider
//
//  Created by 童星 on 16/7/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  本地缓存

import UIKit
typealias $ = TXDiskCacheHelper

public struct TXDiskCacheHelper {
    
    /**
     本地缓存对象
     */
    static func saveObj(_ key:String,value:AnyObject?,completeHandler:(()->())? = nil){
        
        TXDiskCache.sharedCacheObj.stroe(key, value: value, image: nil, data: nil, completeHandler: completeHandler)
        
    }
    
    /**
     本地缓存图片
     */
    static func saveImg(_ key:String,image:UIImage?,completeHandler:(()->())? = nil){
        
        TXDiskCache.sharedCacheImage.stroe(key, value: nil, image: image, data: nil, completeHandler: completeHandler)
        
    }
    
    /**
     本地缓存音频 或者其他 NSData类型
     */
    static func saveVoc(_ key:String,data:Data?,completeHandler:(()->())? = nil){
        
        TXDiskCache.sharedCacheVoice.stroe(key, value: nil, image: nil, data: data, completeHandler: completeHandler)
        
    }
    
    /**
     获得本地缓存的对象
     */
    static func getObj(_ key:String,compelete:@escaping ((_ obj:AnyObject?)->())){
        
        TXDiskCache.sharedCacheObj.retrieve(key, objectGetHandler: compelete, imageGetHandler: nil, voiceGetHandler: nil)
        
    }
    
    /**
     获得本地缓存的图像
     */
    static func getImg(_ key:String,compelete:@escaping ((_ image:UIImage?)->())){
        
        TXDiskCache.sharedCacheImage.retrieve(key, objectGetHandler: nil, imageGetHandler: compelete, voiceGetHandler: nil)
        
    }
    
    /**
     获得本地缓存的音频数据文件
     */
    static func getVoc(_ key:String,compelete:@escaping ((_ data:Data?)->())){
        
        TXDiskCache.sharedCacheVoice.retrieve(key, objectGetHandler: nil, imageGetHandler: nil, voiceGetHandler: compelete)
        
    }
    
}
