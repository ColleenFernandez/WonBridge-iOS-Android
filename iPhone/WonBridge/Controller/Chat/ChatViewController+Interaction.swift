//
//  ChatViewController+Interaction.swift
//  WonBridge
//
//  Created by July on 2016-09-25.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation
import Photos
import MobileCoreServices
import Synchronized

// MARK: - @delegate ChatActionBarViewDelegate
extension ChatViewController: ChatActionBarViewDelegate {
    
    func chatActionBarShowEmotionKeyboard() {
        
        let heightOffset = self.shareMoreView.height
        self.listTableView.stopScrolling()
        self.actionBarPaddingBottomConstranit?.updateOffset(-heightOffset)
        
        self.view.bringSubviewToFront(self.shareMoreView)
        UIView.animateWithDuration(
            0.25,
            delay: 0,
            options: .CurveEaseInOut,
            animations: {
                self.shareMoreView.snp_updateConstraints { make in
                    make.top.equalTo(self.chatActionBarView.snp_bottom).offset(self.shareMoreView.height)
                }
                self.shareMediaView.snp_updateConstraints { make in
                    make.top.equalTo(self.chatActionBarView.snp_bottom).offset(self.shareMediaView.height)
                }
                self.emotionInputView.snp_updateConstraints { make in
                    make.top.equalTo(self.chatActionBarView.snp_bottom).offset(0)
                }
                self.view.layoutIfNeeded()
                self.listTableView.scrollBottomToLastRow()
            },
            completion: { bool in
        })
    }
    
    func chatActionBarShowShareKeyboard() {
        
        let heightOffset = self.shareMoreView.height
        self.listTableView.stopScrolling()
        self.actionBarPaddingBottomConstranit?.updateOffset(-heightOffset)
        
        self.view.bringSubviewToFront(self.shareMoreView)
        UIView.animateWithDuration(
            0.25,
            delay: 0,
            options: .CurveEaseInOut,
            animations: {
                self.shareMoreView.snp_updateConstraints { make in
                    make.top.equalTo(self.chatActionBarView.snp_bottom).offset(0)
                }
                self.shareMediaView.snp_updateConstraints { make in
                    make.top.equalTo(self.chatActionBarView.snp_bottom).offset(self.shareMediaView.height)
                }
                self.emotionInputView.snp_updateConstraints { make in
                    make.top.equalTo(self.chatActionBarView.snp_bottom).offset(self.emotionInputView.height)
                }
                self.view.layoutIfNeeded()
                self.listTableView.scrollBottomToLastRow()
            },
            completion: { bool in
        })
    }
    
    func chatActionBarHideMediaKeyboard() {
        
        let heightOffset = self.shareMoreView.height
        self.listTableView.stopScrolling()
        self.actionBarPaddingBottomConstranit?.updateOffset(-heightOffset)
        
        UIView.animateWithDuration(
            0.25,
            delay: 0,
            options: .CurveEaseInOut,
            animations: {
                self.shareMediaView.snp_updateConstraints { make in
                    make.top.equalTo(self.chatActionBarView.snp_bottom).offset(self.shareMediaView.height)
                }
                self.view.layoutIfNeeded()
                self.listTableView.scrollBottomToLastRow()
            },
            completion: { bool in
        })
    }
}

// MARK: - @protocol ChatShareMoreViewDelegate
extension ChatViewController: ChatShareMoreViewDelegate {
    
    func chatShareMoreViewPhotoTaped() {
        
        _photos.removeAll()
        synchronized(_assets) {
            
            let copy = _assets
            guard NSClassFromString("PHAsset") != nil else { return }
            
            // Photos library
            let itemSizeW = (UIScreen.width - kLeftRightTopPadding*(kPhotoItemCountOfRow + 1)) / kPhotoItemCountOfRow
            let thumbSize = CGSizeMake(itemSizeW, itemSizeW)
            for asset in copy {
                let _asset = asset as! PHAsset
                if _asset.mediaType == PHAssetMediaType.Image {
                    _photos.append(WBMediaModel(asset: asset as! PHAsset, targetSize: thumbSize))
                }
            }
        }
        
        self.shareMediaView._isPhotoView = true
        self.shareMediaView.reloadList(_photos)
        
        self.chatActionBarView.replaceActionBarUI(imageChat: true, isPhotoView: true)
        
        let heightOffset = self.shareMediaView.height
        self.listTableView.stopScrolling()
        self.actionBarPaddingBottomConstranit?.updateOffset(-heightOffset)
        
        self.view.bringSubviewToFront(self.shareMediaView)
        UIView.animateWithDuration(
            0.25,
            delay: 0,
            options: .CurveEaseInOut,
            animations: {
                self.shareMediaView.snp_updateConstraints { make in
                    make.top.equalTo(self.chatActionBarView.snp_bottom).offset(0)
                }
                self.view.layoutIfNeeded()
                self.listTableView.scrollBottomToLastRow()
            }, completion: { bool in                
        })
    }
    
