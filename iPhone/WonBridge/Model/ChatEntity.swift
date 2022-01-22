//
//  XmppPacket.swift
//  WonBridge
//
//  Created by Tiia on 28/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import YYText

/*
 * 聊天内的子 model，根据字典返回类型做处理
 */

// ROOM#1_2_6_1476158652943:1_2_5_6_7:test05#2#20161011,04:05:39    // normal text
// ROOM#1_2_6_1476158652943:1_2_5_6_7:test05#IMAGE#http://52.78.120.201/uploadfiles/file/2016/10/6_14761591019.JPG#2448#3264#IMG_0022.JPG#20161011,04:11:41
// ROOM#1_2_6_1476158652943:1_2_5_6_7:test05#SYSTEM#test06$INVITE**ROOM#20161011,04:04:35 ( me = 6)                 - invite   ( 5, 7 was invited )
// ROOM#1_2_6_1476158652943:1_2_5_6:test05#SYSTEM#test06$7$BANISH**ROOM#20161011,04:12:57                           - banish 9 ( 7 was banished )
// ROOM#1_2_6_1476158652943:1_2_5_6:test05#SYSTEM#[GROUP NOTI]\n123#20161011,04:14:28                               - group notification
// ROOM#1_2_6_1476158652943:1_2_5_6:test05#SYSTEM#test2$1_2_6_1476158652943$DELEGATE**ROOM##20161011,04:16:04       - delegate
// ROOM#1_2_6_1476158652943:1_2_5_6:test05#SYSTEM#test05$LEAVE**ROOM#20161011,04:17:21                              - leave room

class ChatImageEntity : NSObject {
    var imageHeight : CGFloat?
    var imageWidth : CGFloat?
    var originalURL : String?
    var thumbURL : String?                  // not used
    var localStoreName: String?             //拍照，选择相机的图片的临时名称
    var localThumbnailImage: UIImage? {     //从 Disk 加载出来的图片
        if let theLocalStoreName = localStoreName {
            let path = ImageFilesManager.cachePathForKey(theLocalStoreName)
            return UIImage(contentsOfFile: path!)
        } else {
            return nil
        }
    }
    
    override init() {
        super.init()
    }
}

class ChatEntity: NSObject {
    
    var _chatSendId: Int!
    
    var _contentType: MessageContentType = .TEXT            // TEXT, IMAGE, VIDEO, FILE
    var _content: String!                                   // Message String
    var _fileName: String!                                  // received file name
    var _sentTime: String!                                  // sent time
    var _from: String!                                      // sender name or idx
    var _roomName: String!
    var _participants: String!                              //  participants name ( 1_2_3)
    
    var _timestamp: String!                                 // full time string - yyyy:MM:dd,H:mm:ss
    var _date: String!                                      // date string - yyyyMMdd
    
    var _isDelayed: Bool!
    var  _isNewMsg: Bool!
    
    var _progressValue: Int!
    
    var fromMe: Bool { return self._chatSendId == WBAppDelegate.me._idx}
    
    var richTextLayout: YYTextLayout?
    var richTextLinePositionModifier: WBYYTextLinePositionModifier?
    var richTextAttributedString: NSMutableAttributedString?
    var messagesendSuccessType: MessageSendSuccessType = .Failed
    var cellHeight: CGFloat = 0

    var imageModel: ChatImageEntity?
    var status: ModelStatus = .Normal
    
    override init() {
        
        _chatSendId = 0
        _contentType = .TEXT
        _content = ""
        _fileName = ""
        _sentTime = ""
        _from = ""
        _date = ""
        _isDelayed = false
        _isNewMsg = false
        _progressValue = 0
    }
    
    convenience init(room: RoomEntity, senderName: String, contentType: MessageContentType, content: String, fileName: String, sendTime: String, imageModel: ChatImageEntity?) {
        
        self.init()
        
        _roomName = room._name
        _participants = room._participants
        _contentType = contentType
        _content = content
        _fileName = fileName
        _timestamp = sendTime
        _from = senderName
        _chatSendId = Int(_from)
        self.imageModel = imageModel
    }
    
    convenience init(timestamp: String) {
        
        self.init()
        
        _contentType = .TIME
        _content = timestamp
    }
    
