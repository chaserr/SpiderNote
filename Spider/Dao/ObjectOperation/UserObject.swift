//
//  UserObject.swift
//  Spider
//
//  Created by 童星 on 16/8/17.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import RealmSwift

class UserObject: Object {

    /** 用户id */
    dynamic var userId: String = ""
    /** 用户昵称 */
    dynamic var userName: String = ""
    /** 用户密码 */
    dynamic var password: String = ""
    /** 用户手机号 */
    dynamic var mobileNum: String = ""
    /** 用户邮箱 */
    dynamic var email: String = ""
    /** 注册时间 */
    dynamic var createAt: String = ""
    /** 登录次数 */
    dynamic var loginCount: String = ""
    /** 登录时间 */
    dynamic var loginTime: String = ""
    /** 上次登录时间 */
    dynamic var lastLoginTime: String = ""
    /** 用户性别*/
    dynamic var sex: String = ""
    /** 占有空间 */
    dynamic var occupancySpace: String = ""
    
    // 重写set方法
    dynamic private var _image: UIImage? = nil
    dynamic private var imageData: NSData? = nil
    dynamic var userPortrial: UIImage? {
    
        set{
        
            self._image = newValue
            if let value = newValue {
                self.imageData = UIImagePNGRepresentation(value)
            }
        }
        get{
        
            if let image = self._image{return image}
            if let data = self.imageData {
                self._image = UIImage(data: data)
                return self._image
            }
            return nil
            
        }
    }
    
    override static func primaryKey() -> String? {
        return "userId"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["userPortrial", "_image"]
    }
    
    
    
    func saveUserObj() -> Void {
        try! REALM.realm.write {
            REALM.realm.add(self, update: true)
        }
    }
    
    /** 内容直接更新 , 适用于从数据库查询已有对象，更新某一个属性*/
    func updateUserObj(transtionBlock: () -> Void) -> Void {
        try! REALM.realm.write({
            transtionBlock()
        })
    }
    
    /** 通过主键更新*/
    func updateAccoundPrimaryKey() -> Void {
        try! REALM.realm.write({ 
            REALM.realm.create(UserObject.self, value: self, update: true)
        })
    }
    
    func deleteUserObj() -> Void {
        try! REALM.realm.write {
            REALM.realm.delete(self)
        }
    }
    
    static func fetchUserObj(userId: String) -> UserObject?{
    
        return REALM.realm.objectForPrimaryKey(self, key: userId)!
    }
    
}
