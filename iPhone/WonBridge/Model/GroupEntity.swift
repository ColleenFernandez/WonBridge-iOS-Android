//
//  GroupEntity.swift
//  WonBridge
//
//  Created by Tiia on 16/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class GroupEntity: NSObject {
    
    var _nickname = ""
    
    var ownerID: Int! = 0
    var name: String! = ""
    var participants: String! = ""
    var profileUrl: String! = ""
    var regDate: String! = ""
    var isRequested: Bool = false
    var countryCode: String = "CN"
    var profileUrls = [String]()
    
    var nickname: String {
        get {
            return self._nickname == "" ? Constants.DEFAULT_GROUPNAME : self._nickname
        }
        set {
            self._nickname = newValue
        }
    }
    
    var memberCount: Int {
        return self.participants.componentsSeparatedByString("_").count
    }
    
    override init() {
        super.init()
    }
    
    convenience init(name: String, participants: String) {
        self.init()
        
        self.name = name
        self.participants = participants
    }
    
    func getNickname() -> String {
        return nickname == "" ? Constants.DEFAULT_GROUPNAME : self.nickname
    }
    
    func equals(group: GroupEntity) -> Bool{
        if name == group.name {
            return true
        }
        
        if name.characters.count != group.name.characters.count {
            return false
        }
        
        if name.lowercaseString != group.name.lowercaseString {
            return false
        }
        
        return true
    }
    
    func removeParticipant(userId: Int) {
        
        let ids = participants.componentsSeparatedByString("_")
        var idList = [Int]()
        for id in ids {
            idList.append(Int(id)!)
        }
        
        if idList.contains(userId) {
            idList.remove(userId)
        }
        
        idList = idList.sort {
            return $0 < $1
        }
        
        var _participants = ""
        for partId in idList {
            _participants += "\(partId)_"
        }
        
        if _participants.length > 0 {
            _participants = _participants.substringToIndex(_participants.endIndex.advancedBy(-1))
        }
        
        participants = _participants
    }
}
