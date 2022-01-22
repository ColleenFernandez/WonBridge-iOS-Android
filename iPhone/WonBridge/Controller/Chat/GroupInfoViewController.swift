//
//  GroupInfoViewController.swift
//  WonBridge
//
//  Created by July on 2016-09-30.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import AVFoundation

private let kCollectionViewPadding: CGFloat = 10
private let kRowCount: CGFloat = 4.0
private let kNameLabelHeight: CGFloat = 25

class GroupInfoViewController: BaseViewController {
    
    // me - global user
    var _user: UserEntity?
    // selected group
    var selectedGroup: GroupEntity?
    
    // participant list
    @IBOutlet weak var listCollectionView: UICollectionView!
    
    @IBOutlet weak var lblMemberCount: UILabel!
    @IBOutlet weak var imvAvatar: UIImageView!
    @IBOutlet weak var imvEdit: UIImageView!
    @IBOutlet weak var lblNickName: UILabel!            // Group name
    
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var groupTopSwitch: UISwitch!

    var collectionItemSize = CGSize()
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeightForHiddenConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ownerView: UIView!
    
    var finalGroup: GroupEntity?
    var room: RoomEntity?
    var members = [FriendEntity]()
    var newParticipants = [FriendEntity]()
    var banishParticipants = [FriendEntity]()
    
    var isGroupOwner = false
    
    let plusFriend = FriendEntity()
    let minusFriend = FriendEntity()
    
    var itemSizeH: CGFloat = kNameLabelHeight
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {    
        super.viewDidLoad()
        
        initData()
        
        initView()
        
        updateUI()
        
        picker.delegate = self
    }
    
    func initData() {
        
        _user = WBAppDelegate.me
        
        // check user's group list
        // this is exception process in case of coming of group chatting room.
        //  in this case we need to group's information but we have a chat room but no have group entity 
        // that's why group is being managed by admin.
        guard selectedGroup != nil else { return }
        
        finalGroup = _user!.getGroup(selectedGroup!.name)
        if finalGroup == nil {
            finalGroup = selectedGroup
        }
        
        room = _user!.getRoom(finalGroup!.name)
        if room != nil {
            let leaveIdList = room!._leaveMembers.componentsSeparatedByString("_")
            for friend in room!._participantList {
                if !leaveIdList.contains("\(friend._idx)") {
                    members.append(friend)
                }
            }
        }
        
        // add plus member for control
        plusFriend._name = kPlusMemberName
        members.append(plusFriend)
        
        if _user!._idx == finalGroup!.ownerID {
            isGroupOwner = true
            minusFriend._name = kMinusMemberName
            members.append(minusFriend)
        } else {
            isGroupOwner = false
        }
    }
    
    func initView() {
        
        // group profile image
        imvAvatar.setImageWithUrl(NSURL(string: finalGroup!.profileUrl)!, placeHolderImage: WBAsset.GroupPlaceHolder.image)
        
        // calculate collectionView height according to selected group member count
        // will be variant according to selected group
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: kCollectionViewPadding, left: kCollectionViewPadding, bottom: kCollectionViewPadding, right: kCollectionViewPadding)
        let itemSizeW: CGFloat = (self.view.width - 8*kCollectionViewPadding) / kRowCount
        itemSizeH += itemSizeW
        layout.itemSize = CGSizeMake(itemSizeW, itemSizeH)
        layout.minimumInteritemSpacing = kCollectionViewPadding
        listCollectionView.collectionViewLayout = layout
        
        listCollectionView.backgroundColor = UIColor.clearColor()
        
