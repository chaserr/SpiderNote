
//
//  UploadProjectManager.swift
//  Spider
//
//  Created by 童星 on 16/8/18.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

let UPLOADPROMANAGER = UploadProManager.getInstance()

open class UploadProManager {

   
    var conflictProArr = [ProjectObject]()
    
    static var instance:UploadProManager?
    class func getInstance() ->UploadProManager {
        if (instance == nil) {
            instance = UploadProManager()
        }
        return instance!
    }
    
    func uploadProject(_ parameters:[String: AnyObject], success: () -> Void, failure: () -> Void) -> Void {
        
        AOHUDVIEW.showLoadingHUD("加载中...", parentView: APP_DELEGATE.window!)
        AORequest(requestMethod: .POST, specialParameters: parameters, api: .uploadProjectsUrl).responseJSON { response in
            if response.result.isSuccess{
                AOHUDVIEW.hideHUD()
                let jsonData = JSON(response.result.value!)
                let dic = JsonStrToDic(jsonData.rawString()!)
                AODlog((dic! as NSDictionary).description)
                let code = dic!["code"] as! String
                switch code {
                case EAOUploadProject.UploadSuccess.rawValue:
                    // 上传成功
                    let noteArr: [Dictionary] = dic!["notes"] as! [Dictionary<String, AnyObject>]
                    for noteItem in noteArr {
                        
                        switch (noteItem["code"] as! String) {
                        case EAOUploadProjectState.Success.rawValue:
                            // 上传成功
                            
                            success()
                            
                        case EAOUploadProjectState.SaveSectionException.rawValue:
                            // 保存段落出现异常
                            AOHUDVIEW.showTips(noteItem["message"] as! String)
                            failure()

                        case EAOUploadProjectState.SaveMindException.rawValue:
                            // 保存节点出现异常
                            AOHUDVIEW.showTips(noteItem["message"] as! String)
                            failure()
                        case EAOUploadProjectState.SaveProjectException.rawValue:
                            // 保存项目本身出现异常
                            AOHUDVIEW.showTips(noteItem["message"] as! String)
                            failure()

                        default: break
                            
                        }
//                        AODlog((noteItem as NSDictionary).description)
                        
                    }
                case EAOUploadProject.SaveSectionException.rawValue:
                    AOHUDVIEW.showTips("数据库被锁定，请稍后再试")
                    failure()
                case EAOUploadProject.SaveProjectException.rawValue:
                    AOHUDVIEW.showTips("服务端异常，请从新上传")
                    failure()
                default:break
                }
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
    
    
    func analiysisParam(_ param: [String: AnyObject]) -> Void {
        
    }
    

    
    /**
     第二次上传参数格式
     
     - returns: return value description
     */
    func getSecondRequestParam(_ uploadProjectID: [String]) -> [String:AnyObject] {
        
        var paramDic                     = [String: AnyObject]()
        paramDic["userId"]               = APP_UTILITY.currentUser?.userID! as AnyObject// 用户ID
        paramDic["deviceId"]             = APPIdentificationManage.sharedInstance().readUUID() as AnyObject// 设备唯一标识符
        /** 项目 */
        var projectArr = [ProjectObject]()
        
        for projectId in uploadProjectID {
            
            let projectItem = ProjectObject.fetchOneProObject(projectId, project: ProjectObject())
            projectArr.append(projectItem)
        }
        var notesArr                     = [AnyObject]()
        for item in projectArr {
            var proDic              = [String: AnyObject]()
            proDic["id"]            = item.id as AnyObject
            proDic["userId"]        = APP_UTILITY.currentUser?.userID! as AnyObject
            proDic["deviceId"]      = item.deviceId as AnyObject
            proDic["name"] = item.name as AnyObject
            proDic["createAt"] = item.createAtTime as AnyObject
            proDic["updateAt"] = item.updateAtTime as AnyObject
            var mindsArr: Array = [AnyObject]()
            var childIds: String = ""
            if item.minds.count != 0 {
                for (index,mind) in item.minds.enumerated() {
                    if item.minds.count == 1 {
                        childIds = childIds + mind.id
                    }else if index == item.minds.count - 1{
                        childIds = childIds + mind.id
                    }else{
                        childIds = childIds + mind.id + ","
                    }
                    var mindDic            = [String: AnyObject]()
                    mindDic["id"] = mind.id as AnyObject
                    mindDic["noteId"] = mind.noteID as AnyObject
                    mindDic["mindType"] = mind.type as AnyObject
                    mindDic["name"] = mind.name as AnyObject
                    mindDic["deleteFlag"] = mind.deleteFlag as AnyObject
                    var sectionIds: String = ""
                    if mind.sections.count != 0 {
                        for (index,section) in mind.sections.enumerated() {
                            if mind.subMinds.count == 1 {
                                sectionIds = sectionIds + section.id
                            }else if index == mind.subMinds.count - 1{
                                sectionIds = sectionIds + section.id
                            }else{
                                sectionIds = sectionIds + section.id + ","
                            }
                        }
                    }
                    mindDic["sectionIds"] = sectionIds as AnyObject ?? ""
                    var childIds: String = ""
                    if mind.subMinds.count != 0 {
                        for (index,submind) in mind.subMinds.enumerated() {
                            if mind.subMinds.count == 1 {
                                childIds = childIds + submind.id
                            }else if index == mind.subMinds.count - 1{
                                childIds = childIds + submind.id
                            }else{
                                childIds = childIds + submind.id + ","
                            }
                        }
                    }
                    mindDic["childIds"] = childIds as AnyObject ?? ""
                    mindsArr.append(mindDic as AnyObject)
                }
            }
            proDic["childIds"] = childIds as AnyObject ?? ""
            proDic["minds"] = mindsArr as AnyObject
            notesArr.append(proDic as AnyObject)
        }
        paramDic["notes"]               = notesArr as AnyObject
        
        
        /** 段落 */
        let sectionArr: Array  = REALM.realm.objects(SectionObject).toArray()
        var sectionsArr: Array = [AnyObject]()
        for item in sectionArr {
            var sectionDic            = [String: AnyObject]()
            sectionDic["id"]          = item.id as AnyObject
            sectionDic["userId"]      = APP_UTILITY.currentUser?.userID as AnyObject
            sectionDic["noteId"]      = item.projectID as AnyObject
            sectionDic["undocFlag"]   = item.undocFlag as AnyObject
            sectionDic["sectionType"] = item.type as AnyObject
            sectionDic["updateAt"]    = item.updateAt as AnyObject
            sectionDic["deleteFlag"]  = item.deleteFlag as AnyObject
            var picsArr: Array = [AnyObject]()
            if item.pics.count != 0 {
                for pic in item.pics {
                    var picDic            = [String: AnyObject]()
                    picDic["id"] = pic.id as AnyObject
                    picDic["imageUrl"] = pic.url as AnyObject
                    var picTagsArr: Array = [AnyObject]()
                    if pic.tags.count != 0 {

                        for picTag in pic.tags {
                            var picTagDic            = [String: AnyObject]()
                            picTagDic["id"] = picTag.id as AnyObject
                            picTagDic["tagType"] = picTag.type as AnyObject
                            picTagDic["directionX"] = picTag.location.toCGPoint().x as AnyObject
                            picTagDic["directionY"] = picTag.location.toCGPoint().y as AnyObject
                            picTagDic["text"] = picTag.content as AnyObject
                            picTagDic["sourceUrl"] = picTag.sourceUrl as AnyObject
                            picTagDic["duration"] = picTag.duration as AnyObject
                            picTagDic["isLeft"] = picTag.direction as AnyObject
                            picTagsArr.append(picTagDic as AnyObject)
                        }
                    }
                    picDic["imageTagIds"] = picTagsArr as AnyObject
                    picsArr.append(picDic as AnyObject)
                }
            }
            sectionDic["imageIds"] = picsArr as AnyObject
            
            var audioDic            = [String: AnyObject]()
            if (item.audio != nil) {

                audioDic["id"] = item.audio?.id as AnyObject
                audioDic["audioUrl"] = item.audio?.url as AnyObject
                audioDic["duration"] = item.audio?.duration as AnyObject
                var audioTagArr: Array = [AnyObject]()
                if item.audio?.tags.count != 0  {
                    for audioTag in (item.audio?.tags)! {
                        var audioTagDic            = [String: AnyObject]()
                        audioTagDic["id"] = audioTag.id as AnyObject
                        audioTagDic["tagType"] = audioTag.type as AnyObject
                        audioTagDic["text"] = audioTag.content as AnyObject
                        audioTagDic["imageUrl"] = audioTag.sourceUrl as AnyObject
                        audioTagDic["timePoint"] = audioTag.timePoint as AnyObject
                        audioTagArr.append(audioTagDic as AnyObject)
                    }
                }
                audioDic["audioTagIds"] = audioTagArr as AnyObject
            }
            sectionDic["audioId"]     = audioDic as AnyObject
            sectionDic["text"]        = item.text as AnyObject
            sectionsArr.append(sectionDic as AnyObject)
        }
        
        paramDic["sections"] = sectionsArr as AnyObject

        let parad = paramDic as NSDictionary
        AODlog(parad.description)
        return paramDic
    }
    
    func downloadAudio(_ url: String, success: @escaping () -> Void, failure: @escaping () -> Void) -> Void {
        AOHUDVIEW.showLoadingHUD("加载中...", parentView: APP_DELEGATE.window!)
        AORequest.init(requestMethod: .GET, urlStr: url).responseJSON { (response) in
            if response.result.isSuccess{
                AOHUDVIEW.hideHUD()
                
                success()
                
            }
            
            if response.result.isFailure{
                AOHUDVIEW.hideHUD()
                if let responseString = response.result.error?.debugDescription {
                    failure()
                    AOHUDVIEW.showTips(responseString)
                }
            }
        }
    }

}

extension UploadProManager{

    // TODO: 测试
    func testNetWorking(_ success: @escaping () -> Void,  failure: @escaping () -> Void) -> Void {
        AOHUDVIEW.showLoadingHUD("加载中...", parentView: APP_DELEGATE.window!)
        AORequest(requestMethod: .GET, urlStr: "http://api2.pianke.me/read/columns").responseJSON { (response) in
            if response.result.isSuccess{
                AOHUDVIEW.hideHUD()
                let jsonData = JSON(response.result.value!)
                alert(jsonData.description, message: nil, parentVC: getCurrentRootViewController()!)
                
                success()
            }
            
            if response.result.isFailure{
                AOHUDVIEW.hideHUD()
                if let responseString = response.result.error?.debugDescription {
                    failure()
                    AOHUDVIEW.showTips(responseString)
                }
            }
        }
    }
}
