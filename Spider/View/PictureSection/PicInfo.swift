//
//  PicInfo.swift
//  Spider
//
//  Created by Atuooo on 5/30/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import Foundation
import RealmSwift

enum PicTagType: Int {
    case text  = 0
    case pic   = 1
    case audio = 2
}

enum PicState: Int {
    case new      = 0
    case normal   = 1
    case deleted  = 2
    case modified = 3
}

struct PicTagInfo {
    
    var id: String
    var type: TagType
    var perXY: CGPoint
    
    var state = PicState.normal
    var direction = TagDirection.right
    
    var content:   String?    = nil
    var audioInfo: AudioInfo? = nil
    var picInfo:   PicInfo?   = nil
    
    init(object: TagObject) {
        
        self.id        = object.id
        self.type      = TagType(rawValue: object.type)!
        self.perXY     = object.location.toCGPoint()
        self.direction = TagDirection(rawValue: object.direction)!
        
        switch type {
            
        case .pic:
            picInfo = PicInfo(tagObject: object)
            
        case .text:
            content = object.content
            
        case .audio:
            audioInfo = AudioInfo(object: object)
        }
    }
    
    init(id: String, type: TagType, perXY: CGPoint, picInfo: PicInfo? = nil, audioInfo: AudioInfo? = nil, content: String? = nil) {
        
        self.id        = id
        self.type      = type
        self.perXY     = perXY
        self.state     = .new
        
        switch type {
            
        case .text:
            self.content = content
            
        case .pic:
            self.picInfo = picInfo
            guard let image = picInfo?.image else { return }
            image.saveToDisk(withid: id)
            
        case .audio:
            self.audioInfo = audioInfo
        }
    }
}

public struct PicSectionInfo {
    
    var tags  = [String: PicTagInfo]()
    var state = PicState.normal
    var picInfo: PicInfo

    init(object: PicSectionObject) {

        self.picInfo = PicInfo(object: object)
        
        for tag in object.tags {
            tags[tag.id] = PicTagInfo(object: tag)
        }
    }
    
    init(photo: UIImage) {
        
        let id = UUID().uuidString
        photo.saveToDisk(withid: id)
        
        self.state = PicState.new
        self.picInfo = PicInfo(id: id, image: photo)
    }
}



