//
//  SetupViewController.swift
//  WonBridge
//
//  Created by Roch David on 15/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class SettingViewController: BaseTableViewController {
    
    var _user: UserEntity?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _user = WBAppDelegate.me

        // Do any additional setup after loading the view.
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signoutButtonTapped(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertViewController") as! CustomAlertViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        customAlert.statusBarHidden = prefersStatusBarHidden()
        
        customAlert.showCustomAlert(self, title: Constants.TITLE_LOGOUT, positive: Constants.ALERT_OK, negative: Constants.ALERT_CANCEL, positiveAction: {
            
            self.logout()
            
        }) {}
    }
    
    func logout() {
        
        showLoadingViewWithTitle("")
        
        WebService.logout(_user!._idx) { (status) in
            
            self.hideLoadingView()
            if status {
               
                CommonUtils.setUserAutoLogin(false)
                WBAppDelegate.xmpp.disconnect ()
            
//                WBAppDelegate.me = UserEntity()
//                WBAppDelegate.me.loadUserInfo()
                
                WBAppDelegate.me!.clear()
                
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let loginNAV = storyboard.instantiateViewControllerWithIdentifier("LoginNAV") as! NavigationController
                UIApplication.sharedApplication().keyWindow?.rootViewController = loginNAV
                
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                
            } else {
                
                self.showAlert(Constants.APP_NAME, message: Constants.FAIL_TO_CONNECT, positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
    
    @IBAction func backButtonTapped(sender: UIBarButtonItem) {
        
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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if CommonUtils.isSocialLogin {
            if section == 0 {
                return 0
            } else {
                return super.tableView(tableView, heightForFooterInSection: section)
            }
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if CommonUtils.isSocialLogin {
            if indexPath.section == 0 && indexPath.row == 0 {
                return 0
            } else {
                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            }
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
}

