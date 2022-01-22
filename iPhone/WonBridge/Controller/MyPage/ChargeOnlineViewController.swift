//
//  ChargeOnlineViewController.swift
//  WonBridge
//
//  Created by Tiia on 17/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class ChargeOnlineViewController: BaseTableViewController {
    
    var _user: UserEntity?
    
    // can be 0, 1, 2
    var expandedIndex = 0
    
    @IBOutlet weak var expandIcon1: UIImageView!
    @IBOutlet weak var expandIcon2: UIImageView!
    @IBOutlet weak var expandIcon3: UIImageView!
    var expandIcconArray = [UIImageView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _user = WBAppDelegate.me!

        // Do any additional setup after loading the view.
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        expandIcconArray.append(expandIcon1)
        expandIcconArray.append(expandIcon2)
        expandIcconArray.append(expandIcon3)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceivePaymentResult(_:)), name: "didReceivePaymentResult", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // sender tag - 200 ~ 203
    private let startExpandButtonTag = 200
    @IBAction func expandButtonTapped(sender: UIButton) {
        
        guard expandedIndex != sender.tag - startExpandButtonTag else { return }
        
        expandedIndex = sender.tag - startExpandButtonTag
        
        for iconImageView in expandIcconArray {
            iconImageView.image = WBAsset.Icon_Fold.image
        }
        expandIcconArray[expandedIndex].image = WBAsset.Icon_Opened.image
        
        self.tableView.reloadData()
    }
    
    private let startPayButtonTag = 300
    @IBAction func wechatPayTapped(sender: UIButton) {
        
        if WXApi.isWXAppSupportApi() {
            
            showLoadingViewWithTitle(Constants.GET_PREPAYID)
            
            let payResult = WXApiRequestHandler.jumpToBizPay(Constants.WECHAT_APP_ID, WXApiKey: Constants.WECHAT_SECRET, WXPartnerKey: Constants.WECHAT_MCH_ID)
            hideLoadingView()
            
            if payResult != "" {
                showAlert(Constants.APP_NAME, message: "Failed to Pay", positive: Constants.ALERT_OK, negative: nil)
            }
        } else {
            showAlert(Constants.APP_NAME, message: Constants.INSTALL_WECHAT, positive: Constants.ALERT_OK, negative: nil)
        }
    }
    
    // MARK: didReceivePaymentResult
    func didReceivePaymentResult(notification: NSNotification) {
        
        let userInfo = notification.userInfo! as NSDictionary
        let resultCode = userInfo.valueForKey("resultCode") as! Int
        
        if resultCode == 0 {
            
            showLoadingViewWithTitle("")
            WebService.setPayment(_user!._idx, amount: 20, completion: { (status) in
                
                self.hideLoadingView()
                if status {
                    self.showAlert(Constants.APP_NAME, message: "Success to pay.", positive: Constants.ALERT_OK, negative: nil)
                }
            })
            
        } else {
            
            //            showAlert(Constants.APP_NAME, message: "Failed to pay.", positive: Constants.ALERT_OK, negative: nil)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if expandedIndex == indexPath.section {
            if indexPath.row == 1 {
                return UITableViewAutomaticDimension
            } else {
                return 44
            }
        } else {
            if indexPath.row == 1 {
                return 0
            } else {
                return 44
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
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
      