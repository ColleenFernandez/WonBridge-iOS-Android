//
//  ChatViewController+Setting.swift
//  WonBridge
//
//  Created by July on 2016-09-27.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

// MARK - @delegate - ChatSettingMenuDelegate
extension ChatViewController: ChatSettingMenuDelegate {
    
    func soundAction(state: Bool) {
        
    }

    // group chat action
    func groupChatAction() {
        
        self.hideAllKeyboard()
        
        let selectFriendVC = self.storyboard?.instantiateViewControllerWithIdentifier("SelectFriendViewController") as! SelectFriendViewController
        
        selectFriendVC.from = FROM_CHAT_SETTING
        
        saveRoomChat()
        selectFriendVC.earlierRoom = chatRoom
        
        self.navigationController?.pushViewController(selectFriendVC, animated: true)
    }
    
    // status: true : block action, false: unblock action
    func blockAction(status: Bool) {
        
        guard chatRoom!._participantList.count == 1 else { return }

        if status {
            blockUser()
        } else {
            unblockUser()
        }
    }
    
    func blockUser() {
     
        let blockUser = chatRoom!._participantList[0]        
        WebService.setBlockUser(_user!._idx, blockId: blockUser._idx) { (status, message) in
            
            if (status) {
                
                self._user!._blockList.append(blockUser)
                self.setBlockState(false)
                
                self.settingVC.updateUI(.UNBLOCKED)
                self.settingVC.blockStatus = .UNBLOCKED
            }
        }
    }
    
    func unblockUser() {
        
        let unblockUser = chatRoom!._participantList[0]        
        WebService.setUnblockUser(_user!._idx, unblockId: unblockUser._idx) { (status, message) in
            
            if (status) {
                
                self._user!.removeblockUser(unblockUser)
                
                self.setBlockState(true)
                
                self.settingVC.updateUI(.BLOCKED)
                self.settingVC.blockStatus = .BLOCKED
            }
        }
    }
}



