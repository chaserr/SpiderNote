//
//  OutlineLayout.swift
//  Spider
//
//  Created by ooatuoo on 16/8/29.
//  Copyright © 2016年 auais. All rights reserved.
//

import Foundation

public enum OutlineStatus: Int {
    case opened = 0
    case closed = 1
    case unable = 2
}

typealias IndexRange = CountableClosedRange<Int>

public struct OutlineLayout {

    var minds                   = [MindObject]()
    var editIndex: Int?         = nil
    var projectID               = ""// current show project ID
    var openedMindIndex: [Int?] = Array(repeating: nil, count: kSpiderLevelCount)
    
    var offset: CGPoint         = CGPoint.zero
    
    var chooseMind: MindObject? {
        guard let index = editIndex else { return nil }
        return minds[index]
    }
    
    func statusOf(_ index: Int) -> OutlineStatus {
        let mind = minds[index]
        
        if let submind = mind.subMinds.filter("deleteFlag == 0").first {
            
            if index == minds.count - 1 {
                
                return .closed
                
            } else {
                
                if minds[index+1].id == submind.id {
                    return .opened
                } else {
                    return .closed
                }
            }
            
        } else {
            
            return .unable
        }
    }
    
    init() {
        
    }
            
    init(mainNote: ProjectObject) {
        if let outline = UserDefaults.standard.string(forKey: mainNote.id.toNSDefaultKey()) {
            
            let subminds = outline.components(separatedBy: ">")
            
            if let id = subminds.last, let lastMind = REALM.realm.object(ofType: MindObject.self, forPrimaryKey: id as AnyObject), lastMind.outlineInfo == outline {
                
                for i in 0 ..< subminds.count {
                    if i == 0 {
                        let showNote = REALM.realm.object(ofType: ProjectObject.self, forPrimaryKey: subminds[i] as AnyObject)!
                        self.projectID = showNote.id
                        minds.append(contentsOf: showNote.usefulMinds)
                    } else {
                        let mind = REALM.realm.object(ofType: MindObject.self, forPrimaryKey: subminds[i] as AnyObject)!
                        let index = minds.index(of: mind)!
                        openedMindIndex[i] = index
                        minds.insert(contentsOf: mind.usefulMinds, at: index+1)
                    }
                }
                
            } else {
                
                self.projectID = mainNote.id
                minds.append(contentsOf: mainNote.usefulMinds)
                
                UserDefaults.standard.removeObject(forKey: mainNote.id.toNSDefaultKey())
                UserDefaults.standard.synchronize()
            }
            
        } else {
            
            self.projectID = mainNote.id
            minds.append(contentsOf: mainNote.usefulMinds)
        }
    }
    
    func recordOutlineInfo() {
        if let mind = chooseMind {
            
            UserDefaults.standard.set(mind.outlineInfo, forKey: projectID.toNSDefaultKey())
            UserDefaults.standard.synchronize()
        }
    }
    
    mutating func insertAtTop(_ mind: MindObject) {
        minds.insert(mind, at: 0)
        
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
        
        if let openedIndex = openedMindIndex[level], openedIndex != index {
            if statusOf(openedIndex) == .opened {
                
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
    
    mutating func openMind(_ mind: MindObject) -> IndexRange? {
        guard let index = minds.index(of: mind) else { return nil }
        let subminds = mind.usefulMinds
        
        if subminds.count > 0 {
            openedMindIndex[minds[index].level] = index
            minds.insert(contentsOf: subminds, at: index + 1)
            return (index+1 ... index+subminds.count) 
        } else {
            println("OutlineLayout openMind Failed: find \(subminds.count) subminds")
            return nil
        }
    }
    
    mutating func closeMind(at index: Int) -> IndexRange? {
        let closeLevel = minds[index].level
        var range: IndexRange = 0 ... 0 as IndexRange
        
        for i in index+1 ..< minds.count {
            if minds[i].level > closeLevel {
                range = index+1 ... i
            } else {
                break
            }
        }
        
        if range.upperBound > range.lowerBound {
            
            openedMindIndex[closeLevel] = nil
            minds.removeSubrange(range)
            return range
            
        } else {
            
            println("OutlineLayout closeMind Failed: can't remove subminds")
            return nil
        }
    }
}
