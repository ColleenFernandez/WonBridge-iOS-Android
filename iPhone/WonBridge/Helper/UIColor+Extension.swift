//
//  UIColor+Extention.swift
//  WonBridge
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, fade: CGFloat) {
        
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: fade)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff, fade: 1.0)
    }
    
    convenience init(netHex: Int, alpha: CGFloat) {
        
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff, fade: alpha)
    }
}
