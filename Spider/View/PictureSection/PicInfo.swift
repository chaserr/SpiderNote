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
    case Text  = 0
    case Pic   = 1
    case Audio = 2
}

enum PicState: Int {
    case New      = 0
    case Normal   = 1
    case Deleted  = 2
    case Modified = 3
}

struct PicTagInfo {
    
    var id: String
    var type: TagType
    var perXY: CGPoint
    
    var state = PicState.Normal
    var direction = TagDirection.Right
    
    var content:   String?    = nil
    var audioInfo: AudioInfo? = nil
    var picInfo:   PicInfo?   = nil
    
    init(object: TagObject) {
        
        self.id        = object.id
        self.type      = TagType(rawValue: object.type)!
        self.perXY     = object.location.toCGPoint()
        self.direction = TagDirection(rawValue: object.direction)!
        
        switch type {
            
        case .Pic:
            picInfo = PicInfo(tagObject: object)
            
        case .Text:
            content = object.content
            
        case .Audio:
            audioInfo = AudioInfo(object: object)
        }
    }
    
    init(id: String, type: TagType, perXY: CGPoint, picInfo: PicInfo? = nil, audioInfo: AudioInfo? = nil, content: String? = nil) {
        
        self.id        = id
        self.type      = type
        self.perXY     = perXY
        self.state     = .New
        
        switch type {
            
        case .Text:
            self.content = content
            
        case .Pic:
            self.picInfo = picInfo
            guard let image = picInfo?.image else { return }
            image.saveToDisk(withid: id)
            
        case .Audio:
            self.audioInfo = audioInfo
        }
    }
}

public struct PicSectionInfo {
    
    var tags  = [String: PicTagInfo]()
    var state = PicState.Normal
    var picInfo: PicInfo

    init(object: PicSectionObject) {

        self.picInfo = PicInfo(object: object)
        
        for tag in object.tags {
            tags[tag.id] = PicTagInfo(object: tag)
        }
    }
    
    init(photo: UIImage) {
        
        let id = NSUUID().UUIDString
        photo.saveToDisk(withid: id)
        
        self.state = PicState.New
        self.picInfo = PicInfo(id: id, image: photo)
    }
}



