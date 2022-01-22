//
//  Array+Extension.swift
//  WonBridge
//
//  Created by July on 2016-10-05.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        
        for object in array {
            self.removeObject(object)
        }
    }
}
