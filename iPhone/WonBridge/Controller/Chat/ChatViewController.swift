//
//  ChatViewController.swift
//  WonBridge
//
//  Created by Tiia on 01/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import Cent

let CONTENTVIEW_HEIGHT = CGFloat(201)

class ChatViewController: BaseViewController {
    // me
    var _user: UserEntity?
    var chatRoom: RoomEntity?
    
    var _assets = [AnyObject]()
    var _photos = [WBMediaModel]()
    var _videos = [WBMediaModel]()
    
    var from = ""
    var isFriendRequest = false
    
    var refreshCount = 1
    var lastReceivedDate = ""
    
    var bChatAvailable = false
    
    var isOnlineService: Bool = false
    
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    lazy var listTableView: UITableView = {
        let listTableView = UITableView(frame: CGRect.zero, style: .Plain)
        listTableView.dataSource = self
        listTableView.delegate = self
        listTableView.backgroundColor = UIColor.clearColor()
        listTableView.separatorStyle = .None
        listTableView.showsVerticalScrollIndicator = false
        return listTableView
    }()
    
    var chatActionBarView: ChatActionBarView!   // action bar
    var actionBarPaddingBottomConstranit: Constraint?   // action bar bottom constraint
    var keyboardHeightConstraint: NSLayoutConstraint?

    var emotionInputView: ChatEmotionInputView!
    var shareMoreView: ChatShareMoreView!
    var shareMediaView: ChatShareMediaView!

    let disposeBag = DisposeBag()
    var imagePicker: UIImagePickerController! = UIImagePickerController()

    var itemDataSource = [ChatEntity]()
    var isReloading: Bool = false
    var isEndRefreshing: Bool = true
    
    // popover setting menu
    var settingVC: ChatMenuViewController!
    
    let dateFormatter = NSDateFormatter()
    
    let modalTransition = ModalTrainsition(animationType: ModalAnimationType.simple)
    
