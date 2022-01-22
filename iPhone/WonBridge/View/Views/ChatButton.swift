//
//  ChatButton.swift
//  WonBridge
//
//  Created by July on 2016-09-26.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

class ChatButton: UIButton {

    var showTypingKeyboard: Bool
    
    required init?(coder aDecoder: NSCoder) {
        self.showTypingKeyboard = true
        super.init(coder: aDecoder)
    }
}