    // from db or coming message from other user
    // timezone will be utc when it comes from other user
    // timezone will be local timezone when it comes from local database
    convenience init(message: String, sender: String, isLocalTime: Bool) {
        
        self.init()
        
        _from = sender
        _chatSendId = Int(_from)
        
        _roomName = getRoomName(message)
        _participants = getRoomParticipants(message)
        _contentType = getType(message)
        _content = getMessage(message)
        _fileName = getFileName(message)
        if isLocalTime {
            _timestamp = getLocalTime(message)
        } else {
            _timestamp = getTime(message)
        }
        _date = getDate(_timestamp)
        _sentTime = getDisplayTime(_timestamp)
    }
    
    // timezone utc
    // only precessing for my message
    convenience init(message: String, sender: String, imageModel: ChatImageEntity?) {
       
        self.init()
        
        self.imageModel = imageModel
        _from = sender
        _chatSendId = Int(_from)
        
        _roomName = getRoomName(message)
        _participants = getRoomParticipants(message)
        _contentType = getType(message)
        _content = getMessage(message)
        _fileName = getFileName(message)
        _timestamp = getTime(message)                       // need to change utc to local time
        _date = getDate(_timestamp)
        _sentTime = getDisplayTime(_timestamp)
    }
    
    // time is utc, wille chaned to local time
    convenience init(room: RoomEntity, sender: String, contentType: MessageContentType, content: String, time: String) {
        
        self.init()
        
        _roomName = room._name
        _participants = room._participants
        _contentType = contentType
        _content = content
        _timestamp = time.utc2Local()
        _date = getDate(_timestamp)
        _sentTime = getDisplayTime(_timestamp)
        _from = sender
        _chatSendId = Int(sender)
    }
    
    // packet to message string for sending
    // room#roomJID#message#20151212 AM(PM), 12:00:00
    // room#roomJID#IMAGE#message#fileName#20151212 AM(PM), 12:00:00
    func toMessage() -> String {
        
        // add contentType:IMAGE# (VIDEO#, FILE#)
        var _message: String = ""        
        if _contentType == .IMAGE {
            _message = Constants.KEY_IMAGE_MARKER
        } else if _contentType ==  .FILE {
             _message = Constants.KEY_FILE_MARKER
        } else if _contentType ==  .VIDEO {
             _message = Constants.KEY_VIDEO_MARKER
        } else if _contentType == .SYSTEM {
            _message = Constants.KEY_SYSTEM_MARKER
        }
        
        // add content : IMAGE#content (content will be file url)
        _message += _content
        if _contentType == .IMAGE || _contentType == .VIDEO {
            if imageModel != nil {
                // add image size: IMAGE#content#imageWidth#imageHeght
                _message += Constants.KEY_SEPERATOR + "\(Int(self.imageModel!.imageWidth!))" + Constants.KEY_SEPERATOR + "\(Int(self.imageModel!.imageHeight!))"
            }
            // add filename: IMAGE#content#imageWidth#imageHeght#fileName
            _message += Constants.KEY_SEPERATOR + _fileName
        }
        
        // add room marker and room name into message
        _message = Constants.KEY_ROOM_MARKER + _roomName + ":" + _participants + ":" + _from + Constants.KEY_SEPERATOR + _message + Constants.KEY_SEPERATOR + _timestamp
        
        return _message
    }
    
    func getRoomName(body: String) -> String {
        
        var roomName = ""
        roomName = body.componentsSeparatedByString("#")[1]
        roomName = roomName.substringToIndex(roomName.rangeOfString(":")!.startIndex)
        
        return roomName
    }
    
    func getRoomParticipants(body: String) -> String {
        
        var participantName = ""
        
        participantName = body.componentsSeparatedByString("#")[1]
        participantName = participantName.componentsSeparatedByString(":")[1]
        
        return participantName
    }
    
    var participantsCount: Int {
        return _participants.componentsSeparatedByString("_").count
    }
    
    // ROOM#1_2_6_1476158652943:1_2_5_6_7:test05#2#20161011,04:05:39    // normal text
    // ROOM#1_2_6_1476158652943:1_2_5_6_7:test05#IMAGE#http://52.78.120.201/uploadfiles/file/2016/10/6_14761591019.JPG#2448#3264#IMG_0022.JPG#20161011,04:11:41
    // ROOM#1_2_6_1476158652943:1_2_5_6_7:test05#SYSTEM#test06$INVITE**ROOM#20161011,04:04:35 ( me = 6)                 - invite   ( 5, 7 was invited )
    // ROOM#1_2_6_1476158652943:1_2_5_6:test05#SYSTEM#test06$7$BANISH**ROOM#20161011,04:12:57                           - banish 9 ( 7 was banished )
    // ROOM#1_2_6_1476158652943:1_2_5_6:test05#SYSTEM#[GROUP NOTI]\n123#20161011,04:14:28                               - group notification
    // ROOM#1_2_6_1476158652943:1_2_5_6:test05#SYSTEM#test2$1_2_6_1476158652943$DELEGATE**ROOM##20161011,04:16:04       - delegate
    // ROOM#1_2_6_1476158652943:1_2_5_6:test05#SYSTEM#test05$LEAVE**ROOM#20161011,04:17:21                              - leave room
    
