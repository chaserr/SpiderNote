//
//  Realm+Spider.swift
//  Spider
//
//  Created by ooatuoo on 16/8/12.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation
import RealmSwift

//let realmQueue = dispatch_queue_create("com.Yep.realmQueue", DISPATCH_QUEUE_SERIAL)
//public let realmQueue = dispatch_queue_create("com.Yep.realmQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0))

// MARK: - Search
class SpiderRealm {
    
    class func getProjects() -> Results<ProjectObject> {
        return REALM.realm.objects(ProjectObject).filter("deleteFlag == 0").sorted("createAtTime", ascending: false)
    }
    
    class func getUndocItems() -> Results<SectionObject>! {
        return REALM.realm.objects(SectionObject.self).filter("undocFlag == 1 AND deleteFlag == 0")
    }
    
    class func getUndocItemCount() -> Int {
        return REALM.realm.objects(SectionObject.self).filter("undocFlag == 1 AND deleteFlag == 0").count
    }
    
    // MARK: - Undoc Box
    class func groupUndocItems(items: Results<SectionObject>? = nil) -> [[SectionObject]] {
        let undocItems = items ?? getUndocItems()
        let results = undocItems!.sorted("updateAt", ascending: false)
        var timeSortor = "...", index = 0, isOld = false
        var sortedResults = [[SectionObject]]()
        
        let _ = results.map { result in
            
            if result.updateAt.isThisYear() {
                
                if result.updateAt.toYearMonth() != timeSortor {
                    
                    index = sortedResults.count
                    timeSortor = result.updateAt.toYearMonth()
                    sortedResults.append([SectionObject]())
                    sortedResults[index].append(result)
                    
                } else {
                    
                    sortedResults[index].append(result)
                }
                
            } else {
                
                if !isOld {
                    isOld = true
                    index = sortedResults.count
                    sortedResults.append([SectionObject]())
                }
                
                sortedResults[index].append(result)
            }
            
        }
        
        return sortedResults
    }
    
    class func indexPathOf(section: SectionObject, in sectionSs: [[SectionObject]]) -> NSIndexPath {
        
        var indexPath = NSIndexPath(forItem: 0, inSection: 0)
        
        for i in 0 ..< sectionSs.count {
            for j in 0 ..< sectionSs[i].count {
                if sectionSs[i][j] == section {
                    indexPath = NSIndexPath(forItem: j, inSection: i)
                }
            }
        }
        
        return indexPath
    }
}

// MARK: - Tag
extension SpiderRealm {
    
    class func addTag(tag: TagObject, to audioSection: SectionObject, at index: Int) {
        
        guard let audio = audioSection.audio else { return }
        
        try! REALM.realm.write({ 
            REALM.realm.add(tag)
            audio.tags.insert(tag, atIndex: index)
            audioSection.update()
        })
    }
    
    class func updateTextTag(in audioSection: SectionObject, at index: Int, with text: String) {
        
        guard let audio = audioSection.audio else { return }
        
        try! REALM.realm.write({ 
            audio.tags[index].content = text
            audioSection.update()
        })
    }
    
    class func deleteTag(in audioSection: SectionObject, at index: Int) {
        
        guard let audio = audioSection.audio else { return }
        
        try! REALM.realm.write({ 
            audio.tags.removeAtIndex(index)
            audioSection.update()
        })
    }
}


// MARK: - Project

extension SpiderRealm {
    class func update(project: ProjectObject? = nil, text: String) {
        try! REALM.realm.write({ 
            if let project = project {
                project.name = text
                project.update()
            } else {
                let newNote = ProjectObject(name: text)
                REALM.realm.add(newNote, update: true)
            }
        })
    }
    
    class func remove(project: ProjectObject) {
        try! REALM.realm.write({ 
            project.deleteFlag = 1  // TODO: - SubItems set flag
            project.update()
        })
    }
}

// MARK: - Mind

extension SpiderRealm {
    
    class func swap(aMind: MindObject, _ bMind: MindObject, in owner: Object?) {
        guard let project = SpiderConfig.sharedInstance.project else { return }
        
        if let ownerMind = owner as? MindObject {
            
            guard let aIndex = ownerMind.subMinds.indexOf(aMind),
                bIndex = ownerMind.subMinds.indexOf(bMind) else { return }
            
            let time = NSDate().toString()
            
            try! REALM.realm.write {
                project.update(time)
                ownerMind.subMinds.swap(aIndex, bIndex)
                ownerMind.update(time)
            }
            
        } else {
            
            guard let project = owner as? ProjectObject,
                aIndex = project.minds.indexOf(aMind),
                bIndex = project.minds.indexOf(bMind) else { return }
            
            try! REALM.realm.write {
                project.minds.swap(aIndex, bIndex)
                project.update()
            }
        }
    }
    
