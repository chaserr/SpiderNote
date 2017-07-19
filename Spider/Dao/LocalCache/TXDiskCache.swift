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

open class TXDiskCache {
    
    fileprivate let defaultCacheName = "_default"
    fileprivate let cachePrex = "com.zz.disk.cache."
    fileprivate let ioQueueName = "com.disk.cache.ioQueue."
    
    fileprivate var fileManager: FileManager!
    fileprivate let ioQueue: DispatchQueue
    var diskCachePath:String
    // 针对Page
    open class var sharedCacheObj: TXDiskCache {
        return page
    }
    
    // 针对Image
    open class var sharedCacheImage: TXDiskCache {
        return image
    }
    
    // 针对Voice
    open class var sharedCacheVoice: TXDiskCache {
        return voice
    }
    
    fileprivate var storeType:CacheFor
    
    init(type:CacheFor) {
        self.storeType = type
        
        switch type {
        case .Image:
            diskCachePath = (APP_UTILITY.userDocumentPath()?.stringByAppendingPathComponent("image"))!
        case .Voice:
            diskCachePath = (APP_UTILITY.userDocumentPath()?.stringByAppendingPathComponent("voice"))!
        case .Object:
            diskCachePath = (APP_UTILITY.userDocumentPath()?.stringByAppendingPathComponent("object"))!        }
        
        
        ioQueue = DispatchQueue(label: ioQueueName+type.rawValue, attributes: [])

        ioQueue.sync { () -> Void in
            self.fileManager = FileManager()
            //创建子目录对应的文件夹
            do {
                try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
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
    open func stroe(_ key:String,value:AnyObject? = nil,image:UIImage?,data:Data?,completeHandler:(()->())? = nil){
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
    fileprivate func stroeObject(_ key:String,value:AnyObject?,path:String,completeHandler:(()->())? = nil){
        ioQueue.async{
            let data = NSMutableData()  //声明一个可变的Data对象
            //创建归档对象
            let keyArchiver = NSKeyedArchiver(forWritingWith: data)
            //开始归档
            keyArchiver.encode(value, forKey: key.md5())  //对key进行MD5加密
            //完成归档
            keyArchiver.finishEncoding() //归档完毕
            
            do {
                //写入文件
                try data.write(toFile: path, options: NSData.WritingOptions.atomic)  //存储
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
    fileprivate func storeImage(_ image:UIImage,forKey key:String,path:String,completeHandler:(()->())? = nil){
        ioQueue.async {
            let data = UIImagePNGRepresentation(image.zz_normalizedImage())
            if let data = data {
                self.fileManager.createFile(atPath: path, contents: data, attributes: nil)
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
    fileprivate func storeVoice(_ data:Data?,forKey key:String,path:String,completeHandler:(()->())? = nil){
        ioQueue.async {
            if let data = data {
                self.fileManager.createFile(atPath: path, contents: data, attributes: nil)
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
    open func retrieve(_ key:String,objectGetHandler:((_ obj:AnyObject?)->())? = nil,imageGetHandler:((_ image:UIImage?)->())? = nil,voiceGetHandler:((_ data:Data?)->())?){
        let path = self.cachePathForKey(key)
        switch storeType{
        case .Object:
            self.retrieveObject(key.md5(), path: path, objectGetHandler: objectGetHandler)
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
    fileprivate func retrieveObject(_ key:String,path:String,objectGetHandler:((_ obj:AnyObject?)->())?){
        //反归档 获取
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            if self.fileManager.fileExists(atPath: path){
                let mdata = NSMutableData(contentsOfFile:path)  //声明可变Data
                let unArchiver = NSKeyedUnarchiver(forReadingWith: mdata! as Data) //反归档对象
                let obj = unArchiver.decodeObject(forKey: key)    //反归档
                objectGetHandler?(obj as AnyObject)  //完成回调
            }
            objectGetHandler?(nil)
        }
    }
    
    /**
     获取图片
     
     - parameter path:            路径
     - parameter imageGetHandler: 获得后回调闭包
     */
    fileprivate func retrieveImage(_ path:String,imageGetHandler:((_ image:UIImage?)->())?){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                if let image = UIImage(data: data){
                    imageGetHandler?(image)
                }
            }
            imageGetHandler?(nil)
        }
    }
    
    /**
     获取音频数据
     
     - parameter path:            路径
     - parameter voiceGetHandler: 获得后回调闭包
     */
    fileprivate func retrieveVoice(_ path:String,voiceGetHandler:((_ data:Data?)->())?){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                voiceGetHandler?(data)
            }
            voiceGetHandler?(nil)
        }
    }
}

extension TXDiskCache{
    func cachePathForKey(_ key: String) -> String {
        let fileName = cacheFileNameForKey(key)     //对name进行MD5加密
        return (diskCachePath as NSString).appendingPathComponent(fileName)
    }
    
    func cacheFileNameForKey(_ key: String) -> String {
        return key.md5()
    }
}


extension UIImage {
    
    func zz_normalizedImage() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage!;
    }
}

