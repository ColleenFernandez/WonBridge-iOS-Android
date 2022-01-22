//
//  GroupRequestViewController.swift
//  WonBridge
//
//  Created by Elite on 11/4/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

private let kRequestMaxLength = 100

class GroupRequestViewController: BaseViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var msgView: KMPlaceholderTextView!
    
    var group: GroupEntity?
    
    var confirmAction: ((reqContent: String) -> Void)?
    var cancelAction: ((Void) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        msgView.placeholder = Constants.GROUP_REQUEST
        msgView.delegate = self
        
        if group != nil {
            lblTitle.text = "群组名称: " + group!.nickname
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        deregisterForKeyboardNotification()
    }
    
    func registerForKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterForKeyboardNotification() {
        
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillHideNotification)
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillShowNotification)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        
        let offsetY = keyboardRectangle.height / 2.0
        
        UIView.animateWithDuration(0.2) { () -> Void in
            
            var f = self.view.frame
            f.origin.y = -offsetY;
            self.view.frame = f;
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        UIView.animateWithDuration(0.2) { () -> Void in
            
            var f = self.view.frame
            f.origin.y = 0
            self.view.frame = f;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmTapped(sender: AnyObject) {
        
        msgView.resignFirstResponder()
        
        dismissViewControllerAnimated(true) {
            guard self.confirmAction != nil else { return }
            self.confirmAction!(reqContent: self.msgView.text)
        }
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        
        msgView.resignFirstResponder()
        
        dismissViewControllerAnimated(true) { 
            guard self.cancelAction != nil  else { return }
            self.cancelAction!()
        }
    }
    
    
    func showRequestDialog(sender: UIViewController, group: GroupEntity, confirmAction: ((reqContent: String) -> Void)?, cancelAction: ((Void) -> Void)) {
        
        self.group = group
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

extension GroupRequestViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        
        lblCounter.text = "\(kRequestMaxLength - textView.text.characters.count)"
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        guard let strText = textView.text else { return true }
        let newLength = strText.characters.count + text.characters.count - range.length
        
        return newLength <= kRequestMaxLength
    }
}