    class func removeMind(mind: MindObject, in owner: Object?) {
        guard let mProject = SpiderConfig.sharedInstance.project else { return }

        try! REALM.realm.write({
            let time = NSDate().toString()
            mind.deleteAt(time)
            
            if let ownerMind = owner as? MindObject {
                ownerMind.update(time)
            } else {
                guard let project = owner as? ProjectObject else { return }
                project.update(time)
            }
            
            mProject.update(time)
        })
    }
    
    class func updateMind(mind: MindObject, text: String = "", to owner: Object? = nil) {
        try! REALM.realm.write({ 
            
            if let ownerMind = owner as? MindObject {
                
                ownerMind.subMinds.append(mind)
                ownerMind.update()
                
            } else if let project = owner as? ProjectObject {
                
                project.minds.append(mind)
                project.update()
                
            } else {
                
                mind.name = text
                mind.update()
            }
            
            REALM.realm.add(mind, update: true)
        })
    }
    
    class func addMind(mind: MindObject, to sMind: MindObject) {
        try! REALM.realm.write({ 
            REALM.realm.add(mind, update: true)
            sMind.subMinds.insert(mind, atIndex: 0)
            sMind.update()
        })
    }
    
    class func addMind(mind: MindObject, to noteID: String) {
        guard let note = REALM.realm.objectForPrimaryKey(ProjectObject.self, key: noteID) else { return }
        
        try! REALM.realm.write({ 
            REALM.realm.add(mind, update: true)
            note.minds.insert(mind, atIndex: 0)
            note.update()
        })
    }
    
    class func move(aMind: MindObject, to bMind: MindObject) {
        guard let mProject = SpiderConfig.sharedInstance.project else { return }

        try! REALM.realm.write({
            
            let time = NSDate().toString()
            
            if let ownerMind = aMind.ownerMind.first {
                ownerMind.removeSubmind(aMind)
                ownerMind.update(time)
            } else if let ownerNote = aMind.ownerProject.first {
                ownerNote.removeMind(aMind)
                ownerNote.update(time)
            }
            
            bMind.subMinds.append(aMind)
            bMind.update(time)
            mProject.update(time)
        })
    }
    
    class func moveMinds(mindIDs: [String], to toMind: MindObject) {
        //TODO:- Move Between Different Project
        guard let exID = mindIDs.first,
            exMind = REALM.realm.objectForPrimaryKey(MindObject.self, key: exID) else { return }
        
        let time = NSDate().toString()
        
        REALM.realm.beginWrite()
        
        if let ownerMind = exMind.ownerMind.first {
            
            for id in mindIDs {
                if let mind = ownerMind.removeSubmindWith(id) {
                    toMind.subMinds.append(mind)
                }
            }
            
            ownerMind.update(time)
            ownerMind.project?.update(time)
            
        } else if let ownerNote = exMind.ownerProject.first {
            
            for id in mindIDs {
                if let mind = ownerNote.removeMindWith(id) {
                    toMind.subMinds.append(mind)
                }
            }
            
            ownerNote.update(time)
        }
        
        toMind.update(time)
        toMind.project?.update(time)
        
        let _ = try? REALM.realm.commitWrite()
    }
    
    class func moveMinds(mindIDs: [String], to projectID: String) {
        //TODO:- Move Between Different Project
        guard let exID = mindIDs.first,
            exMind = REALM.realm.objectForPrimaryKey(MindObject.self, key: exID),
            project = REALM.realm.objectForPrimaryKey(ProjectObject.self, key: projectID)
        else { return }
        
        let time = NSDate().toString()
        
        REALM.realm.beginWrite()
        
        if let ownerMind = exMind.ownerMind.first {
            
            for id in mindIDs {
                if let mind = ownerMind.removeSubmindWith(id) {
                    project.minds.append(mind)
                }
            }
            
            ownerMind.update(time)
            ownerMind.project?.update(time)
            
        } else if let ownerNote = exMind.ownerProject.first {
            
            for id in mindIDs {
                if let mind = ownerNote.removeMindWith(id) {
                    project.minds.append(mind)
                }
            }
            
            ownerNote.update(time)
        }
        
        project.update(time)
        
        let _ = try? REALM.realm.commitWrite()
    }
    
    class func removeMindUp(mind: MindObject) {
        guard let mProject = SpiderConfig.sharedInstance.project else { return }

