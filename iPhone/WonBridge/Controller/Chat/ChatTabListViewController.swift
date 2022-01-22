//
//  ChatTabListViewController.swift
//  WonBridge
//
//  Created by Elite on 11/1/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class ChatTabListViewController: BaseViewController {
    
    var _user: UserEntity?
    
    @IBOutlet weak var listTableView: UITableView!
    var itemDataSource = [RoomEntity]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _user = WBAppDelegate.me!
        
        listTableView.dataSource = self
        listTableView.delegate = self
        
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        WBAppDelegate.xmpp._chatListMessageDelegate = self
        
        initChatList()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        WBAppDelegate.xmpp._chatListMessageDelegate = self
    }
    
    func initChatList() {
        
        itemDataSource.removeAll()
        
        for room in _user!._roomList {
            if room._recentTime.length > 0 {
                itemDataSource.append(room)
            }
        }
        
        itemDataSource = itemDataSource.sort( {
            guard $0.getDate() != nil && $1.getDate() != nil else { return true }
            return $0.getDate()!.compare($1.getDate()!) == .OrderedDescending
        })
        
        var topList = [RoomEntity]()
        var notTopList = [RoomEntity]()
        for room in itemDataSource {
            let top = UserDefault.getBool(Constants.PREFKEY_TOP + room._name, defaultValue: false)
            if top {
                topList.append(room)
            } else {
                notTopList.append(room)
            }
        }
        
        itemDataSource.removeAll()
        itemDataSource += topList
        itemDataSource += notTopList
 
        listTableView.reloadData()
    }
    
    func initView() {
        
        // remove empty cell of tableview
        listTableView.tableFooterView = UIView()
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
        
        listTableView.reloadData()
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
    
    /**
     * remove chat of selected room from database
     */
    func removeChat(room: RoomEntity) {
        
        if (room._recentCount > 0) {
            WebService.reduceBadgeCount(_user!._idx, count: room._recentCount, completion: { (status) in
            })
        }
        
//        guard let index = _user!._roomList.indexOf(room) else { return }
        
        // delete room from database
        DBManager.getSharedInstance().removeRoom(room._name)
        
        // remove room from user's room list
//        _user!._roomList.removeAtIndex(index)
        _user!.removeRoom(room)
        
        // remove group
        if let group = _user!.getGroup(room._name) {
            _user!.removeGroup(group)
        }
        
        // recalculate not read count
        _user!.notReadCount -= room._recentCount
        
        // notify
        WBAppDelegate.notifyReceiveNewMessage()
        
        initChatList()
        
        if !room.isSingle() {
            sendLeaveMessage(room)
            setLeaveMemberToServer(room)
        }
    }
    
    // notify user(me) to leave this room to all room participants
    func sendLeaveMessage(room: RoomEntity) {
        
        for friend in room._participantList {
            
            let fullMsg = getRoomInfoString(room) + Constants.KEY_SYSTEM_MARKER + _user!._name + "$" + Constants.KEY_LEAVEROOM_MARKER + Constants.KEY_SEPERATOR + NSDate.utcString()
            WBAppDelegate.xmpp.sendMessage(fullMsg, to: friend._idx)
        }
    }
    
    // set group info.
    func setLeaveMemberToServer(room: RoomEntity) {
        
//        WebService.setLeaveMemberToServer(room._name, participants: room.participantsWithoutLeaveMembers(false)) { (status) in
//        }
        
        WebService.setParticipantToServer(room._name, participants: room.participantsWithoutLeaveMembers(false)) { (status, groupProfileUrls) in
            // 
        }
    }
    
    func getRoomInfoString(model: RoomEntity) -> String {
        
        return Constants.KEY_ROOM_MARKER + model._name + ":" + model._participants + ":" + _user!._name + Constants.KEY_SEPERATOR
    }
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let selectFriendVC = storyboard.instantiateViewControllerWithIdentifier("SelectFriendViewController") as! SelectFriendViewController
        navigationController?.pushViewController(selectFriendVC, animated: true)
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

// MARK: - @protocol UITableVieDataSource & UITableViewDelegate
extension ChatTabListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatListCell") as! ChatListCell
        cell.configureCell(itemDataSource[indexPath.row], readAction: { (sender) in
            
            self.readChat(self.itemDataSource[indexPath.row])
            }) { (sender) in
                self.showDeleteDialog(self.itemDataSource[indexPath.row])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // go to chat view
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let chatVC = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        
        let chatRoom = itemDataSource[indexPath.row]
        
        WBAppDelegate.xmpp.enterChattingRoom(chatRoom)
        
        if (chatRoom._recentCount > 0) {
            
            WebService.reduceBadgeCount(_user!._idx, count: chatRoom._recentCount, completion: { (status) in
            })
            
            _user!.notReadCount -= chatRoom._recentCount
            
            // update tabbar badge number
            WBAppDelegate.notifyReceiveNewMessage()
            chatRoom._recentCount = 0
            // update db with _recentCount
            DBManager.getSharedInstance().updateRoom(chatRoom)
        }
        
        chatVC.chatRoom = chatRoom
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 78
    }
}

// MARK: - @protocol WBMessageDelegate
extension ChatTabListViewController: WBMessageDelegate {
    
    // update chat list with received chat
    func newPacketReceived(_revPacket: ChatEntity) {
        
        self.initChatList()
    }
}


