//
//  SpiderConfig.swift
//  Spider
//
//  Created by ooatuoo on 16/7/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: - Global
public let kScreenWidth  = UIScreen.main.bounds.width //ATScreenSize.shareInstance.size.width
public let kScreenHeight = UIScreen.main.bounds.height //ATScreenSize.shareInstance.size.height
public let kScreenBounds = UIScreen.main.bounds

public let kStatusBarHeight = CGFloat(20)

// project 
public let kUnchiveBoxItemRect      = CGRect(x: kScreenWidth - 16 - 20, y: 22 + 7, width: 20, height: 20)
public let kProjectCellWidth        = (kScreenWidth - 3 * 5) / 2

// mind
public let kMindIconViewSize        = CGFloat(30)
public let kMindInteritemSpacing    = CGFloat(18)
public let kMindVerticalSpacing     = CGFloat(22)
public let kMindTextLabelWidth      = kScreenWidth - kMindIconViewSize - 3 * kMindInteritemSpacing
public let kMindTextLabelMinHeight  = CGFloat(39)
public let kMindSeparatorHeight     = kMindVerticalSpacing * 2
public let kMindFoldButtonSize      = CGFloat(36)

// audio sectin
public let kAudioToolBarHeight      = CGFloat(110)
public let kAudioTitleHeight        = CGFloat(60)
public let kAudioTagInfoViewHeight  = kScreenHeight - kAudioToolBarHeight - kAudioTitleHeight
public let kAudioTagCellHeight      = CGFloat(34)

public let kArticlePlusHeight       = CGFloat(24)
public let kArticleVerticlSpace     = CGFloat(20)
public let kArticleCellTopOffset    = kArticleVerticlSpace - kArticlePlusHeight / 2
public let kArticleCellBottomOffset = kArticleVerticlSpace + kArticlePlusHeight / 2

public let kArticleAudioHeight      = CGFloat(66)
public let kArticleAudioCellVS      = CGFloat(32)

/** PicSection */
public let kPicThumbH               = CGFloat(68)
public let kPicDetailH              = kScreenHeight - kPicThumbH    

/** UndocBox */
public let kBoxHeaderHeight         = CGFloat(34)

/** Outline */
public let kOutlineCellHeight       = CGFloat(60)
public let kOutlineEditBarW         = CGFloat(90)

/** Common */
public let MaxPicCount              = 4
public let kEdgePopGesWidth         = CGFloat(30)

public let kTmpImageName            = "article_tmp_image"

public let kSpiderLevelCount        = 5

/** Shared Prenc */
//public let 

final public class SpiderConfig {
    static let sharedInstance = SpiderConfig()
    
    var project: ProjectObject? = nil
//    var projectID: String = ""
    
    public struct ArticleList {
        
        static var article: MindObject?
        static var insertIndex: Int? = 0
        static var showIndex: Int? = 0
        
        static func reset() {
            article = nil
            insertIndex = 0
        }
    }
    
    public struct Color {
        public static let LightText  = UIColor.color(withHex: 0xffffff)
        public static let DarkText   = UIColor.color(withHex: 0x222222)
        public static let HintText   = UIColor.color(withHex: 0xdddddd)
        public static let ButtonText = UIColor.color(withHex: 0x4caf50)
        
        public static let BackgroundDark = UIColor.color(withHex: 0x555555)
        public static let Line = UIColor.color(withHex: 0xeaeaea)
        
        public static let EditTheme  = UIColor.color(withHex: 0xc1c1c1)
    }
    
    public struct Font {
        public static let Text = UIFont.systemFont(ofSize: 16)
        public static let Title = UIFont.systemFont(ofSize: 14)
    }
}

// MARK: - Spider Struct
var SPIDERSTRUCT = SpiderStruct.sharedInstance
class SpiderStruct {
    static let sharedInstance = SpiderStruct()
    var currentLevel: Int = 0
    var structLevel: Int = 0
    var allPushMindPath = [String]()
    var currentMindPath: String? = nil // 当前结构路径
    var lastMind: Object?
    var selectLevelItem: StructLevelItem?
    var sourceMindType: SourceMindControType?
    
    fileprivate init() {}
}


//public var kCurrentLevel = SpiderStruct.sharedInstance.currentLevel
//public var kStructLevel = SpiderStruct.sharedInstance.structLevel
