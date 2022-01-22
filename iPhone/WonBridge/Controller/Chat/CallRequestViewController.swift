//
//  MediaRequestViewController.swift
//  WonBridge
//
//  Created by Roch David on 14/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import AVFoundation

class CallRequestViewController: BaseViewController {
    
    var callerId: Int! = 0
    var callerName: String! = ""
    var rooomId: String! = ""
    var videoEnable: Bool! = true
    
    
    @IBOutlet weak var lblNavTitle: UILabel!
    
    @IBOutlet weak var lblCallerName: UILabel!

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()
        
        WBAppDelegate.xmpp._callMsgDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioPlayInstance.playSoundWithType(.Ring_2)
    }
    
    func initView() {
        
        lblNavTitle.text = callerName
        lblCallerName.text = callerName
    }
    
    @IBAction func acceptButtonTapped(sender: AnyObject) {
        
        AudioPlayInstance.stopPlayer()
        
        // TODO send accept message
        CommonUtils.checkPermission(AVMediaTypeVideo) { (granted) in
            
            if granted {
                
                CommonUtils.checkPermission(AVMediaTypeAudio, completion: { (granted) in
                    
                    if granted {                        
                        // do process for video calling
                        self.dismissViewControllerAnimated(true, completion: {
                            WBAppDelegate.gotoCallVC(self.rooomId, partnerName: self.callerName, partnerId: self.callerId, videoEnable: self.videoEnable, isSender: false)
                        })
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
    
    @IBAction func declineButtonTapped(sender: AnyObject) {
        // TODO send decline message
        
        AudioPlayInstance.stopPlayer()
        
        self.dismissViewControllerAnimated(true) { 
        
            WBAppDelegate.xmpp.sendVideoDecline(self.callerId)
        }
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

// MARK: @protocol CancelMessageDelegate
extension  CallRequestViewController: CallMessageDelegate {
    
    func cancelMessageReceived() {
        
        AudioPlayInstance.stopPlayer()
        
        self.dismissViewControllerAnimated(true) {
            WBAppDelegate.xmpp.logCall(self.callerId, chatId: self.callerId, message: Constants.CALL_CANCELLED_BYOTHER, time: NSDate.utcString())
        }
    }
}

