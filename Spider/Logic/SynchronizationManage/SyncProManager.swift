//
//  SyncProMnaager.swift
//  Spider
//
//  Created by 童星 on 16/8/18.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

let SYNCPROMANAGER = SyncProManager.getInstance()

class SyncProManager: NSObject {
    
    /** 直接同步的项目 */
    static var instance:SyncProManager?
    class func getInstance() ->SyncProManager {
        if (instance == nil) {
            instance = SyncProManager()
        }
        return instance!
    }
    
    func syncProject(parameters:[String: AnyObject], success: (uploadProObjID: [String]) -> Void, failure: () -> Void) -> Void {
        
        AOHUDVIEW.showLoadingHUD("同步中...", parentView: APP_DELEGATE.window!)
        AORequest(requestMethod: .POST, specialParameters: parameters, api: .syncPorjectsUrl).responseJSON { response in
            if response.result.isSuccess{
                AOHUDVIEW.hideHUD()
                let jsonData = JSON(response.result.value!)
                let dic = JsonStrToDic(jsonData.rawString()!)
                AODlog((dic! as NSDictionary).description)
                var directlySyncProArr = [String]()
                let code = dic!["code"] as! String
                switch code {
                    
                case EAOSyncError.SyncSuccess.rawValue:
                    // 同步成功
                    APP_USER.lastSyncTime = DateUtil.getCurrentDateStringWithFormat(kDUYYYYMMddhhmmss)
                    APP_USER.saveUserInfo()
                    let noteArr: [Dictionary] = dic!["notes"] as! [Dictionary<String, AnyObject>]
                    for noteItem in noteArr {
                        
                        switch (noteItem["code"] as! String) {
                        case EAOSyncProjectState.NewProject.rawValue, EAOSyncProjectState.ClientNotExist.rawValue,EAOSyncProjectState.SameVersion.rawValue,EAOSyncProjectState.SameDeviceID.rawValue:
                            // 直接上传的新项目
                            directlySyncProArr.append(noteItem["noteId"] as! String)
                            
                        case EAOSyncProjectState.LocalFirstMindModify.rawValue, EAOSyncProjectState.LocalMindModify.rawValue,EAOSyncProjectState.SeverProjectDelete.rawValue:
                            // 本地没修改，项目有更新，解析返回来的项目信息,写入数据库
                            self.analiysisParam(noteItem)
                        case EAOSyncProjectState.LocalModify.rawValue, EAOSyncProjectState.LocalModifyAndSeverDelete.rawValue:
                            // 本地已修改，项目有更新，解析返回来的项目信息,写入数据库
                            self.analiysisParam(noteItem)
                        default: break
                            
                        }
                        AODlog((noteItem as NSDictionary).description)
                        
                    }
                case EAOSyncError.SyncLock.rawValue:
                    AOHUDVIEW.showTips("数据库被锁定，请稍后再试")
                case EAOSyncError.SyncSeverException.rawValue:
                    AOHUDVIEW.showTips("服务端异常，请从新上传")
                default:break
                }
                success(uploadProObjID: directlySyncProArr)
                
            }
            
            if response.result.isFailure{
                AOHUDVIEW.hideHUD()
                if let responseString = response.result.error?.debugDescription {
                    failure()
                    AODlog(responseString)
                }
            }
        }
        
        
    }
    
    func analiysisParam(param: [String: AnyObject]) -> Void {
        
    }
    
    /**
     第一次上传参数格式
     
     {
     userId:"user0001",
     deviceId:"device0001",
     sectionSyncTimestamp:"2016-08-10 16:58:23",
     notes:[
     {
     "noteId":"note0001",
     "syncTimestamp":"2016-08-10 16:58:23",
     "modifyFlag":1
     },
     {
     "noteId":"note0002",
     "syncTimestamp":"2016-08-10 16:58:23",
     "modifyFlag":1
     }
     ]
     }
     - returns:
     */
    // MARK: 获取上传的参数
    func getFirstRequestParam() -> [String:AnyObject] {
        var paramDic                     = [String: AnyObject]()
        paramDic["userId"]               = APP_UTILITY.currentUser?.userID!// 用户ID
        paramDic["deviceId"]             = APPIdentificationManage.sharedInstance().readUUID()
        // 客户端持有的最晚的段落时间戳
        let timeStr: Array?  = REALM.realm.objects(SectionObject).sorted("syncTimesTamp", ascending: true).toArray()
        if timeStr?.count != 0 && timeStr!.first!.syncTimesTamp != "" {
            paramDic["sectionSyncTimestamp"] = timeStr!.first!.syncTimesTamp
        }else{
            
            
            paramDic["sectionSyncTimestamp"] = DateUtil.getCurrentDateStringWithFormat(kDU_YYYYMMddhhmmss)
        }
        
        let projectArr                   = REALM.realm.objects(ProjectObject).toArray()
        var notesArr                     = [AnyObject]()
        
        for item in projectArr {
            var proDic = [String: AnyObject]()
            proDic["noteId"]        = item.id
            proDic["syncTimestamp"] = item.syncTimesTamp == "" ? DateUtil.getCurrentDateStringWithFormat(kDU_YYYYMMddhhmmss) : item.syncTimesTamp
            proDic["modifyFlag"]    = "item.modifyFlag"
            notesArr.append(proDic)
        }
        paramDic["notes"]               = notesArr
        
        //        let parad = paramDic as NSDictionary
        //
        //        AODlog(parad.description)
        return paramDic
    }
}
