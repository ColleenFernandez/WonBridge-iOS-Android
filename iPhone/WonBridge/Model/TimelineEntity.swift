//
//  TimelineEntity.swift
//  WonBridge
//
//  Created by Saville Briard on 23/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class TimeLineEntity: NSObject {
    
    // user
    var user_id: Int = 0
    var user_name: String = ""
    var photo_url: String = ""
    var userLastLogin: String = ""
    var isFriend: Bool = false
    
    var id: Int = 0
    var content: String = ""
    
    var postedTime: String = ""
    var distance: String = ""
    
    var likeCount: Int = 0
    var replyCount: Int = 0
    var countryCode: String = "CN"
    var favCountry: String = ""
    
    var location: CLLocationCoordinate2D!
    
    var file_url = [String]()
    var likeUsers = [String]()
    var replies = [ReplyEntity]()
    
    var isExpanded: Bool = false
}
