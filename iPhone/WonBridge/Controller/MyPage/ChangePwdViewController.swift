//
//  ChangePwdViewController.swift
//  WonBridge
//
//  Created by Tiia on 16/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import Material

class ChangePwdViewController: BaseViewController {
    
    // global user - me
    var _user: UserEntity?
    
    @IBOutlet weak var currentPasswordField: TextField!
    
    @IBOutlet weak var newPasswordField: TextField!
    
    @IBOutlet weak var confirmPasswordField: TextField!
    
    @IBOutlet weak var btnContainerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var errorMsgLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me
        
        currentPasswordField.textAlignment = .Center
        newPasswordField.textAlignment = .Center
        confirmPasswordField.textAlignment = .Center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func confirmBtnTapped(sender: AnyObject) {
        
        if (checkValid()) {
        
            let currentPassword = currentPasswordField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).encodeString()
            
            let newPassword = newPasswordField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).encodeString()
            
            showLoadingViewWithTitle("")
            
            WebService.changePassword(_user!._idx, currentPwd: currentPassword!, newPwd: newPassword!, completion: { (status, message) in
                
                self.hideLoadingView()
                
                if status {
                    
                    if message == "" {
                        self._user!._password = self.currentPasswordField.text!
                        UserDefault.setString(Constants.pref_user_passsowrd, value: self._user!._password)
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        
                        self.showError(message)
                    }
                    
                } else {
                    
                    self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
                }
            })
        }
    }
    
    @IBAction func cancelBtnTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func checkValid() -> Bool {
        
        if currentPasswordField.text!.characters.count < 4 || newPasswordField.text!.characters.count < 4 {
            
            showError(Constants.INPUT_PASSWORD)
            
            return false
            
        } else if newPasswordField.text != confirmPasswordField.text {
            
            showError(Constants.CONFIRM_PASSWORDERROR)
            
            return false
        }
        
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showError(errorMsg: String) {
        
        errorMsgLabel.text = errorMsg
        
        btnContainerTopConstraint.constant = 55
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
            
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    
    func hideError() {
        
        btnContainerTopConstraint.constant = 20
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
            
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }

}

extension ChangePwdViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        hideError()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        
        if textField == currentPasswordField {
            
            newPasswordField.becomeFirstResponder()
        } else if (textField == newPasswordField) {
            
            confirmPasswordField.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        
        return newLength <= kNicknameMaxLength
    }
}


