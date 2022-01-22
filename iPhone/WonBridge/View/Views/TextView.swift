//
//  TextView.swift
//  WonBridge
//
//  Created by Elite on 10/12/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

@IBDesignable class TextView: UITextView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return false
    }
}
