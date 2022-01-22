//
//  VideoViewController.swift
//  WonBridge
//
//  Created by July on 2016-10-04.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class VideoViewController: BaseViewController {
    
    var videoUrl = ""
    private var player: Player?
    var isPlaying = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        player = Player()
        player!.delegate = self
        player!.view.frame = self.view.frame
        
        self.player!.setUrl(NSURL(string: videoUrl)!)
        self.player!.playbackLoops = true
        
        self.addChildViewController(self.player!)
        self.view.addSubview(self.player!.view)
        self.player!.didMoveToParentViewController(self)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.numberOfTapsRequired = 1
        self.player!.view.addGestureRecognizer(tap)
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
    
    func handleTap(gestureRecognizer: UITapGestureRecognizer) {        
        dismissViewControllerAnimated(true, completion: nil)
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

extension VideoViewController: PlayerDelegate {
    
    func playerReady(player: Player) {
        self.player!.playFromBeginning()
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
