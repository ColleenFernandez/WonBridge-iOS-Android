//
//  ChangeGroupNameViewController.swift
//  WonBridge
//
//  Created by July on 2016-10-01.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class ChangeGroupNameViewController: BaseViewController {
    
    var oldName: String! = ""
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    
    var changeAction: ((newName: String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize code here
        
        inputTextField.text = oldName
        
//        inputTextField.becomeFirstResponder()
        keyboardControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func keyboardControl() {
       
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, name: UIKeyboardWillShowNotification, object: nil, handler: {
            
            [weak self] observer, notification in
            
            guard let strongSelf = self else { return }
            
            strongSelf.keyboardControl(notification, isShowing: true)
            })
        
        notificationCenter.addObserver(self, name: UIKeyboardDidShowNotification, object: nil, handler: {
            
            observer, notification in
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                
                _ = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            }
        })
        
        notificationCenter.addObserver(self, name: UIKeyboardWillHideNotification, object: nil, handler: {
            
            [weak self] observer, notification in
            
            guard let strongSelf = self else { return }
            
            strongSelf.keyboardControl(notification, isShowing: false)
            })
        
        notificationCenter.addObserver(self, name: UIKeyboardDidHideNotification, object: nil) { (observer, notification) in
        }
    }
    
    func keyboardControl(notification: NSNotification, isShowing: Bool) {
        
        var userInfo = notification.userInfo!
        let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.unsignedIntValue
        
        let options = UIViewAnimationOptions(rawValue: UInt(curve) << 16 | UIViewAnimationOptions.BeginFromCurrentState.rawValue)
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        let heightOffset = (keyboardRect.origin.y - self.view.bounds.size.height)/2.0
        centerConstraint.constant = heightOffset
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil) 
    }
    
    func showGroupNameEditView(sender: UIViewController, oldName: String, changeAction: ((newName: String) -> Void)?) {
        
        self.oldName = oldName
        self.changeAction = changeAction
        
        sender.presentViewController(self, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonTapped(sender: UIButton) {
    
        guard !inputTextField.text!.isEmpty else { return }
        
        let newName = inputTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        changeAction!(newName: newName!)
    }
    
    @IBAction func closeTapped(sender: AnyObject) {
        
        self.inputTextField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
