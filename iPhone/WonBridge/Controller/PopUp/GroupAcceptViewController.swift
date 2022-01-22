//
//  GroupAcceptViewController.swift
//  WonBridge
//
//  Created by Elite on 11/5/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class GroupAcceptViewController: BaseViewController {
    
    @IBOutlet weak var imvUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var txvContent: KMPlaceholderTextView!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    
    var confirmAction: ((Void) -> Void)?
    var cancelAction: ((Void) -> Void)?
    
    var request: GroupRequestEntity?
    var requestSize: Int = 0
    var requestIdx: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if request != nil {
            
            imvUser.sd_setImageWithURL(NSURL(string: request!.userPhoto), placeholderImage: WBAsset.UserPlaceHolder.image)
        
            lblUserName.text = request!.username
            if requestSize == 0 {
                lblCount.text = ""
            } else {
                lblCount.text = "\(requestIdx)/\(requestSize)"
            }
            txvContent.text = request!.content
        }
        
        txvContent.userInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true) {
            guard self.confirmAction != nil else { return }
            self.confirmAction!()
        }
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
       
        dismissViewControllerAnimated(true) {
            guard self.cancelAction != nil  else { return }
            self.cancelAction!()
        }
    }
    
    func showAcceptDialog(sender: UIViewController, request: GroupRequestEntity, requestIdx: Int,  requestSize: Int, confirmAciton: ((Void) -> Void)?, cancelAction: ((Void) -> Void)?) {
        
        self.request = request
        self.confirmAction = confirmAciton
        self.cancelAction = cancelAction
        self.requestSize = requestSize
        self.requestIdx = requestIdx
        
        sender.presentViewController(self, animated: true, completion: nil)
    }
    
    func showAcceptSingleDialog(sender: UIViewController, request:GroupRequestEntity, confirmAction: ((Void) -> Void)?, cancelAction: ((Void) -> Void)?) {
        
        self.request = request
        self.confirmAction = confirmAction
        self.cancelAction = cancelAction
        
        sender.presentViewController(self, animated: true, completion: nil)
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
