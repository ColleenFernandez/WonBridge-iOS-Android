//
//  XmppEndPoint.swift
//  WonBridge
//
//  Created by Tiia on 28/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation
import UIKit
import JLToast

protocol WBMessageDelegate {
    
    func newPacketReceived(_revPacket: ChatEntity)
}

protocol WBRoomMessageDelegate {
    
    func newRoomPacketReceived(_revPacket: ChatEntity)
}

protocol XmppCustomReconnectionDelegate {
    
    func xmppConnected()
    func xmppDisconnected()
}

protocol XmppFriendRequestDelegate {
    
    func sendFriendRequest()
}

@objc protocol CallMessageDelegate {
    
    optional func declineMessageReceived()
    
    optional func cancelMessageReceived()
    
    optional func acceptMessageReceived()
}

//protocol DeclineMessageDelegate {
//    
//    func declineMessageReceived()
//}
//
//protocol CancelMessageDelegate {
//    
//    func cancelMessageReceived()
//}
//
//protocol AcceptMessageDelegate {
//    
//    func acceptMessageReceived()
//}

class XmppEndPoint: NSObject, XMPPStreamDelegate, XMPPRoomDelegate {
   
    var hostName: String!
    var hostPort: Int!
    var conferenceService: String!
    
    var xmppStream: XMPPStream!
    var xmppReconnect: XMPPReconnect!
    
    var xmppJoinRoom: XMPPRoom!
    var xmppJoinRoomStorage: XMPPRoomMemoryStorage!
    
    var xmppRoomJIDPaused: XMPPJID!
    
    var userID: Int!
    var password: String!
    
    var isXmppConnected: Bool = false
    var customCertEvaluation: Bool = false
    
    // 1:1 chat message delegate - room out side message
    var _chatListMessageDelegate: WBMessageDelegate?
    // group chat message delegate - room out side messge
    var _grpChatListMessageDelegate: WBMessageDelegate?
    
    // room out side message delegate for ChatViewController
    var _chatMessageDelegate: WBMessageDelegate?
    var _roomMessageDelegate: WBRoomMessageDelegate?
    
    var _reconnectionDelegate: XmppCustomReconnectionDelegate?
    var _friendRequestDelegate: XmppFriendRequestDelegate?
    
//    // video calling decline message delegate
//    var _declineMsgDelegate: DeclineMessageDelegate?
//    // video calling cancel message delegate
//    var _cancelMsgDelegate: CancelMessageDelegate?
//    
//    var _acceptMsgDelegate: AcceptMessageDelegate?
    
    var _callMsgDelegate: CallMessageDelegate?
    
    var isSentFriendRequest: Bool!
    
    var _user: UserEntity!
    
    override init() {
        
        // Configure loggin framework
        DDLog.addLogger(DDTTYLogger.sharedInstance(), withLogLevel: XMPP_LOG_FLAG_SEND | XMPP_LOG_FLAG_RECV_POST)
    }
    
    convenience init(p_strHostName: String, p_nHostPort: Int) {
        
        self.init()
        
        DDLog.addLogger(DDTTYLogger.sharedInstance(), withLogLevel: XMPP_LOG_FLAG_SEND | XMPP_LOG_FLAG_RECV_POST)
        
        hostName = p_strHostName
        hostPort = p_nHostPort
        conferenceService = "conference." + hostName
        
        xmppStream = nil
        xmppReconnect = nil
        
        xmppJoinRoom = nil
        xmppJoinRoomStorage = nil
        
        userID = -1
        password = nil
        
        _user =  WBAppDelegate.me!
        
        isSentFriendRequest = false
    }
    
    func setupStream() {
        
        //
        // Setup xmpp stream
        //
        // The XMPPStream is the base class for all activity
        // Everything else plugs into the xmmppStream, such as modules/extensions and delegates
        
        xmppStream = XMPPStream()
        
        xmppReconnect = XMPPReconnect()
        
        xmppReconnect.activate(xmppStream)
        
        xmppStream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        xmppStream.hostName = hostName
        xmppStream.hostPort = UInt16(hostPort)
        
        customCertEvaluation = true
    }
    
