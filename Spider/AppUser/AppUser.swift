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
        decodeAuto(withAutoCoder: aDecoder)
//        account = aDecoder.decodeObjectForKey("account") as! String
//        password = aDecoder.decodeObjectForKey("password") as! String
//        token = aDecoder.decodeObjectForKey("token") as! String
//        userId = aDecoder.decodeObjectForKey("userId") as! String
//        nickName = aDecoder.decodeObjectForKey("nickName") as! String
        autoSync = aDecoder.decodeObject(forKey: "autoSync") as! Int
        wifiSync = aDecoder.decodeObject(forKey: "wifiSync") as! Int
//        syncrate = aDecoder.decodeObjectForKey("syncrate") as! String
//        uploadPhotoSizeLiimit = aDecoder.decodeObjectForKey("uploadPhotoSizeLiimit") as! String

        
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
         encodeAuto(with: aCoder)
//        aCoder.encodeObject(account, forKey: "account")
//        aCoder.encodeObject(password, forKey: "password")
//        aCoder.encodeObject(self.userId, forKey: "userId")
//        aCoder.encodeObject(nickName, forKey: "nickName")
        aCoder.encode(NSNumber.init(value: autoSync as Int), forKey: "autoSync")
        aCoder.encode(NSNumber.init(value: wifiSync as Int), forKey: "wifiSync")
//        aCoder.encodeObject(syncrate, forKey: "syncrate")
//        aCoder.encodeObject(uploadPhotoSizeLiimit, forKey: "uploadPhotoSizeLiimit")
//        aCoder.encodeObject(token, forKey: "token")
    }
    
    class func objectForKey(_ key:String) ->AnyObject?{
        
        let path = dataFilePathForKey(key)
        if path != nil {
            let obj = NSKeyedUnarchiver.unarchiveObject(withFile: path!)
            
            return obj as AnyObject
        }else{
            
            return nil
        }
        
        
    }
    
    @discardableResult
    class func setObject(_ value:AnyObject, key:String) -> AnyObject? {
        let path:String = dataFilePathForKey(key)!
        
        return NSKeyedArchiver.archiveRootObject(value, toFile: path) as AnyObject
    }
    
    class func dataFilePathForKey(_ key:String) -> String? {
        let document = APP_UTILITY.userDocumentPath()
        let dir = document!.stringByAppendingPathComponent("userdata")
        if !FileManager.default.fileExists(atPath: dir) {
            do{
                
                try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                
                
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
    func saveProtrialImage(_ image:UIImage, path:String) -> Bool {
        let fileMgr = FileManager.default
        let imageCacheMgrDir = getImageCachePath()
        if !fileMgr.fileExists(atPath: imageCacheMgrDir) {
            do{
                
                try FileManager.default.createDirectory(atPath: imageCacheMgrDir, withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError{
                
                AODlog(error.description)
            }
        }
        
        return ((try? UIImageJPEGRepresentation(image, 0.6)?.write(to: URL(fileURLWithPath: imageCacheMgrDir.stringByAppendingPathComponent(path.md5())), options: [.atomic])) != nil)
    }
    
    /** 读取数据 */
    func readPhotoFromLocalCache(_ path:String) -> UIImage? {
        // 图片缓存目录
        let imageCacheMgrDir:String = getImageCachePath()
        // 最终图片路径 = 图片缓存目录/url.md5
        let imageCacheMgrPath:String = imageCacheMgrDir.stringByAppendingPathComponent(path.md5())
        
        var reader:Data?
        
        do{
            
            reader = try Data.init(contentsOf: URL(fileURLWithPath: imageCacheMgrPath), options: NSData.ReadingOptions.mappedIfSafe)
            return UIImage.init(data: reader!)

        }catch let error as NSError{
            
            AODlog(error.domain)
            return nil
        }
    
    }
    
    /** 删除图片 */
    func deleteProtrialFileWithPath(_ path:String) -> Bool {
        // 图片缓存目录
        let imageCacheMgrDir:String = getImageCachePath()
        // 最终图片路径 = 图片缓存目录/url.md5
        let imageCacheMgrPath:String = imageCacheMgrDir.stringByAppendingPathComponent(path.md5())
        let fileMgr = FileManager.default
        var isSucceed:Bool!
        do{
            try fileMgr.removeItem(atPath: imageCacheMgrPath)
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
        let path:String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        return path
        
    }
    
}
