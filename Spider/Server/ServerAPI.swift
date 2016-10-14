//
//  ServerAPI.swift
//  Spider
//
//  Created by 童星 on 16/7/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

//extension AORequest

/** 同步接口 */
public enum EAOSyncError: String{

    case SyncSuccess = "0000" /** 0000同步成功 */
    case SyncLock = "1000" /** 1000数据库被锁定 */
    case SyncSeverException = "1001" /** 1001服务端异常，请从新上传 */
    
}

/** Project State */
public enum EAOSyncProjectState: String{

    case NewProject = "1001" /** 1001新项目，直接上传 */
    case SameDeviceID = "1002" /** 1002设备id一致，直接上传 */
    case SameVersion = "1003" /** 1003版本号一致，直接上传 */
    case ClientNotExist = "1004" /** 1004客户端不存在，服务端存在，新项目，直接上传 */
    case LocalMindModify = "2001" /** 2001本地无修改，服务端有更高版本，并且节点有修改，返回项目信息和高版本的节点信息 */
    case LocalFirstMindModify = "2002" /** 2002本地无修改，服务端有更高版本，但是节点没有修改，仅仅是名字或者一节节点发生修改，仅返回项目信息 */
    case SeverProjectDelete = "2003" /** 2003 本地无修改，服务端项目已经删除，仅仅返回项目信息 */
    
    case LocalModify = "3001" /** 3001 本地已经修改，服务端项目没有删除，返回全量项目信息 */
    case LocalModifyAndSeverDelete = "3002" /** 3002 本地已经修改，但是服务端项目已经删除，仅返回项目信息 */
    
}

/** 上传接口回调码*/
public enum EAOUploadProject: String{

    case UploadSuccess = "0000" /** 0000上传成功 */
    case SaveSectionException = "1001"  /** 1001保存段落时出现异常 */
    case SaveProjectException = "1002" /** 1002 保存项目时出现问题 */
}

public enum EAOUploadProjectState: String{

    case Success = "0000" /** 0000上传成功 */
    case SaveSectionException = "1001"  /** 1001保存段落时出现异常 */
    case SaveMindException = "1002" /** 1002保存结点发生异常 */
    case SaveProjectException = "1003" /** 1003 保存项目本身的发生异常 */
}


/** 所有接口*/
public enum EAOServerRequestAPI:String {

    case test = "/read/columns"
    case testUrl = "/note/showMind" // 测试链接
    case registerUrl = "/login/register" // 注册第一步
    case sendEmailUrl = "/login/validateEmail" // 验证邮箱
    case loginUrl = "/login/login"  // 登录接口
    case logoutUrl = "/login/logout" // 登出接口
    case uploadProjectsUrl = "/note/uploadProjects" // 上传接口
    case syncPorjectsUrl = "/note/syncProjects" // 同步接口
}
