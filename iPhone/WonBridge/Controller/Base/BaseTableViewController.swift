//
//  BaseTableViewController.swift
//  WonBridge
//
//  Created by Roch David on 16/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import JLToast

class BaseTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped(_:)))
//        tap.numberOfTapsRequired = 1
//        tap.numberOfTouchesRequired = 1
//        self.tableView.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func tableViewTapped(sender: UITapGestureRecognizer) {
//        
//        self.view.endEditing(true)
//    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return .LightContent
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    override func shouldAutorotate() -> Bool {
        
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.Portrait
    }

    // show alert
    func showAlert(title: String!, message: String!, positive: String?, negative: String?, positiveAction: ((positiveAciton: UIAlertAction) -> Void)?, negativeAction: ((negativeAction: UIAlertAction) -> Void)?, completion:(() -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if (positive != nil) {
            
            alert.addAction(UIAlertAction(title: positive, style: .Default, handler: positiveAction))
        }
        
        if (negative != nil) {
            
            alert.addAction(UIAlertAction(title: negative, style: .Default, handler: negativeAction))
        }
        
        self.presentViewController(alert, animated: true, completion: completion)
    }
    
    func showAlert(title: String!, message: String!, positive: String?, negative: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if (positive != nil) {
            
            alert.addAction(UIAlertAction(title: positive, style: .Default, handler: nil))
        }
        
        if (negative != nil) {
            
            alert.addAction(UIAlertAction(title: negative, style: .Default, handler: nil))
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // show loading view
    func showLoadingViewWithTitle(title: String!) {
        
        WBProgressHUD.wb_showWithStatus(title)
    }
    
    // hide loading view
    func hideLoadingView() {
        
        WBProgressHUD.wb_dismiss()
    }
    
    // show toast message with duration
    func showToast(msg: String) {
        
        JLToast.makeText(msg, duration: TOAST_SHORT).show()
    }
}


