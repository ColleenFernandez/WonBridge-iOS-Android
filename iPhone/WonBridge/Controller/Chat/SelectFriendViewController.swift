//
//  FriendSelectViewController.swift
//  WonBridge
//
//  Created by Tiia on 31/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

let FROM_CHAT_SETTING                   =           "From_Chat_Setting"
let FROM_GROUP_CHAT_SETTING             =           "From_GroupChat_Setting"    //(will be removed)
let FROM_GROUP_INFO                     =           "From_GroupInfoViewController"
let FROM_CHAT_LIST                      =           "From_Chat_GroupChat_ListViewController"

class SelectFriendViewController: BaseViewController {
    
    var from = FROM_CHAT_LIST       // default
    
    // Common User - Me
    var _user: UserEntity?
    
    // This is the room where user was chatting with friend or friends before to come to this page
    // This will be valid when user come from ChatViewController (mean user clicked setting/group to set new group)
    var earlierRoom: RoomEntity?
    var members = [FriendEntity]()
    
    // will be used when comes from GroupInfoViewController 
    // user will invite or banish ( banishing user is available for only room owner)
    var isInvite: Bool = true
    
    // will be used when comes from GroupInfoViewController
    // selected user will be set room owner ( this function will be available for only room owner)
    var isDelegate: Bool = false
    var selectedDelegater: FriendEntity?
    
    // friend collectionviewcell item size
    private var itemSize: CGSize = CGSize()
    
    // filtered friend list
    // will be vary depending on where it comes.
    var itemDataSource = [FriendEntity]()
    
    // new participant(s) in case of inviting from group chatting
    var selectedFriendList: [FriendEntity] = []
    
    // refresh control
    var upperRefreshControl = UIRefreshControl()
    var bottomRefreshControl = UIRefreshControl()
    var pageIndex = 1
    
    @IBOutlet weak var gridFriend: UICollectionView!
    @IBOutlet weak var btnConfirm: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me;
        
        if isDelegate {
            gridFriend.allowsMultipleSelection = false
        }
        
        if earlierRoom != nil {
            
            let leaveIds = earlierRoom!._leaveMembers.componentsSeparatedByString("_")
            for participant  in earlierRoom!._participantList {
            
                if !leaveIds.contains("\(participant._idx)") {
                    members.append(participant)
                }
            }
        }
        
        initView()
        
        initFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        
        // title with white color
        self.title = Constants.FRIEND_SELECT
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // define collectioviewcell width and height according to root view size
        itemSize.width = (self.view.frame.size.width - 20) / 3
        itemSize.height = itemSize.width * 1.5
        // add pull to refresh on UITableView
        upperRefreshControl.tintColor = UIColor(netHex: 0x3366AD)
        upperRefreshControl.addTarget(self, action: #selector(refreshFriendList(_:)), forControlEvents: .ValueChanged)
        gridFriend.addSubview(upperRefreshControl)
        // add bottom refresh control on UITableView
        bottomRefreshControl.triggerVerticalOffset = 90
        bottomRefreshControl.tintColor = UIColor(netHex: 0x3366AD)
        bottomRefreshControl.addTarget(self, action: #selector(refreshFriendList(_:)), forControlEvents: UIControlEvents.ValueChanged)
        gridFriend.bottomRefreshControl = bottomRefreshControl
    }
    
    func isOldMember(user: FriendEntity) -> Bool {
        
        guard earlierRoom != nil  else { return false }
        
        for member in members {
            if member._idx == user._idx {
                return true
            }
        }
        
        return false
    }
    
    func initFriends() {
        
        itemDataSource.removeAll()
        
        if isInvite {
            for friend in _user!._frList {
                // will not add blocked friend
                guard !_user!.isBlockedFriend(friend._idx) else { continue }
                
                if earlierRoom != nil {
                    // in case that comes from ChatView or GroupInfoView, user is attempting to invite new friends to group chat
                    if !isOldMember(friend) {
                        itemDataSource.append(friend)
                    }
                } else {
                    // in case that comes from ChatListView or GroupChatListView, user is attempting to make a new chat room or group chat room
                    // user is stand on out of room (no have current room), so this value (earlier room) will be nil
                    itemDataSource.append(friend)
                }
            }
        } else {
            // case 1: banishing user(s)
            // case 2: delegate of room owner
            // will show original room participants            
            for friend in members {
                if isDelegate {
                    guard !_user!.isBlockedFriend(friend._idx) else { continue }
                }
                itemDataSource.append(friend)
            }
        }
        
        // deselect all users
        for friend in itemDataSource {
            friend._isSelected = false
        }
        
        gridFriend.reloadData()
        
        selectedFriendList.removeAll()
        updateConfirmButtonTitle()
    }
    
    func refreshFriendList(sender: UIRefreshControl) {
        
        if sender == upperRefreshControl {
            getFriendList(true)
        } else {
            getFriendList(false)
        }
    }
    
    func getFriendList(isRefresh: Bool) {
        
        if isRefresh {
            pageIndex = 1
        } else {
            pageIndex += 1
        }
        
        WebService.getFriends(_user!._idx, pageIndex: pageIndex) { (status, message, friendList) in
            
            if self.upperRefreshControl.refreshing {
                self.upperRefreshControl.endRefreshing()
            }
            
            if self.bottomRefreshControl.refreshing {
                self.bottomRefreshControl.endRefreshing()
            }
            
            if (status) {
                guard friendList.count > 0 else {
                    self.pageIndex -= 1
                    return
                }
                
                self.refreshUserFriendList(friendList)
            }
        }
    }
    
    func refreshUserFriendList(friendList: [FriendEntity]) {
        
        for friend in friendList {
            // if friend is already exist in user's friend list then it will be updated with new one
            // otherwise it will be added in user's friend list
            _user!.addFriend(friend)
        }
        
        // reload friend grid view
        initFriends()
    }
    
    func updateConfirmButtonTitle() {
        
        // disable animation to remove blink when to change button title
        UIView.setAnimationsEnabled(false)
        // update confirm button title according to selected friends count
        if (selectedFriendList.count == 0) {
            btnConfirm.title = Constants.TITLE_CONFIRM
        } else {
            btnConfirm.title = Constants.TITLE_CONFIRM + "(\(selectedFriendList.count))"
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func selectFriend(friend: FriendEntity) {
        
        friend._isSelected = !friend._isSelected
        
        if friend._isSelected {
            // add friend to selected friend list
            selectedFriendList.append(friend)
        } else {
            // remove friend from selected friend lsit
            selectedFriendList.removeAtIndex(selectedFriendList.indexOf(friend)!)
        }
        
        gridFriend.reloadData()
        updateConfirmButtonTitle()
    }
    
    func selectOneFriend(friend: FriendEntity) {
        
        for _friend in itemDataSource {
            if _friend.equals(friend) {
                _friend._isSelected = true
                
            } else {
                _friend._isSelected = false
            }
        }
        gridFriend.reloadData()
        selectedDelegater = friend
    }
    
    func makeRoom() {
        
        btnConfirm.enabled = false
        
        var participantList = [FriendEntity]()      // This will be room participants' list
        var newParticipantList = [FriendEntity]()   // new participants' list
        
        // here is two cases
        // case 1: members is nil       -  user is attempting to make a new chat room with selected friend(s) by clicking plus button on chat or group chat list
        //                              -   in case of group chat ( selectedFriend.count > 1 ) will make a new group ( room ) everytime
        //                              -   in case of 1:1 chat (selectedFriend.count == 1) will check if user has the chatting room with selected user if does, then will go to this room 
        //                                  otherwise will make a new 1:1 chat room with this user
        // case 2: members is not nil   -  user is attempting to make a new gorup in case that comes from 1:1 chat   ( will make a new room)
        //                              -  will not make a new group, invited selected will be  friend to same group ( will not make a new room)
        if earlierRoom != nil {
            participantList.insertContentsOf(earlierRoom!._participantList, at: 0)
        }
        
        for friend in selectedFriendList {
            participantList.append(friend)
            newParticipantList.append(friend)
        }
        
        guard participantList.count > 0 else { return }
        
        if earlierRoom == nil || earlierRoom?._participantList.count == 1 {
            // case 1: user is attempting make a new chat room (1:1 or group chat) by clicking + button on chatList         - earlierRoom is nil in this case
            // case 2: user is attempting make a new group from 1:1 chatting ( with earlier friend and selected friend(s))  - earlier room is not nill, room._participants.count = 1
            
            let newRoom = RoomEntity(participants: participantList)
            if !_user!.isExistRoom(newRoom) {
                if participantList.count == 1 {
                    // user made a new 1:1 chat room by selecting only one friend
                    _user!._roomList.append(newRoom)
                    DBManager.getSharedInstance().createRoom(newRoom)
                    gotoChattingRoom(newRoom)
                } else {
                    // group chat
                    uploadGroup(newRoom)
                }
            } else {
                // 1:1 chatting by clicking + button on chat list view
                // the room with selected user is already exist, so will go to existing room
                gotoChattingRoom(newRoom)
            }
        } else {
            // user is attempting to invite selected friend(s) to exsiting group chat
            // GroupInfoView + button click
            // perform unwind segue to GroupInfoViewController
            performSegueWithIdentifier("Segue2GroupInfo", sender: self)
        }
    }
    
    func uploadGroup(room: RoomEntity) {
        
        WebService.uploadGroup(_user!._idx, name: room._name, participants: room._participants) { (status, message) in
            self.btnConfirm.enabled = true
            
            if status {
                // add room into user's room list and save to database
                self._user!._roomList.append(room)
                
                // add inviteMessage
                var names = ""
                for friend in room._participantList {
                    names += friend._name + ","
                }
                names = names.substringToIndex(names.endIndex.advancedBy(-1))
                
                let statusMsg = names + "$" + Constants.KEY_INVITE_MARKER
                let roomInfo = Constants.KEY_ROOM_MARKER + room._name + ":" + room._participants + self._user!._name + Constants.KEY_SEPERATOR
                let fullMsg = roomInfo + Constants.KEY_SYSTEM_MARKER + statusMsg + Constants.KEY_SEPERATOR + NSDate.utcString()
                let inviteItem = ChatEntity(message: fullMsg, sender: "\(self._user!._idx)", imageModel: nil)
                
                DBManager.getSharedInstance().addChat(inviteItem, isCurrent: 0)
                
                room._recentTime = inviteItem._timestamp
                room._recentContent = inviteItem.recentContent
                DBManager.getSharedInstance().createRoom(room)
                
                let group = GroupEntity()
                group.name = room._name
                group.participants = room._participants
                group.ownerID = self._user!._idx
                group.countryCode = self._user!._countryCode
                
                for participant in room._participantList {
                    group.profileUrls.append(participant._photoUrl)
                }
                
                if group.profileUrls.count < 4 {
                    group.profileUrls.append(self._user!._photoUrl)
                }
                
                let calendar = NSCalendar.currentCalendar()
                let dateComponents = calendar.components([.Second, .Minute, .Hour, .Day, .Month, .Year], fromDate: NSDate())
                
                let time = String(format: "%d-%02d-%02d %02d:%02d:%02d", dateComponents.year, dateComponents.month, dateComponents.day, dateComponents.hour, dateComponents.minute, dateComponents.second)                
                group.regDate = time.displayRegTime()
                self._user!._groupList.append(group)
                
                // go to chat
                self.gotoChattingRoom(room)
                
            } else {
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
                self.btnConfirm.enabled = true
            }
        }
    }
    
    func showConfirmBanishDialog() {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertViewController") as! CustomAlertViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        customAlert.statusBarHidden = prefersStatusBarHidden()

        customAlert.showCustomAlert(self, title: Constants.TITLE_BANISH_ALERT, positive: Constants.ALERT_OK, negative: Constants.ALERT_CANCEL, positiveAction: {
            self.performSegueWithIdentifier("Segue2GroupInfo", sender: self)
        }) {}
    }
    
    func showConfirmDelegateDialog() {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertViewController") as! CustomAlertViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        customAlert.statusBarHidden = prefersStatusBarHidden()
        
        customAlert.showCustomAlert(self, title: selectedDelegater!._name + Constants.TITLE_DELEGATE_ALERT, positive: Constants.ALERT_OK, negative: Constants.ALERT_CANCEL, positiveAction: {
            
            self.performSegueWithIdentifier("Segue2GroupInfo", sender: self)
            }) {}
    }
    
    func gotoChattingRoom(room: RoomEntity) {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let chatVC = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        var viewControllers = navigationController?.viewControllers
        // remove SelectFriendVC from viewControllers stack
        viewControllers?.removeLast()
        
        if from == FROM_CHAT_LIST {
            // earlier room = nil, isInvite = true(default), isDelegate = false(default)
            // 1:1 chatting ( new and exist room ), group chatting ( will be new group everytime)
            chatVC.chatRoom = room
            chatVC.from = FROM_CHAT_LIST
            viewControllers?.append(chatVC)
            
            WBAppDelegate.xmpp.enterChattingRoom(room)
            
            navigationController?.setViewControllers(viewControllers!, animated: true)
            
        } else if from == FROM_CHAT_SETTING { // to check
            // user already save the chat data in database, so need to leave earlier chatting room in this case
            // leave earlier chatting room and enter a new group chat room
            leaveRoom()
            
            chatVC.chatRoom = room
            chatVC.from = FROM_CHAT_LIST
            // remove earlier ChatViewController
            viewControllers?.removeLast()
            // add new ChatViewController
            viewControllers?.append(chatVC)
            
            WBAppDelegate.xmpp.enterChattingRoom(room)
            
            navigationController?.setViewControllers(viewControllers!, animated: true)
        } 
    }
    
    func leaveRoom() {
        if earlierRoom != nil {
            WBAppDelegate.xmpp.leaveRoom(earlierRoom!)
        }
    }
    
    // go to chat with selected friends
    @IBAction func confirmButtonTapped(sender: AnyObject) {
        
        if isDelegate {
            //set room owner action
            guard selectedDelegater != nil else {
                debugPrint("select room owner to delegate")
                return
            }
            showConfirmDelegateDialog()
        } else {
            
            if isInvite {
                makeRoom()
            } else {
                showConfirmBanishDialog()
            }
        }
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

extension SelectFriendViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK - UICollectionViewDataSource and Delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return itemDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserGridCell", forIndexPath: indexPath) as! UserGridCell
        
        // set user model
        cell.setUser(itemDataSource[indexPath.row])
        // show check box for select user
        cell.setCheckVisibility(true)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let friend = itemDataSource[indexPath.row]
        if isDelegate {
            selectOneFriend(friend)
        } else {
            selectFriend(friend)
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return itemSize
    }
}

