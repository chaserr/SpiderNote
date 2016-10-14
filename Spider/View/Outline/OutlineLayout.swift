//
//  OutlineLayout.swift
//  Spider
//
//  Created by ooatuoo on 16/8/29.
//  Copyright © 2016年 auais. All rights reserved.
//

import Foundation

public enum OutlineStatus: Int {
    case Opened = 0
    case Closed = 1
    case Unable = 2
}

typealias IndexRange = Range<Int>

public struct OutlineLayout {

    var minds                   = [MindObject]()
    var editIndex: Int?         = nil
    var projectID               = ""// current show project ID
    var openedMindIndex: [Int?] = Array(count: kSpiderLevelCount, repeatedValue: nil)
    
    var offset: CGPoint         = CGPointZero
    
    var chooseMind: MindObject? {
        guard let index = editIndex else { return nil }
        return minds[index]
    }
    
    func statusOf(index: Int) -> OutlineStatus {
        let mind = minds[index]
        
        if let submind = mind.subMinds.filter("deleteFlag == 0").first {
            
            if index == minds.count - 1 {
                
                return .Closed
                
            } else {
                
                if minds[index+1].id == submind.id {
                    return .Opened
                } else {
                    return .Closed
                }
            }
            
        } else {
            
            return .Unable
        }
    }
    
    init() {
        
    }
            
    init(mainNote: ProjectObject) {
        if let outline = NSUserDefaults.standardUserDefaults().stringForKey(mainNote.id.toNSDefaultKey()) {
            
            let subminds = outline.componentsSeparatedByString(">")
            
            if let id = subminds.last, lastMind = REALM.realm.objectForPrimaryKey(MindObject.self, key: id)
                where lastMind.outlineInfo == outline {
                
                for i in 0 ..< subminds.count {
                    if i == 0 {
                        let showNote = REALM.realm.objectForPrimaryKey(ProjectObject.self, key: subminds[i])!
                        self.projectID = showNote.id
                        minds.appendContentsOf(showNote.usefulMinds)
                    } else {
                        let mind = REALM.realm.objectForPrimaryKey(MindObject.self, key: subminds[i])!
                        let index = minds.indexOf(mind)!
                        openedMindIndex[i] = index
                        minds.insertContentsOf(mind.usefulMinds, at: index+1)
                    }
                }
                
            } else {
                
                self.projectID = mainNote.id
                minds.appendContentsOf(mainNote.usefulMinds)
                
                NSUserDefaults.standardUserDefaults().removeObjectForKey(mainNote.id.toNSDefaultKey())
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            
        } else {
            
            self.projectID = mainNote.id
            minds.appendContentsOf(mainNote.usefulMinds)
        }
    }
    
    func recordOutlineInfo() {
        if let mind = chooseMind {
            
            NSUserDefaults.standardUserDefaults().setObject(mind.outlineInfo, forKey: projectID.toNSDefaultKey())
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    mutating func insertAtTop(mind: MindObject) {
        minds.insert(mind, atIndex: 0)
        
        if let index = editIndex {
            editIndex = index + 1
        }

        for i in 0 ..< openedMindIndex.count {
            if let index = openedMindIndex[i] {
                openedMindIndex[i] = index + 1
            }
        }
    }
    
    mutating func closeOpenedMindOfLevel(at index: Int) -> IndexRange? {
        let level = minds[index].level
        
        if let openedIndex = openedMindIndex[level] where openedIndex != index {
            if statusOf(openedIndex) == .Opened {
                
                for lv in level ... kSpiderLevelCount - 1 {
                    openedMindIndex[lv] = nil
                }
                
                return closeMind(at: openedIndex)
                
            } else {
                
                openedMindIndex[level] = nil

                return nil
            }

        } else {
            return nil
        }
    }
    
    mutating func openMind(mind: MindObject) -> IndexRange? {
        guard let index = minds.indexOf(mind) else { return nil }
        let subminds = mind.usefulMinds
        
        if subminds.count > 0 {
            openedMindIndex[minds[index].level] = index
            minds.insertContentsOf(subminds, at: index + 1)
            return index+1 ... index+subminds.count
        } else {
            println("OutlineLayout openMind Failed: find \(subminds.count) subminds")
            return nil
        }
    }
    
    mutating func closeMind(at index: Int) -> IndexRange? {
        let closeLevel = minds[index].level
        var range: IndexRange = 0 ... 0
        
        for i in index+1 ..< minds.count {
            if minds[i].level > closeLevel {
                range = index+1 ... i
            } else {
                break
            }
        }
        
        if range.endIndex > range.startIndex {
            
            openedMindIndex[closeLevel] = nil
            minds.removeRange(range)
            return range
            
        } else {
            
            println("OutlineLayout closeMind Failed: can't remove subminds")
            return nil
        }
    }
}
