//
//  UserProfileViewController.swift
//  WonBridge
//
//  Created by Tiia on 31/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMaps

let FROM_USERLIST                       =           "From_UserListViewController"
let FROM_TIMELINEDETAIL                 =           "From_TimeLineDetailViewController"
let FROM_TIMELINE                       =           "From_TimeViewController"
let FROM_USERPROFILE                    =           "From_UserProfileViewController"
let FROM_CONTACT_FRIENDLIST             =           "From_ContactFriendViewController"

private let kProfileActivityPhotoWidth: CGFloat = 60
private let kDefaultPadding: CGFloat = 12
private let kProfileActivityPhotoHeight: CGFloat = (UIScreen.width - kDefaultPadding*2 - 8)*3/4.0

class UserProfileViewController: BaseViewController {
    
    var _user: UserEntity!                  // me
    var _selectedUser: FriendEntity?        // selected user
    var arrTimeLines:[String] = []          // recent timeline files ( 3 in maximum)
    
    var from = ""
    
    var isFriend = false    
    // function
    var enableMedia: Bool = false
    
    ///
    // user info view
    ///
    // user profile image
    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imvGender: UIImageView!
    @IBOutlet weak var lblUserId: UILabel!

    // user last logged time
    @IBOutlet weak var lblLastLoggedTime: UILabel!
    // user friend status
    @IBOutlet weak var lblFriendStatus: UILabel!
    // user registration date
    @IBOutlet weak var lblRegDate: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var imvCountry: UIImageView!
    
    
    @IBOutlet weak var lblSchool: UILabel!
    @IBOutlet weak var lblVillage: UILabel!
    @IBOutlet weak var lblWorking: UILabel!
    @IBOutlet weak var lblInterest: UILabel!
    // user address
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var timeLineView: UIView!
    // timeline tableview
    private lazy var listTableView: UITableView = {
      
        let tableView = UITableView(frame: CGRectMake(0, 0, kProfileActivityPhotoWidth, kProfileActivityPhotoHeight))
        tableView.backgroundColor = UIColor.clearColor()
        tableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
        tableView.center =  CGPointMake(kProfileActivityPhotoHeight / 2, self.timeLineView.frame.size.height / 2 )
        tableView.pagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.rowHeight = kProfileActivityPhotoWidth
        return tableView
    }()
    
    @IBOutlet weak var bottomView: UIView!
    
    // voice call
    @IBOutlet weak var imvIconVoice: UIImageView!
    @IBOutlet weak var lblIconVoice: UILabel!
    // video call
    @IBOutlet weak var imvIconVideo: UIImageView!
    @IBOutlet weak var lblIconVideo: UILabel!
    // chat
    @IBOutlet weak var imvIconChat: UIImageView!
    @IBOutlet weak var lblIconChat: UILabel!
    // Gift
    @IBOutlet weak var imvIconGift: UIImageView!
    @IBOutlet weak var lblIconGift: UILabel!
    // delete friend
    @IBOutlet weak var imvIconRemoveF: UIImageView!
    @IBOutlet weak var lblIconRemoveF: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me
        
        if CommonUtils.isCNLocale() {
            geocodeSearch = BMKGeoCodeSearch()
        } else {
            googleGeocoder = GMSGeocoder()
        }

        initView()