    func chatShareMoreViewVideoTaped() {
        
        _videos.removeAll()
        synchronized(_assets) {
            
            let copy = _assets
            guard NSClassFromString("PHAsset") != nil else { return }
            
            // Photos library
            let itemSizeW = (UIScreen.width - kLeftRightTopPadding*(kVideoItemCountOfRow + 1)) / kVideoItemCountOfRow
            let thumbSize = CGSizeMake(itemSizeW, itemSizeW)
            for asset in copy {
                let _asset = asset as! PHAsset
                if _asset.mediaType == PHAssetMediaType.Video {
                    _videos.append(WBMediaModel(asset: asset as! PHAsset, targetSize: thumbSize))
                }
            }
        }
        
        self.shareMediaView._isPhotoView = false
        self.shareMediaView.reloadList(self._videos)
        
        self.chatActionBarView.replaceActionBarUI(imageChat: true, isPhotoView: false)
        
        let heightOffset = self.shareMediaView.height
        self.listTableView.stopScrolling()
        self.actionBarPaddingBottomConstranit?.updateOffset(-heightOffset)
        
        self.view.bringSubviewToFront(self.shareMediaView)
        UIView.animateWithDuration(
            0.25,
            delay: 0,
            options: .CurveEaseInOut,
            animations: {
                self.shareMediaView.snp_updateConstraints { make in
                    make.top.equalTo(self.chatActionBarView.snp_bottom).offset(0)
                }
                self.view.layoutIfNeeded()
                self.listTableView.scrollBottomToLastRow()
            }, completion: { bool in
        })
    }
    
    func chatShareMoreViewCameraTapped() {
        
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if authStatus == .NotDetermined {
            self.checkCameraPermission()
        } else if authStatus == .Restricted || authStatus == .Denied {
            self.showAlert("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限", positive: Constants.ALERT_OK, negative: nil)
        } else if authStatus == .Authorized {
            self.openCamera()
        }
    }
    
