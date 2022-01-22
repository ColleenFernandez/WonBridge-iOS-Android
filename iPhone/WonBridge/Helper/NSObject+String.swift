//
//  NSObject_String.swift
//  WonBridge
//
//  Created by July on 2016-09-25.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    
    class var nameOfClass:  String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last! as String
    }
    
    class var identifier: String {
        return String(format:"%@_identifier", self.nameOfClass)
    }
}
