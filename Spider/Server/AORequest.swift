//
//  AORequest.swift
//  Spider
//
//  Created by 童星 on 16/7/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CryptoSwift
import AdSupport
import Reachability

public enum RequestMethod: String {
    case OPTIONS, HEAD, PUT, PATCH, DELETE, TRACE, CONNECT
    case GET
    case POST
}
//let kHostUrl =  "http://api2.pianke.me"//"localhost:9000"

//let kHostUrl =  "http://192.168.120.45:8080/spiderNote" // 朱大红
//let kHostUrl =  "http://58.221.61.66/spiderNote"
//let kHostUrl =  "http://192.168.232.152/spiderNote" // 冷键家
//let kHostUrl =  "http://192.168.1.105:8080/spiderNote" // 童星家
let kHostUrl =  "http://139.224.25.115:8080/spiderNote" // 阿里服务器


public class AORequest: NSObject {

    private var url = ""
    private var parameters:[String:AnyObject] = [:]
    private var filePath = ""
    
    //上传参数
    private let boundary: String = "--"
    private let boundaryID: String = "FlPm4LpSXsE"
    var uploadRequest: NSMutableURLRequest?
    var parameterName: String = ""
    var mimType: String?
    var baseType:String?
    var bodyHeader: NSMutableString?
    var bodyFooter: NSMutableString?
    var bodyData: NSMutableData = NSMutableData()
    var requestMethod = RequestMethod.GET
    
    
    init (requestMethod: RequestMethod, specialParameters : [String:AnyObject],api : EAOServerRequestAPI)
    {
        super.init()
        
        self.requestMethod = requestMethod
        addParameters(specialParameters)
        andCompleteOfRequestUrl(api)
    }
    
    /**
     添加请求参数
     
     - parameter specialPearameters: 请求参数列表
     */
    func addParameters(specialPearameters:[String:AnyObject] = [:]) {
        
        parameters.removeAll()
        
        parameters["deviceId"] = APPIdentificationManage.sharedInstance().readUUID()
//        parameters["platformInfo"] = getPlatformInfo()
        let token = APP_UTILITY.currentUser?.token
        if token != nil {
            parameters["token"] = token
        }
        
        guard specialPearameters.count != 0 else {
            return
        }
        
        for (key,value) in specialPearameters {
            parameters[key] = value
        }
    }
    
    /**
     拼接请求地址
     
     - parameter api: 请求调用的api
     */
    private func andCompleteOfRequestUrl(api: EAOServerRequestAPI)
    {
        let lastUrl = kHostUrl + api.rawValue
        //        let sessionId = Defaults[.sessionId]
        //        if  sessionId != nil {
        //            lastUrl = lastUrl.stringByReplacingOccurrencesOfString("unknown", withString: sessionId!)
        //        }
        
        //        lastUrl += "?oh=\(getAuthCode())"
        
        url = lastUrl
    }
    
    // multipart/form-data 编码格式上传下载图片和语音，其中 isImage 来判断上传的是语音还是图片， 上传语音的格式是aac 上传图片的格式是jpg
    
    init(specialParameters : [String:AnyObject],api : EAOServerRequestAPI,uploadPath:String, isImage:Bool){
        
        super.init()
        addUploadRequestUrl(api, parameter: specialParameters)
        self.filePath = uploadPath
        if isImage{
            self.mimType = "image/jpg"
            self.baseType = ".jpg"
        }else{
            self.mimType = "audio/x-mei-aac"
            self.baseType = ".aac"
        }
        
        creatMutableRequest()
    }
    
