//
//  ArticleModel.swift
//  Spider
//
//  Created by 童星 on 16/8/8.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class ArticleModel: NSObject {

    var title: String?
    var updateTime: String?
    /** 文字段落 */
    var textSectionArr: Array   = [SectionObject]()
    /** 音频段落 */
    var vedioSectionArr: Array = [SectionObject]()
    /** 图片段落 */
    var picSectionArr: Array   = [PicSectionObject]()
    
    var cellRowHight: CGFloat = 0

    
}
