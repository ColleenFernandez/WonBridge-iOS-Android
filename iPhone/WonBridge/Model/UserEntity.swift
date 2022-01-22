//
//  UserEntity.swift
//  WonBridge
//
//  Created by Saville Briard on 22/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class UserEntity: NSObject {
    
    var _idx: Int = -1
    var _name: String = ""
    var _age: Int = 0
    var _gender: GenderType = .FEMALE
    
    var _photoUrl: String = ""
    var _regDate: String = ""
    var _phoneNumber: String = ""
    
    var _email: String = ""
    var _password: String  = ""
    
    var _isPublicLocation: Bool = true
    var _isPublicTimeLine: Bool = true
    
    var _countryCode: String = "CN"
    
    var _wechatId: String = ""
    var _qqId: String = ""
    
    var _school: String = ""
    var _village: String = ""
    var _favCountry: String = ""
    var _working: String = ""
    var _interest: String = ""
    
    // friend list
    var _frList: [FriendEntity] = []
    // block list
    var _blockList: [FriendEntity] = []
    // room list
    var _roomList: [RoomEntity] = []
    // group list
    var _groupList: [GroupEntity] = []
    
    // unread message count
    var notReadCount: Int = 0
    
    var location: CLLocationCoordinate2D?
    
    func setUserInfo(user: UserEntity) {
        
        _idx = user._idx
        _name = user._name
        _email = user._email
        _password = user._password
        _photoUrl = user._photoUrl
        _phoneNumber = user._phoneNumber
        _gender = user._gender
        _countryCode = user._countryCode
        _wechatId = user._wechatId
        _qqId = user._qqId
        _isPublicLocation = user._isPublicLocation
        _isPublicTimeLine = user._isPublicTimeLine
        
        _school = user._school
        _village = user._village
        _favCountry = user._favCountry
        _working = user._working
        _interest = user._interest
    }
    
    func clear() {
        
        _idx = -1
        _name = ""

        _gender = .FEMALE
        
        _photoUrl = ""
        _regDate = ""
        _phoneNumber = ""
        
        _email = ""
        _password  = ""
        
        _isPublicLocation = true
        _isPublicTimeLine = true
        
        _countryCode = "CN"
        _favCountry = ""
        _wechatId = ""
        _qqId = ""
        
        _school = ""
        _village = ""
        _favCountry = ""
        _working = ""
        _interest = ""
        
        _frList.removeAll()
        _blockList.removeAll()
        _groupList.removeAll()
        _roomList.removeAll()
    }
    
    // check user validation
    func isValid() -> Bool {
        
        if (_idx > 0 && _name != "" && _password != "") {
            return true
        }
        
        return false
    }
   
    // check if the user who has idx is my friend or not
    func isFriend(idx: Int) -> Bool {
        
        for _friend in _frList {
            if (_friend._idx == idx) {
                return true
            }
        }
        
        return false
    }
    
    // check room already exists in user's room list
    func isExistRoom(room: RoomEntity) -> Bool {
        
        for existRoom in _roomList {
            if existRoom._name == room._name {
                return true
            }
        }
        
        return false
    }
    
    func isExistGroup(group: GroupEntity) -> Bool {
        
        for existGroup in _groupList {
            if existGroup.name == group.name {
                return true
            }
        }
        
        return false
    }
    
    // return friend who has idx in my friend list
    func getFriend(idx: Int) -> FriendEntity? {
        
        for friend in _frList {
            if (friend._idx == idx) {
                return friend
            }
        }
        
        return nil
    }
    
    
    // add new room message received
    // as you got new message, so need to increase unread message count
    // you're doing asynchronous communication with a server, it needs to check incoming message everytime
    func addRoom(newRoom: RoomEntity) {
        
        if let existRoom =  getRoom(newRoom._name) {
            
            existRoom._recentContent = newRoom._recentContent
            existRoom._recentTime = newRoom._recentTime
            existRoom._recentCount += 1
            
            // if room participatns was updated, it will update room participants of existing room
            if existRoom._participants != newRoom._participants {
                existRoom._participants = newRoom._participants
                existRoom._participantList = newRoom._participantList
            }
            
            DBManager.getSharedInstance().updateRoom(existRoom)
        } else {
            
            // add a new room in room list
            _roomList.append(newRoom)            
            DBManager.getSharedInstance().createRoom(newRoom)
        }
    }
    
    func addFriend(_friend: FriendEntity) -> Bool {
        
        for _existFriend in _frList {
            
            // update friend information
            if (_existFriend._idx == _friend._idx) {
                
                _existFriend._idx = _friend._idx
                _existFriend._name = _friend._name
                _existFriend._gender = _friend._gender
                
                _existFriend._photoUrl = _friend._photoUrl
                _existFriend._regDate = _friend._regDate
                _existFriend._phoneNumber = _friend._phoneNumber
                
                _existFriend._lastLogin = _friend._lastLogin
                
                _existFriend._isFriend = _friend._isFriend
                _existFriend._blockStatus = _friend._blockStatus
                
                _existFriend._isPublic = _friend._isPublic
                _existFriend._isFriend = _friend._isFriend
                
                _existFriend.location = _friend.location
                
                return false
            }
        }
        
        _frList.append(_friend)
        
        return true
    }
    
    func removeFriend(_friend: FriendEntity) {
        
        for index in 0 ..< _frList.count {
            
            let _existFriend = _frList[index]
            if _existFriend._idx == _friend._idx {
                _frList.removeAtIndex(index)
                return
            }
        }
    }
    
    func removeGroup(group: GroupEntity) -> Bool {
        
        for existGroup in _groupList {
            if existGroup.name == group.name {
                
                _groupList.remove(existGroup)
                return true
            }
        }
        
        return false
    }
    
    func removeRoom(room: RoomEntity) -> Bool {
        
        for existRoom in _roomList {
            if room._name == existRoom._name {
                
                _roomList.remove(existRoom)
                return true
            }
        }
        
        return false
    }
    
    func isBlockedFriend(_friendIdx: Int) -> Bool {
        
        for blockedUser in _blockList {
            if blockedUser._idx == _friendIdx {
                return true
            }
        }
        
        return false
    }
    
    func removeblockUser(blockUser: FriendEntity) {
        
        for index in  0 ..< _blockList.count {
            let blockedUser = _blockList[index]
            
            if blockedUser._idx == blockedUser._idx {
                _blockList.removeAtIndex(index)
                return
            }
        }
    }
    
    // name: group name
    // return group entity with name
    func getGroup(name: String) -> GroupEntity? {
        
        for group in _groupList {
            if group.name == name {
                return group
            }
        }
        
        return nil
    }
    
    // name: group name
    func getRoom(name: String) -> RoomEntity? {
        
        for room in _roomList {
            if room._name == name {
                return room
            }
        }
        
        return nil
    }
    
    // get single chat room badge count
    func getChatUnReadMsgCount() -> Int {
        
        var _count = 0
        
        for _room in _roomList {
            if _room.isSingle() {
                _count += _room._recentCount
            }
        }
        
        return _count
    }
    
    // get group chat room badge count
    func getGrpChatUnreadCount() -> Int {
        
        var _count = 0
        for _room in _roomList {
            if !_room.isSingle() {
                _count += _room._recentCount
            }
        }
        return _count
    }
    
    // get user location
    func getUserLocation() -> CLLocationCoordinate2D? {
        
        if self.location != nil {
            return self.location
        }
        
        guard UserDefault.getString(Constants.PREF_USER_LAT) != nil && UserDefault.getString(Constants.PREF_USER_LONG) != nil else {
            self.location = nil
            return nil
        }
        
        self.location = CLLocationCoordinate2D(latitude: Double(UserDefault.getString(Constants.PREF_USER_LAT)!)!, longitude: Double(UserDefault.getString(Constants.PREF_USER_LONG)!)!)
        
        return self.location
    }
    
    // save user location
    func saveUserLocation() -> Bool {
        
        guard location != nil else {
            return false
        }
        
        UserDefault.setString(Constants.PREF_USER_LAT, value: "\(location!.latitude)")
        UserDefault.setString(Constants.PREF_USER_LONG, value: "\(location!.longitude)")
        return true
    }
    
    func loadUserInfo() {
        
        _idx = UserDefault.getInt(Constants.pref_user_id, defaultValue: 0)                 //  0
        _name = UserDefault.getString(Constants.pref_user_name, defaultValue: "")!
        _password = UserDefault.getString(Constants.pref_user_passsowrd, defaultValue: "")!
        _email = UserDefault.getString(Constants.pref_user_email, defaultValue: "")!
        _phoneNumber = UserDefault.getString(Constants.pref_user_phonenumber, defaultValue: "")!
        _photoUrl = UserDefault.getString(Constants.pref_user_photoURL, defaultValue: "")!
        _wechatId = UserDefault.getString(Constants.pref_user_wechatId, defaultValue: "")!
        _qqId = UserDefault.getString(Constants.pref_user_qqId, defaultValue: "")!
        
        // load location
        self.getUserLocation()
    }
    
    func saveUserInfo() {
        
        UserDefault.setInt(Constants.pref_user_id, value: _idx)
        UserDefault.setString(Constants.pref_user_name, value: _name)
        UserDefault.setString(Constants.pref_user_email, value: _email)
        UserDefault.setString(Constants.pref_user_passsowrd, value: _password)
        UserDefault.setString(Constants.pref_user_phonenumber, value: _phoneNumber)
        UserDefault.setString(Constants.pref_user_photoURL, value: _photoUrl)
        UserDefault.setString(Constants.pref_user_wechatId, value: _wechatId)
        UserDefault.setString(Constants.pref_user_qqId, value: _qqId)
    }
    
    func checkNewUser() -> Bool {
        
        guard let userOldEmail = UserDefault.getString(Constants.pref_user_email) else {
            return false
        }
        
        let userNewEmail = _email
        if (userNewEmail != userOldEmail) {
            DBManager.getSharedInstance().clearDB()
            return true
        }
        
        return false
    }
    
    func getDistance(otherLocation: CLLocationCoordinate2D?) -> String {
        
        guard otherLocation != nil && location != nil else  {
            return "999km"
        }
        
        let myLoc = CLLocation(latitude: location!.latitude, longitude: location!.longitude)
        let newLoc = CLLocation(latitude: otherLocation!.latitude, longitude: otherLocation!.longitude)
        
        let distance = Int(newLoc.distanceFromLocation(myLoc) / 1000)
        return "\(distance)km"
    }
}









