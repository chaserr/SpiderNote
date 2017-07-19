//
//  PicSectionObject.swift
//  Spider
//
//  Created by ooatuoo on 16/7/29.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation
import RealmSwift

class PicSectionObject: Object {
    
    /** url */
    dynamic var url: String = ""
    
    /** pic ID */
    dynamic var id: String = ""
        
    /** 子标记 */
    let tags = List<TagObject>()
    
    let owner = LinkingObjects(fromType: SectionObject.self, property: "pics")
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(url: String) {
        self.init()
        
        self.id  = UUID().uuidString
        self.url = url
    }
    
    /** ignored properties */
    
    var index: Int? {
        return owner.first?.pics.indexOf(self)
    }
}

open class PicInfo {
    var id: String
    var url: URL?
    var image: UIImage?
    
    init(object: PicSectionObject) {
        self.url   = object.url.toSpiderURL()
        self.id    = object.url
        self.image = nil
    }
    
    init(tagObject: TagObject) {
        self.id = tagObject.content
        self.url = tagObject.content.toSpiderURL()
        self.image = nil
    }
    
    init(id: String = "", image: UIImage, url: URL? = nil) {
        self.id    = id
        self.url   = url
        self.image = image
    }
    
    // tmp
    init() {
        id = ""
        url = nil
        image = UIImage(named: "article_tmp_image")
    }
}
