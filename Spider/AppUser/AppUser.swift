//
//  AppUser.swift
//  Spider
//
//  Created by 童星 on 16/7/21.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
let APP_USER = AppUser.getInstance()
let AO_CLIENT_KEY = "ao_user_info.plist"

class AppUser: NSObject {

    var account:String!
    var password:String!
    var token:String!
    var userID:String!
    var nickName:String!
    /* 自动同步，0关闭， 1开启**/
    var autoSync:Int!
    /* 仅仅在wifi下同步，0关闭， 1开启**/
    var wifiSync:Int!
    /** 同步频率 */
    var syncrate:String!
    /** 用户上次同步时间 */
    var lastSyncTime: String!
    
    /** 上传图片大小 */
    var uploadPhotoSizeLiimit:String!
    /** 关闭提示登录时间*/
    var closeWarnLoginTime: String!
    
    
    static var instance:AppUser?
    class func getInstance() ->AppUser {
        if (instance == nil) {
            instance = AppUser.objectForKey(AO_CLIENT_KEY) as? AppUser
            if (instance == nil) {
                instance = AppUser()
            }
        }
        return instance!
    }
    
    class func clearInstance() -> Void {
        if instance != nil {
            instance = nil
        }
        
    }
    
    override init() {
        account = "00000001"
        password = nil
        token = nil
        userID = "00000001"
        nickName = nil
        autoSync = 0
        wifiSync = 1
        syncrate = "每天"
        uploadPhotoSizeLiimit = "原图"
        lastSyncTime = nil
        closeWarnLoginTime = nil
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        // 因为这个检测不了Int型的属性，所以还是要手动添加归档
        decodeAutoWithAutoCoder(aDecoder)
//        account = aDecoder.decodeObjectForKey("account") as! String
//        password = aDecoder.decodeObjectForKey("password") as! String
//        token = aDecoder.decodeObjectForKey("token") as! String
//        userId = aDecoder.decodeObjectForKey("userId") as! String
//        nickName = aDecoder.decodeObjectForKey("nickName") as! String
        autoSync = aDecoder.decodeObjectForKey("autoSync") as! Int
        wifiSync = aDecoder.decodeObjectForKey("wifiSync") as! Int
//        syncrate = aDecoder.decodeObjectForKey("syncrate") as! String
//        uploadPhotoSizeLiimit = aDecoder.decodeObjectForKey("uploadPhotoSizeLiimit") as! String

        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
         encodeAutoWithCoder(aCoder)
//        aCoder.encodeObject(account, forKey: "account")
//        aCoder.encodeObject(password, forKey: "password")
//        aCoder.encodeObject(self.userId, forKey: "userId")
//        aCoder.encodeObject(nickName, forKey: "nickName")
        aCoder.encodeObject(NSNumber.init(integer: autoSync), forKey: "autoSync")
        aCoder.encodeObject(NSNumber.init(integer: wifiSync), forKey: "wifiSync")
//        aCoder.encodeObject(syncrate, forKey: "syncrate")
//        aCoder.encodeObject(uploadPhotoSizeLiimit, forKey: "uploadPhotoSizeLiimit")
//        aCoder.encodeObject(token, forKey: "token")
    }
    
    class func objectForKey(key:String) ->AnyObject?{
        
        let path = dataFilePathForKey(key)
        if path != nil {
            let obj = NSKeyedUnarchiver.unarchiveObjectWithFile(path!)
            
            return obj
        }else{
            
            return nil
        }
        
        
    }
    
    class func setObject(value:AnyObject, key:String) -> AnyObject? {
        let path:String = dataFilePathForKey(key)!
        
        return NSKeyedArchiver.archiveRootObject(value, toFile: path)
    }
    
    class func dataFilePathForKey(key:String) -> String? {
        let document = APP_UTILITY.userDocumentPath()
        let dir = document!.stringByAppendingPathComponent("userdata")
        if !NSFileManager.defaultManager().fileExistsAtPath(dir) {
            do{
                
                try NSFileManager.defaultManager().createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil)
                
                
            }catch let error as NSError{
                
                AODlog(error.domain)
                return nil
            }
        }
        
        let path = "\(dir)/\(key)"
        return path
    }
    
    /** 存储当前信息 */
    func saveUserInfo() -> Void {
        
        AppUser.setObject(self, key: AO_CLIENT_KEY)
    }
    
    /** 存储头像 */
    func saveProtrialImage(image:UIImage, path:String) -> Bool {
        let fileMgr = NSFileManager.defaultManager()
        let imageCacheMgrDir = getImageCachePath()
        if !fileMgr.fileExistsAtPath(imageCacheMgrDir) {
            do{
                
                try NSFileManager.defaultManager().createDirectoryAtPath(imageCacheMgrDir, withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError{
                
                AODlog(error.description)
            }
        }
        
        return (UIImageJPEGRepresentation(image, 0.6)?.writeToFile(imageCacheMgrDir.stringByAppendingPathComponent(path.md5()), atomically: true))!
    }
    
    /** 读取数据 */
    func readPhotoFromLocalCache(path:String) -> UIImage? {
        // 图片缓存目录
        let imageCacheMgrDir:String = getImageCachePath()
        // 最终图片路径 = 图片缓存目录/url.md5
        let imageCacheMgrPath:String = imageCacheMgrDir.stringByAppendingPathComponent(path.md5())
        
        var reader:NSData?
        
        do{
            
            reader = try NSData.init(contentsOfFile: imageCacheMgrPath, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            return UIImage.init(data: reader!)

        }catch let error as NSError{
            
            AODlog(error.domain)
            return nil
        }
    
    }
    
    /** 删除图片 */
    func deleteProtrialFileWithPath(path:String) -> Bool {
        // 图片缓存目录
        let imageCacheMgrDir:String = getImageCachePath()
        // 最终图片路径 = 图片缓存目录/url.md5
        let imageCacheMgrPath:String = imageCacheMgrDir.stringByAppendingPathComponent(path.md5())
        let fileMgr = NSFileManager.defaultManager()
        var isSucceed:Bool!
        do{
            try fileMgr.removeItemAtPath(imageCacheMgrPath)
            isSucceed = true
            
        }catch let error as NSError{
            isSucceed = false
            AODlog(error.domain)
        }

        return isSucceed!
    }
    
    
    func getImageCachePath() -> String {
        let imageCachePath:String = getCachePath().stringByAppendingPathComponent("image/AOImageDownloadCache")
        return imageCachePath
    }
    
    func getCachePath() -> String {
        let path:String = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
        return path
        
    }
    
}
