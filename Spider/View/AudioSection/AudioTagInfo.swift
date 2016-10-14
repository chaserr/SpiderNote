//
//  AudioTagInfo.swift
//  Spider
//
//  Created by Atuooo on 5/25/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import Foundation

enum AudioTagType: Int {
    case Text = 0
    case Pic  = 1
}

struct AudioTagInfo {
    var id: String
    var type = AudioTagType.Text
    
    var time: String
    var pic: PicInfo?
    var content: String?
    
    var selected: Bool = false
    var height: CGFloat = kAudioTagCellHeight
    
    init(content: String? = nil, pic: UIImage? = nil, selected: Bool, time: String, height: CGFloat = kAudioTagCellHeight) {
        
        self.id       = NSUUID().UUIDString
        self.height   = height
        self.time     = time
        self.selected = selected
        
        if let text = content {
            self.content = text
            self.type = .Text
        }
        
        if let pic = pic {
            pic.saveToDisk(withid: id)
            self.pic    = PicInfo(id: id, image: pic)
            self.type    = .Pic
        }
    }
    
    init(tag: TagObject) {
        
        self.id = tag.id
        self.time = tag.location
        
        guard let type = AudioTagType(rawValue: tag.type) else { return }
        self.type = type
        
        switch type {
            
        case .Text:
            self.content = tag.content
            
        case .Pic:
            pic = PicInfo(tagObject: tag)
        }
        
    }
}