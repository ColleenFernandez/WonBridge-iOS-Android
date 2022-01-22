//
//  ServiceViewController.swift
//  WonBridge
//
//  Created by Roch David on 15/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import MessageUI

class QAViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func callServiceCenter() {
        
        if CommonUtils.isCNLocale() {
            // call service center
            if let url = NSURL(string: "tel://\(SERVICE_PHONE_NUMBER)") {
                UIApplication.sharedApplication().openURL(url)
            }
        } else {
            showAlert(Constants.APP_NAME, message: Constants.NOT_USE_PHONE, positive: Constants.ALERT_OK, negative: nil)
        }
    }
    
    func sendEnail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([SERVICE_EMAIL_ADDRESS])
            mail.setMessageBody("", isHTML: true)
            presentViewController(mail, animated: true, completion: nil)
        } else {
            showToast("Please setup your email address.")
        }
    }
    
    func gotoOnlineChat() {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let onlineVC = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        onlineVC.hidesBottomBarWhenPushed = true
        onlineVC.isOnlineService = true
        
        navigationController?.pushViewController(onlineVC, animated: true)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 1 {
                callServiceCenter()
            } else if indexPath.row == 2 {
                sendEnail()
            } else if indexPath.row == 3 {
                gotoOnlineChat()
            }
            
        } else {
            // help center
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
}

// MARK: @protocol MFMailComposeViewControllerDelegate
extension QAViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

