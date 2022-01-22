//
//  RoomEntity.swift
//  WonBridge
//
//  Created by Tiia on 28/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class RoomEntity: NSObject {

    // 1:1 - participant idx
    // group chat - particpants idx array 1_2_3..._currentTime(milliseconds) separated by underline
    var _name: String = ""
    // participants index array 1_2_3_currentTime
    // 1_2_3_currentTime (once 4 is invited : 1_2_3_4_currentTime)
    var _participants: String = ""              //  participants index array
    // left members index array 4_5
    // user 4 and 5 was left the room
    var _leaveMembers: String = ""
    // room display name on chat list
    // 1:1 - Friend's Name, GroupChat - participants name array separated by commas
    var _displayName: String = ""               // displayname 2,3,4 (me: 1)
    
    var _recentContent: String = ""
    // 20160910,20(10):30:30 (yyyyMMdd,h:mm:ss)
    // PM(PM) 10:30 - display time format in chat table view
    //              - this will be changed according to received date in chat list tableview ( 2 days ago ..)
    var _recentTime: String = ""
    var _recentCount: Int = 0
    
    var _isSelected: Bool = false
    
    var _participantList: [FriendEntity] = []   // not contains me
    var _leaveMemberList: [FriendEntity] = []   // not contains me
    
    // when to make a new room by selection users or friends
    // or it will be called after getting new message from new user ( room message) for making a room with participants
    convenience init(participants: [FriendEntity]) {
        
        self.init()
        
        _participantList = participants
        
        if _participantList.count == 1 {
            _name = makeParticipants()
        } else {
            _name = makeParticipants() + "_\(Int(KVOValue: NSDate.milliseconds)!)"
        }
        
        _participants  = makeParticipants()        
        makeRoomDisplayName()
    }
    
    convenience init(name: String) {
        self.init()
        
        self._name = name
        makeRoomDisplayName()
    }
    
    convenience init(name: String, participants: String, leaveMembers: String, recentContent: String, recentTime: String, recentCount: Int) {
        self.init()
        
        self._name = name
        self._participants = participants
        self._recentContent = recentContent
        self._recentTime = recentTime
        self._recentCount = recentCount
        self._leaveMembers = leaveMembers
    }
    
    // when to make a new room by invitation message
    convenience init(roomName: String, participants: [FriendEntity]!) {
        
        self.init()
        
        _name = roomName
        _participantList = participants
        _participants = makeParticipants()
        
        makeRoomDisplayName()
    }
    
    // make participants name 
    // participants index array: 1_2_3 ( 3 participants: 1, 2, 3 it will involve me)
    func makeParticipants() -> String {
        
        var _partsName = ""
        var _nameArray = [Int]()
        
        for _user in _participantList {
            _nameArray.append(_user._idx)
        }
        _nameArray.append(WBAppDelegate.me!._idx)
        
        var _sortedArray = _nameArray.sort { (obj1, obj2) -> Bool in
            return obj1 < obj2
        }
        
        for index in 0 ..< _sortedArray.count {
            _partsName = _partsName + "_\(_sortedArray[index])"
        }
        
        _partsName = _partsName[_partsName.startIndex.advancedBy(1) ..< _partsName.endIndex]
        
        return _partsName
    }
    
    func participantsWithoutLeaveMembers(involve: Bool) -> String {
        
        var roomName = ""
        
        let leaveIdList = _leaveMembers.componentsSeparatedByString("_")
        var idList = [Int]()
        for participant in _participantList {
            if leaveIdList.contains("\(participant._idx)") {
                continue
            }
            idList.append(participant._idx)
        }
        
        if involve {
            idList.append(WBAppDelegate.me!._idx)
        }
        
        idList = idList.sort{ (obj1, obj2) -> Bool in
            return obj1 < obj2
        }
        
        for id in idList {
            roomName += "\(id)" + "_"
        }
        
        roomName = roomName.substringToIndex(roomName.endIndex.advancedBy(-1))
        return roomName
    }
    
    func participantsWithLeaveMembers() -> String {
        
        var roomName = ""
        
        var idList = [Int]()
        // add participant
        for idx in _participants.componentsSeparatedByString("_") {
            idList.append(Int(idx)!)
        }
        
        if _leaveMembers.length > 0 {
            for leaveIdex in _leaveMembers.componentsSeparatedByString("_") {
                idList.append(Int(leaveIdex)!)
            }
        }
        
        // sort id array
        idList = idList.sort { (obj1, obj2) -> Bool in
            return obj1 < obj2
        }
        
        for id in idList {
            roomName += "\(id)_"
        }        
        roomName = roomName.substringToIndex(roomName.endIndex.advancedBy(-1))
        
        return roomName
    }
    
    // make a room display name
    func makeRoomDisplayName() {
        
        var roomDisplayName = ""
        
        // 1:1 chatting
        if _participantList.count == 1 {
            self._displayName = _participantList[0]._name
            return
        }
        
        // group chatting
        let leaveIdList = _leaveMembers.componentsSeparatedByString("_")
        var _sortedArray = _participantList.sort { (obj1, obj2) -> Bool in
            return obj1._idx < obj2._idx
        }
        
        for index in 0 ..< _sortedArray.count {
            
            guard !leaveIdList.contains("\(_sortedArray[index]._idx)") else { continue }
            roomDisplayName = roomDisplayName + ", \(_sortedArray[index]._name)"
        }
        
        if roomDisplayName.characters.count == 0 {
            roomDisplayName = Constants.TITLE_GROUP
        } else {
            roomDisplayName = roomDisplayName[roomDisplayName.startIndex.advancedBy(2) ..< roomDisplayName.endIndex]
        }
        
        self._displayName = roomDisplayName
    }
    
    func getDisplayCount() -> String {
        
        var displayCount = ""
        if (_participantList.count >= 2) {
            var leaveCount = 0
            if _leaveMembers.characters.count > 0 {
                leaveCount = _leaveMembers.componentsSeparatedByString("_").count
            }
            
            displayCount += " (\(_participantList.count - leaveCount + 1))"
        }
        
        return displayCount
    }
    
    func equals(other: RoomEntity) -> Bool {
        
        return other._name == _name
    }
    
    // 
    // idx - chatting friend idx
    // check if there is a friend with idx in participants
    //
    func getParticipant(idx: Int) -> FriendEntity? {
        
        for _user in _participantList {
            if (_user._idx == idx) {
                return _user
            }
        }
        
        return nil
    }
    
    func getCurrentUsers() -> Int {
        return _participantList.count
    }
    
    // 
    // inviting other user by myself in this room
    // update participant with param ... participants
    //
    func updateParticipants(newParticipants: [FriendEntity]!) {
        
        _participantList += newParticipants
        
        // update participant name and display name
        _participants = makeParticipants()
        makeRoomDisplayName()
        DBManager.getSharedInstance().updateRoom(self)
    }
    
    // check if selected friend is room participant or not    
    func isParticipant(friend: FriendEntity) -> Bool {
        for part in _participantList {
            if part._idx == friend._idx {
                return true
            }
        }
        
        return false
    }
    
    /**
     * remove partcipant
     * parameter idx : user idx to remove
     */
    func removeParticipantFromList(idx: Int) -> Bool {
        for participant in _participantList {
            if participant._idx == idx {
                _participantList.removeAtIndex(_participantList.indexOf(participant)!)
                return true
            }
        }
        
        return false
    }
    
    func removeParticipantList(userId: Int) {
        
        for participant in _participantList {
            if participant._idx == userId {
                _participantList.remove(participant)
            }
        }
    }
    
    func removeParticipant(userId: Int) {
        
        let ids = _participants.componentsSeparatedByString("_")
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
        
        var participants = ""
        for partId in idList {
            participants += "\(partId)_"
        }
        
        if participants.length > 0 {
            participants = participants.substringToIndex(participants.endIndex.advancedBy(-1))
        }
        
        _participants = participants
    }
    
    // check if a room is signle chat room or multi-chat room
    // should check with _participants
    // do not check with _participantList
    func isSingle() -> Bool {
        
        if _name.componentsSeparatedByString("_").count > 2 {
            return false
        } else {
            return true
        }
    }

    func getDate() -> NSDate? {
     
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd,H:mm:ss"
        // _recentTime - Local TimeZone TimeString, returned date will be utcDate
        let utcDate = dateFormatter.dateFromString(_recentTime)
        
        return utcDate
    }

    func getLocalDate() -> NSDate? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd,H:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let localDate = dateFormatter.dateFromString(_recentTime)
        
        return localDate
    }
    
    func getDisplayTime() -> String {
        
        if _recentTime == "" {
            return ""
        }
        
        // _recentTime will be local time string
        let calendar = NSCalendar.currentCalendar()
        let recentDay = calendar.components([.Year, .Month, .Day], fromDate: getDate()!)
        
        // get today
        let today = calendar.components([.Year, .Month, .Day], fromDate: NSDate())
        
        if today == recentDay {
         
            var dispTime = _recentTime.componentsSeparatedByString(",")[1]
            
            dispTime = dispTime.substringToIndex(dispTime.rangeOfString(":", options: .BackwardsSearch)!.startIndex)
            
            let arrHourMin = dispTime.componentsSeparatedByString(":")
            
            var _hour = Int(arrHourMin[0])!
            
            let _minute = arrHourMin[1]
            
            if (_hour < 12) {
                
                dispTime = Constants.TIME_AM + " \(_hour):" + _minute
                
            } else {
                
                _hour = _hour - 12
                
                if (_hour == 0) {
                    
                    _hour = 12
                }
                
                dispTime = Constants.TIME_PM + " \(_hour):" + _minute
            }
            
            return dispTime
            
        } else {
            
            return calendar.dateByAddingComponents(NSDateComponents(), toDate: getDate()!, options: [])!.timeAgo
        }
    }
}