    func teardownStream() {
        
        xmppStream.removeDelegate(self)
        
        xmppReconnect.deactivate()
        xmppStream.disconnect()
        
        xmppStream = nil
        xmppReconnect = nil
    }
    
    func goOnline() {
        
        if (xmppStream != nil) {
            
            let presence: XMPPPresence = XMPPPresence()
            
            xmppStream.sendElement(presence)
        }
        
        if(xmppRoomJIDPaused != nil) {
            
            enterRoomInBg(xmppRoomJIDPaused!)
        }
    }
    
    func goOffline() {
        
        if (xmppStream != nil) {
            
            let presence = XMPPPresence(type: "unavailable")
            
            xmppStream.sendElement(presence)
        }
    }
    
    // MARK: - Connect / Disconnect
    func connect(p_nUserId: Int, p_strPwd: String) -> Bool {
        
        if (xmppStream != nil) {
            
            if (!xmppStream!.isDisconnected()) {
                
                return true
            }
        }
        
        // myJID = "user@gmail.com/WonBridge"
        // mypassword = "******"
        
        let myJID = "\(p_nUserId)@" + hostName + "/" + XMPP_RESOURCE
        
        xmppStream.myJID = XMPPJID.jidWithString(myJID)
        
        password = p_strPwd
        
        do {
            
            guard let _ = try xmppStream?.connectWithTimeout(XMPPStreamTimeoutNone) else {
                
                return false
            }
            
        } catch let error as NSError {
            
            print(error.localizedDescription)
        }
        
        return true
    }
    
    func disconnect() {
        
        goOffline()
        
        if (xmppStream != nil) {
            
            xmppStream.disconnect()
        }
    }
    
    func registerDeviceToken(deviceToekn: String) {
        
        let query = DDXMLElement(name: "query", xmlns: "urn:xmpp:apns")
        let token = DDXMLElement(name: "token", xmlns: deviceToekn)
        
        query.addChild(token)
        
        let iq = XMPPIQ(type: "set", to: XMPPJID.jidWithString(hostName), elementID: "apns68057d6a", child: query)
        
        if (xmppStream != nil) {
            
            xmppStream.sendElement(iq)
        }
    }
    
    // MARK: - XMPPStream Delegate
    func xmppStream(sender: XMPPStream!, socketDidConnect socket: GCDAsyncSocket!) {
        print("stream connected")
    }
    
    func xmppStreamDidConnect(sender: XMPPStream!) {
        
        isXmppConnected = true
        
        do {
            try xmppStream.authenticateWithPassword(password)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func xmppStreamDidDisconnect(sender: XMPPStream!, withError error: NSError!) {
        
        if xmppStream != nil {
            if xmppJoinRoom != nil {
                xmppRoomJIDPaused = xmppJoinRoom.myRoomJID
            } else {
                xmppRoomJIDPaused = nil
            }
        }
        
        _reconnectionDelegate?.xmppDisconnected()
        if (!isXmppConnected) {
            print("Unable to connect to server. check xmppstrea,.hostname")
        }
    }
    
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        
        goOnline()
    }
    
    func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        
        print("did not authenticate")
    }
    
