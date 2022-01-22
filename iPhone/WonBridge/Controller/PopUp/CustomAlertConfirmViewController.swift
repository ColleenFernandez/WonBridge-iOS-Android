//
//  CustomAlertConfirmViewController.swift
//  WonBridge
//
//  Created by July on 2016-10-02.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class CustomAlertConfirmViewController: BaseViewController {

    var customTitle: String!
    var confirmButtonTitle: String!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var statusBarHidden: Bool = false
    
    var confirmAction: ((Void) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        
        return statusBarHidden
    }
    
    func initView() {
        lblTitle.text = customTitle
        confirmButton.setTitle(confirmButtonTitle, forState: .Normal)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func showCustomAlert(sender: UIViewController, title: String, positive: String, positiveAction: (Void) -> Void) {
        
        self.customTitle = title
        self.confirmButtonTitle = positive
        self.confirmAction = positiveAction
        
        sender.presentViewController(self, animated: true, completion: nil)
    }
    
    @IBAction func confirmTapped(sender: UIButton) {
        
        guard confirmAction != nil else { return }
        confirmAction!()
    }
}
