//
//  ChatListViewController.swift
//  WonBridge
//
//  Created by Tiia on 31/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

///
// Chat List of Signle User
///

class ChatListViewController: BaseViewController, IndicatorInfoProvider {
    
    var _user: UserEntity?
    
    weak var stripDelegate: StripTitleHideDelegate?
    
    var itemInfo = IndicatorInfo(title: Constants.SLIDE_CHATTING)
    
    @IBOutlet weak var tblChatList: UITableView!
    
    // Chat Room List
    var arrChat: [RoomEntity] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _user = WBAppDelegate.me
        
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        
        // remove tableview separator of empty cell
        tblChatList.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        WBAppDelegate.xmpp._chatListMessageDelegate = self
        
        refreshChatList()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        WBAppDelegate.xmpp._chatListMessageDelegate = nil
    }
    
    func getChatList() {
        
        arrChat.removeAll()
        
        for _room in _user!._roomList {
            if _room.isSingle() && _room._recentTime.length > 0 {
                arrChat.append(_room)
            }
        }
        
        arrChat = arrChat.sort( {
            guard $0.getDate() != nil && $1.getDate() != nil else { return true }
            return $0.getDate()!.compare($1.getDate()!) == .OrderedDescending
        })
    }
    
    // reload chat list
    func refreshChatList() {
        
        self.getChatList()
        self.tblChatList.reloadData()
    }
    
    // init recentCount of selected room and refresh chat list
    func readChat(room: RoomEntity) {
        
        guard room._recentCount > 0 else { return }
        
        WebService.reduceBadgeCount(_user!._idx, count: room._recentCount, completion: { (status) in
        })
        
        var badgeCount = UIApplication.sharedApplication().applicationIconBadgeNumber - room._recentCount
        badgeCount = badgeCount >= 0 ? badgeCount : 0
        UIApplication.sharedApplication().applicationIconBadgeNumber = badgeCount
        
        _user!.notReadCount -= room._recentCount
        room._recentCount = 0
        
        // notify
        WBAppDelegate.notifyReceiveNewMessage()
        
        // update database
        DBManager.getSharedInstance().updateRoom(room)
        
        tblChatList.reloadData()
    }
    
    /**
     * remove chat of selected room from database
     */
    func removeChat(room: RoomEntity) {
        
        if (room._recentCount > 0) {
            WebService.reduceBadgeCount(_user!._idx, count: room._recentCount, completion: { (status) in
            })
            
            var badgeCount = UIApplication.sharedApplication().applicationIconBadgeNumber - room._recentCount
            badgeCount = badgeCount >= 0 ? badgeCount : 0
            UIApplication.sharedApplication().applicationIconBadgeNumber = badgeCount
        }
        
        guard let index = _user!._roomList.indexOf(room) else { return }
        
        // delete room from database
        DBManager.getSharedInstance().removeRoom(room._name)
        
        // remove room from user's room list
        _user!._roomList.removeAtIndex(index)
        
        // recalculate not read count
        _user!.notReadCount -= room._recentCount
        
        // notify
        WBAppDelegate.notifyReceiveNewMessage()
        
        refreshChatList()
    }
    
    // show deleting confirmation dialog
    func showDeleteDialog(room: RoomEntity) {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertViewController") as! CustomAlertViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        customAlert.statusBarHidden = prefersStatusBarHidden()
        
        customAlert.showCustomAlert(self, title: Constants.TITLE_CONFIRM_DELETE, positive: Constants.ALERT_OK, negative: Constants.ALERT_CANCEL, positiveAction: { _ in
            self.removeChat(room)
            }) { _ in                
        }
    }
    
    // MARK: - Indicator Info Providers
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return itemInfo
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "SegueChatList2FriendSelect" || segue.identifier == "SegueChatList2Chat") {
            
            stripDelegate?.hideStripTitleOnNavBar()
        }
        
        if (segue.identifier == "SegueChatList2Chat") {
            
            let chatRoom = arrChat[tblChatList.indexPathForSelectedRow!.row]
            
            WBAppDelegate.xmpp.enterChattingRoom(chatRoom)
            
            if (chatRoom._recentCount > 0) {
                
                WebService.reduceBadgeCount(_user!._idx, count: chatRoom._recentCount, completion: { (status) in                    
                })
                
                var badgeCount = UIApplication.sharedApplication().applicationIconBadgeNumber - chatRoom._recentCount
                badgeCount = badgeCount >= 0 ? badgeCount : 0
                UIApplication.sharedApplication().applicationIconBadgeNumber = badgeCount
                
                _user!.notReadCount -= chatRoom._recentCount
                // update tabbar badge number
                WBAppDelegate.notifyReceiveNewMessage()
                chatRoom._recentCount = 0                
                // update db with _recentCount
                DBManager.getSharedInstance().updateRoom(chatRoom)
            }
            
            let chatVC = segue.destinationViewController as! ChatViewController
            chatVC.chatRoom = chatRoom
        }
    }
}

extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource and Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrChat.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatListCell") as! ChatListCell
        cell.configureCell(arrChat[indexPath.row], readAction: { (sender) in
            self.readChat(self.arrChat[indexPath.row])
            
            }) { (sender) in
                self.showDeleteDialog(self.arrChat[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 78
    }

}

extension ChatListViewController: WBMessageDelegate {
    
    // update chat list with received packet
    func newPacketReceived(_revPacket: ChatEntity) {
        
        self.refreshChatList()
    }
}