    func creatMutableRequest(){
        
        let date = NSDate()
        let fileName = Int(date.timeIntervalSince1970 * 1000)
        self.bodyData.appendData(self.httpHeaderStringWithFile("\(fileName)").dataUsingEncoding(NSUTF8StringEncoding)!)
        //尾部
        let data = NSData(contentsOfFile: self.filePath)
        self.bodyData.appendData(data!)
        self.bodyData.appendData(self.httpBottomString().dataUsingEncoding(NSUTF8StringEncoding)!)
        let uploadUrl = NSURL(string: self.url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        
        guard  uploadUrl != nil else{
            
            return
        }
        
        
        let mutableRequest = NSMutableURLRequest(URL:uploadUrl!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30)
        
        mutableRequest.HTTPMethod = "POST"
        mutableRequest.HTTPBody = self.bodyData
        mutableRequest.addValue("multipart/form-data;charset=UTF-8; boundary=\(self.boundaryID)", forHTTPHeaderField: "Content-Type")
        mutableRequest.addValue("\(self.bodyData.length)", forHTTPHeaderField: "Content-Length")
        self.uploadRequest = mutableRequest
        
        
    }

        //简单下载
    init(requestMethod: RequestMethod, urlStr:String){
        self.url = urlStr
        
    }
    
    //MARK:- functions
    /**
     处理服务器返回
     
     - parameter response: 服务器响应回调
     */
    func responseJSON(response : Response<AnyObject, NSError> -> Void){
        //这里面需要指定encoding:.JSON  服务器端会在GetAttribute()里面获取到所传参数， 否则在GetParameter()中获取到
        switch requestMethod {
        case .GET:
            Alamofire.request(.GET, url, parameters: parameters, encoding: .JSON).responseJSON { (alamofireResponse) in
                response(alamofireResponse)
            }
        case .POST:
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
            
            ]
            Alamofire.request(.POST, url, parameters: parameters, headers: headers).responseJSON { (alamofireResponse) in
                response(alamofireResponse)
            }
        default: break
            
        }
        
    }
    
    
    func responString(response: Response<String, NSError> -> Void) {
        switch requestMethod {
        case .GET:
            Alamofire.request(.GET, url, parameters: parameters, encoding: .JSON).responseString(completionHandler: { (alamofireResponse) in
                response(alamofireResponse)
            })
        case .POST:
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
                
            ]
            Alamofire.request(.POST, url, parameters: parameters, headers: headers).responseString(completionHandler: { alamofireResponse in
                response(alamofireResponse)
            })
        default: break
            
        }
    }
    
    /*
     下载语音
     */
    func responseDownLoadAudio(downloadFileDestination:(NSURL, NSHTTPURLResponse) -> NSURL){
        
        //        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        
        Alamofire.download(.GET, self.url, destination: {  destionat in
            
            downloadFileDestination(destionat)
            
            
        })
            .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                print(totalBytesRead)
        }
        
        
    }
    
    /*
     下载服务
     */
    func responseDownload(progress:(readed:Int64,total:Int64,unRead:Int64)->Void, response: Response<AnyObject, NSError>->Void){
        
        
        
        Alamofire.download(.GET, url, destination: { (temporaryURL, response) in
            if let directoryURL = NSFileManager.defaultManager()
                .URLsForDirectory(.DocumentDirectory,
                    inDomains: .UserDomainMask)[0]
                as? NSURL {
                let pathComponent = response.suggestedFilename
                
                return directoryURL.URLByAppendingPathComponent(pathComponent!)!
            }
            
            return temporaryURL
            
        }).progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            
            progress(readed:bytesRead,total:totalBytesRead,unRead:totalBytesExpectedToRead)
            
            }
            .response {  (request, response, _, error)  in
                
                
        }
        
        
    }
    
    /*
     上传服务
     */
    func responseUpload(progress:(readed:Int64,total:Int64,unRead:Int64)->Void ,response:Response<AnyObject, NSError>->Void){
        
        Alamofire.upload(self.uploadRequest!, data:self.bodyData).progress({
            (bytesRead, totalBytesRead, totalBytesExpectedToRead)  in
            progress(readed:bytesRead,total:totalBytesRead,unRead:totalBytesExpectedToRead )
            
        }).responseJSON { alamofireResponse  in
            response(alamofireResponse)
        }
        
    }
    
    func httpHeaderStringWithParameters(parameter: String, paramName: String) ->String {
        var header: String = self.boundary+self.boundaryID+"\r\n"
        header += "Content-Disposition: form-data;name=\"\(paramName)\"\r\n"
        header += parameter+"\r\n"
        
        return header
        
    }
    
    //拼接带文件的头部
    func httpHeaderStringWithFile(upLoadFileName: String) ->NSString {
        
        
        let header: NSMutableString = NSMutableString.init()
        header.appendString(self.boundary+self.boundaryID)
        header.appendFormat("\r\n")
        header.appendFormat("Content-Disposition: form-data; name=\"file\"; filename=\"\(upLoadFileName)\(baseType!)\"\r\n")
        header.appendFormat("Content-Type:\(mimType!)\r\n\r\n") //        audio/x-mei-aac
        
        self.bodyHeader = header
        
        //        header += "Content-Disposition: form-data; name=\"file\"; filename=\"\(upLoadFileName)\""
        //        header += ".caf\\r\n;"
        //        header += "Content-Type: \(mimType)\r\n\r\n"
        //        //        header += "Content-Transfer-Encoding: binary\r\n"
        //        self.bodyHeader = header
        
        return header
    }
    
    //拼接底部
    func httpBottomString() -> NSString {
        
        let footer: NSMutableString = NSMutableString.init()
        footer.appendFormat("\r\n")
        footer.appendString(self.boundary+self.boundaryID+self.boundary)
        footer.appendFormat("\r\n")
        self.bodyFooter = footer
        
        return footer
    }
    
    //指定全路径文件的mimType
    func mimTypeWithFilePath(filePath: String) {
        
        if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            return
        }
        
        let url = NSURL(fileURLWithPath: filePath)
        let request = NSMutableURLRequest(URL: url)
        
        var response: NSURLResponse?
        
        do {
            try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            self.mimType = response!.MIMEType
        } catch {
            print(error)
            return
        }
    }
    
    
    private func addUploadRequestUrl(api: EAOServerRequestAPI,parameter:[String:AnyObject] = [:]){
        var lastUrl = kHostUrl + api.rawValue
        
//        let sessionId = Defaults[.sessionId]
//        if  sessionId != nil {
//            lastUrl = lastUrl.stringByReplacingOccurrencesOfString("unknown", withString: sessionId!)
//        }
        
//        lastUrl += "?oh=\(getAuthCode())"
        let token = Defaults[.token]
        if token != nil {
            lastUrl += "&token=\(token!)"
        }
        for  (key,value) in parameter{
            lastUrl+="&\(key)=\(value)"
        }
        
        let parametersInfo = self.parameters
        
        for (key,value) in parametersInfo{
            
            lastUrl += "&\(key)=\(value)"
        }
//        let platformInfo = self.getPlatformInfo()
//        for (key,value) in platformInfo {
//            lastUrl += "&\(key)=\(value)"
//        }
        
        
        url = lastUrl
        
        
    }
    
    
    
    /**
     计算oh
     
     - returns: 返回添加时间戳和idfa并且进行加密计算
     FIX: 1.这里使用到了idfa来得到设备唯一id，但是，在应用中并没有使用到广告，所以在提交APP的时候需要注意
          2.
     http:blog.csdn.net/bddzzw/article/details/52083192
     */
    private func getAuthCode()->String {
        let adId = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
        
        //这里需要使用Int64 因为在iPhone4s Int默认为32位，将float转变为Int32无法继续
        let nowTime = Int64(NSDate().timeIntervalSince1970 * 1000)
        
        let str = "\(adId)_\(nowTime)"
        
        return str + "_" + str.AOMD5(str)
    }
    
    /**
     获取配置信息
     
     - returns: 配置信息字典
     */
    func getPlatformInfo()->[String:AnyObject] {
        /*
         "version":版本号,
         "platform":平台(8->IOS),
         "phonetype":手机型号,
         "w":分辨率宽,
         "h":分辨率高,
         "systemVersion":系统版本,
         "netType":联网类型(0->无网络,2->wifi,11->2G网络,12->3G网络,13->4G网络)
         "imsi":sim卡imsi号,
         "mobileIP":手机ip
         "release":发版时间，例如：20150117
         */
//
        var netType = 0
        let reach = Reachability.reachabilityForInternetConnection().currentReachabilityStatus()
        
        switch(reach) {
        case .NotReachable:
            netType = 0
        case .ReachableViaWiFi:
            netType = 1
        case .ReachableViaWWAN:
            netType = 2
        }
        var platformInfo : [String:AnyObject] = [:]
        var releaseTime:String = "20160818"
        
        let infoDict = NSBundle.mainBundle().infoDictionary as [String : AnyObject]?
        if let info = infoDict {
            releaseTime = info["CFBundleVersion"] as! String
        }
        platformInfo["version"]         = "50010200"
        platformInfo["platform"]        = "iOS"
        platformInfo["phonetype"]       = UIDevice.currentDevice().name
        platformInfo["w"]               = UIScreen.mainScreen().bounds.size.width
        platformInfo["h"]               = UIScreen.mainScreen().bounds.size.height
        platformInfo["systemVersion"]   = UIDevice.currentDevice().systemVersion
        platformInfo["netType"]         = netType
        platformInfo["mobileIP"]        = "127.0.0.1"
        platformInfo["release"]         = releaseTime
        return platformInfo
    }

}

//MARK:- 缓存路径
extension AORequest {
    
    func getCachPath()->String{
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,.UserDomainMask,true)
        let path = paths[0]
        return path
    }
    
    func getAudioCachPath()->String{
        
        let audioPath = self.getCachPath()+"audio/aoAudioDownloadCache"
        return audioPath
    }
    
}

/// 全局的数据请求
class YYRequestData {
    //声明为单例
    class var sharedInstance : YYRequestData {
        struct Static {
            static let instance : YYRequestData = YYRequestData()
        }
        return Static.instance
    }
    
    /**
     获取配置信息
     */
//    func getConfigInfo() {
//        
//        let parameter:[String:AnyObject] = [:]
//        
//        AORequest(specialParameters: parameter, api: .GetConfigInfo).responseJSON { response in
//            if response.result.isSuccess {
//                let json = JSON(data: response.data!)
//                let getConfigInfoData = getConfigInfoObj(json: json)
//                
//                YYDateAppInfo.sharedInstance.configInfo = getConfigInfoData
//            }
//            
//            if response.result.isFailure {
//                if let responseString = response.result.error?.debugDescription {
//                    print(responseString)
//                }
//            }
//        }
//    }
    
}
