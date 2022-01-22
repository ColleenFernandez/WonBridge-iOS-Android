//
//  ContactEntity.swift
//  WonBridge
//
//  Created by Tiia on 16/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class ContactEntity: NSObject {
    
    var contactName: String!
    var nickName: String!
    var photoURL: String!
    var isMember: Bool!
    
    override init() {
        
        contactName = ""
        nickName = ""
        photoURL = ""
        isMember = false
    }
    
    convenience init(contactName: String, nickName: String, photoURL: String, isMember: Bool) {
        
        self.init()
        
        self.contactName = contactName
        self.nickName = nickName
        self.photoURL = photoURL
        self.isMember = isMember
    }
}