        try! REALM.realm.write({
            let time = NSDate().toString()
            
            if let ownerMind = mind.ownerMind.first {
                ownerMind.removeSubmind(mind)
                ownerMind.update(time)
                
                if let superMind = ownerMind.ownerMind.first {
                    superMind.subMinds.append(mind)
                    superMind.update(time)
                } else if let superNote = ownerMind.ownerProject.first {
                    superNote.minds.append(mind)
                    superNote.update(time)
                }
            }
            
            mProject.update(time)
        })
    }
}

// MARK: - Section
extension SpiderRealm {
    
    // MARK: - undocBox
    class func removeSection(section: SectionObject) {
        
        try! REALM.realm.write {
            section.modifiyFlag = 1
            section.deleteFlag = 1
            section.updateAt = NSDate().toString()
        }
    }
    
    class func removeSections(with ids: [String]) {
        try! REALM.realm.write({
            for id in ids {
                if let section = REALM.realm.objectForPrimaryKey(SectionObject.self, key: id) {
                    section.modifiyFlag = 1
                    section.deleteFlag = 1
                    section.updateAt = NSDate().toString()
                }
            }
        })
    }
    
    // MARK: - Article List
    class func swap(aSection: SectionObject, _ bSection: SectionObject) {
        guard let article = SpiderConfig.ArticleList.article,
                  aIndex  = article.sections.indexOf(aSection),
                  bIndex  = article.sections.indexOf(bSection) else { return }
        
        try! REALM.realm.write({
            article.sections.swap(aIndex, bIndex)
            article.update()
        })
    }
    
    class func move(aSection: SectionObject, to bSection: SectionObject) {
        guard let article = SpiderConfig.ArticleList.article,
            aIndex  = article.sections.indexOf(aSection),
            bIndex  = article.sections.indexOf(bSection) else { return }
        
        try! REALM.realm.write({
            article.sections.move(from: aIndex, to: bIndex)
            article.update()
        })
    }
    
    class func removeSection(section: SectionObject, in article: MindObject) {
        
        try! REALM.realm.write({ 
            section.deleteFlag = 1
            section.modifiyFlag = 1
            article.update()
        })
    }
    
    class func removeSections(sections: [SectionObject], in article: MindObject) {
        REALM.realm.beginWrite()
        
        for section in sections {
            section.deleteFlag = 1
            section.modifiyFlag = 1
        }
        
        article.update()
        let _ = try? REALM.realm.commitWrite()
    }
    
    class func insertUndocSection(aSection: SectionObject, before bSection: SectionObject? = nil) {
        guard let article = SpiderConfig.ArticleList.article else { return }
        
        REALM.realm.beginWrite()
        
        aSection.undocFlag = 0
        aSection.update()
        
        if let bSection = bSection, index = article.sections.indexOf(bSection) {
            article.sections.insert(aSection, atIndex: index)
        } else {
            article.sections.append(aSection)
        }
        
        article.update()
        
        let _ = try? REALM.realm.commitWrite()
    }
    
    class func insertUndocSection(section: SectionObject, to index: Int) {
        guard let article = SpiderConfig.ArticleList.article else { return }
        
        try! REALM.realm.write({
            section.undocFlag = 0
            section.update()
            article.sections.insert(section, atIndex: index)
            article.update()
        })
    }
    
    class func moveSections(ids: [String], to toArticle: MindObject) {
        
        //TODO:- Move Sections between different Project
        let fromArticle = SpiderConfig.ArticleList.article ?? nil
        let time = NSDate().toString()
        
        REALM.realm.beginWrite()

        for id in ids {
            if let section = REALM.realm.objectForPrimaryKey(SectionObject.self, key: id) {
                
                if let index = fromArticle?.sections.indexOf(section) {
                    fromArticle!.sections.removeAtIndex(index)
                } else {
                    section.undocFlag = 0
                }
                
                toArticle.sections.append(section)
            }
        }

        fromArticle?.update(time)
        toArticle.update(time)
        fromArticle?.project?.update()
        toArticle.project?.update()
        
        let _ = try? REALM.realm.commitWrite()
    }
    
    class func unchiveSection(section: SectionObject) {
        
        guard let type = SectionType(rawValue: section.type),
                  article = SpiderConfig.ArticleList.article else { return }
        
        var newSection: SectionObject
        
        REALM.realm.beginWrite()
        
