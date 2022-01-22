//
//  CustomSlider.swift
//  WonBridge
//
//  Created by July on 2016-09-18.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var trackHeight: CGFloat = 3
    
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        
        // set your bounds here
        return CGRect(origin: bounds.origin, size: CGSizeMake(bounds.width, trackHeight))
    }

}