    func getType(body: String) -> MessageContentType {
        
        var _type: MessageContentType = .TEXT
        // remove room marker
        var body1 = body.substringFromIndex(body.rangeOfString(Constants.KEY_SEPERATOR)!.endIndex)
        // remove roomname, participants, sender
        body1 = body1.substringFromIndex(body1.rangeOfString(Constants.KEY_SEPERATOR)!.endIndex)
        
        if body1.hasPrefix(Constants.KEY_IMAGE_MARKER) {
            _type =  .IMAGE
        } else if body1.hasPrefix(Constants.KEY_VIDEO_MARKER) {
            _type =  .VIDEO
        } else if body1.hasPrefix(Constants.KEY_SYSTEM_MARKER) {
            _type = .SYSTEM
        } else if body1.hasPrefix(Constants.KEY_FILE_MARKER) {
            _type =  .FILE
        }
        
        if _type == .IMAGE || _type == .VIDEO {
            if imageModel == nil { imageModel = ChatImageEntity() }
        }
        
        return _type
    }
    
    func getMessage(body: String) -> String {
        
        var message = ""
        
        // remove room marker and date
        var body1 = body.substringWithRange(body.rangeOfString(Constants.KEY_SEPERATOR)!.endIndex ... body.rangeOfString(Constants.KEY_SEPERATOR, options: .BackwardsSearch)!.startIndex.advancedBy(-1))
        // remove room name, participant, sender.
        body1 = body1.substringFromIndex(body1.rangeOfString(Constants.KEY_SEPERATOR)!.endIndex)
        
        if _contentType == .TEXT  {
            // normal text ( will contain emoji)
            message = body1
        } else if _contentType == .SYSTEM || _contentType == .FILE {
            // system or file ( remove system or file marker)
            message = body1.substringFromIndex(body1.rangeOfString(Constants.KEY_SEPERATOR)!.endIndex)
        } else {
            // remove image or video marker and filename (marker#url#width#height#filename)
            message = body1.substringWithRange(body1.rangeOfString(Constants.KEY_SEPERATOR)!.endIndex ... body1.rangeOfString(Constants.KEY_SEPERATOR, options: .BackwardsSearch)!.startIndex.advancedBy(-1))
            let height = message.substringFromIndex(message.rangeOfString(Constants.KEY_SEPERATOR, options: .BackwardsSearch)!.endIndex)
            message = message.substringToIndex(message.rangeOfString(Constants.KEY_SEPERATOR, options: .BackwardsSearch)!.startIndex)
            let width = message.substringFromIndex(message.rangeOfString(Constants.KEY_SEPERATOR, options: .BackwardsSearch)!.endIndex)
            message = message.substringToIndex(message.rangeOfString(Constants.KEY_SEPERATOR, options: .BackwardsSearch)!.startIndex)
            guard imageModel != nil else { return message }
            
            if imageModel!.imageWidth == nil {
                if let dwidth = NSNumberFormatter().numberFromString(width) {
                    imageModel!.imageWidth = CGFloat(dwidth)
                }
            }
            
            if imageModel!.imageHeight == nil {
                if let dheight = NSNumberFormatter().numberFromString(height) {
                    imageModel!.imageHeight = CGFloat(dheight)
                }
            }
            
            if message.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.whitespaceCharacterSet()) != "" {
                imageModel!.originalURL = message
            }
        }

