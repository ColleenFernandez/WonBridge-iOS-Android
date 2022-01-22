//
//  VideoPreviewController.swift
//  WonBridge
//
//  Created by July on 2016-10-04.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import Photos

protocol VideoSendDelegate: class {
    func videoSend(video: WBMediaModel)
}

class VideoPreviewController: BaseViewController {
    
    var video: WBMediaModel?
    private var player: Player?
    var isPlaying = false
    
    var videoSendDelegate: VideoSendDelegate?
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var playButton: UIButton!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        player = Player()
        player!.delegate = self
        player!.view.frame = self.view.frame
        
        self.addChildViewController(self.player!)
        self.view.addSubview(self.player!.view)
        self.player!.didMoveToParentViewController(self)
        
        guard video != nil else { return }
        
        guard video!.asset != nil  else { return }
        
        PHCachingImageManager().requestAVAssetForVideo(video!.asset!, options: nil) { (asset, audioMux, info) in
            
            let asset = asset as! AVURLAsset
            
            dispatch_async(dispatch_get_main_queue(), {
                self.player!.setUrl(asset.URL)
                self.player!.playbackLoops = true
            })
        }
        
        self.view.bringSubviewToFront(cancelButton)
        self.view.bringSubviewToFront(sendButton)
        self.view.bringSubviewToFront(playButton)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func playButttonTapped(sender: AnyObject) {
        self.player!.playFromBeginning()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        if self.isPlaying {
            self.player!.stop()
            self.player = nil
            self.isPlaying = false
        }
        
        dismissViewControllerAnimated(true) {
            if self.videoSendDelegate != nil && self.video != nil {
                self.videoSendDelegate!.videoSend(self.video!)
            }
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

extension VideoPreviewController: PlayerDelegate {
    
    func playerReady(player: Player) {
        
    }
    
    func playerPlaybackStateDidChange(player: Player) {
        
    }
    
    func playerBufferingStateDidChange(player: Player) {
        
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
        
    }
    
    func playerPlaybackDidEnd(player: Player) {
        
    }
    
    func playerCurrentTimeDidChange(player: Player) {
        
    }
}