    // MARK: - didReceiveMessage: Independent message, outside of room
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        
        if (message.isChatMessageWithBody()) {
            
            let msg = message.elementForName("body").stringValue()
            
            print("call message: \(msg)")
            
            let from = message.attributeForName("from").stringValue()
            let sender = from.componentsSeparatedByString("@")[0]
            
            // do not process from blocked user
            guard !_user!.isBlockedFriend(Int(sender)!) else { return }
            
            // *****************************  video calling message process *********************************** //
            if msg.componentsSeparatedByString(Constants.KEY_SEPERATOR)[0] == Constants.VIDEO_CHATTING_SENT {
                
                // do not process offline message
                guard message.elementForName("delay") == nil else {
                    return
                }
                
                guard _user.isFriend(Int(sender)!) else  {
                    return
                }
                
                // you've received a video or voice calling request
                let partner = msg.componentsSeparatedByString(Constants.KEY_SEPERATOR)[1]       // sender name
                let room = msg.componentsSeparatedByString(Constants.KEY_SEPERATOR)[2]          // room number
                let videoEnable = msg.componentsSeparatedByString(Constants.KEY_SEPERATOR)[3]   // video or voice calling
                
                if (videoEnable.toBool()) {
                    WBAppDelegate.showCallRequest(Int(sender)!, fromUserName: partner, roomName: room, videoEnable: true)
                } else {
                    WBAppDelegate.showCallRequest(Int(sender)!, fromUserName: partner, roomName: room, videoEnable: false)
                }
                return
                
            } else if msg.componentsSeparatedByString(Constants.KEY_SEPERATOR)[0] == Constants.VIDEO_CHATTING_DECLINE {
                
                guard _user.isFriend(Int(sender)!) else  {
                    return
                }
                
//                _declineMsgDelegate?.declineMessageReceived()
                
                guard _callMsgDelegate != nil && _callMsgDelegate?.declineMessageReceived != nil else {
                    return
                }
                
                _callMsgDelegate!.declineMessageReceived!()
                
                return
                
            } else if msg.componentsSeparatedByString(Constants.KEY_SEPERATOR)[0] == Constants.VIDEO_CHATTING_CANCEL {
                
                guard _user.isFriend(Int(sender)!) else  {
                    return
                }
                
                // if a user received video chatting cancel offline message, it will need to leave cancel message here
                guard message.elementForName("delay") == nil else {
            
                    // get message timestamp
                    let delay: DDXMLElement = message.elementForName("delay")
                    guard let stamp = delay.attributeForName("stamp") else { return }
                    let timestamp = stamp.stringValue()
                    print("timestamp: \(timestamp)")
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'H:mm:ss.SSSZ"
                    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
                    guard let utcDate = dateFormatter.dateFromString(timestamp) else { return }
                    
                    dateFormatter.dateFormat = "yyyyMMdd,HH:mm:ss"
                    let strUTCDate = dateFormatter.stringFromDate(utcDate)
                    
                    logCall(Int(sender)!, chatId: Int(sender)!, message: Constants.CALL_CANCELLED_BYOTHER, time: strUTCDate)
                    return
                }
                
                guard _callMsgDelegate != nil && _callMsgDelegate?.cancelMessageReceived != nil else {
                    return
                }
                
                _callMsgDelegate!.cancelMessageReceived!()
                
//                _cancelMsgDelegate?.cancelMessageReceived()
                return
            } else if msg.componentsSeparatedByString(Constants.KEY_SEPERATOR)[0] == Constants.VIDEO_CHATTING_ACCEPT {
                
                guard _callMsgDelegate != nil && _callMsgDelegate?.acceptMessageReceived != nil else {
                    return
                }
                
                _callMsgDelegate!.acceptMessageReceived!()
             
//                _acceptMsgDelegate?.acceptMessageReceived()
                return
            }
            
            // *****************************   message process *********************************** //
            // make a chat item with received message
            // save a chat item to local database
            // this will be new chat item so it will not affect to pull load more...
            let newItem = ChatEntity(message: msg, sender: sender, isLocalTime: false)
            
            if newItem._contentType != .SYSTEM || !newItem._content.containsString(Constants.KEY_REQUEST_MARKER) {
                DBManager.getSharedInstance().addChat(newItem, isCurrent: 1)
            }
            
            
            // here are all system messages ( group notification, invitation, banish, delegate, leave room), delayed messages or user can get message once become a member at first
            // no need to save chat item to database except delaying message ( offline message)
            // case 1: first message from group ( 1:1 or n:n ) it will be needed to create a new room and group with received chat item
            // case 2: group notification - it will be needed to update recent content, recent time, recent counter of this room
            // case 3: invitation - it will be needed to update room participant and group
            // case 4: banish -  you're banished by room owner, it will delete room and all chat history from local database and on chat list
            // case 5: delegate - it will be need to show system message, if you're a selected owner by old owner of this room, you will need to change group owner as you.
            // case 6: leave room  -  all room members will save leave member(s), after leaving, will not send any message to left member.
            // case 7: single chat
            let existRoom = _user.getRoom(newItem._roomName)
            if existRoom == nil || (existRoom!._participants != newItem._participants && !newItem._content.containsString(Constants.KEY_BANISH_MARKER)) {
                
                // ***
                // received first message, invitation, leave room message from other user ( case 1, case 3, case 6)
                
                // process for first message or invitation
                getRoomInfo(newItem)
            } else {
                
                processMessage(existRoom!, newItem: newItem, isUpdateRoom: true)
            }
        }
    }
    
    // received chat was already saved.
    // need to update room, and process system message
    // normal message processing in existing room ( 1:1 chat, group chat)
    // first message from new group will also process here after being made a room and group
    // system message processing ( leaveRoom - message from other user(s), group notification, delegate, banish, invite)
    func processMessage(existRoom: RoomEntity, newItem: ChatEntity, isUpdateRoom: Bool) {
        
        // *** 
        // it will be not run in case of invite or first message
        // this is already processed
        if existRoom._participants != newItem._participants {
            
            let group = GroupEntity(name: newItem._roomName, participants: newItem._participants)
            if let existGroup = _user.getGroup(group.name) {
                existGroup.participants = newItem._participants
            }
            
            // should update participants and participantList
            existRoom._participants = newItem._participants
        }

        // update room recent content, recent time, increase recent count.
        // update local database
        if isUpdateRoom {
            existRoom._recentContent = newItem.recentContent
            existRoom._recentTime = newItem._timestamp
            existRoom._recentCount += 1
            DBManager.getSharedInstance().updateRoom(existRoom)
        }
        
        if newItem._contentType == .SYSTEM {
            
            if newItem._content.containsString(Constants.KEY_REQUEST_MARKER) {
                
            }
            
            if newItem._content.containsString(Constants.KEY_LEAVEROOM_MARKER) {
                
                // left user id.
                let leaveId = newItem._chatSendId
                if (existRoom._leaveMembers.length == 0) {
                    existRoom._leaveMembers = "\(leaveId)"
                } else {
                    let leaveMembers = existRoom._leaveMembers.componentsSeparatedByString("_")
                    var leaveIds = [Int]()
                    for leaveMember in leaveMembers {
                        leaveIds.append(Int(leaveMember)!)
                    }
                    
                    if !leaveIds.contains(leaveId) {
                        existRoom._leaveMembers += "_" + "\(leaveId)"
                    }
                }
                
                existRoom.removeParticipant(leaveId)
                // remove left user in group participant
                if let group = _user.getGroup(existRoom._name) {
                    group.removeParticipant(leaveId)
                }
                
                DBManager.getSharedInstance().updateRoom(existRoom)
                
                getGroupProfileUrls(existRoom._name)
            }
            
            if newItem._content.containsString(Constants.KEY_DELEGATE_MARKER) {
                // process delegate message on existing room
                // ownername$roomname$DELEGATE**ROOM#
                let roomname_ownername = newItem._content.substringToIndex((newItem._content.rangeOfString("$",   options: .BackwardsSearch)?.endIndex.advancedBy(-1))!)
                let ownername = roomname_ownername.substringToIndex((roomname_ownername.rangeOfString("$", options: .BackwardsSearch)?.endIndex.advancedBy(-1))!)
                
                // if owner was set me by earlier room owner
                if ownername == _user._name {
                    if let group = _user.getGroup(newItem._roomName) {
                        group.ownerID = _user._idx
                    }
                } else {
                    if newItem._chatSendId == _user!._idx {
                        if let group = _user!.getGroup(newItem._roomName) {
                            group.ownerID = 0
                        }
                    }
                }
            }
            
            if newItem._content.containsString(Constants.KEY_BANISH_MARKER) {
                
                // process banish message on existing room
                var dolIndex = newItem._content.rangeOfString("$", options: .BackwardsSearch)?.endIndex.advancedBy(-1)
                let all = newItem._content.substringToIndex(dolIndex!)
                dolIndex = all.rangeOfString("$", options: .BackwardsSearch)?.endIndex
                //                    let names = all.substringToIndex(dolIndex!.advancedBy(-1))
                let ids = all.substringFromIndex(dolIndex!)
                let idList = ids.componentsSeparatedByString("_")
                
                // banish to me
                if idList.contains("\(_user._idx)") {
                    // delete room database
                    DBManager.getSharedInstance().removeRoom(newItem._roomName)
                    
                    // delete group and room
                    if let banishedGroup = _user.getGroup(newItem._roomName) {
                        _user._groupList.remove(banishedGroup)
                    }
                    
                    if let banishedRoom = _user.getRoom(newItem._roomName) {
                        _user._roomList.remove(banishedRoom)
                    }
                } else {
                    
                    let roomName = newItem._roomName
                    for idx in idList {
                        DBManager.getSharedInstance().deleteUserChat(roomName, sender: Int(idx)!)
                        
                        existRoom.removeParticipantList(Int(idx)!)
                    }
                }
                
                getGroupProfileUrls(existRoom._name)
            }
            
            if newItem._content.containsString(Constants.KEY_INVITE_MARKER) {
                // TO DO 
                // if you want to remove left room chat history in case of inviting for left user, process here
                
                // process invite for already left user from this room
                // need to remove leave user array 
                // if invitation of leave member then it will needed to remove invited user in leave members array
                // existing leave members array
                // if you have no leave members on existing room then it will change participants
//                var idList = existRoom._leaveMembers.componentsSeparatedByString("_")
//                guard idList.count != 0 else {
//                    return
//                }
                
//                var 
            }
        }
        
        // add delegate to process the above message
        // only need to update current ui, message was already saved.
        if let currentRoomName = xmppJoinRoom?.myRoomJID.user {
            // user already entered the room, so the message will be processs on there
            if newItem._roomName == currentRoomName {
                if newItem._contentType == .SYSTEM {
                    _chatMessageDelegate?.newPacketReceived(newItem)
                }
                return
            }
        }
        
        // will notify user received new message
        _user.notReadCount += 1
        WBAppDelegate.notifyReceiveNewMessage()
        
        // if user stands on other page except chat list and group chat list
        // all message processing already done.
        // chat was saved, room updated or created, notified new message received.
        
        // if user stands on chat list or group chat list page, it will be need to refresh chat list
//        if _chatListMessageDelegate != nil && !newItem.isGroupMessage {
//            _chatListMessageDelegate!.newPacketReceived(newItem)
//        } else if _grpChatListMessageDelegate != nil && newItem.isGroupMessage {
//            _grpChatListMessageDelegate!.newPacketReceived(newItem)
//        }
        
        if _chatListMessageDelegate != nil {
            _chatListMessageDelegate!.newPacketReceived(newItem)
        }
        
        WBSystemSoundPlayer.playSoundWithType(.Chat)
//        AudioPlayInstance.playSoundWithType(.Notification)
    }
    
    /**
     ** get group profile urls
     ** parameter: name - room name
     **/
    func getGroupProfileUrls(name: String) {
        
        WebService.getGroupProfile(name, completion: { (status, groupProfileUrls) in
            
            if status {
                if let group = self._user!.getGroup(name) {
                    
                    guard groupProfileUrls != nil else { return }
                    
                    group.profileUrls.removeAll()
                    group.profileUrls = groupProfileUrls!
                    
                    if let topViewController = WBAppDelegate.window!.visibleViewController() {
                        if topViewController.isKindOfClass(ChatTabListViewController) {
                            let chatListVC = topViewController as! ChatTabListViewController
                            chatListVC.initChatList()
                        }
                    }
                }
            }
        })
    }
    
    // get room info
    func getRoomInfo(msg: ChatEntity) {
        
        WebService.getRoomAndGroupInfo(_user._idx, participantName: msg._participants, roomName: msg._roomName) { (status, room, group) in
            
            if status {
                
                guard room != nil else { return }
                
                // process group before processing room message
                if group != nil {
                    
                    self._user.removeGroup(group!)
                    self._user._groupList.append(group!)
                }
                
                // make a room
                let revMsgRoom = room!
                revMsgRoom._recentContent = msg.recentContent
                revMsgRoom._recentTime = msg._timestamp
                revMsgRoom._recentCount = 1
                
                // this will add a new room that was made with received message if the room not exists,
                // otherwise it will update participants, participantList, recentContent, recentTime, recentCount of exist room and also local database
                self._user.addRoom(revMsgRoom)
                
                // *** this process will be done except user recieved banish message (banish to me and banish to other, leave room)
                // *** invite, received new message ( group or 1:1 chat)
                // *** invited message for user(s) who was already left or banished from this room
                self.processMessage(room!, newItem: msg, isUpdateRoom: false)
                
            } else {
                debugPrint("fail to load room info")
                return
            }
        }
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        
        return false
    }

    // MARK: - XMPPRoom Delegate
    func xmppRoomDidCreate(sender: XMPPRoom!) {
        
        sender.configureRoomUsingOptions(nil)
    }
    
    func xmppRoomDidJoin(sender: XMPPRoom!) {
        
        if (xmppRoomJIDPaused != nil) {
            
            xmppRoomJIDPaused = nil
        }
        
        _reconnectionDelegate?.xmppConnected()
    }
    
    func xmppRoomDidLeave(sender: XMPPRoom!) {
        
        print("user leaved room")
    }
    
    // MARK: didReceiveMessage - room message
    func xmppRoom(sender: XMPPRoom!, didReceiveMessage message: XMPPMessage!, fromOccupant occupantJID: XMPPJID!) {
        
        if (message.isMessageWithBody()) {
            
            let msg = message.elementForName("body").stringValue()
            let _from = message.attributeForName("from").stringValue()
            let _sender = _from.componentsSeparatedByString("/")[1]
            let senderId = Int(_sender)!
            
            // do not process message from me or blocked friend
            guard senderId != _user._idx && !_user.isBlockedFriend(senderId) else { return }
            
            // create new xmpp packet
            let revChatItem = ChatEntity(message: msg, sender: _sender, isLocalTime: false)
            // set new message 
            revChatItem._isNewMsg = true
            // delegate for processing incoming message
            _roomMessageDelegate?.newRoomPacketReceived(revChatItem)
        }
    }
    
    // MARK: - create and join room with room information - RoomEntity
    func enterChattingRoom(_room: RoomEntity) {
        
        let virtualDomain = xmppStream.myJID.domain
        let jid = _room._name + "@conference." + virtualDomain!
        let _roomJID = XMPPJID.jidWithString(jid)
        
        xmppJoinRoomStorage = XMPPRoomMemoryStorage()
        
        xmppJoinRoom = XMPPRoom(roomStorage: xmppJoinRoomStorage, jid: _roomJID, dispatchQueue: dispatch_get_main_queue())
        xmppJoinRoom.activate(xmppStream)
        xmppJoinRoom.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        let history = DDXMLElement(name: "history")
        history.addAttributeWithName("maxstanzas", stringValue: "0")
        
        xmppJoinRoom.joinRoomUsingNickname(xmppStream.myJID.user, history: history, password: nil)
    }
    
    func leaveRoom(_room: RoomEntity) {
        
        guard xmppJoinRoom != nil else { return }
        
        xmppJoinRoom.leaveRoom()
        xmppJoinRoom.removeDelegate(self)
        xmppJoinRoom.deactivate()
        
        xmppJoinRoomStorage = nil
        xmppJoinRoom = nil
    }
    
    // when the app become inactive, leave the room
    func leaveRoomInBg() {
        
        guard xmppJoinRoom != nil else { return }
        
        xmppJoinRoom.leaveRoom()
        xmppJoinRoom.removeDelegate(self)
        xmppJoinRoom.deactivate()
        
        xmppJoinRoomStorage = nil
        xmppJoinRoom = nil
    }
    
    func enterRoomInBg(roomJID: XMPPJID) {
        
        xmppJoinRoomStorage = XMPPRoomMemoryStorage()
        
        xmppJoinRoom = XMPPRoom(roomStorage: xmppJoinRoomStorage, jid: roomJID, dispatchQueue: dispatch_get_main_queue())
        
        xmppJoinRoom.activate(xmppStream)
        xmppJoinRoom.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        // no history
        let history = DDXMLElement(name: "history")
        history.addAttributeWithName("maxstanzas", stringValue: "0")
        
        xmppJoinRoom.joinRoomUsingNickname(xmppStream.myJID.user, history: history, password: nil)
    }
    
    // send message (group notification, invite message, )
    func sendMessage(fullMsg: String, to: Int) {
     
        let message = XMPPMessage(type: "chat", to: XMPPJID.jidWithString("\(to)@" + XMPP_SERVER_URL + "/" + XMPP_RESOURCE))
        message.addBody(fullMsg)
        xmppStream.sendElement(message)
    }
    
    // outside message - Independent User
    // send message to outside user
    func sendPacket(item: ChatEntity, friendIdx: Int) {
        let message = XMPPMessage(type: "chat", to: XMPPJID.jidWithString("\(friendIdx)@" + XMPP_SERVER_URL + "/" + XMPP_RESOURCE))
        message.addBody(item.toMessage())
        xmppStream.sendElement(message)
    }
    
    // room message
    // send message to all users of room
    func sendPacket(item: ChatEntity) {
        xmppJoinRoom!.sendMessageWithBody(item.toMessage())
    }
    
    // it will be send by outside meesage
    // send video request message
    /**
     *      it will be send by outside message
     *      send video call request message
     *      parameter completion: closure for processing call log
     */
    func sendVideoRequest(to: Int, partnerName: String, videoEnable: Bool) {
        
        let message = XMPPMessage(type: "chat", to: XMPPJID.jidWithString("\(to)@" + XMPP_SERVER_URL + "/" + XMPP_RESOURCE))
        let roomNumber = CommonUtils.getRandomRoomNumber()
        message.addBody(Constants.VIDEO_CHATTING_SENT + Constants.KEY_SEPERATOR + _user._name + Constants.KEY_SEPERATOR + "\(roomNumber)" + Constants.KEY_SEPERATOR + "\(videoEnable)")
        xmppStream.sendElement(message)
        
        WBAppDelegate.gotoCallVC("\(roomNumber)", partnerName: partnerName, partnerId: to, videoEnable: videoEnable, isSender: true)
    }
    
    // it will send video accept message to user
    // for processing call log and duration
    func sendVideoAcceptMessage(to: Int) {
        
        let message = XMPPMessage(type: "chat", to: XMPPJID.jidWithString("\(to)@" + XMPP_SERVER_URL + "/" + XMPP_RESOURCE))
        message.addBody(Constants.VIDEO_CHATTING_ACCEPT + Constants.KEY_SEPERATOR + "\(to)" + Constants.KEY_SEPERATOR + "\(_user._idx)")
        xmppStream.sendElement(message)
    }
    
    // send video decline message
    // You decline video request message from fromUserId
    // You are sending decline message to fromUserId
    func sendVideoDecline(fromUserId: Int) {
        
        let message = XMPPMessage(type: "chat", to: XMPPJID.jidWithString("\(fromUserId)@" + XMPP_SERVER_URL + "/" + XMPP_RESOURCE))
        message.addBody(Constants.VIDEO_CHATTING_DECLINE + Constants.KEY_SEPERATOR + "\(fromUserId)" + Constants.KEY_SEPERATOR + "\(_user._idx)")
        xmppStream.sendElement(message)
        
        // log message for calling history
        logCall(fromUserId, chatId: _user._idx, message: Constants.CALL_DECLINED_BYME, time: NSDate.utcString())
    }
    
    // send calling cancel message to partner
    func sendVideoCancel(partnerId: Int) {
        
        let message = XMPPMessage(type: "chat", to: XMPPJID.jidWithString("\(partnerId)@" + XMPP_SERVER_URL + "/" + XMPP_RESOURCE))
        message.addBody(Constants.VIDEO_CHATTING_CANCEL + Constants.KEY_SEPERATOR + "\(partnerId)")
        xmppStream.sendElement(message)
        
        // log message for calling history
        logCall(partnerId, chatId: _user._idx, message: Constants.CALL_CANCELLED_BYME, time: NSDate.utcString())
    }
    
    func sendVideoNoAnswer(partnerId: Int) {
        
        let message = XMPPMessage(type: "chat", to: XMPPJID.jidWithString("\(partnerId)@" + XMPP_SERVER_URL + "/" + XMPP_RESOURCE))
        message.addBody(Constants.VIDEO_CHATTING_CANCEL + Constants.KEY_SEPERATOR + "\(partnerId)")
        xmppStream.sendElement(message)
        
        // log message for calling history
        logCall(partnerId, chatId: _user._idx, message: Constants.CALL_NO_ANSWER, time: NSDate.utcString())
    }
    
    // leave call history
    func logCall(partnerId: Int, chatId: Int, message: String, time: String) {
        
//        let time = NSDate.utcString()
        // user stands on chatview with other friend
        var roomName = "\(partnerId)" + "_" + "\(_user._idx)"
        if partnerId > _user._idx {
            roomName = "\(_user._idx)" + "_" + "\(partnerId)"
        }
        
        var chatItem: ChatEntity
        if let room = _user.getRoom(roomName) {
            
            chatItem = ChatEntity(room: room, sender: "\(chatId)", contentType: .TEXT, content: message, time: time)
            // update room 
            room._recentContent = message
            room._recentTime = chatItem._timestamp
            room._recentCount += 1
            
            DBManager.getSharedInstance().updateRoom(room)
            
        } else {
            
            let tempRoom = RoomEntity()
            tempRoom._name = roomName
            tempRoom._participants = roomName
            
            chatItem = ChatEntity(room: tempRoom, sender: "\(chatId)", contentType: .TEXT, content: message, time: time)
            
            // update room
            tempRoom._recentContent = message
            tempRoom._recentTime = chatItem._timestamp
            tempRoom._recentCount += 1
            
            DBManager.getSharedInstance().updateRoom(tempRoom)
        }
        
        DBManager.getSharedInstance().saveChat(chatItem._roomName, message: chatItem.toMessage(), sender: chatItem._chatSendId, datetime: time, isCurrent: 1)
        
        // update room
        if let topViewController = WBAppDelegate.window!.visibleViewController() {
            if topViewController.isKindOfClass(ChatViewController) {
                
                // if topViewController is ChatViewController, then will add call history message
                let chatVC = topViewController as! ChatViewController
                if !chatVC.isOnlineService {
                    
                    let currentPartnerId = chatVC.chatRoom!._participantList[0]._idx
                    if currentPartnerId == partnerId {
                        
                        chatItem._isNewMsg = true
                        chatVC.addMessage(chatItem)
                    }
                }                
            } else {
                
                if topViewController.isKindOfClass(ChatTabListViewController) {
                    _chatListMessageDelegate?.newPacketReceived(chatItem)
                }
                
                // will notify user received new message
                _user.notReadCount += 1
                WBAppDelegate.notifyReceiveNewMessage()
            }
        }
    }
}







