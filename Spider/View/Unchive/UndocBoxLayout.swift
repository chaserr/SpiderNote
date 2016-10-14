//
//  UndocBoxLayout.swift
//  Spider
//
//  Created by ooatuoo on 16/8/20.
//  Copyright © 2016年 auais. All rights reserved.
//

import Foundation

public struct UndocBoxLayout {
    
    var type: SectionType = .Text
    var timeTamp: String = ""
    var selected: Bool = false
    
    var text: String?     = "Not Found"
    var picInfo: PicInfo? = nil
    var duration: String? = nil
    
    init(section: SectionObject) {
        guard let type = SectionType(rawValue: section.type) else { return }
        self.type = type
        self.timeTamp = section.updateAt.toUndocCellTime()
        
        switch type {
            
        case .Text:
            self.text = section.text
            
        case .Pic:
            guard let picObject = section.pics.first else { return }
            self.picInfo = PicInfo(object: picObject)
            
        case .Audio:
            self.duration = section.audio?.duration
        }
    }
}

struct UndocBoxLayoutPool {
    var choosedAll = false
    var sectionLayoutHash = [String: UndocBoxLayout]()
    
    mutating func cellLayoutOfSection(section: SectionObject) -> UndocBoxLayout {
        let key = section.id
        
        if var layout = sectionLayoutHash[key] {
            
            layout.text = section.text
            return layout
            
        } else {
            
            var layout = UndocBoxLayout(section: section)
            layout.selected = choosedAll
            updateCellLayout(layout, forSection: section)
            
            return layout
        }
    }
    
    mutating func updateSelectState(section: SectionObject) -> Bool {
        guard let layout = sectionLayoutHash[section.id] else { return false}
        
        sectionLayoutHash[section.id]!.selected = !layout.selected
        
        return !layout.selected
    }
    
    mutating func chooseAllItem(selected: Bool) {
        choosedAll = selected
        
        for (id, _) in sectionLayoutHash {
            sectionLayoutHash[id]?.selected = selected
        }
    }
    
    mutating func updateCellLayout(layout: UndocBoxLayout, forSection section: SectionObject) {
        
        let key = section.id
        
        if !key.isEmpty {
            sectionLayoutHash[key] = layout
        }
    }
    
    func chooseItemIDs() -> [String] {
        var ids = [String]()
        
        sectionLayoutHash.forEach { (id, layout) in
            if layout.selected { ids.append(id) }
        }

        return ids
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
}
