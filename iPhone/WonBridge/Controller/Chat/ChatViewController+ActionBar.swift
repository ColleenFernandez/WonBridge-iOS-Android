//
//  ChatViewController+Inputbar.swift
//  WonBridge
//
//  Created by July on 2016-09-20.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

// MARK: - @extension ChatViewController
extension ChatViewController {
    
    func setupActionBarButtonInterAction() {
    
        let shareButton: ChatButton = self.chatActionBarView.shareButton
        let emotionButton: ChatButton = self.chatActionBarView.emotionButton
        let textSendButton: ChatButton = self.chatActionBarView.textSendButton
        let imageSendButton: UIButton = self.chatActionBarView.imageSendButton
        
        // add action to show emoji keyboard
        emotionButton.rx_tap.subscribeNext { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.chatActionBarView.resetButtonUI()
            // setup button ui
            emotionButton.replaceEmotionButtonUI(showKeyboard: !emotionButton.showTypingKeyboard)
            if emotionButton.showTypingKeyboard {
                strongSelf.chatActionBarView.showTyingKeyboard()
            } else {
                strongSelf.chatActionBarView.showEmotionKeyboard()
            }
            strongSelf.controlExpandableInputView(showExpandable: true)
        }.addDisposableTo(self.disposeBag)
        
        // add action to send text chat
        textSendButton.rx_tap.subscribeNext { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.chatSendText()
        }.addDisposableTo(self.disposeBag)
        
        // add action to send image
        imageSendButton.rx_tap.subscribeNext { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.chatSendLocalImage()
        }.addDisposableTo(self.disposeBag)
        
        // add action to show more view
        shareButton.rx_tap.subscribeNext { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.chatActionBarView.resetButtonUI()
            
            if strongSelf.chatActionBarView.keyboardType == .Media {
                strongSelf.chatActionBarView.hideMediaKeyboard()
            } else {
                if shareButton.showTypingKeyboard {
                    strongSelf.chatActionBarView.showTyingKeyboard()
                } else {
                    strongSelf.chatActionBarView.showShareKeyboard()
                }
                strongSelf.controlExpandableInputView(showExpandable: true)
            }
        }.addDisposableTo(disposeBag)
        
        // textview
        let textView: UITextView = self.chatActionBarView.inputTextView
        let tap = UITapGestureRecognizer()
        textView.addGestureRecognizer(tap)
        tap.rx_event.subscribeNext { (_) in
            textView.inputView = nil
            textView.becomeFirstResponder()
            textView.reloadInputViews()
        }.addDisposableTo(self.disposeBag)
    }
    
    /**
     Control the actionBarView height:
     We should make actionBarView's height to original value when the use wants to show recoding keyboard.
     Otherwise we should make actionBarView's height to currentHeight
     
     -parameter showExpandable: show or hide expandable inputTextView
     **/
    func controlExpandableInputView(showExpandable showExpandable: Bool) {
       
        let textView = self.chatActionBarView.inputTextView
        let currentTextHeight = self.chatActionBarView.inputTextViewCurrentHeight
        UIView.animateWithDuration(0.3) { () -> Void in
            let textHeight = showExpandable ? currentTextHeight : kChatActionBarOriginalHeight
            self.chatActionBarView.snp_updateConstraints { (make) -> Void in
                make.height.equalTo(textHeight)
            }
            self.view.layoutIfNeeded()
            self.listTableView.scrollBottomToLastRow()
            textView.contentOffset = CGPoint.zero
        }
    }
}


