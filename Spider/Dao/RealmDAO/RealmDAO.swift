//
//  RealmDAO.swift
//  Spider
//
//  Created by 童星 on 16/7/4.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

let REALM = RealmDAO.instance()


class RealmDAO: NSObject {
    
    let filemgr = NSFileManager.defaultManager()
    
    var realm: Realm!
    
    static var realmManage: RealmDAO?

    class func instance() -> RealmDAO {
        if (realmManage == nil) {
            realmManage = RealmDAO()
            realmManage?.createDatabase()
        }
        return realmManage!
    }
    
    //     销毁单利
    class func destory() -> Void {
        if realmManage != nil {
            realmManage = nil
        }
    }
    
    /**
     初始化数据库
     */
     func createDatabase() -> Void {
        
        let config = Realm.Configuration (

            fileURL: NSURL.fileURLWithPath(APP_UTILITY.databasePath()),
            schemaVersion: RealmDBSchema,
            deleteRealmIfMigrationNeeded: false,
            // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < RealmDBSchema) {
                    // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
                }
                
        })

    //        if !filemgr.fileExistsAtPath(databasePath) {
            do {
                REALM.realm = try Realm(configuration: config)
            } catch {
                AODlog(error)
            }
    //        }

    }
    
    /**
     *  @author 童星, 16-07-05 15:07:49
     *
     *  @brief 数据库之间迁移
     *
     *  @since 1.0
     */
    func copyObjectBetweenRealms<T : RealmSwift.Object>(oldRealmPath:String, willCopyObject:T.Type) -> Void {
    
        // 默认的数据库路径
//        let oldSqlPath = FileUtil.getFileUtil().getDocmentPath().stringByAppendingPathComponent(defaultUserID).stringByAppendingPathComponent("sql")
        let oldRealmConfig = Realm.Configuration(
        fileURL:  NSURL.init(string: oldRealmPath),
        schemaVersion: RealmDBSchema + 1
        )
//        migrateRealm(oldRealmConfig)
        let oldRealm = try!Realm(configuration: oldRealmConfig)
        let willCopyObjects = oldRealm.objects(willCopyObject)

        try! REALM.realm?.write({
            for object in willCopyObjects {
            
                REALM.realm?.create(willCopyObject.self, value: object, update: true)
            }
        })
    }
}
