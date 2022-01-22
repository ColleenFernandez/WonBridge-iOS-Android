//
//  ChatViewController+HandleData.swift
//  WonBridge
//
//  Created by July on 2016-09-26.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation
import Photos
import Synchronized

// MARK: - @extension ChatViewController
extension ChatViewController {
    
    // MARK: - Load Assets
    func loadAssets() {
        
        guard NSClassFromString("PHAsset") != nil else { return }
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.Authorized {
                    self.performLoadAssets()
                }
            })
        } else if status == PHAuthorizationStatus.Authorized {
            self.performLoadAssets()
        }
    }
    
    func performLoadAssets() {
        
        // initialize array
        self._assets.removeAll()
        
        guard NSClassFromString("PHAsset") != nil else  { return }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResults = PHAsset.fetchAssetsWithOptions(fetchOptions)
            
            fetchResults.enumerateObjectsUsingBlock({ (obj, idx, stop) in
                self._assets.append(obj)
            })
        }
    }
    
    // remove banished user(s) from participantList of chatRoom, delete banished user message
    func removeBanishUsers(idList: [String]) {
        
        var newParticipantList = [FriendEntity]()
        for existParticipant in self.chatRoom!._participantList {
            if !idList.contains("\(existParticipant._idx)") {
                
                newParticipantList.append(existParticipant)
            }
        }
        
        self.chatRoom!._participantList = newParticipantList
        
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue, {
            
            self.isEndRefreshing = false
            self.isReloading = true
            
            var copy: [ChatEntity] = self.itemDataSource
            
            for index in 1 ..< copy.count {
                
                let chatItem = copy[index]
                if idList.contains("\(chatItem._chatSendId)") {
                    self.itemDataSource.remove(chatItem)
                }
            }
            
            sleep(1)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.listTableView.reloadData({ 
                    self.isReloading = false
                    self.isEndRefreshing = true
                })
            })
        })
    }
    
    func sendAcceptMessage() {
        
        // add message directly to message array
        let revFullMSg = getRoomInfoString() + "You" + Constants.FRIEND_REQUEST_ACCEPT + Constants.KEY_SEPERATOR + NSDate.utcString()
        let acceptChatItem = ChatEntity(message: revFullMSg, sender: "\(_user!._idx)", imageModel: nil)
        acceptChatItem._isNewMsg = true
        
        addMessage(acceptChatItem)
        saveMessage(acceptChatItem)
        
        // send
        let sendFullMsg = getRoomInfoString() + _user!._name.capitalizingFirstLetter() + Constants.FRIEND_REQUEST_ACCEPT + Constants.KEY_SEPERATOR + NSDate.utcString()
        let sendAcceptChatItem = ChatEntity(message: sendFullMsg, sender: "\(_user!._idx)", imageModel: nil)
        sendPacket(sendAcceptChatItem)
    }
    
    // make a packet to send or receive
    // isSend : true is packet to send, false is received packet
    func makePacket(contentType: MessageContentType, content: String, fileName: String, imageModel: ChatImageEntity?, _isSend: Bool) -> ChatEntity {

        let sendTime = NSDate.utcString()

        // in case of sending: senderName will be sender name
        // in case of receiving: senderName will be sender idx
        let _sendPacket = ChatEntity(room: chatRoom!, senderName: _user!._name, contentType: contentType, content: content, fileName: fileName, sendTime: sendTime, imageModel: imageModel)
        
        if (!_isSend) {
            let _revMsg = _sendPacket.toMessage()
            let _revPacket = ChatEntity(message: _revMsg, sender: "\(_user!._idx)", imageModel: imageModel)
            return _revPacket
        }
        
        return _sendPacket
    }
    
    func getRoomInfoString() -> String {
        
        if isOnlineService {
            return Constants.KEY_ROOM_MARKER + Constants.KEY_ONLINE_SERVICEROOM + ":" + "\(_user!._idx)" + ":" + _user!._name  + Constants.KEY_SEPERATOR
        }
        
        return Constants.KEY_ROOM_MARKER + chatRoom!._name + ":" + chatRoom!._participants + ":" + _user!._name + Constants.KEY_SEPERATOR
    }
    
    // proceed message array
    // add receiving or sending packet (add message and update table, scoll to last indexPath)
    // if chat type is image or video, do upload a file to server
    func addMessage(_revPacket: ChatEntity) {
 
        var indexPaths = [NSIndexPath]()
        
        // add date 
        if _revPacket._date != lastReceivedDate {
            dateFormatter.dateFormat = "yyyyMMdd,H:mm:ss"
            let receivedDate = dateFormatter.dateFromString(_revPacket._timestamp)
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            self.itemDataSource.append(ChatEntity(timestamp: self.dateFormatter.stringFromDate(receivedDate!)))
            lastReceivedDate = _revPacket._date
            indexPaths.insert(NSIndexPath(forRow: itemDataSource.count - 1, inSection: 0), atIndex: 0)
        }
        
        self.itemDataSource.append(_revPacket)
        indexPaths.insert(NSIndexPath(forRow: itemDataSource.count - 1, inSection: 0), atIndex: 0)
        
        self.listTableView.insertRowsAtBottom(indexPaths)
    }
    
    // save chat to local database
    func saveMessage(model: ChatEntity) {
        
        // save chat
        if (model._isNewMsg!) {
            DBManager.getSharedInstance().saveChat(model._roomName, message: model.toMessage(), sender: Int(model._from)!, datetime: model._timestamp, isCurrent: 1)
        }

        chatRoom!._recentContent = model.recentContent
        chatRoom!._recentTime = model._timestamp
        chatRoom!._recentCount = 0
        
        DBManager.getSharedInstance().updateRoom(chatRoom!)
    }
    
    // send a packet
    func sendPacket(_sendPacket: ChatEntity) {
        
        // send room message to all user of ths room
        WBAppDelegate.xmpp .sendPacket(_sendPacket)
        
        for ids in chatRoom!._participants.componentsSeparatedByString("_") {
            WBAppDelegate.xmpp.sendPacket(_sendPacket, friendIdx: Int(ids)!)
        }
        
        WBSystemSoundPlayer.playSoundWithType(.Chat)
//        AudioPlayInstance.playSoundWithType(.Chat)
    }
    
    // send a text message
    func chatSendText() {
        
        if !isOnlineService {
            
            guard self.bChatAvailable else {
                showToast(Constants.DISCONNECTED_CHAT_SERVER)
                return
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            guard let strongSelf = self else { return }
            let textView = strongSelf.chatActionBarView.inputTextView
            let text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            guard text.length > 0  else {
                return
            }
            
            let fullMsg = strongSelf.getRoomInfoString() + text + Constants.KEY_SEPERATOR + NSDate.utcString()
            let chatItem = ChatEntity(message: fullMsg, sender: "\(strongSelf._user!._idx)", imageModel: nil)
            chatItem._isNewMsg = true
            
            strongSelf.addMessage(chatItem)
            
            if strongSelf.isOnlineService {
                
                strongSelf.sendOnlineMessage(text, isImage: false, width: 0, height: 0)
                
            } else {
            
                // then save message here
                strongSelf.saveMessage(chatItem)
                
                // send
                let _sendPacket = strongSelf.makePacket(.TEXT, content: text, fileName: "", imageModel: nil, _isSend: true)
                strongSelf.sendPacket(_sendPacket)
            }
            
            textView.text = "" //发送完毕后清空
            strongSelf.textViewDidChange(strongSelf.chatActionBarView.inputTextView)
        })
    }
   
    // send a image
    func chatSendImage(imageModel: ChatImageEntity, sendImage: UIImage, fileName: String) {
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            guard let strongSelf = self else { return }
            
            let msg = Constants.KEY_IMAGE_MARKER + " " + Constants.KEY_SEPERATOR + "\(Int(sendImage.width))" + Constants.KEY_SEPERATOR + "\(Int(sendImage.height))" + Constants.KEY_SEPERATOR + fileName
            let fullMsg = strongSelf.getRoomInfoString() + msg + Constants.KEY_SEPERATOR + NSDate.utcString()
            let chatItem = ChatEntity(message: fullMsg, sender: "\(strongSelf._user!._idx)", imageModel: imageModel)
            
            chatItem._isNewMsg = true
            strongSelf.addMessage(chatItem)
            
            NSNotificationCenter.defaultCenter().postNotificationName(CHAT_LOADING_DID_START_NOTIFICATION, object: chatItem)
            
            WebService.uploadFile(sendImage, type: 1, fileName: fileName, userId: strongSelf._user!._idx, model: chatItem, completion: { (status, message, model) in
                
                NSNotificationCenter.defaultCenter().postNotificationName(CHAT_LOADING_DID_END_NOTIFICATION, object: chatItem)
                
                if (status) {                    
                    // then save message here
                    imageModel.originalURL = model._content
                    
                    if strongSelf.isOnlineService {
                        
                        strongSelf.sendOnlineMessage(model._content, isImage: true, width: Int(KVOValue: imageModel.imageWidth!)!, height: Int(KVOValue: imageModel.imageHeight!)!)
                        
                    } else {
                        
                        strongSelf.saveMessage(model)
                        
                        // send message to user
                        let sendPacket = strongSelf.makePacket(.IMAGE, content: model._content, fileName: model._fileName, imageModel: imageModel,  _isSend: true)
                        strongSelf.sendPacket(sendPacket)
                    }
                }
            })
        })
    }
    
    func chatSendVideo(imageModel: ChatImageEntity, fileName: String, uploadData: NSData) {
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            
            guard let strongSelf = self else { return }

//            let _revPacket = strongSelf.makePacket(.VIDEO, content: " ", fileName: fileName, imageModel: imageModel, _isSend: false)
//
//            _revPacket._isNewMsg = true
//            strongSelf.addMessage(_revPacket)
            
            let msg = Constants.KEY_VIDEO_MARKER + " " + Constants.KEY_SEPERATOR + "\(Int(imageModel.imageWidth!))" + Constants.KEY_SEPERATOR + "\(Int(imageModel.imageHeight!))" + Constants.KEY_SEPERATOR + fileName
            let fullMsg = strongSelf.getRoomInfoString() + msg + Constants.KEY_SEPERATOR + NSDate.utcString()
            let chatItem = ChatEntity(message: fullMsg, sender: "\(strongSelf._user!._idx)", imageModel: imageModel)
            
            chatItem._isNewMsg = true
            strongSelf.addMessage(chatItem)
            
            NSNotificationCenter.defaultCenter().postNotificationName(CHAT_LOADING_DID_START_NOTIFICATION, object: chatItem)

            WebService.uploadFile(uploadData, type: 2, fileName: fileName, userId: strongSelf._user!._idx, model: chatItem, completion: { (status, message, model) in
                
                NSNotificationCenter.defaultCenter().postNotificationName(CHAT_LOADING_DID_END_NOTIFICATION, object: chatItem)


                if (status) {
                    
                    // save video to local filePath
//                    model._content = CommonUtils.saveVideoToFile(uploadData, filePath: Constants.UPLOAD_FILE_PATH, fileName: model._fileName)
                    // then save message here
                    imageModel.originalURL = model._content
                    
                    if strongSelf.isOnlineService {
                        strongSelf.sendOnlineMessage(model._content, isImage: true, width: Int(KVOValue: imageModel.imageWidth!)!, height: Int(KVOValue: imageModel.imageHeight!)!)
                    } else {
                       
                        strongSelf.saveMessage(model)
                        
                        // send message to user
                        let sendPacket = strongSelf.makePacket(.VIDEO, content: model._content, fileName: model._fileName, imageModel: imageModel,  _isSend: true)
                        strongSelf.sendPacket(sendPacket)
                    }
                }
            })
        })
    }
    
    func chatSendEmotion(emotion: EmotionModel) {
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            
            guard let strongSelf = self else { return }
            
            let fullMsg = strongSelf.getRoomInfoString() + emotion.text + Constants.KEY_SEPERATOR + NSDate.utcString()
            let chatItem = ChatEntity(message: fullMsg, sender: "\(strongSelf._user!._idx)", imageModel: nil)
            chatItem._isNewMsg = true
            
            strongSelf.addMessage(chatItem)
            
            if strongSelf.isOnlineService {
                
                strongSelf.sendOnlineMessage(emotion.text, isImage: false, width: 0, height: 0)
                
            } else {
            
                strongSelf.saveMessage(chatItem)
                
                // send
                let _sendPacket = strongSelf.makePacket(.TEXT, content: emotion.text, fileName: "", imageModel: nil, _isSend: true)
                strongSelf.sendPacket(_sendPacket)
            }
        })
    }
    
    func chatSendLocalImage() {
        
        var selectedMedia = [WBMediaModel]()
        selectedMedia.insertContentsOf(self.shareMediaView._selectedPhotos, at: 0)
        guard selectedMedia.count > 0 else { return }
        
        for photo in selectedMedia {
            
            guard photo.asset != nil else { return }
            
            let manager = PHImageManager.defaultManager()
            let options = PHImageRequestOptions()
            options.synchronous = true
            options.networkAccessAllowed = true
            options.version = .Current
            options.deliveryMode = .HighQualityFormat
            options.resizeMode = .Exact
            
            manager.requestImageForAsset(photo.asset!, targetSize: CGSizeMake(CGFloat(photo.asset!.pixelWidth), CGFloat(photo.asset!.pixelHeight)), contentMode: .AspectFill, options: options, resultHandler: { (result, info) in
                
                if let image = result {
                
                    let thumbSize = ChatConfig.getThumbImageSize(image.size)
                    let sendImageSize = ChatConfig.getChatImageSize(image.size)
                    let storeKey = "IMG_" + "\(NSDate().millisecondesInt)"
                    
                    var fileName = storeKey
                    if let _fileName = (info?["PHImageFileURLKey"] as? NSURL)?.lastPathComponent {
                        //do sth with file name
                        fileName = _fileName
                    }
                    
                    guard let sendImage = image.resize(sendImageSize) else  { return }
                    guard let thumbnail = image.resize(thumbSize) else { return }
                    
                    ImageFilesManager.storeImage(thumbnail, key: storeKey, completionHandler: { [weak self] in
                        
                        guard let strongSelf = self else { return }
                        
                        let sendImageModel = ChatImageEntity()
                        
                        sendImageModel.imageHeight = sendImage.size.height
                        sendImageModel.imageWidth = sendImage.size.width
                        sendImageModel.localStoreName = storeKey
                        
                        strongSelf.chatSendImage(sendImageModel, sendImage: sendImage, fileName: fileName)
                        })
                }
            })
        }
        
        self.shareMediaView.reloadList()
    }
    
    func chatSendLocalVideo(video: WBMediaModel) {
        
        guard video.asset != nil  else { return }
        
        guard let image = video.asset!.getUIImage() else { return }
        let thumbnailSize = ChatConfig.getThumbImageSize(image.size)
        
        guard let thumbnail = image.resize(thumbnailSize) else { return }
        
        let storeKey = "VIDEO_" + "_\(NSDate().millisecondesInt)"
        ImageFilesManager.storeImage(thumbnail, key: storeKey) { [weak self] in
            
            guard let strongSelf = self else { return }
            
            let sendImageModel = ChatImageEntity()
            sendImageModel.imageHeight = image.size.height
            sendImageModel.imageWidth = image.size.width
            sendImageModel.localStoreName = storeKey
            
            PHCachingImageManager().requestAVAssetForVideo(video.asset!, options: nil) { (asset, audioMux, info) in
    
                let asset = asset as! AVURLAsset
                guard let videoData = NSData(contentsOfURL: asset.URL) else { return }                
                
                let pathArray = asset.URL.absoluteString.componentsSeparatedByString("/")
                let assetName = pathArray[pathArray.count - 1]
                
                strongSelf.chatSendVideo(sendImageModel, fileName: assetName, uploadData: videoData)
            }
        }
    }
    
    func chatShowVideoPreView(asset: WBMediaModel) {
        
        self.hideAllKeyboard()
        
        // show video preview
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        let videoPreviewVC = storyboard.instantiateViewControllerWithIdentifier("VideoPreviewController") as! VideoPreviewController
        videoPreviewVC.video = asset
        videoPreviewVC.transitioningDelegate = modalTransition
        videoPreviewVC.videoSendDelegate = self
        modalTransition.interactiveDismissAnimator.wireToViewController(videoPreviewVC)
        
        presentViewController(videoPreviewVC, animated: true, completion: nil)
    }
    
    func showChatDetail(model: ChatEntity) {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        if model._contentType == .IMAGE {
            
            let photoVC = storyboard.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController
            photoVC.imageUrl = model.imageModel!.originalURL!
            photoVC.transitioningDelegate = modalTransition
            modalTransition.interactiveDismissAnimator.wireToViewController(photoVC)
            
            presentViewController(photoVC, animated: true, completion: nil)
            
        } else if model._contentType == .VIDEO {
            
            let videoVC = storyboard.instantiateViewControllerWithIdentifier("VideoViewController") as! VideoViewController
            videoVC.videoUrl = model.imageModel!.originalURL!
            videoVC.transitioningDelegate = modalTransition
            modalTransition.interactiveDismissAnimator.wireToViewController(videoVC)
            
            presentViewController(videoVC, animated: true, completion: nil)
        }
    }
    
    func sendOnlineMessage(message: String, isImage: Bool, width: Int, height: Int) {
        
        WebService.sendOnlineMessage(_user!._idx, message: message, isImage: isImage, width: width, height: height) { (status) in
            
            WBSystemSoundPlayer.playSoundWithType(.Chat)
//            AudioPlayInstance.playSoundWithType(.Chat)
            
            if !status {
                self.showAlert(Constants.APP_NAME, message: Constants.FAIL_TO_CONNECT, positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
}

// MARK: - @delegate XmppCustomReconnectionDelegate
extension ChatViewController: XmppCustomReconnectionDelegate {
    
    // user can send message to his friend
    func xmppConnected() {
        
        showToast(Constants.CONNECTED_CHAT_SERVER)

        bChatAvailable = true

        if isFriendRequest {
            
            let revFullMsg = getRoomInfoString() + "You" + Constants.FRIEND_REQUEST_SENT + Constants.KEY_SEPERATOR + NSDate.utcString()
            let revFriendRequestItem = ChatEntity(message: revFullMsg, sender: "\(_user!._idx)", imageModel: nil)
            revFriendRequestItem._isNewMsg = true

            addMessage(revFriendRequestItem)
            saveMessage(revFriendRequestItem)

            // send
            let sendFullMsg = getRoomInfoString() + _user!._name.capitalizingFirstLetter() + Constants.FRIEND_REQUEST_SENT + Constants.KEY_SEPERATOR + NSDate.utcString()
            let sendRequestChatItem = ChatEntity(message: sendFullMsg, sender: "\(_user!._idx)", imageModel: nil)
            sendPacket(sendRequestChatItem)

            isFriendRequest = false
        }
    }
    
    func xmppDisconnected() {
        
        showToast(Constants.DISCONNECTED_CHAT_SERVER)

        bChatAvailable = false
    }
}

// MARK: - @delegate WBMessageDelegate
extension ChatViewController: WBMessageDelegate {
    
    // independent message (outside of room)
    // update participants with received packet
    func newPacketReceived(_revPacket: ChatEntity) {
        
        var isRequest = false
        if _revPacket._contentType == .SYSTEM && _revPacket._content.containsString(Constants.KEY_REQUEST_MARKER) {
            isRequest = true
        }
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            
            guard let strongSelf = self else { return }
            
            // no need to update in case of group notification, delegator 
            // now igore this case
            if _revPacket._contentType == .SYSTEM {
                
                if isRequest {
                    strongSelf.getGroupRequestByUserId(_revPacket._chatSendId)
                    return
                }
                
                if _revPacket._content.containsString(Constants.KEY_BANISH_MARKER) {
                 
                    // process banish message on existing room
                    var dolIndex = _revPacket._content.rangeOfString("$", options: .BackwardsSearch)?.endIndex.advancedBy(-1)
                    let all = _revPacket._content.substringToIndex(dolIndex!)
                    dolIndex = all.rangeOfString("$", options: .BackwardsSearch)?.endIndex
                    //                    let names = all.substringToIndex(dolIndex!.advancedBy(-1))
                    let ids = all.substringFromIndex(dolIndex!)
                    let idList = ids.componentsSeparatedByString("_")
                    
                    if idList.contains("\(strongSelf._user!._idx)") {
                        // process banish for me
                        strongSelf.hideAllKeyboard()
                        WBAppDelegate.xmpp.leaveRoom(strongSelf.chatRoom!)
                        strongSelf.navigationController?.popViewControllerAnimated(true)
                        return
                    } else {
                        // process banish for other user
                        // remove banished user(s) in participantList ( participants already changed )
                        strongSelf.removeBanishUsers(idList)
                        strongSelf.updateRoomTitle()
                    }
                    
                } else {
                    strongSelf.updateRoomTitle()
                }
            }
            
            strongSelf.addMessage(_revPacket)
        }
        
        if !isRequest {
            WBSystemSoundPlayer.playSoundWithType(.Chat)
//            AudioPlayInstance.playSoundWithType(.Chat)
        }
    }
}

// MARK: - @delegate WBRoomMessageDelegate
extension ChatViewController: WBRoomMessageDelegate {
    
    // room message delegate
    func newRoomPacketReceived(_revPacket: ChatEntity) {
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            
            guard let strongSelf = self else { return }
            
            strongSelf.addMessage(_revPacket)
        }
        
        WBSystemSoundPlayer.playSoundWithType(.Chat)
//        AudioPlayInstance.playSoundWithType(.Chat)
    }
}





