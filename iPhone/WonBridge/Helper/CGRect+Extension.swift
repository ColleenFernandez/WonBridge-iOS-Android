//
//  CGRect+Extension.swift
//  WonBridge
//
//  Created by July on 2016-09-26.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

public extension CGRect {
    
    var originX: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self = CGRectMake(newValue, self.minY, self.sizeWidth, self.sizeHeight)
        }
    }
    
    var originY: CGFloat {
        get {
            return self.origin.y
        }
        set {
            self = CGRectMake(self.originX, newValue, self.sizeWidth, self.sizeHeight)
        }
    }
    
    var sizeWidth: CGFloat {
        get {
            return self.size.width
        }
        set {
            self = CGRectMake(self.originX, self.minY, newValue, self.sizeHeight)
        }
    }
    
    var sizeHeight: CGFloat {
        get {
            return self.size.height
        }
        set {
            self = CGRectMake(self.originX, self.minY, self.sizeWidth, newValue)
        }
    }
    
    var top: CGFloat {
        get {
            return self.origin.y
        }
        set {
            originY = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.origin.y + self.size.height
        }
        set {
            self = CGRectMake(originX, newValue - sizeHeight, sizeWidth, sizeHeight)
        }
    }
    
    var left: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self.originX = newValue
        }
    }
    
    var right: CGFloat {
        get {
            return originX + sizeWidth
        }
        set {
            self = CGRectMake(newValue - sizeWidth, originY, sizeWidth, sizeHeight)
        }
    }
    
    
    var midX: CGFloat {
        get {
            return self.originX + self.sizeWidth / 2
        }
        set {
            self = CGRectMake(newValue - sizeWidth / 2, originY, sizeWidth, sizeHeight)
        }
    }
    
    var midY: CGFloat {
        get {
            return self.originY + self.sizeHeight / 2
        }
        set {
            self = CGRectMake(originX, newValue - height / 2, sizeWidth, sizeHeight)
        }
    }
    
    
    var center: CGPoint {
        get {
            return CGPointMake(self.midX, self.midY)
        }
        set {
            self = CGRectMake(newValue.x - sizeWidth / 2, newValue.y - sizeHeight / 2, sizeWidth, sizeHeight)
        }
    }
}