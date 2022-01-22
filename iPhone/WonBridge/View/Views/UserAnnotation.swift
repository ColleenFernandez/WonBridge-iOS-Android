//
//  UserAnnotation.swift
//  WonBridge
//
//  Created by July on 2016-09-19.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

// MARK: - Baidu Map User Annotation
class UserAnnotation: BMKPointAnnotation {
    
    var name: String?
    
    var user: FriendEntity?
   
    override init() {
        
        super.init()
    }

    convenience init(user: FriendEntity) {
        
        self.init()
        
        self.user = user
        
        if user._isPublic {
            self.title = user._name
        } else {
            self.title = nil
        }
        
        if user.location != nil {        
            self.coordinate = user.location!
        }
    }
}