        switch type {
            
        case .Text:
            newSection = SectionObject(type: .Text, undoc: 1, text: section.text)
            
        case .Pic:
            newSection = SectionObject(type: .Pic, undoc: 1)
            
            for pic in section.pics {
                
                let newPic = PicSectionObject(url: pic.url)
                
                for tag in pic.tags {
                    
                    let newTag = TagObject(tag: tag)
                    newPic.tags.append(newTag)
                    REALM.realm.add(newTag)
                }
                
                newSection.pics.append(newPic)
                REALM.realm.add(newPic)
            }
            
        case .Audio:
            
            guard let audio = section.audio else { return }
            
            newSection = SectionObject(type: .Audio, undoc: 1)
            let newAudio = AudioSectionObject(url: audio.url, duration: audio.duration)
            
            for tag in audio.tags {
                let newTag = TagObject(tag: tag)
                audio.tags.append(newTag)
                
                REALM.realm.add(newTag)
            }
            
            newSection.audio = newAudio
            REALM.realm.add(newAudio)
        }
        
        newSection.modifiyFlag = 1
        REALM.realm.add(newSection)
        
        section.modifiyFlag = 1
        section.deleteFlag = 1
        
        article.modifiyFlag = 1
        
        let _ = try? REALM.realm.commitWrite()
    }
}


// MARK: - Create
extension SpiderRealm {
    
    // MARK: - TextSection 

    class func updateTextSection(section: SectionObject? = nil, with text: String, undoc: Int = 0) {
        var textSection: SectionObject
        REALM.realm.beginWrite()
        
        if let section = section {
            
            textSection = section
            
            if textSection.text != text {
                textSection.text = text
                textSection.update()
            }
            
        } else {
            
            textSection = SectionObject(type: .Text, undoc: undoc, text: text)
            
            if let article = SpiderConfig.ArticleList.article {
                
                let insertIndex = SpiderConfig.ArticleList.insertIndex ?? 0
                
                article.modifiyFlag = 1
                article.updateAtTime = textSection.updateAt
                article.sections.insert(textSection, atIndex: insertIndex)
            }
        }
        
        REALM.realm.add(textSection, update: true)

        let _ = try? REALM.realm.commitWrite()
    }
    
    // MARK: - AudioSection
    
    class func createAudioSection(id: String, duration: String, with infos: [AudioTagInfo]) -> SectionObject {
        
        let section = SectionObject(type: .Audio, undoc: 1)
        let audioObject = AudioSectionObject(url: id, duration: duration)
        
        REALM.realm.beginWrite()
        
        for info in infos {
            
            let tag = TagObject(tagInfo: info)
            audioObject.tags.append(tag)
            
            REALM.realm.add(tag)
        }
        
        section.audio = audioObject
        
        REALM.realm.add(audioObject)
        REALM.realm.add(section)
        
        if let article = SpiderConfig.ArticleList.article {
            
            article.modifiyFlag = 1
            article.updateAtTime = section.updateAt
            section.undocFlag = 0
            
            let insertIndex = SpiderConfig.ArticleList.insertIndex ?? 0
            article.sections.insert(section, atIndex: insertIndex)
        }
        
        let _ = try? REALM.realm.commitWrite()
        
        return section
    }
    
    // MARK: - PicSection
    
    class func createPicSection(with infos: [PicSectionInfo]) -> SectionObject {
        
        let section = SectionObject(type: .Pic, undoc: 1)

        REALM.realm.beginWrite()
        
        for picNode in infos {
            
            let picObject = PicSectionObject(url: picNode.picInfo.id)
            
            for (_, tag) in picNode.tags {
                
                if tag.state != .Deleted {
                    
                    let tagObject = TagObject(tagInfo: tag)
                    picObject.tags.append(tagObject)
                    
                    REALM.realm.add(tagObject)
                }
            }
            
            section.pics.append(picObject)
            
            REALM.realm.add(picObject)
            REALM.realm.add(section)
        }
        
        if let article = SpiderConfig.ArticleList.article {
            
            section.undocFlag = 0

            let insertIndex = SpiderConfig.ArticleList.insertIndex ?? 0
            article.sections.insert(section, atIndex: insertIndex)
        }
        
        let _ = try? REALM.realm.commitWrite()
        
        return section
    }
    
    class func updatePicSection(section: SectionObject, with infos: [PicSectionInfo]) {
        
        REALM.realm.beginWrite()
        
        section.pics.removeAll() // TODO: - optimize
        
        for picNode in infos {
            
            let picObject = PicSectionObject(url: picNode.picInfo.id)
            picObject.tags.removeAll()
            
            for (_, tag) in picNode.tags {
                
                switch tag.state {
                    
                case .Deleted:
                    break
                    
                default:
                    
                    let tagObject = TagObject(tagInfo: tag)
                    picObject.tags.append(tagObject)
                    REALM.realm.add(tagObject, update: true)
                }
            }
            
            REALM.realm.add(picObject, update: true)
            section.pics.append(picObject)
        }
        
        section.update()
        
        REALM.realm.add(section, update: true)
        
        let _ = try? REALM.realm.commitWrite()
    }
}



