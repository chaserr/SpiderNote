//
//  AudioSectionObject.swift
//  Spider
//
//  Created by ooatuoo on 16/7/29.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation
import RealmSwift

class AudioSectionObject: Object {
    
    /** sourceID */
    dynamic var url: String = ""
    /** 时长 */
    dynamic var duration: String = ""
    /** id */
    dynamic var id: String = ""
    
    dynamic var audioTagIds: String = ""
    /** 标记 */
    var tags = List<TagObject>()
    
    convenience init(url: String, duration: String) {
        self.init()
        
        self.id = UUID().uuidString
        self.url = url
        self.duration = duration
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

public struct AudioInfo {
    var id: String  = ""
    var url: URL? = nil
    var duration: String = ""
    var ownerID: String = ""
    
    init(object: TagObject) {
        self.id = object.content
        self.duration = object.duration
        self.url = object.content.toSpiderURL()
    }
    
    init(section: SectionObject) {
        self.ownerID = section.id
        
        guard let audio = section.audio else { return }
        
        self.id = audio.url
        self.duration = audio.duration
        
        self.url = audio.url.toSpiderURL()
    }
    
    init(id: String, duration: String) {
        self.id = id
        self.duration = duration
    }
}
