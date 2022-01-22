//
//  TimeLineDetailViewController+Keyboard.swift
//  WonBridge
//
//  Created by July on 2016-09-20.
//  Copyright © 2016 elitedev. All rights reserved.
//

/*
TimeLineDetailViewController bottom constraint of reply input bar
 */

import Foundation

// MARK: - @extension TimeLineDetailViewController

extension TimeLineDetailViewController {
    
    func keyboardControl() {
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, name: UIKeyboardWillShowNotification, object: nil, handler: {
            
            [weak self] observer, notification in
            
            guard let strongSelf = self else { return }
            
            strongSelf.keyboardControl(notification, isShowing: true)
        })
        
        notificationCenter.addObserver(self, name: UIKeyboardDidShowNotification, object: nil, handler: {
            
            observer, notification in
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                
                _ = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            }
        })
        
        notificationCenter.addObserver(self, name: UIKeyboardWillHideNotification, object: nil, handler: {
            
            [weak self] observer, notification in
            
            guard let strongSelf = self else { return }
            
            strongSelf.keyboardControl(notification, isShowing: false)
        })
        
        notificationCenter.addObserver(self, name: UIKeyboardDidHideNotification, object: nil) { (observer, notification) in
            
        }
    }
    
    func keyboardControl(notification: NSNotification, isShowing: Bool) {
        
        var userInfo = notification.userInfo!
        let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.unsignedIntValue

        let options = UIViewAnimationOptions(rawValue: UInt(curve) << 16 | UIViewAnimationOptions.BeginFromCurrentState.rawValue)
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        if (isShowing) {
        
            self.inputbarBottomConstraint.constant = keyboardRect.height
            
        } else {
            
            self.inputbarBottomConstraint.constant = 0
        }
        
        
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: { 
            
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
}

extension TimeLineDetailViewController: TimeLineInputbarDelegate {
    
    func didPressSendButton(inputbar: TimeLineInputbar) {
       
        guard inputbar.text != "" else { return }
        
        guard selectedTimeLine!.user_id != _user!._idx  else {
            
            inputbar.endEditing()
            return
        }
        
        inputbar.endEditing()
        
        let replyMsg = inputbar.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let encodedMsg = replyMsg.encodeString()
        
        WebService.sendReply(selectedTimeLine!.id, userId: _user!._idx, replyMsg: encodedMsg!) { (status, reply) in
            
            if (status) {
                
                reply._content = replyMsg
                
                reply._userId = self._user!._idx
                reply._userName = self._user!._name
                reply._userProfile = self._user!._photoUrl
                
                self._replys.append(reply)
                
                self.updateReplyView()
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    
                    self.scrollToBottom()
                })
            }
        }
    }
    
    func didChangeHeight(height: CGFloat) {
        
        self.view.keyboardTriggerOffset = height
        inputbarHeightConstraint.constant = height
        
        UIView.animateWithDuration(0.3) {
            
            self.view.layoutIfNeeded()
        }
    }
}