//
//  Double+Extension.swift
//  WonBridge
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

extension Double {
    
    func format(f: String) -> String {
        
        return String(format: "%\(f)f", self)
    }
    
    func format(f: String) -> Double {
        
        return Double(String(format: "%\(f)f", self))!
    }
    
    func duration() -> String {
        
        let seconds: Int = Int(self / 1000)
        let mins: Int = Int(seconds / 60)
        let hours: Int = Int(mins / 60)
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, mins, seconds)
        } else {
            return String(format: "%02d:%02d", mins, seconds)
        }
    }
}
