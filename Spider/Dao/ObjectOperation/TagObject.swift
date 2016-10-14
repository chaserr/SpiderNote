//
//  TagObject.swift
//  Spider
//
//  Created by 童星 on 16/7/7.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation
import RealmSwift

public enum TagType: Int {
    case Text  = 0
    case Pic   = 1
    case Audio = 2
}

public enum TagDirection: Int {
    case Right = 0
    case Left  = 1
    case None  = 2
}

class TagObject: Object {
    
    /** ID */
    dynamic var id: String = ""
    
    /** 标记类型 */
    dynamic var type: Int = TagType.Text.rawValue
    
    /** 若 type 为 Text, 则为文字内容
        若 type 为 Audio/Pic，则为 sourceID */
    dynamic var content: String = ""
    
    dynamic var sourceUrl: String = ""
    dynamic var isLeft: Int = 0
    dynamic var timePoint: String = ""
    
    /** 方向 0 -> Left, 1 -> Right */
    dynamic var direction: Int = TagDirection.Right.rawValue
    
    /** 位置信息 */
    dynamic var location: String = ""
    
    /** type = .Audio */
    dynamic var duration: String = ""
    
    let audioOwner = LinkingObjects(fromType: AudioSectionObject.self, property: "tags")
    
    let picOwner = LinkingObjects(fromType: PicSectionObject.self, property: "tags")
    
    convenience init(tagInfo: PicTagInfo) {
        self.init()
        
        self.id        = NSUUID().UUIDString
        self.type      = tagInfo.type.rawValue
        self.location  = tagInfo.perXY.toString()
        self.direction = tagInfo.direction.rawValue
        
        switch tagInfo.type {
            
        case .Text:
            self.content   = tagInfo.content!
            
        case .Audio:
            self.duration  = tagInfo.audioInfo!.duration
            self.content   = tagInfo.audioInfo!.id

        case .Pic:
            self.content   = tagInfo.id
        }
    }
    
    convenience init(tagInfo: AudioTagInfo) {
        self.init()
        
        self.id       = NSUUID().UUIDString
        self.type     = tagInfo.type.rawValue
        self.location = tagInfo.time
        
        switch tagInfo.type {
            
        case .Text:
            self.content = tagInfo.content!
            
        case .Pic:
            self.content = tagInfo.id
        }
    }
    
    convenience init(tag: TagObject) {
        self.init()
        
        self.id = NSUUID().UUIDString
        self.type = tag.type
        self.location = tag.location
        self.direction = tag.direction
        self.content = tag.content
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension TagObject {
    var picOwnerIndex: Int? {
        return picOwner.first?.index
    }
    
    var indexInAudioTags: Int? {
        return audioOwner.first?.tags.indexOf(self)
    }
}
