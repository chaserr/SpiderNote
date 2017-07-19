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


open class AORequest: NSObject {

    fileprivate var url = ""
    fileprivate var parameters:[String:AnyObject] = [:]
    fileprivate var filePath = ""
    
    //上传参数
    fileprivate let boundary: String = "--"
    fileprivate let boundaryID: String = "FlPm4LpSXsE"
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
    func addParameters(_ specialPearameters:[String:AnyObject] = [:]) {
        
        parameters.removeAll()
        
        parameters["deviceId"] = APPIdentificationManage.sharedInstance().readUUID() as AnyObject
//        parameters["platformInfo"] = getPlatformInfo()
        let token = APP_UTILITY.currentUser?.token
        if token != nil {
            parameters["token"] = token as AnyObject
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
    fileprivate func andCompleteOfRequestUrl(_ api: EAOServerRequestAPI)
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
//        addUploadRequestUrl(api, parameter: specialParameters)
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
        
//        let date = Date()
//        let fileName = Int(date.timeIntervalSince1970 * 1000)
//        self.bodyData.append(self.httpHeaderStringWithFile("\(fileName)").data(using: String.Encoding.utf8.rawValue)!)
//        //尾部
//        let data = try? Data(contentsOf: URL(fileURLWithPath: self.filePath))
//        self.bodyData.append(data!)
//        self.bodyData.append(self.httpBottomString().data(using: String.Encoding.utf8.rawValue)!)
//        let uploadUrl = URL(string: self.url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
//        
//        guard  uploadUrl != nil else{
//            
//            return
//        }
//        
//        
//        let mutableRequest = NSMutableURLRequest(url:uploadUrl!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
//        
//        mutableRequest.httpMethod = "POST"
//        mutableRequest.httpBody = self.bodyData as Data
//        mutableRequest.addValue("multipart/form-data;charset=UTF-8; boundary=\(self.boundaryID)", forHTTPHeaderField: "Content-Type")
//        mutableRequest.addValue("\(self.bodyData.length)", forHTTPHeaderField: "Content-Length")
//        self.uploadRequest = mutableRequest
        
        
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
    
//    func responseJSON(_ response : (Response<AnyObject, NSError>) -> Void){
//        //这里面需要指定encoding:.JSON  服务器端会在GetAttribute()里面获取到所传参数， 否则在GetParameter()中获取到
//        switch requestMethod {
//        case .GET:
//            
//            Alamofire.request(.GET, url, parameters: parameters, encoding: .JSON).responseJSON { (alamofireResponse) in
//                response(alamofireResponse)
//            }
//        case .POST:
//            let headers = [
//                "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
//            
//            ]
//            Alamofire.request(.POST, url, parameters: parameters, headers: headers).responseJSON { (alamofireResponse) in
//                response(alamofireResponse)
//            }
//        default: break
//            
//        }
//        
//    }
    
    
//    func responString(_ response: (Response<String, NSError>) -> Void) {
//        switch requestMethod {
//        case .GET:
//            Alamofire.request(.GET, url, parameters: parameters, encoding: .JSON).responseString(completionHandler: { (alamofireResponse) in
//                response(alamofireResponse)
//            })
//        case .POST:
//            let headers = [
//                "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
//                
//            ]
//            Alamofire.request(.POST, url, parameters: parameters, headers: headers).responseString(completionHandler: { alamofireResponse in
//                response(alamofireResponse)
//            })
//        default: break
//            
//        }
//    }
    
    /*
     下载语音
     */
//    func responseDownLoadAudio(_ downloadFileDestination:(URL, HTTPURLResponse) -> URL){
        
        //        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        
//        Alamofire.download(.GET, self.url, destination: {  destionat in
//            
//            downloadFileDestination(destionat)
//            
//            
//        })
//            .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
//                print(totalBytesRead)
//        }
        
        
//    }
    
    /*
     下载服务
     */
//    func responseDownload(_ progress:(_ readed:Int64,_ total:Int64,_ unRead:Int64)->Void, response: (Response<AnyObject, NSError>)->Void){
    
        
        
//        Alamofire.download(.GET, url, destination: { (temporaryURL, response) in
//            if let directoryURL = NSFileManager.defaultManager()
//                .URLsForDirectory(.DocumentDirectory,
//                    inDomains: .UserDomainMask)[0]
//                as? NSURL {
//                let pathComponent = response.suggestedFilename
//                
//                return directoryURL.URLByAppendingPathComponent(pathComponent!)!
//            }
//            
//            return temporaryURL
//            
//        }).progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
//            
//            progress(readed:bytesRead,total:totalBytesRead,unRead:totalBytesExpectedToRead)
//            
//            }
//            .response {  (request, response, _, error)  in
//                
//                
//        }
        
//        
//    }
    
    /*
     上传服务
     */
//    func responseUpload(_ progress:@escaping (_ readed:Int64,_ total:Int64,_ unRead:Int64)->Void ,response:(Response<AnyObject, NSError>)->Void){
//        
//        Alamofire.upload(self.uploadRequest!, data:self.bodyData).progress({
//            (bytesRead, totalBytesRead, totalBytesExpectedToRead)  in
//            progress(readed:bytesRead,total:totalBytesRead,unRead:totalBytesExpectedToRead )
//            
//        }).responseJSON { alamofireResponse  in
//            response(alamofireResponse)
//        }
//        
//    }
//    
//    func httpHeaderStringWithParameters(_ parameter: String, paramName: String) ->String {
//        var header: String = self.boundary+self.boundaryID+"\r\n"
//        header += "Content-Disposition: form-data;name=\"\(paramName)\"\r\n"
//        header += parameter+"\r\n"
//        
//        return header
//        
//    }
    
    //拼接带文件的头部
//    func httpHeaderStringWithFile(_ upLoadFileName: String) ->NSString {
//        
//        
//        let header: NSMutableString = NSMutableString.init()
//        header.append(self.boundary+self.boundaryID)
//        header.appendFormat("\r\n")
//        header.appendFormat("Content-Disposition: form-data; name=\"file\"; filename=\"\(upLoadFileName)\(baseType!)\"\r\n" as NSString)
//        header.appendFormat("Content-Type:\(mimType!)\r\n\r\n" as NSString) //        audio/x-mei-aac
//        
//        self.bodyHeader = header
//        
//        //        header += "Content-Disposition: form-data; name=\"file\"; filename=\"\(upLoadFileName)\""
//        //        header += ".caf\\r\n;"
//        //        header += "Content-Type: \(mimType)\r\n\r\n"
//        //        //        header += "Content-Transfer-Encoding: binary\r\n"
//        //        self.bodyHeader = header
//        
//        return header
//    }
    
    //拼接底部
//    func httpBottomString() -> NSString {
//        
//        let footer: NSMutableString = NSMutableString.init()
//        footer.appendFormat("\r\n")
//        footer.append(self.boundary+self.boundaryID+self.boundary)
//        footer.appendFormat("\r\n")
//        self.bodyFooter = footer
//        
//        return footer
//    }
    
    //指定全路径文件的mimType
//    func mimTypeWithFilePath(_ filePath: String) {
//        
//        if !FileManager.default.fileExists(atPath: filePath) {
//            return
//        }
//        
//        let url = URL(fileURLWithPath: filePath)
//        let request = NSMutableURLRequest(url: url)
//        
//        var response: URLResponse?
//        
//        do {
//            try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
//            self.mimType = response!.mimeType
//        } catch {
//            print(error)
//            return
//        }
//    }
    
    
//    fileprivate func addUploadRequestUrl(_ api: EAOServerRequestAPI,parameter:[String:AnyObject] = [:]){
//        var lastUrl = kHostUrl + api.rawValue
//        
////        let sessionId = Defaults[.sessionId]
////        if  sessionId != nil {
////            lastUrl = lastUrl.stringByReplacingOccurrencesOfString("unknown", withString: sessionId!)
////        }
//        
////        lastUrl += "?oh=\(getAuthCode())"
//        let token = Defaults[.token]
//        if token != nil {
//            lastUrl += "&token=\(token!)"
//        }
//        for  (key,value) in parameter{
//            lastUrl+="&\(key)=\(value)"
//        }
//        
//        let parametersInfo = self.parameters
//        
//        for (key,value) in parametersInfo{
//            
//            lastUrl += "&\(key)=\(value)"
//        }
////        let platformInfo = self.getPlatformInfo()
////        for (key,value) in platformInfo {
////            lastUrl += "&\(key)=\(value)"
////        }
//        
//        
//        url = lastUrl
//        
//        
//    }
    
    
    
    /**
     计算oh
     
     - returns: 返回添加时间戳和idfa并且进行加密计算
     FIX: 1.这里使用到了idfa来得到设备唯一id，但是，在应用中并没有使用到广告，所以在提交APP的时候需要注意
          2.
     http:blog.csdn.net/bddzzw/article/details/52083192
     */
    fileprivate func getAuthCode()->String {
        let adId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        //这里需要使用Int64 因为在iPhone4s Int默认为32位，将float转变为Int32无法继续
        let nowTime = Int64(Date().timeIntervalSince1970 * 1000)
        
        let str = "\(adId)_\(nowTime)"
        
        return str + "_" + str.md5()
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
        let reach = Reachability.forInternetConnection().currentReachabilityStatus()
        
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
        
        let infoDict = Bundle.main.infoDictionary as [String : AnyObject]?
        if let info = infoDict {
            releaseTime = info["CFBundleVersion"] as! String
        }
        platformInfo["version"]         = "50010200" as AnyObject
        platformInfo["platform"]        = "iOS" as AnyObject
        platformInfo["phonetype"]       = UIDevice.current.name as AnyObject
        platformInfo["w"]               = UIScreen.main.bounds.size.width as AnyObject
        platformInfo["h"]               = UIScreen.main.bounds.size.height as AnyObject
        platformInfo["systemVersion"]   = UIDevice.current.systemVersion as AnyObject
        platformInfo["netType"]         = netType as AnyObject
        platformInfo["mobileIP"]        = "127.0.0.1" as AnyObject
        platformInfo["release"]         = releaseTime as AnyObject
        return platformInfo
    }

}

//MARK:- 缓存路径
extension AORequest {
    
    func getCachPath()->String{
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask,true)
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
