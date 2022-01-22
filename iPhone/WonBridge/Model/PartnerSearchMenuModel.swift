//
//  PartnerSearchMenuModel.swift
//  WonBridge
//
//  Created by Tiia on 16/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class PartnerSearchMenuModel: NSObject {
    
    var name: String! = ""
    var image: String! = ""
    
    override init() {
        
        name = ""
        image = ""
    }
    
    convenience init(name: String, image: String) {
        
        self.init()
        
        self.name = name
        self.image = image
    }
}