    var groupRequests = [GroupRequestEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set global user
        _user = WBAppDelegate.me
        
        // update db
        if chatRoom != nil {
            DBManager.getSharedInstance().updateChatNoCurrent(chatRoom!._name)
        }
        
        // initialize view
        initView()
        
        if isOnlineService {
            // online chat
            
            loadOnlineMessage(true)
        } else {
            // xmpp instant messaging
            // add custom delegate for xmpp here
            WBAppDelegate.xmpp._chatMessageDelegate = self
            WBAppDelegate.xmpp._roomMessageDelegate = self
            WBAppDelegate.xmpp._reconnectionDelegate = self
            
            firstFetchMessageList(chatRoom!._name)
            
            showToast(Constants.CONNECTING_CHAT_SERVER)
        }
        
        loadAssets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func initView() {
        
        // register cell
        self.listTableView.registerNib(ChatTextCell.NibObject(), forCellReuseIdentifier: ChatTextCell.identifier)
        self.listTableView.registerNib(ChatTimeCell.NibObject(), forCellReuseIdentifier: ChatTimeCell.identifier)
        self.listTableView.registerNib(ChatImageCell.NibObject(), forCellReuseIdentifier: ChatImageCell.identifier)
        self.listTableView.registerNib(ChatSystemCell.NibObject(), forCellReuseIdentifier: ChatSystemCell.identifier)
        
        // add pull to refresh on chat tableview
        // table view init
        self.listTableView.tableFooterView = UIView()
        // add refresh control to message tableview
        self.listTableView.addSubview(refreshControl)
        
        setupSubviews(self)
        self.keyboardControl()
        self.setupActionBarButtonInterAction()
        
        // set navigation title
        self.title = getRoomTitle()
        
        guard chatRoom != nil else { return }
        
        // set block status
        if chatRoom!.isSingle() {
            
            let friend = chatRoom!._participantList[0]
            if _user!.isBlockedFriend(friend._idx) {
                setBlockState(false)
            }
            
            if _user!.isFriend(friend._idx) {
                addSettingButton()
            }
            
        } else {
            
            addSettingButton()
        }
        
        // get room information and update ui
        if !isOnlineService {
            getRoomInfo()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateRoomTitle()
    }
    
    // get room participant info and update it
    func getRoomInfo() {
        
        WebService.getRoomInfo(_user!._idx, participantName: chatRoom!._participants) { (status, participants) in
            
            if (status) {
                // need to update participants' information with their new information
                for updatedParticipant in participants {
                    let partId = updatedParticipant._idx
                    
                    guard let originalParticipant = self.chatRoom!.getParticipant(partId) else { continue }
                    originalParticipant._name = updatedParticipant._name
                    originalParticipant._photoUrl = updatedParticipant._photoUrl
                    originalParticipant._isFriend = updatedParticipant._isFriend
                    originalParticipant._lastLogin = updatedParticipant._lastLogin
                    originalParticipant.location = updatedParticipant.location
                }
            }
            
            self.updateAcceptMenu()
            
            self.getGroupRequest()
        }
    }
    
    func getRoomTitle() -> String {
        
        if isOnlineService {
            return Constants.TITLE_ONLINE_SERVICE
        }
        
        guard chatRoom != nil else { return "" }
        
        var title = ""
        if chatRoom!.isSingle() {
            
            title = chatRoom!._participantList[0]._name
        } else {
            
            var leaveCount = 0
            if chatRoom!._leaveMembers.length > 0 {
                leaveCount = chatRoom!._leaveMembers.componentsSeparatedByString("_").count
            }
            
            if let existGroup = _user!.getGroup(chatRoom!._name) {
//                title = existGroup.nickname + " (\(chatRoom!._participantList.count + 1))"
                title = existGroup.nickname + " (\(chatRoom!._participantList.count - leaveCount + 1))" // +1 for me
            } else {
//                title = Constants.TITLE_GROUP + " \(chatRoom!._participantList.count + 1)"
                title = Constants.TITLE_GROUP + " (\(chatRoom!._participantList.count - leaveCount + 1))"
            }
        }
        
        return title
    }
    
    func updateRoomTitle() {
        
        UIView.setAnimationsEnabled(false)
        self.title = getRoomTitle()
        UIView.setAnimationsEnabled(true)
    }
    
    // it will only run on 1:1 chat
    func updateAcceptMenu() {
        
        guard chatRoom!.getCurrentUsers() == 1 else { return }
        
        let other = chatRoom!._participantList[0]
        guard !other._isFriend else { return }

        let btnAccept = UIButton()
        btnAccept.frame = CGRectMake(0, 0, 80, 30)
        btnAccept.setTitle(Constants.TITLE_ACCEPT, forState: .Normal)
        btnAccept.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btnAccept.backgroundColor = UIColor(colorNamed: WBColor.friendAcceptBtnBkgColor)
        btnAccept.titleLabel!.font = UIFont.systemFontOfSize(15)

        btnAccept.addTarget(self, action: #selector(acceptFriendRequest), forControlEvents: .TouchUpInside)

        btnAccept.layer.cornerRadius = 5
        btnAccept.layer.masksToBounds = true
        let acceptRightBarButton = UIBarButtonItem(customView: btnAccept)
        navigationItem.rightBarButtonItem = acceptRightBarButton
    }
    
    func acceptFriendRequest() {
        
        guard bChatAvailable else {
            showToast(Constants.DISCONNECTED_CHAT_SERVER)
            return
        }
        
        makeFriend()
    }
    
    // make a friend with user who sent a freind request
    func makeFriend() {
        
        let otherUser = chatRoom!._participantList[0]
        WebService.makeFriend(_user!._idx, other_id: otherUser._idx) { (status, message) in
            
            if status {
                
                otherUser._isFriend = true
                self.sendAcceptMessage()
                self.removeAcceptButton()
            }
        }
    }

    // remove accept button and add setting button.
    func removeAcceptButton() {
        
        let _settingButton = UIButton()
        _settingButton.frame = CGRectMake(0, 0, 24, 30)
        _settingButton.backgroundColor = UIColor.clearColor()
        _settingButton.setImage(WBAsset.Menu_Setting_Icon.image, forState: .Normal)
        
        _settingButton.addTarget(self, action: #selector(settingButtonTapped(_:)), forControlEvents: .TouchUpInside)
        let settingBarButtonItem = UIBarButtonItem(customView: _settingButton)
        navigationItem.rightBarButtonItem = settingBarButtonItem
    }
    
    func addSettingButton() {
        
        let _settingButton = UIButton()
        _settingButton.frame = CGRectMake(0, 0, 24, 30)
        _settingButton.backgroundColor = UIColor.clearColor()
        _settingButton.setImage(WBAsset.Menu_Setting_Icon.image, forState: .Normal)
        
        _settingButton.addTarget(self, action: #selector(settingButtonTapped(_:)), forControlEvents: .TouchUpInside)
        let settingBarButtonItem = UIBarButtonItem(customView: _settingButton)
        navigationItem.rightBarButtonItem = settingBarButtonItem
    }
    
    // setting tapped
    @IBAction func settingButtonTapped(sender: UIButton) {
        
        if chatRoom!.isSingle() {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
            
            if settingVC == nil {
                settingVC = storyboard.instantiateViewControllerWithIdentifier("ChatMenuViewController") as! ChatMenuViewController
            }
            
            settingVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            settingVC.settingDelegate = self
            settingVC.preferredContentSize = CGSizeMake(self.view.bounds.size.width - 60, 213)
            settingVC.chatRoom = chatRoom
            
            if _user!.isBlockedFriend(chatRoom!._participantList[0]._idx) {
                settingVC.blockStatus = .UNBLOCKED
            } else {
                settingVC.blockStatus = .BLOCKED
            }
            
            let popover: UIPopoverPresentationController = settingVC.popoverPresentationController!
            popover.permittedArrowDirections = UIPopoverArrowDirection.Up
            popover.delegate = self
            popover.sourceView = sender
            let senderRect = sender.convertRect(sender.frame, fromView: sender.superview)
            let sourceRect = CGRect(x: senderRect.origin.x, y: senderRect.origin.y + (sender.frame.size.height / 2), width: senderRect.size.width, height: senderRect.size.height)
            popover.sourceRect = sourceRect
            presentViewController(settingVC, animated: true, completion:nil)
              
        } else {
            
            self.hideAllKeyboard()
            
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let groupInfoVC = storyboard.instantiateViewControllerWithIdentifier("GroupInfoViewController") as! GroupInfoViewController
            
            guard let group = _user!.getGroup(chatRoom!._name) else {
                print("user has no group to current chatting room")
                return
            }
            groupInfoVC.selectedGroup = group
            
            self.navigationController?.pushViewController(groupInfoVC, animated: true)
        }
    }

    // back to previous controller
    @IBAction func backButtonTapped(sender: AnyObject) {

        settingVC?.dismissViewControllerAnimated(true, completion: nil)
        
        if !isOnlineService {
            leaveRoom()
        }
        
        if from == FROM_USERPROFILE {
            performSegueWithIdentifier("SegueChat2TimeLineSlider", sender: self)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // room recent count(not read count) will be set as a zero
    func saveRoomChat() {
        
//        if (itemDataSource.count > 0) {
//            
//            let lastChat: ChatEntity = itemDataSource[itemDataSource.count - 1]
//            chatRoom!._recentContent = lastChat.recentContent
//            chatRoom!._recentTime = lastChat._timestamp
//        }
        chatRoom!._recentCount = 0
        DBManager.getSharedInstance().updateRoom(chatRoom!)        
    }
    
    // All messages of this room will be changed as old messages
    func leaveRoom() {
        
        DBManager.getSharedInstance().updateChatNoCurrent(chatRoom!._name)
        saveRoomChat()
        // leave chat room
        WBAppDelegate.xmpp.leaveRoom(chatRoom!)
    }
    
    func refreshTable() {
        
        if !isOnlineService {
            
            guard self.isEndRefreshing else {
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    self.refreshControl.endRefreshing()
                })
                
                return
            }
            
            self.pullToLoadMore()
            
        } else {
            
            loadOnlineMessage(false)
        }
    }
    
    @IBAction func unwindSegueToChatView(segue: UIStoryboardSegue) {
        
    }
    
    func getGroupRequestByUserId(sender: Int) {
        
        WebService.getGroupRequestByUserId(sender, roomName: chatRoom!._name) { (status, request) in
            
            if status && request != nil {
                
                self.showAcceptGroupDialogWithRequest(request!)
            }
        }
    }
    
    // get group request of current group
    func getGroupRequest() {
        
        // get a group
        guard let group = _user!.getGroup(chatRoom!._name) else { return }
        
        // check if I am a owner of current chatting room,
        // if owner of current room, will process request message
        // otherwise, return
        guard group.ownerID == _user!._idx else { return }
        
        WebService.getGroupRequest(chatRoom!._name) { (status, requests) in
            
            if status {
                
                self.groupRequests.removeAll()
                self.groupRequests = requests!
                
                if self.groupRequests.count > 0 {
                    self.showAcceptGroupDialog(0)
                }
            }
        }
    }
    
    func showAcceptGroupDialogWithRequest(request: GroupRequestEntity) {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("GroupAcceptViewController") as! GroupAcceptViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

        customAlert.showAcceptSingleDialog(self, request: request, confirmAction: { _ in
            
            self.acceptGroupRequest(request)
        }) { _ in
            self.declineGroupRequest(request)
        }
    }
    
    // you have multiple group request for group current group
    // index is a sequence of request array
    func showAcceptGroupDialog(index: Int) {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("GroupAcceptViewController") as! GroupAcceptViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        let request = groupRequests[index]
        customAlert.showAcceptDialog(self, request: request, requestIdx: index + 1, requestSize: groupRequests.count, confirmAciton: { _ in
            
            self.acceptGroupRequest(request)
            
            // process next request 
            if index + 1 < self.groupRequests.count {
                self.showAcceptGroupDialog(index + 1)
            }
            
            }) { _ in
                self.declineGroupRequest(request)
                
                // process next request
                if index + 1 < self.groupRequests.count {
                    self.showAcceptGroupDialog(index + 1)
                }
        }
    }
    
    // will add request user to group (room) participants
    // sync group information with server
    func acceptGroupRequest(request: GroupRequestEntity) {
        
        let requestUser = FriendEntity()
        requestUser._idx = request.userId
        requestUser._name = request.username
        requestUser._photoUrl = request.userPhoto
        
        // check if request user is already member of this room or not
        guard chatRoom!.getParticipant(requestUser._idx) == nil else { return }
        
        // update participant list and participants
        chatRoom!._participantList.append(requestUser)
        chatRoom!._participants = chatRoom!.participantsWithoutLeaveMembers(true)
        
        // update database
        DBManager.getSharedInstance().updateRoom(chatRoom!)
        
        // send accept group request message
        sendAcceptGroupMessage(request)
        
        // sync to server
        WebService.acceptGroupRequest(request, participants: chatRoom!._participants) { (status) in
            if status {
                print("You accepted group request of user: \(request.username)")
            }
        }
    }
    
    // send replies to a request for joining this group
    func sendAcceptGroupMessage(request: GroupRequestEntity) {
       
        let acceptMsg = request.username + "$" + chatRoom!._name + "$" + Constants.KEY_ADD_MARKER
        sendStatusMessageToRoom(acceptMsg, toMe: true)
    }
    
    func sendStatusMessageToRoom(message: String, toMe: Bool) {
        
        let fullMsg = getRoomInfoString() + Constants.KEY_SYSTEM_MARKER + message + Constants.KEY_SEPERATOR + NSDate.utcString()
        
        guard chatRoom != nil else { return }
        
        let participantCount = chatRoom!._participantList.count
        for index in 0 ... participantCount {
            
            var toIndex = 0
            if index < participantCount {
                toIndex = chatRoom!._participantList[index]._idx
            } else {
                if !toMe {
                    break
                }
                toIndex = _user!._idx
            }
            
            WBAppDelegate.xmpp.sendMessage(fullMsg, to: toIndex)
        }
    }
    
    func declineGroupRequest(request: GroupRequestEntity) {
        
        WebService.declineGroupRequest(request) { (status) in
            
            if status {
                print("You declined group request of user: \(request.username)")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }*/
}

// MARK: UIPopoverPresentationControllerDelegate
extension ChatViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

// MARK: @protocol UITableViewDataSource, UITableViewDelegate
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource and Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chatModel = self.itemDataSource.get(indexPath.row)
        guard let type: MessageContentType = chatModel._contentType where chatModel != nil else { return ChatBaseCell() }
        return type.chatCell(tableView, indexPath: indexPath, model: chatModel, room: chatRoom, user: _user!, viewController: self)!
    }
    
    // tableview delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let chatModel = self.itemDataSource.get(indexPath.row)
        guard let type: MessageContentType = chatModel._contentType where chatModel != nil else { return 0 }
        return type.chatCellHeight(chatModel)
    }
}

// MARK: @protocol UIScrollViewDelegate
extension ChatViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        self.hideAllKeyboard()
    }
}

