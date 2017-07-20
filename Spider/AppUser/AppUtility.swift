//
//  AppUtility.swift
//  Spider
//
//  Created by 童星 on 16/7/4.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

let AO_CURRENT_USER_KEY = "ao_current_user_info.plist"
let defaultUserID = "00000001"
let APP_UTILITY = AppUtility.getInstance()

class AOCurrentUser: NSObject, NSCoding{
    var account:String?
    var password:String?
    var userID:String?
    var token:String?
    override init() {
        super.init()
        self.account = nil
        self.password = nil
        self.userID = defaultUserID
        self.token = nil
    }
    //MARK: -序列化
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
//        decodeAutoWithAutoCoder(aDecoder)
        account = aDecoder.decodeObject(forKey: "account") as? String
        password = aDecoder.decodeObject(forKey: "password") as? String
        token = aDecoder.decodeObject(forKey: "token") as? String
        userID = aDecoder.decodeObject(forKey: "userID") as? String

        
        
    }
    
    func encode(with aCoder: NSCoder) {
//        encodeAutoWithCoder(aCoder)
        aCoder.encode(account, forKey: "account")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(self.userID, forKey: "userID")
        aCoder.encode(token, forKey: "token")
    }
    
    deinit{}
    


}

class AppUtility: NSObject {
    
    let filemgr = FileManager.default
    var currentUser:AOCurrentUser?
    
    static var instance:AppUtility?
    class func getInstance() ->AppUtility {
        if (instance == nil) {
            instance = AppUtility()
        }
        return instance!
    }
    
    override init() {
        currentUser = AppUtility.objectForKey(AO_CURRENT_USER_KEY) as? AOCurrentUser
        if currentUser == nil {
            currentUser = AOCurrentUser.init()
        }
    }
    
    //     销毁单利
    class func attemp () -> Void {
        instance = nil
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
    
    class func setObject(_ value:AnyObject, key:String) -> AnyObject? {
        let path: String = dataFilePathForKey(key)!
        return NSKeyedArchiver.archiveRootObject(value, toFile: path) as AnyObject
    }
    
    class func dataFilePathForKey(_ key:String) -> String? {
        let document = FileUtil.getFileUtil().getDocmentPath()
        let dir = document?.stringByAppendingPathComponent("user")
        
        if !FileManager.default.fileExists(atPath: dir!) {
            do{
            
                try FileManager.default.createDirectory(atPath: dir!, withIntermediateDirectories: true, attributes: nil)
                
                
            }catch let error as NSError{
            
                AODlog(error.domain)
                return nil
            }
        }
        
        let path = "\(dir)/\(key)"
        return path
    }
    
    /**检测当前用户*/
    func checkCurrentUser() -> Bool {
        if ((currentUser?.account != nil) && (currentUser?.password != nil)) || currentUser?.token != nil {
            return true
        }else{
        
            return false
        }
    }
    
    /**保存当前用户*/
    func saveCurrentUser() -> Void {
        AppUtility.setObject(currentUser!, key: AO_CURRENT_USER_KEY)
    }
    
    /**清除当前用户*/
    func clearCurrentUser() -> Void {
        // 清除当前用户的数据库引用
        RealmDAO.destory()
        AppUser.clearInstance()
        // 清空当前用户的信息
        currentUser?.token = nil
        currentUser?.password = nil;
        currentUser?.account = nil;
        currentUser?.userID = defaultUserID
        saveCurrentUser()
    }
    
    /**当前用户路径*/
    func userDocumentPath() -> String? {
        let path:String?
        
        if currentUser?.userID == defaultUserID {
            path = FileUtil.getFileUtil().getDocmentPath().stringByAppendingPathComponent(defaultUserID)

            return path
        }
        
        path = FileUtil.getFileUtil().getDocmentPath().stringByAppendingPathComponent(currentUser!.userID!)
        if !filemgr.fileExists(atPath: path!) {
            do{
                
                try FileManager.default.createDirectory(atPath: path!, withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError{
                
                AODlog(error.description)
            }
        }
        return path
    }
    
    /**当前数据库路径*/
    func databasePath() -> String {
        let path = userDocumentPath()?.stringByAppendingPathComponent("sql")
        if !filemgr.fileExists(atPath: path!) {
            do{
                
                try FileManager.default.createDirectory(atPath: path!, withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError{
                
                AODlog(error.description)
            }
        }
     
        return (path?.stringByAppendingPathComponent("spider.realm"))!;

    }
   
    /**当前用户图片路径*/
    func imageFilePath() -> String {
        let path = userDocumentPath()?.stringByAppendingPathComponent("image")
        if !filemgr.fileExists(atPath: path!) {
            do{
                
                try FileManager.default.createDirectory(atPath: path!, withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError{
                
                AODlog(error.description)
            }
        }
        
        return path!;
    }
    
    /**当前用户录音路径*/
    func voiceFilePath() -> String {
        let path = userDocumentPath()?.stringByAppendingPathComponent("voice")
        
        if !filemgr.fileExists(atPath: path!) {
            do{
                
                try FileManager.default.createDirectory(atPath: path!, withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError{
                
                AODlog(error.description)
            }
        }
        
        return path!;
    }
    
    func getAudioFilePath(_ id: String) -> URL? {
        return URL(fileURLWithPath: voiceFilePath()).appendingPathComponent(id).appendingPathExtension(FileExtension.M4A.rawValue)
    }
    
    func removeAudioFile(_ id: String) {
        let path = voiceFilePath().stringByAppendingPathComponent("\(id).\(FileExtension.M4A.rawValue)")
        
        if filemgr.fileExists(atPath: path) {
            do {
                try filemgr.removeItem(atPath: path)
            } catch {
                AODlog("error: remove audio file: \(error)")
            }
        }
    }
    
    /**公共文件夹路径*/
    func commonPath() -> String {
        let path = FileUtil.getFileUtil().getDocmentPath().stringByAppendingPathComponent("common")
        if !filemgr.fileExists(atPath: path) {
            do{
                
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError{
                
                AODlog(error.description)
            }
        }
        return path
    }
    
    func bundleFile(_ file:String) -> String {
        file
        return Bundle.main.path(forResource: (file as NSString).deletingPathExtension, ofType: file.pathExtension)!
    }
    
    
}



