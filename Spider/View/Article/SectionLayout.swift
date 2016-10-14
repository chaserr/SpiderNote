//
//  SectionLayout.swift
//  Spider
//
//  Created by ooatuoo on 16/7/31.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation

public struct SectionLayout {
    var type                       = SectionType.Text
    var height                     = CGFloat(0)
    var selected                   = false

    var text: String?              = "Not Found"
    var tagCount: Int              = 0

    var pics: [PicInfo]?           = nil

    var audioDuration: String?     = nil
    var playedTime: NSTimeInterval = 0.0
    
    init(section: SectionObject) {
        text          = section.text
        tagCount      = section.tagCount
        
        type = SectionType(rawValue: section.type)!
        
        switch type {
            
        case .Pic:
            pics = section.pics.map({ PicInfo(object: $0) })
            height = 250 + kArticleVerticlSpace * 2
            
        case .Audio:
            audioDuration = section.audio?.duration
            height = kArticleAudioHeight + kArticleAudioCellVS * 2
                        
        case .Text:
            let rect = section.text!.boundingRectWithSize(CGSize(width: kScreenWidth - 16 * 2, height: CGFloat(FLT_MAX)), options: [.UsesFontLeading, .UsesLineFragmentOrigin], attributes: [NSFontAttributeName: SpiderConfig.Font.Text], context: nil)
            
            height = ceil(rect.height) + kArticleVerticlSpace * 2
        }
    }
}

public struct LayoutPool {
    
    var choosedAll = false
    var sectionLayoutHash = [String: SectionLayout]()
    
    mutating func cellLayoutOfSection(section: SectionObject) -> SectionLayout {
        let key = section.id
        
        if let layout = sectionLayoutHash[key] {
            return layout
            
        } else {
            
            var layout = SectionLayout(section: section)
            layout.selected = choosedAll
            updateCellLayout(layout, forSection: section)
            return layout
        }
    }
    
    mutating func updateCellLayout(layout: SectionLayout, forSection section: SectionObject) {
        let key = section.id
        
        if !key.isEmpty {
            sectionLayoutHash[key] = layout
        }
    }
    
    mutating func heightOfSection(section: SectionObject) -> CGFloat {
        let layout = cellLayoutOfSection(section)
        return layout.height
    }
    
    mutating func chooseAllItem(selected: Bool) {
        choosedAll = selected
        
        for (id, _) in sectionLayoutHash {
            sectionLayoutHash[id]?.selected = selected
        }
    }
    
    mutating func updateSelectState(section: SectionObject) -> Bool {
        guard let layout = sectionLayoutHash[section.id] else { return false}
        
        sectionLayoutHash[section.id]!.selected = !layout.selected
        
        return !layout.selected
    }
    
    mutating func deleteChoosed() -> [String] {
        var ids = [String]()
        
        for (id, layout) in sectionLayoutHash {
            if layout.selected {
                ids.append(id)
                sectionLayoutHash.removeValueForKey(id)
            }
        }
        
        return ids
    }
    
    mutating func choosedItems() -> [String] {
        var ids = [String]()
        
        for (id, layout) in sectionLayoutHash {
            if layout.selected {
                ids.append(id)
            }
        }
        
        return ids
    }
    
    mutating func updatePlayedTimeOfSection(section: SectionObject) -> SectionLayout {
        let layout = cellLayoutOfSection(section)
        
        if section.id == SpiderPlayer.sharedManager.playingID {
            if let player = SpiderPlayer.sharedManager.player {
                sectionLayoutHash[section.id]?.playedTime = player.currentTime
                return sectionLayoutHash[section.id]!
            }
        }
        
        return layout
    }
}
