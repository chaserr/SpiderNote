//
//  ProjectObject.swift
//  Spider
//
//  Created by ooatuoo on 16/7/21.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class ProjectObject: Object {
    
    dynamic var createAtTime: String = ""
    /**更新时间*/
    dynamic var updateAtTime: String = ""
    /**同步时间*/
    dynamic var syncTimesTamp: String = ""
    /**同步锁, 0->false,1->true*/
    dynamic var modifyFlag: Int = 0
    
    dynamic var id: String = ""
    
    dynamic var name: String = ""
    
    dynamic var deleteFlag: Int = 0

    let minds = List<MindObject>()
    
    convenience init(name: String) {
        self.init()
        self.name = name
        self.id = NSUUID().UUIDString
        self.createAtTime = NSDate().toString()
        self.updateAtTime = createAtTime
        self.syncTimesTamp = createAtTime
    }
    
    required convenience init(_ map: Map) {
        self.init()
        mapping(map)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension ProjectObject {
    
    var deviceId: String {
    
        return APPIdentificationManage.sharedInstance().readUUID()
    }
    
    var usefulMinds: Results<MindObject> {
        return minds.filter("deleteFlag == 0")
    }
    
    func update(time: String = NSDate().toString()) {
        modifyFlag = 1
        updateAtTime = time
    }
    
    func removeMind(mind: MindObject) {
        if let index = minds.indexOf(mind) {
            minds.removeAtIndex(index)
        }
    }
    
    func removeMindWith(id: String) -> MindObject? {
        guard let mind = REALM.realm.objectForPrimaryKey(MindObject.self, key: id) else { return nil}
        removeMind(mind)
        return mind
    }
}

extension ProjectObject: Mappable {

    func mapping(map: Map) {
        id              <- map["noteId"]
        name            <- map["name"]
        syncTimesTamp   <- map["syncTimestamp"]
        createAtTime    <- map["creatAt"]
        updateAtTime    <- map["updateAt"]
        modifyFlag     <- map["modifyFlag"]
        deleteFlag      <- map["deleteFlag"]
    }
}

extension Results {
    
    func toArray() -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            array.append(self[i])
        }
        return array
    }
}

extension ProjectObject{

    /** 根据ID 查询项目*/
    static func fetchOneProObject(targetId: String, project: ProjectObject?) -> ProjectObject {
        var projectObjArr: [ProjectObject] = []
        projectObjArr = REALM.realm!.objects(ProjectObject).filter("id = %@", targetId).toArray()
        var projectObj = projectObjArr.first
        if projectObj == nil {
            projectObj = createOneProOject(targetId, project: project)
        }
        return projectObj!
    }
    
    static func createOneProOject(targetId: String, project: ProjectObject?) -> ProjectObject {
        try! REALM.realm.write({
            REALM.realm.add(project!, update: true)
        })
        
        return fetchOneProObject(targetId, project: project)
        
    }
}
