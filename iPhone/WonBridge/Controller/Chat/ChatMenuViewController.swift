//
//  ChatMenuViewController.swift
//  WonBridge
//
//  Created by Roch David on 06/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

@objc protocol ChatSettingMenuDelegate: class {
    
    optional func soundAction(state: Bool)
    optional func blockAction(actionState: Bool)     // true - unblock, false - block action
    optional func groupChatAction()
}

class ChatMenuViewController: BaseViewController {
    
    var settingDelegate: ChatSettingMenuDelegate?
    
    var user: UserEntity!
    var chatRoom: RoomEntity!
    
    var blockStatus: BlockStatusType = .UNBLOCKED

    @IBOutlet weak var swAlarmOnOff: UISwitch!
    
    
    @IBOutlet weak var imvAddorBlock: UIImageView!
    @IBOutlet weak var lblAddorBlock: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        user = WBAppDelegate.me
        
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
    
        swAlarmOnOff.setOn(UserDefault.getBool(Constants.PREFKEY_NOTISOUND + chatRoom._name, defaultValue: true), animated: false)
        
        updateUI(blockStatus)
    }

    // chatting alarm sound on / off
    @IBAction func switchSoundOnOff(sender: UISwitch) {
        
        if sender.on {
            UserDefault.setBool(Constants.PREFKEY_NOTISOUND + chatRoom._name, value: true)
        } else {
            UserDefault.setBool(Constants.PREFKEY_NOTISOUND + chatRoom._name, value: false)
        }
    }

    // go to SelectFriendViewController
    // invite selectedFriends to chat room
    @IBAction func groupChatTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true) {
            self.settingDelegate?.groupChatAction!()
        }        
    }
    
    // add or block tapped
    @IBAction func addOrBlockTapped(sender: AnyObject) {
        
        settingDelegate?.blockAction!(blockStatus == .BLOCKED ? true : false)
    }
    
    func updateUI(status: BlockStatusType) {
        
        if status == .BLOCKED {
            imvAddorBlock.image = WBAsset.Menu_block_icon.image
            lblAddorBlock.text = Constants.MENU_BLOCK
            blockStatus = .BLOCKED
        } else {
            blockStatus = .UNBLOCKED
            imvAddorBlock.image = WBAsset.Menu_unblock_icon.image
            lblAddorBlock.text = Constants.MENU_UNBLOCK
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
