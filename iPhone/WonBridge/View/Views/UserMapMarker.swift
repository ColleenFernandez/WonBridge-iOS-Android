//
//  UserMapMarker.swift
//  WonBridge
//
//  Created by July on 2016-09-23.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import GoogleMaps

// Google Map Place Marker - User Map Marker
class UserMapMarker: GMSMarker {

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
        
        self.position = user.location!
        
        if !user._isPublic {
            self.icon = UIImage(named: "map_pin_no_sex")
        } else {
            self.icon = user._gender == .MALE ? UIImage(named: "map_pin_male") : UIImage(named: "map_pin_female")
        }
        
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = kGMSMarkerAnimationPop
    }
}
