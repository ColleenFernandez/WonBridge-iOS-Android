//
//  FriendEntity.swift
//  WonBridge
//
//  Created by July on 2016-09-21.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class FriendEntity: NSObject {

    var _idx: Int = 0                   // user identifier ( unique value )
    var _name: String = ""              // user nick name
    var _age: Int = 0                   // user age
    var _gender: GenderType = .FEMALE   // gender
    var _photoUrl: String = ""          // profile image url
    var _regDate: String = ""           // registration date
    var _phoneNumber: String = ""       // phone number
    var _lastLogin: String = ""         // last logged in date
    
    var _countryCode: String = "CN"
    
    // 1 - unblock, 0 - block
    var _blockStatus: BlockUserType = .BLOCKED_USER
    // for variable to select user when make group chat with user's friend.
    // default state will always be false
    var _isSelected: Bool = false
    var _isFriend: Bool = false
    var _isPublic: Bool = false
    
    var location: CLLocationCoordinate2D?
    
    var _school: String = ""
    var _village: String = ""
    var _favCountry: String = ""
    var _working: String = ""
    var _interest: String = ""
    
    func equals(other: FriendEntity) -> Bool {
        
        if _idx == other._idx {
            return true
        }
        
        return false
    }
    
    var distance: Int {
        
        let mylocation = CLLocationCoordinate2D(latitude: Double(UserDefault.getString(Constants.PREF_USER_LAT, defaultValue: "0")!)!, longitude: Double(UserDefault.getString(Constants.PREF_USER_LONG, defaultValue: "0")!)!)
        
        let myLoc = CLLocation(latitude: mylocation.latitude, longitude: mylocation.longitude)
        
        guard location != nil else { return 999 }
        
        let friendLoc = CLLocation(latitude: location!.latitude, longitude: location!.longitude)
        
        return Int(friendLoc.distanceFromLocation(myLoc) / 1000)
    }
}


