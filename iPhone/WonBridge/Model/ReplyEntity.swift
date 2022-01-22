//
//  ReplyEntity.swift
//  WonBridge
//
//  Created by July on 2016-09-21.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class ReplyEntity: NSObject {

    var _id: Int!
    var _userId: Int!
    var _userProfile: String!
    var _userName: String!
    var _content: String!
    var _replyTime: String!
    
    override init() {
        
        super.init()
        
        _id = 0
        _userId = 0
        _userProfile = ""
        _userName = ""
        _content = ""
        _replyTime = ""
    }    
}
