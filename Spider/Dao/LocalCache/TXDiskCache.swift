//
//  TXDiskCache.swift
//  Spider
//
//  Created by 童星 on 16/7/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
// 本地缓存

import UIKit

private let page = TXDiskCache(type:.Object)
private let image = TXDiskCache(type:.Image)
private let voice = TXDiskCache(type:.Voice)

//会在cache下创建目录管理
enum CacheFor:String{
    case Object = "Object"     //页面对象缓存 (缓存的对象)
    case Image = "Image"  //图片缓存 (缓存NSData)
    case Voice = "Voice"  //语音缓存 (缓存NSData)
}

public class TXDiskCache {
    
    private let defaultCacheName = "_default"
    private let cachePrex = "com.zz.disk.cache."
    private let ioQueueName = "com.disk.cache.ioQueue."
    
    private var fileManager: NSFileManager!
    private let ioQueue: dispatch_queue_t
    var diskCachePath:String
    // 针对Page
    public class var sharedCacheObj: TXDiskCache {
        return page
    }
    
    // 针对Image
    public class var sharedCacheImage: TXDiskCache {
        return image
    }
    
    // 针对Voice
    public class var sharedCacheVoice: TXDiskCache {
        return voice
    }
    
    private var storeType:CacheFor
    
    init(type:CacheFor) {
        self.storeType = type
        
        switch type {
        case .Image:
            diskCachePath = (APP_UTILITY.userDocumentPath()?.stringByAppendingPathComponent("image"))!
        case .Voice:
            diskCachePath = (APP_UTILITY.userDocumentPath()?.stringByAppendingPathComponent("voice"))!
        case .Object:
            diskCachePath = (APP_UTILITY.userDocumentPath()?.stringByAppendingPathComponent("object"))!        }
        
        
        ioQueue = dispatch_queue_create(ioQueueName+type.rawValue, DISPATCH_QUEUE_SERIAL)

        dispatch_sync(ioQueue) { () -> Void in
            self.fileManager = NSFileManager()
            //创建子目录对应的文件夹
            do {
                try self.fileManager.createDirectoryAtPath(self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
            
        }
    }
    
    
    /**
     存储
     
     - parameter key:             键
     - parameter value:           值
     - parameter image:           图像
     - parameter data:            data
     - parameter completeHandler: 完成回调
     */
    public func stroe(key:String,value:AnyObject? = nil,image:UIImage?,data:NSData?,completeHandler:(()->())? = nil){
        let path = self.cachePathForKey(key)
        switch storeType{
        case .Object:
            //            print("save Object ")
            self.stroeObject(key, value: value,path:path,completeHandler:completeHandler)
        case .Image:
            print("save Image ")
            if let image = image{
                self.storeImage(image, forKey: key, path: path, completeHandler: completeHandler)
            }
        case .Voice:
            print("save Voice ")
            self.storeVoice(data, forKey: key, path: path, completeHandler: completeHandler)
        }
    }
    
    /**
     对象存储 归档操作后写入文件
     
     - parameter key:   键
     - parameter value: 值
     - parameter path: 路径
     - parameter completeHandler: 完成后回调
     */
    private func stroeObject(key:String,value:AnyObject?,path:String,completeHandler:(()->())? = nil){
        dispatch_async(ioQueue){
            let data = NSMutableData()  //声明一个可变的Data对象
            //创建归档对象
            let keyArchiver = NSKeyedArchiver(forWritingWithMutableData: data)
            //开始归档
            keyArchiver.encodeObject(value, forKey: key.tx_MD5())  //对key进行MD5加密
            //完成归档
            keyArchiver.finishEncoding() //归档完毕
            
            do {
                //写入文件
                try data.writeToFile(path, options: NSDataWritingOptions.DataWritingAtomic)  //存储
                //完成回调
                completeHandler?()
            }catch let err{
                print("err:\(err)")
            }
        }
    }
    
    /**
     图像存储
     
     - parameter image:           image
     - parameter key:             键
     - parameter path:            路径
     - parameter completeHandler: 完成回调
     */
    private func storeImage(image:UIImage,forKey key:String,path:String,completeHandler:(()->())? = nil){
        dispatch_async(ioQueue) {
            let data = UIImagePNGRepresentation(image.zz_normalizedImage())
            if let data = data {
                self.fileManager.createFileAtPath(path, contents: data, attributes: nil)
            }
        }
    }
    
    /**
     存储声音
     
     - parameter data:            data
     - parameter key:             键
     - parameter path:            路径
     - parameter completeHandler: 完成回调
     */
    private func storeVoice(data:NSData?,forKey key:String,path:String,completeHandler:(()->())? = nil){
        dispatch_async(ioQueue) {
            if let data = data {
                self.fileManager.createFileAtPath(path, contents: data, attributes: nil)
            }
        }
    }
    
    /**
     获取数据的方法
     
     - parameter key:              键
     - parameter objectGetHandler: 对象完成回调
     - parameter imageGetHandler:  图像完成回调
     - parameter voiceGetHandler:  音频完成回调
     */
    public func retrieve(key:String,objectGetHandler:((obj:AnyObject?)->())? = nil,imageGetHandler:((image:UIImage?)->())? = nil,voiceGetHandler:((data:NSData?)->())?){
        let path = self.cachePathForKey(key)
        switch storeType{
        case .Object:
            self.retrieveObject(key.tx_MD5(), path: path, objectGetHandler: objectGetHandler)
        case .Image:
            self.retrieveImage(path,imageGetHandler:imageGetHandler)
        case .Voice:
            self.retrieveVoice(path, voiceGetHandler: voiceGetHandler)
        }
    }
    
    
    /**
     获取文件归档对象
     
     - parameter key:              键
     - parameter path:             路径
     - parameter objectGetHandler: 获得后回调闭包
     */
    private func retrieveObject(key:String,path:String,objectGetHandler:((obj:AnyObject?)->())?){
        //反归档 获取
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if self.fileManager.fileExistsAtPath(path){
                let mdata = NSMutableData(contentsOfFile:path)  //声明可变Data
                let unArchiver = NSKeyedUnarchiver(forReadingWithData: mdata!) //反归档对象
                let obj = unArchiver.decodeObjectForKey(key)    //反归档
                objectGetHandler?(obj:obj)  //完成回调
            }
            objectGetHandler?(obj:nil)
        }
    }
    
    /**
     获取图片
     
     - parameter path:            路径
     - parameter imageGetHandler: 获得后回调闭包
     */
    private func retrieveImage(path:String,imageGetHandler:((image:UIImage?)->())?){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if let data = NSData(contentsOfFile: path){
                if let image = UIImage(data: data){
                    imageGetHandler?(image: image)
                }
            }
            imageGetHandler?(image: nil)
        }
    }
    
    /**
     获取音频数据
     
     - parameter path:            路径
     - parameter voiceGetHandler: 获得后回调闭包
     */
    private func retrieveVoice(path:String,voiceGetHandler:((data:NSData?)->())?){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if let data = NSData(contentsOfFile: path){
                voiceGetHandler?(data: data)
            }
            voiceGetHandler?(data: nil)
        }
    }
}

extension TXDiskCache{
    func cachePathForKey(key: String) -> String {
        let fileName = cacheFileNameForKey(key)     //对name进行MD5加密
        return (diskCachePath as NSString).stringByAppendingPathComponent(fileName)
    }
    
    func cacheFileNameForKey(key: String) -> String {
        return key.tx_MD5()
    }
}


extension UIImage {
    
    func zz_normalizedImage() -> UIImage {
        if imageOrientation == .Up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        drawInRect(CGRect(origin: CGPointZero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage!;
    }
}

