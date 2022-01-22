//
//  CountryModel.swift
//  WonBridge
//
//  Created by July on 2016-09-29.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

class CountryModel: NSObject {

    var name: String = ""
    var dialCode: String = ""           // dial code   - +86
    var code: String = ""               // country code - CN
    
    override init() {
        super.init()
    }
    
    convenience init(name: String, dialCode: String, countryCode: String) {
        
        self.init()
        
        self.name = name
        self.dialCode = dialCode
        self.code = countryCode
    }
}
