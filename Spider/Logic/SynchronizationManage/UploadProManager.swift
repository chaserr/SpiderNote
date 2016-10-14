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

public class UploadProManager {

   
    var conflictProArr = [ProjectObject]()
    
    static var instance:UploadProManager?
    class func getInstance() ->UploadProManager {
        if (instance == nil) {
            instance = UploadProManager()
        }
        return instance!
    }
    
    func uploadProject(parameters:[String: AnyObject], success: () -> Void, failure: () -> Void) -> Void {
        
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
    
    
    func analiysisParam(param: [String: AnyObject]) -> Void {
        
    }
    

    
    /**
     第二次上传参数格式
     
     - returns: return value description
     */
    func getSecondRequestParam(uploadProjectID: [String]) -> [String:AnyObject] {
        
        var paramDic                     = [String: AnyObject]()
        paramDic["userId"]               = APP_UTILITY.currentUser?.userID!// 用户ID
        paramDic["deviceId"]             = APPIdentificationManage.sharedInstance().readUUID()// 设备唯一标识符
        /** 项目 */
        var projectArr = [ProjectObject]()
        
        for projectId in uploadProjectID {
            
            let projectItem = ProjectObject.fetchOneProObject(projectId, project: ProjectObject())
            projectArr.append(projectItem)
        }
        var notesArr                     = [AnyObject]()
        for item in projectArr {
            var proDic              = [String: AnyObject]()
            proDic["id"]            = item.id
            proDic["userId"]        = APP_UTILITY.currentUser?.userID!
            proDic["deviceId"]      = item.deviceId
            proDic["name"] = item.name
            proDic["createAt"] = item.createAtTime
            proDic["updateAt"] = item.updateAtTime
            var mindsArr: Array = [AnyObject]()
            var childIds: String = ""
            if item.minds.count != 0 {
                for (index,mind) in item.minds.enumerate() {
                    if item.minds.count == 1 {
                        childIds = childIds + mind.id
                    }else if index == item.minds.count - 1{
                        childIds = childIds + mind.id
                    }else{
                        childIds = childIds + mind.id + ","
                    }
                    var mindDic            = [String: AnyObject]()
                    mindDic["id"] = mind.id
                    mindDic["noteId"] = mind.noteID
                    mindDic["mindType"] = mind.type
                    mindDic["name"] = mind.name
                    mindDic["deleteFlag"] = mind.deleteFlag
                    var sectionIds: String = ""
                    if mind.sections.count != 0 {
                        for (index,section) in mind.sections.enumerate() {
                            if mind.subMinds.count == 1 {
                                sectionIds = sectionIds + section.id
                            }else if index == mind.subMinds.count - 1{
                                sectionIds = sectionIds + section.id
                            }else{
                                sectionIds = sectionIds + section.id + ","
                            }
                        }
                    }
                    mindDic["sectionIds"] = sectionIds ?? ""
                    var childIds: String = ""
                    if mind.subMinds.count != 0 {
                        for (index,submind) in mind.subMinds.enumerate() {
                            if mind.subMinds.count == 1 {
                                childIds = childIds + submind.id
                            }else if index == mind.subMinds.count - 1{
                                childIds = childIds + submind.id
                            }else{
                                childIds = childIds + submind.id + ","
                            }
                        }
                    }
                    mindDic["childIds"] = childIds ?? ""
                    mindsArr.append(mindDic)
                }
            }
            proDic["childIds"] = childIds ?? ""
            proDic["minds"] = mindsArr
            notesArr.append(proDic)
        }
        paramDic["notes"]               = notesArr
        
        
        /** 段落 */
        let sectionArr: Array  = REALM.realm.objects(SectionObject).toArray()
        var sectionsArr: Array = [AnyObject]()
        for item in sectionArr {
            var sectionDic            = [String: AnyObject]()
            sectionDic["id"]          = item.id
            sectionDic["userId"]      = APP_UTILITY.currentUser?.userID
            sectionDic["noteId"]      = item.projectID
            sectionDic["undocFlag"]   = item.undocFlag
            sectionDic["sectionType"] = item.type
            sectionDic["updateAt"]    = item.updateAt
            sectionDic["deleteFlag"]  = item.deleteFlag
            var picsArr: Array = [AnyObject]()
            if item.pics.count != 0 {
                for pic in item.pics {
                    var picDic            = [String: AnyObject]()
                    picDic["id"] = pic.id
                    picDic["imageUrl"] = pic.url
                    var picTagsArr: Array = [AnyObject]()
                    if pic.tags.count != 0 {

                        for picTag in pic.tags {
                            var picTagDic            = [String: AnyObject]()
                            picTagDic["id"] = picTag.id
                            picTagDic["tagType"] = picTag.type
                            picTagDic["directionX"] = picTag.location.toCGPoint().x
                            picTagDic["directionY"] = picTag.location.toCGPoint().y
                            picTagDic["text"] = picTag.content
                            picTagDic["sourceUrl"] = picTag.sourceUrl
                            picTagDic["duration"] = picTag.duration
                            picTagDic["isLeft"] = picTag.direction
                            picTagsArr.append(picTagDic)
                        }
                    }
                    picDic["imageTagIds"] = picTagsArr
                    picsArr.append(picDic)
                }
            }
            sectionDic["imageIds"] = picsArr
            
            var audioDic            = [String: AnyObject]()
            if (item.audio != nil) {

                audioDic["id"] = item.audio?.id
                audioDic["audioUrl"] = item.audio?.url
                audioDic["duration"] = item.audio?.duration
                var audioTagArr: Array = [AnyObject]()
                if item.audio?.tags.count != 0  {
                    for audioTag in (item.audio?.tags)! {
                        var audioTagDic            = [String: AnyObject]()
                        audioTagDic["id"] = audioTag.id
                        audioTagDic["tagType"] = audioTag.type
                        audioTagDic["text"] = audioTag.content
                        audioTagDic["imageUrl"] = audioTag.sourceUrl
                        audioTagDic["timePoint"] = audioTag.timePoint
                        audioTagArr.append(audioTagDic)
                    }
                }
                audioDic["audioTagIds"] = audioTagArr
            }
            sectionDic["audioId"]     = audioDic
            sectionDic["text"]        = item.text
            sectionsArr.append(sectionDic)
        }
        
        paramDic["sections"] = sectionsArr

        let parad = paramDic as NSDictionary
        AODlog(parad.description)
        return paramDic
    }
    
    func downloadAudio(url: String, success: () -> Void, failure: () -> Void) -> Void {
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
    func testNetWorking(success: () -> Void, failure: () -> Void) -> Void {
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
