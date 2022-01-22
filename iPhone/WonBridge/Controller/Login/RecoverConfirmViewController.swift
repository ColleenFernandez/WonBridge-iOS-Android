//
//  RecoverByPhoneViewController.swift
//  WonBridge
//
//  Created by July on 2016-09-29.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class RecoverConfirmViewController: BaseViewController {
    
    @IBOutlet weak var emailorPhoneField: UITextField!
    @IBOutlet weak var verifyCodeField: UITextField!
    
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var errorMsgLabel: UILabel!
    
    @IBOutlet weak var btnViewTopLayoutConstraint: NSLayoutConstraint!
    
    var emailAddress: String?
    var phoneNumber: String?
    var resendCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailorPhoneField.enabled = false
        
        guard emailAddress != nil || phoneNumber != nil else { return }
        
        resendCode = emailAddress != nil ? emailAddress! : phoneNumber!
        emailorPhoneField.text = emailAddress != nil ? emailAddress! : ("+" + resendCode)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func resendButtonTapped() {
        
        guard resendCode != "" else { return }
        
        hideError()
        
        showLoadingViewWithTitle("")
        
        WebService.sendCode(resendCode) { (status, message) in
            
            self.hideLoadingView()
            
            if (status) {
                
//                UIView.setAnimationsEnabled(false)
//                self.sendCodeButton.setTitle(Constants.RESEND_CODE, forState: UIControlState.Normal)
//                UIView.setAnimationsEnabled(true)
                
                self.showAlert(Constants.APP_NAME, message: Constants.CODE_SENT, positive: Constants.ALERT_OK, negative: nil)
            } else {
                
                if message == "" {
                    
                    self.showError(Constants.NOT_REGISTERED_USER)
                    
                } else {
                    self.showAlert(Constants.APP_NAME, message: Constants.FAIL_TO_CONNECT, positive: Constants.ALERT_OK, negative: nil)
                }
            }
        }
    }
    
    func showError(errorMsg: String) {
        
        errorMsgLabel.text = errorMsg
        btnViewTopLayoutConstraint.constant = 80
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func hideError() {
        
        btnViewTopLayoutConstraint.constant = 35
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    @IBAction func confirmButtonTapped() {
        
        self.view.endEditing(true)
        
        if verifyCodeField.text?.characters.count == 0 {
            
            showError(Constants.VERIFY_CODE)
            return
        }
        
        // verify code        
        let verifyCode = verifyCodeField.text!
        
        showLoadingViewWithTitle("")
        
        WebService.getTempPassword(resendCode, verifyCode: verifyCode) { (status, message) in
            
            self.hideLoadingView()
            
            if (status) {
                
                self.showPassword(message)
                
            } else {
                
                if message == "" {
                    self.showError(Constants.WRONG_CODE)
                } else {
                    self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
                }
            }
        }
    }
    
    func showPassword(tmpPwd: String) {
        
        let alertMsg = Constants.TEMP_PWD_PREFIX + "\"\(tmpPwd)\"" + Constants.TEMP_PWD_SUFFIX
        
        showAlert(Constants.APP_NAME, message: alertMsg, positive: Constants.ALERT_OK, negative: nil, positiveAction: { (positiveAciton) in
            self.navigationController?.popViewControllerAnimated(true)
            }, negativeAction: nil, completion: nil)
    }
    
    @IBAction func backButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
}

// MARK - @protocol UITextFieldDelegate
extension RecoverConfirmViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField == verifyCodeField {
            self.hideError()
        }
    }
}



