//
//  CustomAlertViewController.swift
//  WonBridge
//
//  Created by Tiia on 17/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class CustomAlertViewController: BaseViewController {
    
    var customTitle: String!
    var confirmButtonTitle: String!
    var cancelButtonTitle: String!
    
    var statusBarHidden: Bool = false
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var confirmAction: ((Void) -> Void)?
    var cancelAction: ((Void) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        lblTitle.text = customTitle
        confirmButton.setTitle(confirmButtonTitle, forState: .Normal)
        cancelButton.setTitle(cancelButtonTitle, forState: .Normal)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showCustomAlert(sender: UIViewController, title: String, positive: String, negative: String, positiveAction: (Void) -> Void, negativeAction: (Void) -> Void) {
        
        self.customTitle = title
        self.confirmButtonTitle = positive
        self.cancelButtonTitle = negative
        
        self.confirmAction = positiveAction
        self.cancelAction = negativeAction
    
        sender.presentViewController(self, animated: true, completion: nil)
    }
    
    @IBAction func confirmTapped(sender: UIButton) {
        
        dismissViewControllerAnimated(true) {
            guard self.confirmAction != nil else { return }
            self.confirmAction!()
        }
    }
    
    @IBAction func cancelTapped(sender: UIButton) {
     
        dismissViewControllerAnimated(true) {
            guard self.cancelAction != nil else { return }
            self.cancelAction!()
        }
    }
}


