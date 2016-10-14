//
//  SectionObject.swift
//  Spider
//
//  Created by 童星 on 16/7/7.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  段落碎片

import Foundation
import Realm
import RealmSwift

public enum SectionType: Int {
    case Text   = 0
    case Pic    = 1
    case Audio  = 2
}

class SectionObject: Object {
    
    /** ID */
    dynamic var id: String = ""
    /** 更新时间 */
    dynamic var updateAt: String = ""
    /** 同步时间 */
    dynamic var syncTimesTamp: String = ""
    /** 修改标志位 */
    dynamic var modifiyFlag: Int = 0
    /** 未归档标志位 */
    dynamic var undocFlag: Int = 0
    /** 删除标志位 */
    dynamic var deleteFlag: Int = 0
    /** 类型 */
    dynamic var type: Int = SectionType.Text.rawValue    
    /** type = Text */
    dynamic var text: String? = ""
    
    /** type = Pic */
    let pics = List<PicSectionObject>()
    
    /** type = Audio */
    dynamic var audio: AudioSectionObject?
    
    /** 父节点 */
    let owner = LinkingObjects(fromType: MindObject.self, property: "sections")

    convenience init(type: SectionType, undoc: Int = 0, text: String? = nil) {
        self.init()

        self.id            = NSUUID().UUIDString
        self.type          = type.rawValue
        self.text          = text
        self.undocFlag     = undoc
        self.updateAt      = NSDate().toString()
        self.syncTimesTamp = updateAt
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension SectionObject {
    
    var ownerName: String {
        if undocFlag == 1 {
            return "未归档"
        } else {
            if let article = owner.first {
                return article.name
            } else {
                return "Not Found Owner"
            }
        }
    }
    
    var ownerID: String? {
        if let article = owner.first {
            return article.id
        } else {
            return nil
        }
    }
    
    /** tag Count */
    var tagCount: Int {
        guard let type = SectionType(rawValue: type) else { return 0 }
        
        switch type {
            
        case .Audio:
            return audio!.tags.count
            
        case .Pic:
            var count = 0
            let _ = pics.map({ count += $0.tags.count })
            return count
            
        default:
            return 0
        }
    }
    
    /** 项目ID */
    var projectID: String {
        var noteid: String = ""
        let articleMind: MindObject? = owner.first
        if articleMind == nil {
            // 未归档
            return noteid
        }
        var superMind: MindObject? = articleMind!.ownerMind.first
        var mind: MindObject = articleMind!
        
        repeat {
            if let superM = superMind {
                mind = superM
                superMind = superM.ownerMind.first
            } else {
                noteid = mind.ownerProject.first!.id
                break
            }
            
        } while true
        return noteid
    }

    var indexOfOwner: Int? {
        return owner.first?.sections.indexOf(self)
    }
    
    func update(time: String = NSDate().toString()) {
        updateAt = time
        modifiyFlag = 1
    }
}
