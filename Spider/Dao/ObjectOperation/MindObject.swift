//
//  MindObject.swift
//  Spider
//
//  Created by 童星 on 16/7/7.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation
import RealmSwift

public enum MindType: Int {
    case mind = 0
    case article = 1
}

class MindObject: Object {
    
    dynamic var id: String = ""
    dynamic var type: Int = MindType.mind.rawValue
    dynamic var name: String = ""
    dynamic var modifiyFlag: Int = 0
    dynamic var deleteFlag: Int = 0
    /**同步时间*/
    dynamic var syncTimesTamp: String = ""
    dynamic var createAtTime: String = ""
    /**更新时间*/
    dynamic var updateAtTime: String = ""
    
    // 子节点 (type == .Mind)
    let subMinds = List<MindObject>()
    
    // 子段落 (type == .Article)
    let sections = List<SectionObject>()
    
    // 父节点为 Mind
    let ownerMind = LinkingObjects(fromType: MindObject.self, property: "subMinds")
    
    // 父节点为 Project
    let ownerProject = LinkingObjects(fromType: ProjectObject.self, property: "minds")
    
    convenience init(name: String, type: Int) {
        self.init()
        self.type = type
        self.name = name
        self.id = UUID().uuidString
        self.modifiyFlag = 1
        self.createAtTime = Date().toString()
        self.updateAtTime = createAtTime
        self.syncTimesTamp = createAtTime
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return []
    }
}

extension MindObject {

    // 在兄弟节点中的位置
    var index: Int {
        if let mind = ownerMind.first {     // 父节点为 Mind
            return mind.subMinds.indexOf(self)!
        } else {                            // 父节点为 Project
            return ownerProject.first!.minds.indexOf(self)!
        }
    }
    
    /**  所在层级 */
    var level: Int {
        if let mind = ownerMind.first {
            return mind.level + 1
        } else {
            return 1
        }
    }
    
    /** 是否为兄弟节点中最后一个 */
    var isLast: Bool {
        if let mind = ownerMind.first {
            let subminds = mind.usefulMinds
            return subminds.indexOf(self)! == subminds.count - 1 ? true : false
        } else {
            let subminds = ownerProject.first!.usefulMinds
            return subminds.indexOf(self)! == subminds.count - 1 ? true : false
        }
    }
    
    /** 是否有子节点 */
    var foldable: Bool {
        return !usefulMinds.isEmpty
    }
    
    var usefulMinds: Results<MindObject> {
        return subMinds.filter("deleteFlag == 0")
    }
    
    var linkMinds: [MindObject] {
        var minds = [MindObject]()
        minds.append(self)
        var superMind = ownerMind.first
        
        repeat {
            if let superM = superMind {
                superMind = superM.ownerMind.first
                minds.append(superM)
            } else {
                minds.removeLast()
                break
            }
        } while true
        
        return minds
    }
    
    var outlineInfo: String? {
        var outline = self.id
        var superMind = self
        
        repeat {
            if let superM = superMind.ownerMind.first {
                if superM.deleteFlag == 0 {
                    superMind = superM
                    outline = "\(superM.id)>" + outline
                } else {
                    return nil
                }
            } else {
                if let project = superMind.ownerProject.first {
                    
                    if project.deleteFlag == 0 {
                        outline = "\(project.id)>" + outline
                        break
                    } else {
                        return nil
                    }
                    
                } else {
                    return nil
                }
            }
            
        } while true
        
        return outline
    }
    
    var structInfo: String {
        var info = name
        var superMind = ownerMind.first
        var mind: MindObject = self
        
        repeat {
            if let superM = superMind {
                info = superM.name + " > " + info
                mind = superM
                superMind = superM.ownerMind.first
            } else {
                info = mind.ownerProject.first!.name + " > " + info
                break
            }
        } while true
        
        return info
    }
    
    var noteID: String {
        var superMind = ownerMind.first
        var mind: MindObject = self
        var noteid: String = ""
        
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
    
    var project: ProjectObject? {
        var superMind = self
        
        repeat {
            if let superM = superMind.ownerMind.first {
                superMind = superM
            } else {
                return superMind.ownerProject.first
            }
            
        } while true
    }
    
    var depth: Int {
        var depth = 1
        
        func getDepth(_ mind: MindObject, deep: Int) {
            if mind.usefulMinds.isEmpty {
                depth = max(depth, deep)
            } else {
                for submind in mind.usefulMinds {
                    getDepth(submind, deep: deep + 1)
                }
            }
        }
        
        getDepth(self, deep: 1)
        return depth
    }
    
    var ownerID: String {
        if let mind = ownerMind.first {
            return mind.id
        } else {
            return ownerProject.first!.id
        }
    }
    
    func removeSubmind(_ mind: MindObject) {
        if let index = subMinds.indexOf(mind) {
            subMinds.removeAtIndex(index)
        }
    }
    
    func removeSubmindWith(_ id: String) -> MindObject? {
        guard let submind = REALM.realm.objectForPrimaryKey(MindObject.self, key: id) else { return nil }
        removeSubmind(submind)
        return submind
    }
    
    func update(_ time: String = Date().toString()) {
        modifiyFlag = 1
        updateAtTime = time
//        project?.update(time)
    }
    
    func deleteAt(_ time: String = Date().toString()) {
        deleteFlag = 1
        modifiyFlag = 1
        updateAtTime = time
    }
}

extension MindObject{

    /**
     数据查询
     
     - parameter predicate:       查询谓词
     - parameter sortDescriptors: 按条件排序查询结果 // 谓词查询
     
     - returns: MindObject
     */
     func fetchAllMindTypeList(_ predicate: NSPredicate, sortDescriptors: [SortDescriptor]) -> [MindObject] {
        
        var mindTypes:Results<MindObject>

        mindTypes = (realm?.objects(MindObject).filter(predicate).sorted(sortDescriptors))!
        
        var mindTypeList:[MindObject] = []
        for mindType in mindTypes {
            mindTypeList.append(mindType)
        }
        
        return mindTypeList
    }

}