        return message
    }
    
    // room#roomname:participants#message#20151212 AM(PM), 12:00:00
    // room#roomname:participants#IMAGE#message#fileName#20151212 AM(PM), 12:00:00
    func getFileName(body: String) -> String {
        
        var fileName = ""
        if _contentType == .IMAGE || _contentType == .VIDEO || _contentType == .FILE {
            let body1 = body.substringToIndex(body.rangeOfString(Constants.KEY_SEPERATOR, options: .BackwardsSearch)!.startIndex)
            fileName = body1.substringFromIndex(body1.rangeOfString(Constants.KEY_SEPERATOR, options: .BackwardsSearch)!.endIndex)
        }
        
        return fileName
    }
    
    // get time 
    // need to change utc timezone to local timezone
    // message timezone : UTC
    func getTime(body: String) -> String  {
        
        let utcTimeZoneStr = body.substringFromIndex(body.rangeOfString(Constants.KEY_SEPERATOR, options: .BackwardsSearch)!.endIndex)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd,H:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        let utcDate = dateFormatter.dateFromString(utcTimeZoneStr)
        
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let localDateStr = dateFormatter.stringFromDate(utcDate!)
        
        return localDateStr
    }
    
    // message string timestamp local timestamp
    // it will be used when to load chat from database
    func getLocalTime(body: String) -> String {
        
        return body.substringFromIndex(body.rangeOfString(Constants.KEY_SEPERATOR, options: .BackwardsSearch)!.startIndex.advancedBy(1))
    }
    
    func getDate(time: String) -> String {
        
        return time.componentsSeparatedByString(",")[0]
    }
    
    func getDisplayTime(time: String) -> String {
        
        var dispTime = time.componentsSeparatedByString(",")[1]
        
        dispTime = dispTime.substringToIndex(dispTime.rangeOfString(":", options: .BackwardsSearch)!.startIndex)
        
        let arrHourMin = dispTime.componentsSeparatedByString(":")
        
        var _hour = Int(arrHourMin[0])!
        
        let _minute = arrHourMin[1]
        
        if (_hour < 12) {
            
            dispTime = Constants.TIME_AM + "\(_hour):" + _minute
            
        } else {
            
            _hour = _hour - 12
            
            if (_hour == 0) {
                
                _hour = 12
            }
            
            dispTime = Constants.TIME_PM + " \(_hour):" + _minute
        }
        
        return dispTime
    }
    
    // if message is group
    var isGroupMessage: Bool {
        
        if _roomName.componentsSeparatedByString("_").count > 2 {
            return true
        } else {
            return false
        }
    }
    
    var isEmoji: Bool {
        
        if _content.hasPrefix(EMOJI_PREFIX) && _content.hasSuffix(EMOJI_SUFFIX) {
            return true
        } else {
            return false
        }
    }
    
    var recentContent: String {
        var recent = ""
        if _contentType == .SYSTEM {
            var systemMsg = ""
            if _content.containsString(Constants.KEY_GROUPNOTI_MARKER) {
                systemMsg = _content
            } else if _content.containsString(Constants.KEY_LEAVEROOM_MARKER) {
                let name = _content.substringToIndex(_content.rangeOfString("$")!.startIndex)
                systemMsg = name + Constants.LEAVE_ROOM
            } else if _content.containsString(Constants.KEY_BANISH_MARKER) {
                let names = _content.substringToIndex(_content.rangeOfString("$")!.startIndex)
                systemMsg = names + Constants.BANISH_ROOM
            } else if _content.containsString(Constants.KEY_INVITE_MARKER) {
                let names = _content.substringToIndex(_content.rangeOfString("$")!.startIndex)
                systemMsg = names + Constants.INVITEED_ROOM
            } else if _content.containsString(Constants.KEY_DELEGATE_MARKER) {
                let name = _content.substringToIndex(_content.rangeOfString("$")!.startIndex)
                systemMsg = name + Constants.BECOME_GROUPOWNER
            } else if _content.containsString(Constants.KEY_REQUEST_MARKER) {
                let roomname_username = _content.substringToIndex(_content.rangeOfString("$", options: .BackwardsSearch)!.startIndex)
                let name = roomname_username.substringToIndex(_content.rangeOfString("$")!.startIndex)
                systemMsg = name + Constants.GROUP_REQUEST_MSG
            } else if _content.containsString(Constants.KEY_ADD_MARKER) {
                let roomname_username = _content.substringToIndex(_content.rangeOfString("$", options: .BackwardsSearch)!.startIndex)
                let name = roomname_username.substringToIndex(_content.rangeOfString("$")!.startIndex)
                systemMsg = name + Constants.ADDED_TO_ROOM
            }
            recent = systemMsg
        } else if _contentType == .FILE || _contentType == .IMAGE || _contentType == .VIDEO {
            // image, video or file
            recent = Constants.FILE_SENT
        } else {
            // text
            recent = _content
        }
        return recent
    }
}



