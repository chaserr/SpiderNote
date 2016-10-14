//
//  MacroDefinition .swift
//  Spider
//
//  Created by 童星 on 16/7/4.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  常用宏

import Foundation
import AdSupport

let APP_DELEGATE  = UIApplication.sharedApplication().delegate as! AppDelegate
let APP_KEYWINDOW = UIApplication.sharedApplication().keyWindow!


/**日期格式*/
let kDUYYYYMMddHHmm          = "YYYY-MM-dd HH:mm"
let kDUYYYYMMddhhmm          = "YYYY-MM-dd hh:mm"
let kDUHHmmss                = "HH:mm:ss"
let kDUHHmm                  = "HH:mm"
let kDUyyyMMddHHmmssSSSS     = "yyy-MM-dd-HH:mm:ss:SSSS"
let kDUyyyMMddHHmmssss       = "yyy-MM-dd-HH:mm:ssss"
let kDUyyy                   = "yyy"
let kDUyyyyMMdd              = "yyyyMMdd"
let kDUYYYYMMddhhmmss        = "YYYYMMddHHmmss"
let kDUyyyyMMddHHmmssSSS     = "yyyyMMddHHmmssSSS"
let kDU_YYYYMMddhhmmss       = "yyyy-MM-dd HH:mm:ss"
let kDU_yyyyMMdd             = "yyyy-MM-dd"
let kDU_MMddHHmm             = "MM-dd HH:mm"
let kDU_MMdd                 = "MM/dd"
let kDU_MMYUEddRI            = "MM月dd日"
let kDU_EEEdMMMyyyyHHmmsszzz = "EEE,d MMM yyyy HH:mm:ss zzz"
let kDU_dMMMyyyyHHmmsszzz    = "d MMM yyyy HH:mm:ss zzz"
let kDU_MMddyyyyHHmmsstt     = "M/dd/yyyy HH:mm:ss aa"
let kDU_yyyMMddHHmmssS       = "yyyy-MM-dd HH:mm:ss.S"




/** 根据subview位置获取cell的indexPath */
func IndexPath_SubView_TableView(subView:UIView, tableview:UITableView) -> NSIndexPath {
    let subViewFrame = subView.convertRect(subView.bounds, toView: tableview)
    let indexPath    = tableview.indexPathForRowAtPoint(subViewFrame.origin)

    return indexPath!
}

/** 根据subview位置获取cell */
func Cell_SubView_TableView(subView:UIView, tableview:UITableView) -> AnyObject {
    let subViewFrame = subView.convertRect(subView.bounds, toView: tableview)
    let indexPath    = tableview.indexPathForRowAtPoint(subViewFrame.origin)
    let cell         = tableview.cellForRowAtIndexPath(indexPath!)

    return cell!
}

/** json字符串转换成字典 */
public func JsonStrToDic(jsonStr: String) -> [String: AnyObject]? {
    
    let dicData = jsonStr.dataUsingEncoding(NSUTF8StringEncoding)
    
    let dic: [String: AnyObject]? = try! NSJSONSerialization.JSONObjectWithData(dicData!, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject]
    return dic
    
}

/**
 从storyBoard加载控制器
 
 - parameter storyBoardName:         storyBoard的名字
 - parameter viewControllerIdentify: 控制器在storyBoard的标识符
 
 - returns: uiviewcontroller
 */
func getViewControllerFromStoryBoard(storyBoardName:String, viewControllerIdentify:String) -> UIViewController {
    let storyBoard = UIStoryboard.init(name: storyBoardName, bundle: nil)
    let targetVC = storyBoard.instantiateViewControllerWithIdentifier(viewControllerIdentify)
    return targetVC
}



/** 16进制颜色转换*/
func RGBCOLORV(rgbValue:NSInteger) -> UIColor{

    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0,
                   green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0,
                   blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: 1.0)
}

func RGBCOLORVA(rgbValue:NSInteger, alphaValue:CGFloat) -> UIColor{

    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0,
                   green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0,
                   blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: alphaValue)
}
/**RGB颜色转换*/
func RGBCOLOR(r:CGFloat, g:CGFloat, b:CGFloat) -> UIColor {
    return UIColor.init(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: 1.0)
}

func RGBACOLOR(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor.init(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: a)
}



/**系统字体大小*/
func SYSTEMFONT(s: CGFloat) -> UIFont {
    return UIFont.systemFontOfSize(s)
}

func SYSTEMFONT(s: CGFloat, name: String) -> UIFont {
    return UIFont(name: name, size: s)!
}

/**通过广告标识符获取设备唯一ID*/
//func getIDFAIdentify() -> String {
//    let adId = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
//    
//    //这里需要使用Int64 因为在iPhone4s Int默认为32位，将float转变为Int32无法继续
//    let nowTime = Int64(NSDate().timeIntervalSince1970 * 1000)
//    
//    let str = "\(adId)_\(nowTime)"
//    
//    return str + "_" + str.AOMD5(str)
//}

/**alert提示框*/

//typealias AlertViewBlock = () -> Void
//let cancleButtonBlock:AlertViewBlock? = nil
//let otherButtonBlock:AlertViewBlock? = nil

func alert(title:String?, message:String?,parentVC:UIViewController) -> Void {
    let errorAlert   = UIAlertController(
        title: title,
        message: message,
        preferredStyle: UIAlertControllerStyle.Alert
    )
    errorAlert.addAction(
        UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
    )
    parentVC.presentViewController(errorAlert, animated: true, completion: nil)
}


/** 获取当前视图的根控制器 */
func getCurrentRootViewController() -> UIViewController? {
    
    let result:UIViewController?
    
    let topWindow = UIApplication.sharedApplication().keyWindow
    if topWindow?.windowLevel != UIWindowLevelNormal {
        let windows:[UIWindow] = UIApplication.sharedApplication().windows
        for topWindow in windows {
            if topWindow.windowLevel == UIWindowLevelNormal {
                break
            }
        }
        
    }
    
    let rootView = topWindow?.subviews[0]
    let nextResponder = rootView?.nextResponder()
    if (nextResponder?.isKindOfClass(UIViewController)) != nil {
        result = nextResponder as? UIViewController
    }else if ((topWindow?.respondsToSelector(Selector("rootViewController"))) != nil && topWindow!.rootViewController != nil){
    
        result = topWindow!.rootViewController;

    }else{
    
        assert(false, "ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
         result = nil
    }
    return result
    
}




/** 快速查询一段代码的执行时间 */
/** 用法
 TICK
 do your work here
 TOCK
 */

//let TICK = startTime()
//let TOCK = endTime()
//
//func startTime() -> NSDate {
//    return NSDate()
//}
//
//func endTime() -> Void {
//    AODlog(startTime().timeIntervalSinceNow)
//}




        