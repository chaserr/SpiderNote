////
////  UploadResourcesTool.swift
////  Spider
////
////  Created by 童星 on 16/8/19.
////  Copyright © 2016年 auais. All rights reserved.
////
//
//import UIKit
//import Qiniu
//import Kingfisher
//
//let QiNiuBaseUrl = "http://7xozpn.com2.z0.glb.qiniucdn.com/"
//let QNUPLOADRESOURCESTOOL = UploadResourcesTool.getInstance()
//
//class UploadResourcesTool: NSObject {
//    
//    /******************七牛上传文件示例******************************
//     
//    示例地址 :http://o9gnz92z5.bkt.clouddn.com/code/v7/sdk/objc.html#io-put
//     
//    #import <QiniuSDK.h>
//    ...
//    NSString *tokern = @"从服务端SDK获取";
//    QNUploadManager *upManager = [[QNUploadManager alloc] init];
//    NSData *data = [@"Hello, World!" dataUsingEncoding : NSUTF8StringEncoding];
//    [upManager putData:data key:@"hello" token:token
//    complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//    NSLog(@"%@", info);
//    NSLog(@"%@", resp);
//    } option:nil];
//    注意：key 及所有需要输入的字符串必须采用 utf8 编码，如果使用非 utf8 编码访问七牛云存储将反馈错误。
//    
//
//    **************************************************************/
//    
//    var uploadToken: String?
//    
//    
//    static var instance:UploadResourcesTool?
//    class func getInstance() ->UploadResourcesTool {
//        if (instance == nil) {
//            instance = UploadResourcesTool()
//            
//        }
//        return instance!
//    }
//    
//    override init() {
//        super.init()
//        getQiNiuUploadToken({ (token) in
//            self.uploadToken = token
//        } , failure:{
//            self.uploadToken = nil
//        })
//    }
//
//    /** 获取上传凭证*/
//    func getQiNiuUploadToken(success: (token: String) -> Void, failure: (() -> Void)) -> Void{
//        
//        //    {"scope": "spidernotetest", "deadline": timeStamp}
//        // TODO: 客户端获取上传token测试
//        GCQiniuUploadManager.sharedInstance().registerWithScope("spidernotetest", accessKey: "yduQTL0rdDs1KKZeAbi1Jk5L_V7bQ8GbeeZ5L93C", secretKey: "XcXVfmGO48qeIK9z0Bss8b_NuY7ORUrrzCA0DhxS")
//        GCQiniuUploadManager.sharedInstance().createToken()
//        let token = GCQiniuUploadManager.sharedInstance().uploadToken
//        success(token: token);
//        
//        // 从服务器获取uploadToken
//        
//        AORequest.init(requestMethod: .POST, urlStr: "qiniutoken").responseJSON { (response) in
////            if response.re
//        }
//    }
//    
//    /**
//     上传单张图
//     *  @param image    需要上传的image
//     *  @param progress 上传进度block
//     *  @param success  成功block 返回url地址
//     *  @param failure  失败block
//     */
//    func uploadImage(image: UIImage, imageKey: String, progress: QNUpProgressHandler?, success: ((url: String) -> Void)?, failure: (() -> Void)?) -> Void {
//        
//        if uploadToken != nil {
//            let imageData = UIImageJPEGRepresentation(image, 0.01)
//            if imageData == nil {
//                if (failure != nil) {
//                    failure!()
//                }
//                return
//            }
//            let opt = QNUploadOption(mime: nil, progressHandler: progress, params: nil, checkCrc: false, cancellationSignal: nil)
//            let uploadManager = QNUploadManager.sharedInstanceWithConfiguration(nil)
//            uploadManager.putData(imageData, key: imageKey, token: uploadToken, complete: { (info: QNResponseInfo!, key: String!, response: [NSObject : AnyObject]!) in
//                    if info.statusCode == 200 && response != nil {
//                    
//                        let url = "\(QiNiuBaseUrl)\(response["key"])"
//                        
//                        if (success != nil) {
//                        
//                            success!(url: url)
//                        }
//                    }else{
//                
//                        if failure != nil {
//                        
//                            failure!()
//                        }
//                    }
//                }, option: opt)
//
//        }else{ // uploadToken 为nil
//
//            AOHUDVIEW.showTips("上传失败,请检查你的网络")
//        }
//        
//    }
//    
//    /**
//     上传多张图片
//     
//     - parameter imageArray: 图片数组
//     - parameter progress:   上传进度
//     - parameter success:    上传成功回调url地址
//     - parameter failure:    上传失败回调
//     */
//    func uploadImages(imageSectionArray: [PicSectionObject], progress: (allProgress: CGFloat) -> Void, success: ((urlArray: [String]) -> Void), failure: () -> Void) {
//        var imageArray = [UIImage]()
//        var imageKeyArray = [String]()
//        let fetchCacheImageQueue = dispatch_queue_create(KfetchImageFromCache, DISPATCH_QUEUE_SERIAL)
//        let options: KingfisherOptionsInfo = [
//            .CallbackDispatchQueue(fetchCacheImageQueue),
//            .ScaleFactor(UIScreen.mainScreen().scale),
//            ]
//        for imageSection in imageSectionArray {
//            Kingfisher.ImageCache.defaultCache.retrieveImageForKey(imageSection.id, options: options, completionHandler: { (image: Image?, cacheType: CacheType!) in
//                imageArray.append(image!)
//                imageKeyArray.append(imageSection.id)
//            })
//        }
//        
//        var urlArray = [String]()
//        var totalProgress : CGFloat = 0.0
//        let partProgress : CGFloat = CGFloat(1.0 / Double(imageArray.count))
//        var currentIndex : Int = 0
//        QNUPLOADHELPER.failureBlock = {
//            () -> Void in
//            failure()
//            return
//        }
//        
//        QNUPLOADHELPER.successBlock = {
//        
//            (url: String) -> Void in
//            urlArray.append(url)
//            totalProgress += partProgress
//            progress(allProgress: totalProgress)
//            currentIndex = currentIndex + 1
//            if urlArray.count == imageArray.count {
//                success(urlArray: urlArray)
//                return
//            }else{
//            
//                if currentIndex < imageArray.count {
//                    self.uploadImage(imageArray[currentIndex],imageKey: imageKeyArray[currentIndex],progress: nil, success: QNUPLOADHELPER.successBlock, failure: QNUPLOADHELPER.failureBlock)
//                }
//            }
//        }
//        uploadImage(imageArray[0],imageKey: imageKeyArray[0],progress: nil, success: QNUPLOADHELPER.successBlock, failure: QNUPLOADHELPER.failureBlock)
//    }
//    
//    
//    /**
//     音频上传文件
//     
//     - parameter audio:    音频数据结构
//     - parameter progress: 上传进度
//     - parameter success:  上传成功回调
//     - parameter failure:  上传失败回调
//     */
//    func uploadAudio(audio: AudioSectionObject, progress: QNUpProgressHandler?, success: ((url: String) -> Void)?, failure: (() -> Void)?) -> Void {
//        // 判断音频格式
////        let audioType = UtilFunc.getAudioType(<#T##audioPath: String!##String!#>)
//        // 获取音频文件路径
//        let audioDir = "\(APP_UTILITY.voiceFilePath())/\(audio.id) + .aac"
//        let audioData = try? NSData.init(contentsOfFile: audioDir, options: NSDataReadingOptions.DataReadingMappedAlways)
//        
//        if uploadToken != nil {
//            if audioData == nil {
//                if (failure != nil) {
//                    failure!()
//                }
//                return
//            }
//            let opt = QNUploadOption(mime: nil, progressHandler: progress, params: nil, checkCrc: false, cancellationSignal: nil)
//            let uploadManager = QNUploadManager.sharedInstanceWithConfiguration(nil)
//            uploadManager.putData(audioData, key: audio.id, token: uploadToken, complete: { (info: QNResponseInfo!, key: String!, response: [NSObject : AnyObject]!) in
//                if info.statusCode == 200 && response != nil {
//                    
//                    let url = "\(QiNiuBaseUrl)\(response["key"])"
//                    
//                    if (success != nil) {
//                        
//                        success!(url: url)
//                    }
//                }else{
//                    
//                    if failure != nil {
//                        
//                        failure!()
//                    }
//                }
//                
//            }, option: opt)
//                
//        }else{
//            
//            AOHUDVIEW.showTips("上传失败,请检查你的网络")
//                
//        }
//    }
//    
//    
//    func downLoadImage() -> Void {
//        // 使用王巍的下载图片库
//    }
//    
//    func downloadAudio(url: String, success: ((audioUrl: String) -> Void), failure: () -> Void) -> Void {
//        // 判断本地是否有缓存(音频cache文件)
//        let audioPath = audioPathWithUrl(url)
//        if audioPath != nil {
//            success(audioUrl: audioPath!)
//            return
//        }
//        
//        let audioCachePath = getAudioCachePath().stringByAppendingPathComponent(url.md5())
//
//        UPLOADPROMANAGER.downloadAudio(url, success: { 
//            success(audioUrl: audioCachePath)
//        }, failure: {
//                failure()
//        })
//    }
//}
//
//extension UploadResourcesTool{
//
//    func audioPathWithUrl(url:String?) -> String? {
//        if url != nil && url!.length == 0 {
//            return nil
//        }
//        let audioCachePath = getAudioCachePath().stringByAppendingPathComponent((url?.md5())!)
//        if NSFileManager.defaultManager().fileExistsAtPath(audioCachePath) {
//            return audioCachePath
//        }else{
//            
//            return nil
//        }
//    }
//    func getAudioCachePath() -> String {
//        let audioCachePath = getCachePath().stringByAppendingPathComponent("audio/audioDownloadCache")
//        if !NSFileManager.defaultManager().fileExistsAtPath(audioCachePath) {
//            do{
//                
//                try NSFileManager.defaultManager().createDirectoryAtPath(audioCachePath, withIntermediateDirectories: true, attributes: nil)
//            }catch let error as NSError{
//                
//                AODlog(error.description)
//            }
//        }
//        return audioCachePath
//    }
//    
//    func getCachePath() -> String {
//        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//        return paths.first!
//
//    }
//}
//
