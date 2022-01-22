//
//  VideoChatViewController.swift
//  WonBridge
//
//  Created by Roch David on 14/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import AVFoundation

class CallViewController: BaseViewController {

    @IBOutlet weak var remoteView: RTCEAGLVideoView!
    @IBOutlet weak var localView: RTCEAGLVideoView!
    
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var controlContainerView: UIView!
    
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var hangupButton: UIButton!
    
    @IBOutlet weak var lblWaiting: UILabel!
    
    @IBOutlet weak var remoteViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var remoteViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var remoteViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var remoteViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var localViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var localViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var localViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var localViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var btnContainerViewBottomLayout: NSLayoutConstraint!
    
    @IBOutlet weak var btnCameraControl: UIButton!
    
    var _user: UserEntity?
    
    var roomId: String!
    var roomUrl: String!
    var partnerId: Int! = 0
    
    var videoEnable: Bool = true
    var partnerName: String = ""
    
    var client: ARDAppClient?
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    
    var localVideoSize: CGSize!
    var remoteVideoSize: CGSize!
    
    var isZoom: Bool = false
    
    // toggle button parameter
    var isAudioMute: Bool = false
    var isVideoMute: Bool = false
    var isSpeaker: Bool = false
    
    var isFront: Bool = true
    var isVideoOff: Bool = false
    
    var callStartedTime: Double = 0
    
    var isCaller: Bool = true
    
    var isCallConnected = false
    var isNoAnswer = false
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var maskView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _user = WBAppDelegate.me
 
        // Do any additional setup after loading the view.
        self.roomUrl = RTC_SERVER + "/r/" + roomId
        
        initView()
        
        // RTCEAGLVideoViewDelegate provides notifications on video frame dimensions
        remoteView.delegate = self
        localView.delegate = self
        
        WBAppDelegate.xmpp._callMsgDelegate = self
        
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    func initView() {
        
        lblTitle.text = partnerName
        
        // Add Tap to hide/show controls
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(toggleButtonContainer))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
        
        if (videoEnable) {
            isVideoMute = false
        } else {
            isVideoMute = true
            controlContainerView.hidden = true
        }
        
        maskView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Display the local view full screen while connecting to room
        localViewTopConstraint.constant = 44
        localViewLeftConstraint.constant = 0
        localViewWidthConstraint.constant = self.view.frame.size.width
        localViewHeightConstraint.constant = self.view.frame.size.height
        
        // Connect to the room
//        disconnect()
        
