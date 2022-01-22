//
//  RoundButton.swift
//  WonBridge
//
//  Created by Tiia on 16/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class RoundButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        
        didSet {
            
            layer.borderWidth = borderWidth
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        
        didSet {            
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    override func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
    }

}
