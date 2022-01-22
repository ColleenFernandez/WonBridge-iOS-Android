//
//  DepatureDetailViewController.swift
//  WonBridge
//
//  Created by Elite on 10/12/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class DepatureDetailViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()
    }
    
    func initView() {
        self.title = "重磅消息，新一一批澳洲打工工度假签证将于9⽉ 5⽇申请"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionButtonTapped(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let onlineVC = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        onlineVC.hidesBottomBarWhenPushed = true
        onlineVC.isOnlineService = true
        
        navigationController?.pushViewController(onlineVC, animated: true)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
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
