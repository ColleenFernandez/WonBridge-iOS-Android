//
//  ChatButton+UI.swift
//  WonBridge
//
//  Created by July on 2016-09-26.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

// MARK - @extension ChatButton
extension UIButton {
    
    /**
     控制——表情按钮和键盘切换的图标变化
     
     - parameter showKeyboard: 是否显示键盘
     */
    func replaceEmotionButtonUI(showKeyboard showKeyboard: Bool) {
        
        if showKeyboard {
            self.setImage(WBAsset.Tool_keyboard_1.image, forState: .Normal)
            self.setImage(WBAsset.Tool_keyboard_1.image, forState: .Highlighted)
        } else {
            self.setImage(WBAsset.Tool_emotion_1.image, forState: .Normal)
            self.setImage(WBAsset.Tool_emotion_1.image, forState: .Highlighted)
        }
    }
    
    func replaceMethodChatButtonUI(imageChat imageChat: Bool) {
        
        if imageChat {
            self.setImage(WBAsset.Tool_chat_selection_1.image, forState: .Normal)
            self.setImage(WBAsset.Tool_chat_selection_1.image, forState: .Highlighted)
        } else {
            self.setImage(WBAsset.Tool_image_chat_cancel_1.image, forState: .Normal)
            self.setImage(WBAsset.Tool_image_chat_cancel_1.image, forState: .Highlighted)
        }
    }
    
    func replaceSendButtonUI(canSend canSend: Bool) {
        
        if canSend {
            self.setImage(WBAsset.Tool_chat_can_send1.image, forState: .Normal)
            self.setImage(WBAsset.Tool_chat_can_send1.image, forState: .Highlighted)
        } else {
            self.setImage(WBAsset.Tool_chat_send_1.image, forState: .Normal)
            self.setImage(WBAsset.Tool_chat_send_1.image, forState: .Highlighted)
        }
    }
}
