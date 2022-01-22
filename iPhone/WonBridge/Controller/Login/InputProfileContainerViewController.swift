//
//  ImportProfileContainerViewController.swift
//  WonBridge
//
//  Created by Roch David on 07/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class InputProfileContainerViewController: BaseViewController {
    
    var emailAddress: String? = nil
    var phoneNumber: String? = nil
    var wechatId: String? = nil
    var qqId: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func gotoLocationVC() {
        
        self.performSegueWithIdentifier("SegueProfile2Location", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SegueEmbedProfile" {
            
            let profileVC = segue.destinationViewController as! InputProfileViewController
            
            profileVC.rootVC = self
            profileVC.emailAddress = self.emailAddress
            profileVC.phoneNumber = self.phoneNumber
            profileVC.wechatId = self.wechatId
            profileVC.qqId = self.qqId
        }
    }
}