    func chatShareMoreViewVoiceCallTapped() {
        
        guard chatRoom!.isSingle() else { return }
       
        // check block
        let partner = chatRoom!._participantList[0]
        guard !_user!.isBlockedFriend(partner._idx) else  { return }
        
        CommonUtils.checkPermission(AVMediaTypeAudio) { (granted) in
            if granted {
                // do process for voice calling
                self.callWithUser(partner, videoEnable: false)
            } else {
                // show alert
                self.showAlert(Constants.APP_NAME, message: Constants.NEED_ACCESS_MICROHPHONE   , positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
    
    func chatShareMoreViewVideoCallTapped() {
        
        guard chatRoom!.isSingle() else { return }
        
        let partner = chatRoom!._participantList[0]
        guard !_user!.isBlockedFriend(partner._idx) else  { return }
        
        // check camera and mic access permission
        CommonUtils.checkPermission(AVMediaTypeVideo) { (granted) in
            if granted {
                CommonUtils.checkPermission(AVMediaTypeAudio, completion: { (granted) in
                    if granted {
                        // do process for video calling
                        self.callWithUser(partner, videoEnable:true)
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
    
    func chatShareMoreViewGiftTapped() {
        
    }
    
    func callWithUser(partner: FriendEntity, videoEnable: Bool) {
        
        // send video request
        WBAppDelegate.xmpp.sendVideoRequest(partner._idx, partnerName: partner._name, videoEnable: videoEnable)
        
        AudioPlayInstance.playSoundWithType(.Ring_1)
    }
    
    func checkCameraPermission() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { granted in
            if !granted {
                self.showAlert("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限", positive: Constants.ALERT_OK, negative: nil)
            }
        })
    }
    
    func openCamera() {
        if imagePicker == nil {
            imagePicker = UIImagePickerController()
        }
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func resizeAndSendImage(theImage: UIImage) {
        let originalImage = UIImage.fixImageOrientation(theImage)
        let storeKey = "IMG_" + "\(NSDate().millisecondesInt)"
        
//        print( "local upload file name: ------- \(storeKey)")
        
        let thumbSize = ChatConfig.getThumbImageSize(originalImage.size)
        guard let thumbNail = originalImage.resize(thumbSize) else { return }
        
        let sendImageSize = ChatConfig.getChatImageSize(originalImage.size)
        guard let sendImage = originalImage.resize(sendImageSize) else { return }
        
        ImageFilesManager.storeImage(thumbNail, key: storeKey, completionHandler: { [weak self] in
            guard let strongSelf = self else { return }
            
            let sendImageModel = ChatImageEntity()
            sendImageModel.imageHeight = sendImage.size.height
            sendImageModel.imageWidth = sendImage.size.width
            sendImageModel.localStoreName = storeKey
            strongSelf.chatSendImage(sendImageModel, sendImage: sendImage, fileName: storeKey + ".png")
        })
    }
}

// MARK: - @protocol UIImagePickerControllerDelegate
extension ChatViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        guard let mediaType = info[UIImagePickerControllerMediaType] as? NSString else { return }
        if mediaType.isEqualToString(kUTTypeImage as String) {
            guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            if picker.sourceType == .Camera {
                self.resizeAndSendImage(image)
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK - @protocol ChatEmotionInputViewDelegate
extension ChatViewController: ChatEmotionInputViewDelegate {
    
    // emoji cell did tapped
    func chatEmoticonInputViewDidTapCell(cell: ChatEmotionCell) {
        
        self.chatSendEmotion(cell.emotionModel!)
    }
}

// MARK - @protocol ChatShareMediaViewDelegate
extension ChatViewController: ChatShareMediaViewDelegate {
    
    func videoCellTapped(asset: WBMediaModel) {
        self.chatShowVideoPreView(asset)
    }
}

//MARK:  - @protocol VideoSendDelegate
extension ChatViewController: VideoSendDelegate {
    func videoSend(video: WBMediaModel) {
        self.chatSendLocalVideo(video)
    }
}

// MARK: - @protocol ChatCellDelegate
extension ChatViewController: ChatCellDelegate {
    /**
     点击了 cell 本身
     */
    func cellDidTapped(cell: ChatBaseCell) {
        
    }
    
    /**
     点击了 cell 的头像
     */
    func cellDidTappedAvatarImageView(cell: ChatBaseCell) {

    }
    
    /**
     点击了 cell 的图片
     */
    func cellDidTappedImageView(cell: ChatBaseCell) {
        guard let model = cell.model else { return }
        self.showChatDetail(model)
    }
    
    /**
     点击了 cell 中文字的 URL
     */
    func cellDidTappedLink(cell: ChatBaseCell, linkString: String) {

    }
    
    /**
     点击了 cell 中文字的 电话
     */
    func cellDidTappedPhone(cell: ChatBaseCell, phoneString: String) {
   
    }
    
    /**
     点击了声音 cell 的播放 button
     */
    func cellDidTappedVoiceButton(cell: ChatBaseCell, isPlayingVoice: Bool) {
    }
}

// MARK: - @protocol UITextViewDelegate
extension ChatViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
    }
    
    func textViewDidChange(textView: UITextView) {
        
        self.chatActionBarView.resetTextSendButtonUI()
        
        let contentHeight = textView.contentSize.height
        guard contentHeight < kChatActionBarTextViewMaxHeight else { return }
        
        self.chatActionBarView.inputTextViewCurrentHeight = contentHeight + 17
        self.controlExpandableInputView(showExpandable: true)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        self.chatActionBarView.inputTextViewCallKeyboard()
        
        UIView.setAnimationsEnabled(false)
        let range = NSMakeRange(textView.text.length - 1, 1)
        textView.scrollRangeToVisible(range)
        UIView.setAnimationsEnabled(true)
        return true
    }
}