        client = ARDAppClient(delegate: self)
//        client?.serverHostUrl = RTC_SERVER
//        client?.connectToRoomWithId(roomId, options: nil)        
        client?.connectToRoomWithId(RTC_SERVER, roomId: roomId, options: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        disconnect()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func applicationWillResignActive(application: UIApplication) {
     
        self.dismissViewControllerAnimated(true, completion: nil)
        
        disconnect()
    }
    
    // MARK: - disconnect to teh room
    func disconnect() {
        
        guard client != nil else {
            return
        }
        
        if localVideoTrack != nil {
            localVideoTrack?.removeRenderer(localView)
        }
        
        if remoteVideoTrack != nil {
            remoteVideoTrack?.removeRenderer(remoteView)
        }
        
        localVideoTrack = nil
        // remove video frame on localview
//        localView.renderFrame(nil)
        remoteVideoTrack = nil
        // remove video frame on remote view
//        remoteView.renderFrame(nil)
        
        client!.disconnect()
    }
    
    func remoteDisconnected() {
        
        if remoteVideoTrack != nil {
            remoteVideoTrack?.removeRenderer(remoteView)
        }
        remoteVideoTrack = nil
        
        
        self.videoView(localView, didChangeVideoSize: localVideoSize)
    }
    
    // MARK: - toggle button container
    func toggleButtonContainer() {
        
        UIView.animateWithDuration(0.3) {
            
            if self.btnContainerViewBottomLayout.constant <= -91 {
                
                self.btnContainerViewBottomLayout.constant = 50
                self.buttonContainerView.alpha = 1.0
                
            } else {
                
                self.btnContainerViewBottomLayout.constant = -91
                self.buttonContainerView.alpha = 0.0
            }
            
            self.view.layoutIfNeeded()
        }
        
        UIView.transitionWithView(controlContainerView, duration: 0.3, options: .CurveEaseInOut, animations: { 
            self.buttonContainerView.hidden = !self.buttonContainerView.hidden
            }, completion: nil)
    }
    
    @IBAction func audioButtonTapped(sender: UIButton) {
        
        if (isAudioMute) {
            
            isAudioMute = false
            
//            client?.unmuteAudioIn()
            audioButton.setImage(UIImage(named: "button_no_voice_off"), forState: UIControlState.Normal)
            
        } else {
            
            isAudioMute = true
            
//            client?.muteAudioIn()
            audioButton.setImage(UIImage(named: "button_no_voice_on"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func speakerButtonTapped(sender: AnyObject) {
        
        if (isSpeaker) {
            isSpeaker = false
            speakerButton.setImage(UIImage(named: "button_speaker_off"), forState: UIControlState.Normal)
        } else {
            isSpeaker = true
            speakerButton.setImage(UIImage(named: "button_speaker_on"), forState: UIControlState.Normal)
        }
    }

    @IBAction func hangupButtonTapped(sender: UIButton) {
        
        self.disconnect()
        
//        dismissViewControllerAnimated(true) {
//            if self.callStartedTime == 0 {
//                WBAppDelegate.xmpp.sendVideoCancel(self.partnerId)
//            }
//        }
    }
    
    @IBAction func swipeCameraTapped(sender: AnyObject) {
        
        guard !isVideoMute else { return }
        
        guard client != nil else { return  }
        
        self.switchCamera()
        
//        if isFront {
////            client!.swapCameraToBack()
//        } else {
////            client!.swapCameraToFront()
//        }
        
//        isFront = !isFront
    }
    
    // switch camera source
    func switchCamera() {
        
        guard localVideoTrack != nil else {
            return
        }
        
        let source = self.localVideoTrack!.source
        if source.isKindOfClass(RTCAVFoundationVideoSource) {
            let avSource = source as! RTCAVFoundationVideoSource
            avSource.useBackCamera = !avSource.useBackCamera
            self.localView.transform = avSource.useBackCamera ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(-1, 1)
        }
    }
    
    @IBAction func videoMuteTapped(sender: AnyObject) {
        
        guard !isVideoMute else { return }
        
        guard client != nil else { return }
        
        isVideoOff = !isVideoOff
        
        if isVideoOff {
            btnCameraControl.setImage(WBAsset.IconVideoOn.image, forState: .Normal)
            muteVideo(true)
        } else {
            btnCameraControl.setImage(WBAsset.IconVideoOff.image, forState: .Normal)
            muteVideo(false)
        }
    }
    
    func muteVideo(isMute: Bool) {
        
        localVideoTrack?.setEnabled(!isMute)
        remoteVideoTrack?.setEnabled(!isMute)
        
        maskView.hidden = !isMute
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func hideWiatingLabel() {
        
        UIView.animateWithDuration(0.3) {
            self.lblWaiting.alpha = 0
        }
    }
    
    func logCallDuration() {
        
        if callStartedTime == 0 {
            
            if isNoAnswer {
                WBAppDelegate.xmpp.sendVideoNoAnswer(self.partnerId)
            } else {
                WBAppDelegate.xmpp.sendVideoCancel(self.partnerId)
            }
        } else {
            let duration = NSDate.milliseconds - callStartedTime
            callStartedTime = 0
            
            if isCaller {
                WBAppDelegate.xmpp.logCall(partnerId, chatId: _user!._idx, message: Constants.CALL_DURATION + duration.duration(), time: NSDate.utcString())
            } else {
                WBAppDelegate.xmpp.logCall(partnerId, chatId: partnerId, message: Constants.CALL_DURATION + duration.duration(), time: NSDate.utcString())
            }
        }
    }
}

// MARK: - ARDAppClientDelegate
extension CallViewController: ARDAppClientDelegate {
    
    func appClient(client: ARDAppClient!, didChangeState state: ARDAppClientState) {
        
        switch state {
        case ARDAppClientState.Connected:
            
            debugPrint("Client Connected")
            
            NSTimer.after(1.minute) {
                
                if !self.isCallConnected {
                    //
                    self.isNoAnswer = true
                    self.disconnect()
                }
            }
            
            break
            
        case ARDAppClientState.Connecting:
//            debugPrint("Client Connecting")
            
            break
            
        case ARDAppClientState.Disconnected:
            
//            showToast("Client Disconnected.")
            AudioPlayInstance.stopPlayer()
            
            self.dismissViewControllerAnimated(true, completion: { 
                
                self.logCallDuration()
            })
            
            break
        }
    }
    
    func appClient(client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        
        if !videoEnable {
            localVideoTrack.setEnabled(false)
            return
        }
        if self.localVideoTrack != nil {
            self.localVideoTrack?.removeRenderer(self.localView)
            self.localVideoTrack = nil
        }
        
        self.localVideoTrack = localVideoTrack
        
        self.localVideoTrack!.addRenderer(localView)
    }
    
    func appClient(client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        
//        if callStartedTime == 0 {
//            hideWiatingLabel()
//            AudioPlayInstance.stopPlayer()
//            callStartedTime = NSDate.milliseconds
//        }
        
        if !videoEnable {
            remoteVideoTrack.setEnabled(false)
            return
        }
        
        guard remoteVideoTrack != nil else { return }
        
        self.remoteVideoTrack = remoteVideoTrack
        
        self.remoteVideoTrack?.addRenderer(remoteView)
        
        UIView.animateWithDuration(0.4) {
            
            // Instead of using 0.4 of screen size, we re-calculate the local view and keep out aspect ratio
            let orientation = UIDevice.currentDevice().orientation
            
            var videoRect = CGRectMake(0, 0, self.view.frame.size.width/4.0, self.view.frame.size.height/4.0)
            
            if (orientation == .LandscapeLeft || orientation == .LandscapeRight) {
                videoRect = CGRectMake(0, 0, self.view.frame.size.height/4.0, self.view.frame.size.width/4.0)
            }
            
            let videoFrame = AVMakeRectWithAspectRatioInsideRect(self.localView.frame.size, videoRect)
            
            self.localViewWidthConstraint.constant = videoFrame.size.width
            self.localViewHeightConstraint.constant = videoFrame.size.height
            
            self.localViewTopConstraint.constant = 54
            self.localViewLeftConstraint.constant = 10
            
            self.view.layoutIfNeeded()
        }
    }
    
    func appClient(client: ARDAppClient!, didError error: NSError!) {
        
        showToast(Constants.FAIL_TO_CONNECT)
        
        disconnect()
    }
    
    func appClient(client: ARDAppClient!, didChangeConnectionState state: RTCICEConnectionState) {
        
        switch state {
        // partner was connected to the room
        case RTCICEConnectionConnected:
            self.isCallConnected = true
            hideWiatingLabel()
            AudioPlayInstance.stopPlayer()
            callStartedTime = NSDate.milliseconds
            break
            
        default:
            break
        }
    }
}

// MARK: - RTCEAGLVideoViewDelegate
extension CallViewController: RTCEAGLVideoViewDelegate {
    
    func videoView(videoView: RTCEAGLVideoView!, didChangeVideoSize size: CGSize) {
        
//        let orientation = UIDevice.currentDevice().orientation
//        
//        UIView.animateWithDuration(0.4) { 
//            
//            let containerWidth = self.view.frame.size.width
//            let containerHeight = self.view.frame.size.height
//            
//            let defaultAspectRatio = CGSizeMake(16, 9)
//            
//            if videoView == self.localView {
//                
//                // Resize the Local View depending if it is full scree or thumbnail
//                self.localVideoSize = size
//                
//                let aspectRatio = CGSizeEqualToSize(size, CGSizeZero) ? defaultAspectRatio : size
//                
//                var videoRect = CGRectMake(0, 44, self.view.bounds.width, self.view.bounds.height)
//                
//                if self.remoteVideoTrack != nil {
//                    
//                    videoRect = CGRectMake(0, 0, self.view.frame.size.height/4.0, self.view.frame.size.width/4.0)
//                    
//                    if orientation == .LandscapeLeft || orientation == .LandscapeRight {
//                        
//                        videoRect = CGRectMake(0, 0, self.view.frame.size.height/4.0, self.view.frame.size.width/4.0)
//                    }
//                }
//                
//                let videoFrame = AVMakeRectWithAspectRatioInsideRect(aspectRatio, videoRect)
//                
//                // Resize the lovalView accordingly
//                self.localViewWidthConstraint.constant = videoFrame.size.width
//                self.localViewHeightConstraint.constant = videoFrame.size.height
//                
//                if self.remoteVideoTrack != nil {
//                
//                    self.localViewTopConstraint.constant = 54
//                    self.localViewLeftConstraint.constant = 10
//                    
//                } else {
//
//                    self.localViewTopConstraint.constant = 44
//                    self.localViewLeftConstraint.constant = 0
//                }
//                
//            } else if videoView == self.remoteView {
//                
////                // resize remote view
////                self.remoteVideoSize = size
////                
////                let aspectRadio = CGSizeEqualToSize(size, CGSizeZero) ? defaultAspectRatio : size
////                
////                let videoRect = self.view.bounds
////                var videoFrame = AVMakeRectWithAspectRatioInsideRect(aspectRadio, videoRect)
////                
////                if (self.isZoom) {
////                    
////                    // Set Aspect Fill
////                    let scale = max(containerWidth/videoFrame.size.width, containerHeight/videoFrame.size.height)
////                    videoFrame.size.width *= scale
////                    videoFrame.size.height *= scale
////                }
////                
////                self.remoteViewTopConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
////                self.remoteViewBottomConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
////                self.remoteViewLeftConstraint.constant = containerWidth/2.0 - videoFrame.size.width/2.0
////                self.remoteViewRightConstraint.constant = containerWidth/2.0 - videoFrame.size.width/2.0
//            }
//            
//            self.view.layoutIfNeeded()
//        }
    }
}

// MARK: - Call Message Delegate
extension CallViewController: CallMessageDelegate {
    
    func declineMessageReceived() {
        self.dismissViewControllerAnimated(true) { 
            WBAppDelegate.xmpp.logCall(self.partnerId, chatId: self.partnerId, message: Constants.CALL_DECLINED_BYOTHER, time: NSDate.utcString())
        }
    }
    
    func cancelMessageReceived() {
        
        self.dismissViewControllerAnimated(true) { 
            WBAppDelegate.xmpp.logCall(self.partnerId, chatId: self.partnerId, message: Constants.CALL_CANCELLED_BYOTHER, time: NSDate.utcString())
        }
    }
    
    func acceptMessageReceived() {
        
//        hideWiatingLabel()
//        AudioPlayInstance.stopPlayer()
//        callStartedTime = NSDate.milliseconds
    }
}

