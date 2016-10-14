//
//  ShareVC.swift
//  Spider
//
//  Created by 童星 on 16/8/25.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit
import MessageUI
let kShareViewH: CGFloat = 370

class ShareVC: UIViewController, ShareViewDelegate, MFMailComposeViewControllerDelegate {

    var shareTitle: String?
    var detailInfo: String?
    var shareImage: UIImage?
    var shareImageUrl: String?
    var visible: Bool?
    var backView: UIButton?
    lazy var shareView: ShareView? = {

        let shareView = ShareView.createShareView()
        shareView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kShareViewH)
        shareView.delegate = self
        shareView.layer.cornerRadius = 1
        shareView.layer.shadowOffset = CGSizeZero
        shareView.layer.shadowOpacity = 0.3
        return shareView
        
    }()
    init(title: String?, detailInfo: String?, shareImage: UIImage?, shareUrl: String?){
        super.init(nibName: nil, bundle: nil)
        self.shareTitle = title
        self.detailInfo = detailInfo
        self.shareImage = shareImage
        self.shareImageUrl = shareUrl
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func popShareView() -> Void {
        
        backView = UIButton.init(type: UIButtonType.System)
        backView?.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight)
        backView?.backgroundColor = UIColor(white: 0, alpha: 0.5)
        navigationController!.view.addSubview(backView!)
        backView!.addSubview(self.shareView!)

        self.shareView!.transform = CGAffineTransformIdentity;
        self.shareView!.layer.shadowPath = UIBezierPath.init(roundedRect: shareView!.bounds, cornerRadius: shareView!.layer.cornerRadius).CGPath
        
        shareView?.switchValueChange({ (switchOn: Bool) in
            AODlog(switchOn ? "带密操作" : "不带密操作")
        })
        UIView.animateWithDuration(0.25, animations: { 
            self.shareView?.centerY -= kShareViewH
        }) { (finshed: Bool) in
            
        }

        backView?.addTarget(self, action: #selector(closeAction), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func closeAction() -> Void {

        UIView.animateWithDuration(0.25, animations: {
            self.shareView?.centerY += kShareViewH
        }) { (finshed: Bool) in
            
            UIView.animateWithDuration(0.1, animations: {
                self.backView!.alpha = 0.1
            }) { (finished: Bool) in
                
                self.backView!.removeFromSuperview()
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
            
        }

    }
    
    // MARK: shareViewDelegate
    func shareView(shareType: ShareType) {
        switch shareType {
        case .CopyLink:
            closeAction()

        case .TakePassword:
            alert("复制成功", message: nil, parentVC: getCurrentRootViewController()!)

        case .SendEmail:
            callEmailFun()

        case .More:
        
            callSystemShare()

        case .WeiXin:
            closeAction()

        case .FriendCircle:
            closeAction()

        case .MobileQQ:
            closeAction()

        case .Qzone:
            closeAction()

        case .Sina:
            closeAction()

        case .CancelShare:
            closeAction()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
extension ShareVC{

    // 自定义分享
    //创建分享参数
//    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//    [shareParams SSDKSetupShareParamsByText:@"分享内容"
//    images:images //传入要分享的图片
//    url:[NSURL URLWithString:@"http://mob.com"]
//    title:@"分享标题"
//    type:SSDKContentTypeAuto];
//    
//    //进行分享
//    [ShareSDK share:SSDKPlatformTypeSinaWeibo //传入分享的平台类型
//    parameters:shareParams
//    onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) { // 回调处理....}];
//    }
}
extension ShareVC{

    
    func callEmailFun() -> Void {
        if MFMailComposeViewController.canSendMail() {
            let  controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject("邮箱标题")
            controller.setToRecipients(["example@xxx.com"]) // 收件人
            controller.setCcRecipients(["example@.com"]) // 抄送人
            controller.setBccRecipients(["example@126.com"]) // 密送人
            // 添加图片附件
//            let path = NSBundle.mainBundle().pathForResource("hangge.png", ofType: "")
//            let myData = NSData(contentsOfFile: path!)
//            controller.addAttachmentData(myData!, mimeType: "image/png", fileName: "swift.png")
            // 设置邮件正文内容
            controller.setMessageBody("邮件正文:", isHTML: true)
            // 打开界面
            AppNavigator.presentViewController(controller, animation: true, completion: nil)
        }else{
        
            let alertView = CustomSystemAlertView.init(title: "", message: "用户没有设置邮箱，是否去设置？", cancelButtonTitle: "取消", sureButtonTitle: "确定")
            alertView.clickIndexClosure({ (index) in
                switch (index) {
                
                case ClickButtonType.Cancle.rawValue: break
                case ClickButtonType.Sure.rawValue:
                
                    UIApplication.sharedApplication().openURL(NSURL.init(string: "mailto://devprograms@apple.com")!)
                    
                default:
                    break
                }
            })
            alertView.show()
        }
    }
    
    // MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
        switch result {
        case .Sent:
            alert("邮件发送成功", message: nil, parentVC: self)
        case .Cancelled:
            alert("邮件已取消", message: nil, parentVC: self)
        case .Saved:
            alert("邮件已保存", message: nil, parentVC: self)
        case .Failed:
            alert("邮件发送失败", message: nil, parentVC: self)
        }
    }
        
    
    func callSystemShare() -> Void {
        
        let arr        = ["测试"]
        
        let activityVC = UIActivityViewController.init(activityItems: arr, applicationActivities: nil)
        // 屏蔽那些模块
        let cludeActivitys: [String] = [
            
            // 保存到本地相册
            //UIActivityTypeSaveToCameraRoll,
            
            // 拷贝 复制
            //UIActivityTypeCopyToPasteboard,
            
            // 打印
//            UIActivityTypePrint,
            
            // 设置联系人图片
//            UIActivityTypeAssignToContact,
            
            /*
             // Facebook
             UIActivityTypePostToFacebook,
             
             // 微博
             UIActivityTypePostToWeibo,
             
             // 短信
             UIActivityTypeMessage,
             
             // 邮箱
             UIActivityTypeMail,
             
             // 腾讯微博
             UIActivityTypePostToTencentWeibo,
             
             UIActivityTypePostToTwitter,
             
             UIActivityTypePostToVimeo,
             
             UIActivityTypeAirDrop,
             
             UIActivityTypeAddToReadingList,
             UIActivityTypePostToFlickr,
             UIActivityTypeOpenInIBooks, // 9.0
             */
            
        ];
        activityVC.excludedActivityTypes = cludeActivitys
        APP_DELEGATE.window?.rootViewController?.presentViewController(activityVC, animated: true, completion: {
            ez.runThisAfterDelay(seconds: 1, after: {
                self.closeAction()
            })
        })
    }
}