        getUserInfo()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if CommonUtils.isCNLocale() {
            geocodeSearch.delegate = self
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        if CommonUtils.isCNLocale() {
            geocodeSearch.delegate = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        
        // add shadow to bottom button view
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomView.layer.shadowOpacity = 0.2
        bottomView.layer.shadowRadius = 2
        bottomView.layer.masksToBounds = false
        
        timeLineView.addSubview(listTableView)
        listTableView.registerNib(TimeLinePhotoCell.NibObject(), forCellReuseIdentifier: TimeLinePhotoCell.identifier)
  
        guard _selectedUser != nil else { return }

        // navigation title with user's name
        self.title = _selectedUser!._name.uppercaseString + " " + Constants.TITLE_PROFILE
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        lblName.text = _selectedUser!._name
        imvGender.hidden = true // no sex here. it will be hidden during to get all user's information from a server
        
        imvCountry.hidden = true
        
        imvProfile.setImageWithUrl(NSURL(string: _selectedUser!._photoUrl)!, placeHolderImage: WBAsset.UserPlaceHolder.image)

        // disable chat function with blocked user
        if _user!.isBlockedFriend(_selectedUser!._idx) {
            enableChatting(false)
        }

        // voice or video calling, add or delete friend
        updateFunction(_selectedUser!._isFriend)
    }
    
    // show user's timeline list
    @IBAction func timeLineListTapped(sender: AnyObject) {
        
        guard arrTimeLines.count > 0 else { return }
        
        let storyboard = UIStoryboard(name: "TimeLine", bundle: nil)
        let timeLineListVC = storyboard.instantiateViewControllerWithIdentifier("TimeLineListViewController") as! TimeLineListViewController
        timeLineListVC.selectedUser = _selectedUser!
        timeLineListVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(timeLineListVC, animated: true)
    }
    
    @IBAction func backButtonTapped(sender : AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // voice calling action
    @IBAction func voiceCallTapped(sender: AnyObject) {
        
        guard enableMedia else { return }
        
        CommonUtils.checkPermission(AVMediaTypeAudio) { (granted) in
            
            if granted {
                // do process for voice calling
                self.callWithUser(false)
            } else {
                // show alert
                self.showAlert(Constants.APP_NAME, message: Constants.NEED_ACCESS_MICROHPHONE   , positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }

    // video calling action
    @IBAction func videoCallTapped(sender: AnyObject) {
        
        guard enableMedia else { return }
        
        CommonUtils.checkPermission(AVMediaTypeVideo) { (granted) in
            
            if granted {
                
                CommonUtils.checkPermission(AVMediaTypeAudio, completion: { (granted) in
                    if granted {
                        // do process for video calling
                        self.callWithUser(true)
                    } else {
                        // show alert
                        self.showAlert(Constants.APP_NAME, message: Constants.NEED_ACCESS_MICROHPHONE   , positive: Constants.ALERT_OK, negative: nil)
                    }
                })
            } else {
                // show alert
                self.showAlert(Constants.APP_NAME, message: Constants.NEED_ACCESS_CAMERA , positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
    
    // send message (chatting) action
    // go to chat with a selected user
    @IBAction func sendMessageTapped(sender: AnyObject) {
        
        guard _user._idx != _selectedUser!._idx else { return }
        gotoChatViewController(false)
    }
    
    func gotoChatViewController(friendRequest: Bool) {
        
        guard !_user!.isBlockedFriend(_selectedUser!._idx) else { return }
        
        let chatRoom = makeRoomWithUser()
        WBAppDelegate.xmpp.enterChattingRoom(chatRoom)
        
        if (chatRoom._recentCount > 0) {
            _user.notReadCount -= chatRoom._recentCount
            chatRoom._recentCount = 0
            // change application badge count
            WBAppDelegate.notifyReceiveNewMessage()
            
            // update database
            DBManager.getSharedInstance().updateRoom(chatRoom)            
        }
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let chatVC = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        chatVC.chatRoom = chatRoom
        chatVC.isFriendRequest = friendRequest
        chatVC.from = FROM_USERPROFILE
        
        var viewcontrollers = self.navigationController?.viewControllers
        if from == FROM_TIMELINEDETAIL {
            
            // pop two prior viewcontrollers (UserProfileViewController & TimeLineListViewController)
            // from timeline detail
            // remove user profile viewcontroller
            viewcontrollers?.removeLast()
            // remove timeline detail
            viewcontrollers?.removeLast()
            viewcontrollers?.append(chatVC)
            
            self.navigationController?.setViewControllers(viewcontrollers!, animated: true)
        } else {
            // FROM_USERLIST, FROM_TIMELINE, FROM_CONTACT_LIST
            // pop prior viewcontroller (UserProfileViewController)
            // friend view controller
            viewcontrollers?.removeLast()
            viewcontrollers?.append(chatVC)
            
            self.navigationController?.setViewControllers(viewcontrollers!, animated: true)
        }
    }
    
    // make a 1:1 chatting with selected user
    func makeRoomWithUser() -> RoomEntity {
        
        // make a chat room with selected user
        var _participants: [FriendEntity] = []
        _participants.append(_selectedUser!)
        
        // chatting room
        var chatRoom = RoomEntity(participants: _participants)
        // check if user has already the room is made with selected user for now
        for existRoom in _user._roomList {
            if (existRoom.equals(chatRoom)) {
                chatRoom = existRoom
                return chatRoom
            }
        }
        
        _user._roomList.append(chatRoom)
        // updae database
        DBManager.getSharedInstance().createRoom(chatRoom)
        return chatRoom
    }
    
    // send gift action
    @IBAction func sendGiftTapped(sender: AnyObject) {
        
    }
    
    // remove friend action
    @IBAction func removeFriendTapped(sender: AnyObject) {
        
        if _selectedUser!._isFriend {
            deleteFriend()
        } else {
            makeFriend()
        }
    }
    
    // update ui with user's information
    func updateUserInfo() {
        
        imvGender.hidden = false
        imvGender.image = _selectedUser!._gender == .MALE ? WBAsset.Male_Icon.image : WBAsset.Female_Icon.image
        
        lblLastLoggedTime.text = _selectedUser!._lastLogin.displayLocalTime()
        
        if _selectedUser!._isFriend {
            lblFriendStatus.text = Constants.STATE_FRIEND
        } else {
            lblFriendStatus.text = ""
        }
        
        lblRegDate.text = _selectedUser!._regDate.displayRegTime()
        
        getAddress(_selectedUser!.location!) { (address) in            
            self.lblAddress.text = address.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        lblCountry.text = CommonUtils.getDisplayCountryName(_selectedUser!._favCountry)
        imvCountry.image = UIImage(named: "ic_flag_flat_\(_selectedUser!._favCountry.trim().lowercaseString)")
        imvCountry.hidden = false
        
        lblWorking.text = _selectedUser!._working
        lblSchool.text = _selectedUser!._school
        lblVillage.text = _selectedUser!._village
        lblInterest.text = _selectedUser!._interest
        
        self.updateFunction(_selectedUser!._isFriend)
    }
    
    // add or delete friend buttom image and string accroding to selected user or timeline user
    // enable or disable voice and video calling
    func updateFunction(status: Bool) {
        
        if status {
            imvIconRemoveF.image = UIImage(named: "icon_delete_friend")
            lblIconRemoveF.text = Constants.DEL_FRIEND
        } else {
            imvIconRemoveF.image = UIImage(named: "icon_add_friend")
            lblIconRemoveF.text = Constants.ADD_FRIEND
        }
        
        guard !_user!.isBlockedFriend(_selectedUser!._idx) else {
            return
        }
        
        // enable or disable voice and video calling
        enableChatting(_selectedUser!._isFriend)
    }
    
    // enable chat
    func enableChatting(status: Bool) {
        
        // enable or disable voice and video calling
        if status {
            imvIconVoice.image = UIImage(named: "icon_phone")
            lblIconVoice.textColor = UIColor(netHex: 0x2196f3)
            imvIconVideo.image = UIImage(named: "icon_vedio-chat")
            lblIconVideo.textColor = UIColor(netHex: 0x2196f3)
            imvIconChat.image = UIImage(named: "icon_massage_on")
            lblIconChat.textColor = UIColor(netHex: 0x2196f3)
            
            enableMedia = true
        } else {
            imvIconVoice.image = UIImage(named: "icon_phone_off")
            lblIconVoice.textColor = UIColor(netHex: 0xc1c1c1)
            imvIconVideo.image = UIImage(named: "icon_vedio-chat_off")
            lblIconVideo.textColor = UIColor(netHex: 0xc1c1c1)
            imvIconChat.image = UIImage(named: "icon_massage_off")
            lblIconChat.textColor = UIColor(netHex: 0xc1c1c1)
            
            enableMedia = false
        }
    }
    
    func getUserInfo() {
        
        WebService.getUserInfo(_user._idx, otherId: _selectedUser!._idx) { (status, message, user, timeLineList) in
            
            if (status) {
                
                self._selectedUser = user
                self.arrTimeLines = timeLineList!
                self.listTableView.reloadData()
                self.updateUserInfo()
            } else {
                
                self.showToast(message)
            }
        }
    }
    
    func makeFriend() {
        WebService.makeFriend(_user!._idx, other_id: _selectedUser!._idx) { (status, message) in
            
            self.showToast(message)
            if status {
                self._selectedUser!._isFriend = true
                self._user.addFriend(self._selectedUser!)
                self.updateFunction(true)
                self.gotoChatViewController(true)
            }
        }
    }
    
    func deleteFriend() {
        WebService.deleteFriend(_user!._idx, other_id: _selectedUser!._idx) { (status, message) in
            
            self.showToast(message)
            if status {
                self._selectedUser!._isFriend = false
                self._user!.removeFriend(self._selectedUser!)
                self.updateFunction(false)
            }
        }
    }
    
    func callWithUser(videoEnable: Bool) {
        
        // send video request
        WBAppDelegate.xmpp.sendVideoRequest(_selectedUser!._idx, partnerName: _selectedUser!._name, videoEnable: videoEnable)
        
        AudioPlayInstance.playSoundWithType(.Ring_1)
    }
}


// MARK: - UITableViewDataSource & UITableViewDelegate
extension UserProfileViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return arrTimeLines.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TimeLinePhotoCell.identifier, forIndexPath: indexPath)  as! TimeLinePhotoCell
        cell.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2.0))
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.clearColor()
        cell.configCell(arrTimeLines[indexPath.row], bFile: false, deleteAction: nil)
        cell.hideDelButton()
        
        return cell
    }
}


