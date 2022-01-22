//
//  GroupChatListViewController.swift
//  WonBridge
//
//  Created by Tiia on 31/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

///
// Chat List of Group Users
///

class GroupChatListViewController: BaseViewController, IndicatorInfoProvider {
    
    weak var stripDelegate: StripTitleHideDelegate?
    
    var itemInfo = IndicatorInfo(title: Constants.SLIDE_GROUPCHATTING)
    
    @IBOutlet weak var tblGrpChatList: UITableView!
    
    var _user: UserEntity?
    
    // Group Chat Room List
    var arrGrpChat: [RoomEntity] = []

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
        tblGrpChatList.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        WBAppDelegate.xmpp._grpChatListMessageDelegate = self
        
        refreshChatList()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        WBAppDelegate.xmpp._grpChatListMessageDelegate = nil
    }
    
    func getChatList() {
        
        arrGrpChat.removeAll()        
        for _room in _user!._roomList {
            if !_room.isSingle() && _room._recentTime.length > 0 {
                arrGrpChat.append(_room)
            }
        }
        
        arrGrpChat = arrGrpChat.sort( {
            guard $0.getDate() != nil && $1.getDate() != nil else { return true }
            return $0.getDate()!.compare($1.getDate()!) == .OrderedDescending
        })
        
        var topList = [RoomEntity]()
        var notTopList = [RoomEntity]()
        for room in arrGrpChat {
            let top = UserDefault.getBool(Constants.PREFKEY_TOP + room._name, defaultValue: false)
            if top {
                topList.append(room)
            } else {
                notTopList.append(room)
            }
        }
        
        arrGrpChat.removeAll()
        arrGrpChat += topList
        arrGrpChat += notTopList
    }
    
    // reload chat list
    func refreshChatList() {
        
        self.getChatList()
        self.tblGrpChatList.reloadData()
    }
    
    // init recentCount of selected room and refresh chat list
    func readChat(room: RoomEntity) {
        
        guard room._recentCount > 0 else { return }
        
        WebService.reduceBadgeCount(_user!._idx, count: room._recentCount, completion: { (status) in
        })
        
        var badgeCount = UIApplication.sharedApplication().applicationIconBadgeNumber - room._recentCount
        badgeCount = badgeCount >= 0 ? badgeCount : 0
        UIApplication.sharedApplication().applicationIconBadgeNumber = badgeCount
        
        // recalculate not read count
        _user!.notReadCount -= room._recentCount
        room._recentCount = 0
        
        // notify updated badge count
        WBAppDelegate.notifyReceiveNewMessage()
        
        tblGrpChatList.reloadData()
        
        // update database
        DBManager.getSharedInstance().updateRoom(room)
    }
    
    /**
     * remove chat of selected room from database
     * delete chat history on deleted room
     * update badge count and notify it
     * refresh and notify leaving the room to all room participant. ( except me. )
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
        sendLeaveMessage(room)
    }
    
    // show deleting confirmation dialog
    func showDeleteDialog(room: RoomEntity) {
        
        if let group = _user!.getGroup(room._name) {
            if group.ownerID == _user!._idx {
 
                let storyboard = UIStoryboard(name: "Custom", bundle: nil)
                let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertConfirmViewController") as! CustomAlertConfirmViewController
                customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                customAlert.statusBarHidden = prefersStatusBarHidden()
                
                customAlert.showCustomAlert(self, title: Constants.TITLE_LEAVE_ROOM_OWNER, positive: Constants.ALERT_OK, positiveAction: {
                        self.dismissViewControllerAnimated(true, completion: {
                    })
                })
                
                return
            }
        }
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertViewController") as! CustomAlertViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        customAlert.statusBarHidden = prefersStatusBarHidden()
        
        customAlert.showCustomAlert(self, title: Constants.TITLE_CONFIRM_DELETE, positive: Constants.ALERT_OK, negative: Constants.ALERT_CANCEL, positiveAction: { _ in
            self.removeChat(room)
        }) { _ in}
    }

    // notify user(me) to leave this room to all room participants
    func sendLeaveMessage(room: RoomEntity) {
        
        for friend in room._participantList {
            
            let fullMsg = getRoomInfoString(room) + Constants.KEY_SYSTEM_MARKER + _user!._name + "$" + Constants.KEY_LEAVEROOM_MARKER + Constants.KEY_SEPERATOR + NSDate.utcString()
            WBAppDelegate.xmpp.sendMessage(fullMsg, to: friend._idx)
        }
    }
    
    func getRoomInfoString(model: RoomEntity) -> String {
        
        return Constants.KEY_ROOM_MARKER + model._name + ":" + model._participants + ":" + _user!._name + Constants.KEY_SEPERATOR
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "SegueGrpChatList2SelectFriend") {
            
            stripDelegate?.hideStripTitleOnNavBar()
        }
    }
}

extension GroupChatListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource and Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrGrpChat.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatListCell") as! ChatListCell
        cell.configureCell(arrGrpChat[indexPath.row], readAction: { (sender) in
            self.readChat(self.arrGrpChat[indexPath.row])
            }) { (sender) in
                self.showDeleteDialog(self.arrGrpChat[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 78
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        
        let chatRoom = arrGrpChat[indexPath.row]
        
        chatVC.chatRoom = chatRoom
        
        WBAppDelegate.xmpp.enterChattingRoom(chatRoom)
        
        if chatRoom._recentCount > 0 {
            
            WebService.reduceBadgeCount(_user!._idx, count: chatRoom._recentCount, completion: { (status) in
            })
            
            var badgeCount = UIApplication.sharedApplication().applicationIconBadgeNumber - chatRoom._recentCount
            badgeCount = badgeCount >= 0 ? badgeCount : 0
            UIApplication.sharedApplication().applicationIconBadgeNumber = badgeCount
            
            _user!.notReadCount -= chatRoom._recentCount
            chatRoom._recentCount = 0
            
            // update tabbar badge number
            WBAppDelegate.notifyReceiveNewMessage()
            
            // update database
            DBManager.getSharedInstance().updateRoom(chatRoom)
        }
        
        stripDelegate?.hideStripTitleOnNavBar()
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    // MARK: - Indicator Info Providers
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return itemInfo
    }
}

extension GroupChatListViewController: WBMessageDelegate {
    
    // update group chat list with received packet
    func newPacketReceived(_revPacket: ChatEntity) {
        
        // check if the room of received packet is already exist in user's room list
        // if exist then it needs to update the room information
        // else add the room of this received packet into user's room list
        self.refreshChatList()
    }
}