        soundSwitch.setOn(UserDefault.getBool(Constants.PREFKEY_NOTISOUND + finalGroup!.name, defaultValue: true), animated: false)
        groupTopSwitch.setOn(UserDefault.getBool(Constants.PREFKEY_TOP + finalGroup!.name, defaultValue: false), animated: false)
    }
    
    func updateUI() {
        
        let memberCount = isGroupOwner ? members.count - 1 : members.count
        
        self.title = Constants.GROUP_INFO + "(\(memberCount))"
        lblMemberCount.text = Constants.GROUP_MEMBER_COUNT + "(\(memberCount))"
        lblNickName.text = finalGroup!.getNickname()
        
        let colCount = ceil(CGFloat(members.count) / kRowCount)
        collectionViewHeightConstraint.constant = colCount * itemSizeH + kCollectionViewPadding*(colCount + 1)
        
        if !isGroupOwner {
            viewHeightForHiddenConstraint.constant = 0
            imvEdit.hidden = true
            ownerView.hidden = true
        } else {
            viewHeightForHiddenConstraint.constant = 82
            imvEdit.hidden = false
            ownerView.hidden = false
        }
        
        listCollectionView.reloadData()
        
        self.view.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func inviteUser() {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let selectFriendVC = storyboard.instantiateViewControllerWithIdentifier("SelectFriendViewController") as! SelectFriendViewController
        
        selectFriendVC.isInvite = true
        selectFriendVC.from = FROM_GROUP_INFO
        selectFriendVC.earlierRoom = self.room
        
        navigationController?.pushViewController(selectFriendVC, animated: true)
    }
    
    func banishUser() {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let selectFriendVC = storyboard.instantiateViewControllerWithIdentifier("SelectFriendViewController") as! SelectFriendViewController
        
        selectFriendVC.isInvite = false
        selectFriendVC.from = FROM_GROUP_INFO
        selectFriendVC.earlierRoom = self.room
        
        navigationController?.pushViewController(selectFriendVC, animated: true)
    }
    
    func showPickerSheet() {
        
        let alert = UIAlertController(title: nil, message: nil  , preferredStyle: UIAlertControllerStyle.ActionSheet)
        let takePhotoAction = UIAlertAction(title: Constants.TAKE_PHOTO, style: UIAlertActionStyle.Default) { (alert) in
            self.openCamera()
        }
        
        let galleryAction = UIAlertAction(title: Constants.FROM_GALLERY, style: UIAlertActionStyle.Default) { (alert) in
            self.openGallery()
        }
        
        let cancelAction = UIAlertAction(title: Constants.ALERT_CANCEL, style: UIAlertActionStyle.Cancel) {(alert) in
        }
        
        alert.addAction(takePhotoAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // open phone camera
    func openCamera() {
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.allowsEditing = true
            picker.modalPresentationStyle = .FullScreen
            
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    // open gallery
    func openGallery() {
        
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func uploadImage(photoPath: String) {
        
        guard photoPath != "" else { return }
        
        showLoadingViewWithTitle("")
        
        WebService.setGroupProfile(finalGroup!.name, photoPath: photoPath) { (status, message) in
            self.hideLoadingView()
            
            if status {
                self.finalGroup?.profileUrl = message                
                self.showAlert(Constants.APP_NAME, message: Constants.PHOTO_UPLOAD_SUCCESS, positive: Constants.ALERT_OK, negative: nil)
                
            } else {
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
    
    // shows alert when room owner is going to leave the room
    // room owner can leave after delegate the room owner
    func showDelegateDialog() {
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertConfirmViewController") as! CustomAlertConfirmViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        customAlert.statusBarHidden = prefersStatusBarHidden()
        
        customAlert.showCustomAlert(self, title: Constants.TITLE_LEAVE_ROOM_OWNER, positive: Constants.ALERT_OK, positiveAction: {
            
            self.dismissViewControllerAnimated(true, completion: {
                
            })
        })
    }
    
    func deleteRoom() {
        
        guard room != nil else { return }
        
        // delete room
        DBManager.getSharedInstance().removeRoom(room!._name)
        
        // remove room from user's roomlsit
        _user!._roomList.removeObject(room!)
        
        // remove group
        if let group = _user!.getGroup(room!._name) {
            _user!.removeGroup(group)
        }
        
        // send leave message
        sendLeaveMessage()
        
        setLeaveMemberToServer()
    }
    
    func gooutRoom() {
        
        // pop this viewcontroller
        // it will be different depends on comes from which viewcontroller
        var viewControllers = navigationController?.viewControllers
        viewControllers?.removeLast()
        viewControllers?.removeLast()
        
        guard viewControllers != nil else { return }
        navigationController?.setViewControllers(viewControllers!, animated: true)
    }
    
    func sendLeaveMessage() {
        
        let msg = _user!._name + "$" + Constants.KEY_LEAVEROOM_MARKER
        sendStatusMessageToRoom(msg, toMe: false)
    }
    
    func setLeaveMemberToServer() {

        WebService.setParticipantToServer(room!._name, participants: room!.participantsWithoutLeaveMembers(false)) { (status, groupProfileUrls) in
            
            if status && groupProfileUrls != nil {
                
                if let group = self._user!.getGroup(self.room!._name) {
                    group.profileUrls.removeAll()
                    group.profileUrls = groupProfileUrls!
                }
            }
        }
    }
    
    // shows alert that asks user be sure to leave the room
    func showConfirmOutDialog() {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertViewController") as! CustomAlertViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        customAlert.statusBarHidden = prefersStatusBarHidden()
        
        customAlert.showCustomAlert(self, title: Constants.TITLE_CONFIRM_DELETE, positive: Constants.ALERT_OK, negative: Constants.ALERT_CANCEL, positiveAction: {
            self.deleteRoom()
            }, negativeAction: {
        })
    }
    
    func getRoomInfoString(model: RoomEntity) -> String {
        return Constants.KEY_ROOM_MARKER + model._name + ":" + model._participants + ":" + _user!._name + Constants.KEY_SEPERATOR
    }
    
    /**
     * send room out message to all participants
     - parameter toMe : if true, will send message to me
     */
    func sendStatusMessageToRoom(message: String, toMe: Bool) {
        
        let fullMsg = getRoomInfoString(room!) + Constants.KEY_SYSTEM_MARKER + message + Constants.KEY_SEPERATOR + NSDate.utcString()
        
        guard room != nil else { return }
        
        let leaveIds = room!._leaveMembers.componentsSeparatedByString("_")
        
        let participantCount = room!._participantList.count
        for index in 0 ... participantCount {
            
            var toIndex = 0
            if index < participantCount {
                toIndex = room!._participantList[index]._idx
                
                if leaveIds.contains("\(toIndex)") {
                    continue
                }
                
            } else {
                if !toMe {
                    break
                }
                toIndex = _user!._idx
            }
            
            WBAppDelegate.xmpp.sendMessage(fullMsg, to: toIndex)
        }
    }
    
    func sendGroupNotification(notification: String) {
        
        let fullMsg = Constants.KEY_GROUPNOTI_MARKER + notification
        sendStatusMessageToRoom(fullMsg, toMe: true)
    }
    
    func changeGroupNickname(groupName: String) {
        
        let name = groupName.stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH).encodeString()
        WebService.changeGroupNickname(finalGroup!.name, nickname: name!) { (status, message) in
            
            if status {
                self.finalGroup!.nickname = groupName
                self.updateUI()
            } else {
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
    
    // profile edit action
    @IBAction func groupProfileTapped(sender: AnyObject) {
        
        guard isGroupOwner else { return }
        
        CommonUtils.checkPermission(AVMediaTypeVideo) { (granted) in
            if (granted) {
                self.showPickerSheet()
            } else {
                // show alert
                self.showAlert(Constants.APP_NAME, message: Constants.NEED_ACCESS_CAMERA, positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
    
    // delegate action
    @IBAction func delegateButtonTapped(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let selectFriendVC = storyboard.instantiateViewControllerWithIdentifier("SelectFriendViewController") as! SelectFriendViewController
        
        selectFriendVC.isInvite = false
        selectFriendVC.isDelegate = true
        selectFriendVC.from = FROM_GROUP_INFO
        selectFriendVC.earlierRoom = self.room
        
        navigationController?.pushViewController(selectFriendVC, animated: true)
    }
    
    @IBAction func changeGroupNameButtonTapped(sender: AnyObject) {
        
        guard isGroupOwner else { return }
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        let destVC = storyboard.instantiateViewControllerWithIdentifier("ChangeGroupNameViewController") as! ChangeGroupNameViewController
        destVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        destVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        destVC.showGroupNameEditView(self, oldName: finalGroup!.getNickname()) { (newName) in
            self.changeGroupNickname(newName)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private let kGroupSoundTag = 150
    private let kGroupTopTag = 151
    
    @IBAction func swtichValueChanged(sender: UISwitch) {
        // noti.tag = 150, list order 151
        if sender.tag == kGroupSoundTag {
           UserDefault.setBool(Constants.PREFKEY_NOTISOUND + finalGroup!.name, value: sender.on)
        } else {
           UserDefault.setBool(Constants.PREFKEY_TOP + finalGroup!.name, value: sender.on)
        }
    }
    
    @IBAction func sendNotiTapped(sender: AnyObject) {
        
        let notificationVC = self.storyboard!.instantiateViewControllerWithIdentifier("GroupNotiViewController") as! GroupNotiViewController
        notificationVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        notificationVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        notificationVC.showNotiEditView(self) { (notification) in
            self.sendGroupNotification(notification)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func gooutTapped(sender: AnyObject) {
        
        if isGroupOwner {
            showDelegateDialog()
        } else {
            showConfirmOutDialog()
        }
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK - @unwind back from SelectFriendViewController
    @IBAction func unwindFromSelectFriend(segue: UIStoryboardSegue) {
        
        if segue.identifier == "Segue2GroupInfo" {
            
            // room should not be nil
            guard room != nil else { return }
            
            let selectFriendVC = segue.sourceViewController as! SelectFriendViewController
            
            if selectFriendVC.isDelegate {
                
                guard let delegater = selectFriendVC.selectedDelegater else { return }
                
                self.sendDelegateMessage(delegater._idx)
                
                setGroupOwner(delegater._idx, completion: { (status) in
                
                    if (status) {
                        
//                        self.isGroupOwner = false
                        self.members.removeLast()
                        
                        self.updateUI()
                        
//                        self.finalGroup!.ownerID = delegater._idx                        
                    }
                })
            } else {
                
                if selectFriendVC.isInvite {
                    
                    // in case of invite
                    newParticipants.removeAll()
                    newParticipants.insertContentsOf(selectFriendVC.selectedFriendList, at: 0)
                    //                newParticipants = selectFriendVC.selectedFriendList
                    
                    // do not process without new participants
                    guard newParticipants.count > 0 else { return }
                    
                    // add new participants
                    for newFriend in newParticipants {
                        if !room!.isParticipant(newFriend) {
                            room!._participantList.append(newFriend)
                        } else {
                            var stringList = room!._leaveMembers.componentsSeparatedByString("_")
                            // inviting of leave members
                            if stringList.contains("\(newFriend._idx)") {
                                stringList.removeAtIndex(stringList.indexOf("\(newFriend._idx)")!)
                                
                                // new leave members except invited user
                                var leaveMembers = ""
                                for remainId in stringList {
                                    leaveMembers += remainId + "_"
                                }
                                // remove last underline "_"
                                if leaveMembers.length > 0 {
                                    leaveMembers = leaveMembers.substringToIndex(leaveMembers.endIndex.advancedBy(-1))
                                }
                                room!._leaveMembers = leaveMembers
                                
                                // delete leave message from database
                                
                                // delete leave message from db
                            }
                        }
                    }
                    
                    room!._participants = room!.participantsWithoutLeaveMembers(true)
                    DBManager.getSharedInstance().updateRoom(room!)
                    
                    updateGroupParticipants({ (status, groupProfileUrls) in
                        
                        if status {
                            // GroupOwner
                            if self.isGroupOwner {
                                self.members.removeLast()    // remove control "-"
                            }
                            self.members.removeLast()        // remove control "+"
                            // add new participant in member array
                            self.members.insertContentsOf(self.newParticipants, at: self.members.count)
                            self.members.append(self.plusFriend)
                            if self.isGroupOwner {
                                self.members.append(self.minusFriend)
                            }
                            // update ui
                            self.updateUI()
                            // send invitation message
                            self.sendInviteMessage(self.newParticipants)
                            
                            guard groupProfileUrls != nil else { return }
                            
                            self.selectedGroup!.profileUrls.removeAll()
                            self.selectedGroup!.profileUrls.insertContentsOf(groupProfileUrls!, at: 0)
                        }
                    })
                    
                } else {
                    
                    // in case banish
                    banishParticipants.removeAll()
                    banishParticipants.insertContentsOf(selectFriendVC.selectedFriendList, at: 0)
                    
                    // remove banish user from room participants
                    for banishUser in banishParticipants {
                        if room!.isParticipant(banishUser) {
                            room!.removeParticipantFromList(banishUser._idx)
                        }
                    }
                    
                    // update room participatns
                    room!._participants = room!.participantsWithoutLeaveMembers(true)
                    DBManager.getSharedInstance().updateRoom(room!)
                    
                    updateGroupParticipants({ (status, groupProfileUrls) in
                        
                        if status {
                            
                            if self.isGroupOwner {
                                self.members.removeLast()   // remove "-" member
                            }
                            self.members.removeLast()       // remove "+" member
                            // remove banish users
                            self.members.removeObjectsInArray(self.banishParticipants)
                            
                            // add "+" member
                            self.members.append(self.plusFriend)
                            if self.isGroupOwner {
                                self.members.append(self.minusFriend)
                            }
                            
                            self.updateUI()
                            
                            self.sendBanishMessage(self.banishParticipants)
                            
                            guard groupProfileUrls != nil else { return }
                            
                            self.selectedGroup!.profileUrls.removeAll()
                            self.selectedGroup!.profileUrls.insertContentsOf(groupProfileUrls!, at: 0)
                        }
                    })
                }
            }
        }
    }
    
    func setGroupOwner(ownerIdx: Int, completion: (status: Bool) -> Void) {
        
        WebService.setGroupOwner(room!._name, ownerId: ownerIdx) { (status) in
            
            completion(status: status)
            
            if (status) {
                print("Grouo Owner was changed successfully.")
            }
        }
    }
    
    func sendDelegateMessage(ownerIdx: Int) {
        
        var name = ""
        for friend in room!._participantList {
            if friend._idx == ownerIdx {
                name = friend._name
                break
            }
        }
        
        // ownername$roomname$DELEGATE**ROOM#
        let fullMsg = name + "$" + room!._name + "$" + Constants.KEY_DELEGATE_MARKER
        sendStatusMessageToRoom(fullMsg, toMe: true)
    }
    
    // update room particcipants
    // send updated participants to server
    func updateGroupParticipants(completion: (status: Bool, groupProfileUrls: [String]?) -> Void) {
        
        WebService.setParticipantToServer(room!._name, participants: room!.participantsWithoutLeaveMembers(true)) { (status, groupProfileUrls) in
            
            completion(status: status, groupProfileUrls: groupProfileUrls)
        }
        
//        WebService.setParticipantToServer(room!._name, participants: room!._participants) { (status) in
//            
//            completion(status: status)
//            
//            if (status) {
//                print("group participants changed successfully.")
//            }
//        }
    }
    
    /**
     *  send invitation messsage to room participants ( include me)
     *  parameter friends: new friend(s) who become participant of this room
     */
    func sendInviteMessage(friends: [FriendEntity]) {
        
        var names = ""
        
        for friend in friends {
            names += friend._name + ","
        }
        names = names.substringToIndex(names.endIndex.advancedBy(-1))
        let fullMessage = names  + "$" + Constants.KEY_INVITE_MARKER
        sendStatusMessageToRoom(fullMessage, toMe: true)
    }
    
    // send banish message
    func sendBanishMessage(banishUsers: [FriendEntity]) {
        var names = ""
        var ids = ""
        
        for banishUser in banishUsers {
            names += banishUser._name + ","
            ids += "\(banishUser._idx)" + "_"
        }
        names = names.substringToIndex(names.endIndex.advancedBy(-1))
        ids = ids.substringToIndex(ids.endIndex.advancedBy(-1))
        
        let fullMsg = getRoomInfoString(room!) + Constants.KEY_SYSTEM_MARKER + names + "$" + ids + "$" + Constants.KEY_BANISH_MARKER + Constants.KEY_SEPERATOR + NSDate.utcString()
        
        var allUsers = [FriendEntity]()
        allUsers.insertContentsOf(room!._participantList, at: 0)
        allUsers.insertContentsOf(banishUsers, at: allUsers.count)
        
        // will not send a message to leave members
        let leaveIdList = room!._leaveMembers.componentsSeparatedByString("_")
    
        for index in 0 ... allUsers.count {
            var toIndex = 0
            if index < allUsers.count {
                
                toIndex = allUsers[index]._idx
                
                // except leave members
                if leaveIdList.contains("\(toIndex)") {
                    continue
                }
                
            } else {
                toIndex = _user!._idx
            }
            
            WBAppDelegate.xmpp.sendMessage(fullMsg, to: toIndex)
        }
    }
}

// MARK: - @protocol UICollectionViewDelegate
extension GroupInfoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return members.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GroupMemberCell", forIndexPath: indexPath) as! GroupMemberCell
        cell.setContent(members[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if isGroupOwner {
            
            if indexPath.row == members.count - 2 {
                inviteUser()
            } else if indexPath.row == members.count - 1 {
                banishUser()
            }
        } else {
            if indexPath.row == members.count - 1 {
                inviteUser()
            }
        }
    }
}

// MARK: - @protocol UIImagePickerControllerDelegate
extension GroupInfoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let chosenImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
         
            let originalImage = UIImage.fixImageOrientation(chosenImage)
            let strPhotoPath = CommonUtils.saveToFile(originalImage, filePath: Constants.SAVE_ROOT_PATH, fileName: "group_profile.png")
            dispatch_async(dispatch_get_main_queue(), { 
                self.imvAvatar.contentMode = .ScaleAspectFit
                self.imvAvatar.image = UIImage(contentsOfFile: strPhotoPath)
                
                self.uploadImage(strPhotoPath)
            })
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}







