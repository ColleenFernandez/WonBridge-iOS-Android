//
//  InputEmailViewController.swift
//  WonBridge
//
//  Created by Roch David on 07/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

private let kVerifyCodeLength = 6

class InputEmailViewController: BaseViewController {

    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtAuthCode: UITextField!
    
    @IBOutlet weak var btnNext: UIButton!
    
    // send verification code button
    @IBOutlet weak var btnSendCode: UIButton!
    
    var isVerified = false
    
    @IBOutlet weak var errorMsgLabel: UILabel!
    
    @IBOutlet weak var btnViewTopLayoutConstraint: NSLayoutConstraint!
    
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
        
        btnNext.layer.borderColor = UIColor(netHex: 0x5f99fb).CGColor
    }
    
    func showError(errorMsg: String) {
        
        errorMsgLabel.text = errorMsg
        btnViewTopLayoutConstraint.constant = 70
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
    
    // send email address for authentication
    @IBAction func resendTapped(sender: AnyObject) {
        
        if txtEmailAddress.text!.isEmpty {
            
            showError(Constants.INPUT_EMAIL)
            return
        }
        
        if !txtEmailAddress.text!.isValidEmailAddress() {
            showError(Constants.INPUT_RIGHT_EMAIL)
            return
        }
        
        self.view.endEditing(true)
        hideError()
        
        sendCode()
    }
    
    // verify authcode for going on signup progress
    @IBAction func confirmTapped(sender: AnyObject) {
        
        if !CommonUtils.isValidEmail(txtEmailAddress.text!) {
            showError(Constants.INPUT_EMAIL)
            return
        }
        
        if txtAuthCode.text!.isEmpty {
            showError(Constants.VERIFY_CODE)
            return
        }
        
        self.view.endEditing(true)
        hideError()
        
        verifyCode()
    }
    
    @IBAction func nextBtnTapped(sender: AnyObject) {
        
        if !isVerified {
            
            showAlert(Constants.APP_NAME, message: Constants.VERIFY_EMAIL, positive: Constants.ALERT_OK, negative: nil)
            
            return
        }
        
        // go to input profile
        performSegueWithIdentifier("SegueInputEmail2Profile", sender: self)
    }
    
    @IBAction func backTapped(sender: UIButton) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // send email address for authentication
    func sendCode() {
        
        let emailAddress = txtEmailAddress.text!
        
        showLoadingViewWithTitle("")
        
        WebService.getAuthCode(emailAddress) { (status, message) -> Void in
            
            self.hideLoadingView()
            
            if status {
            
                UIView.setAnimationsEnabled(false)
                self.btnSendCode.setTitle(Constants.RESEND_CODE, forState: UIControlState.Normal)
                UIView.setAnimationsEnabled(true)
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil, positiveAction: nil, negativeAction: nil, completion: nil)
            } else {
                if message == "" {
                    self.showError(Constants.EXIST_EMAIL)
                } else {
                    self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil, positiveAction: nil, negativeAction: nil, completion: nil)
                }
            }
        }
    }
    
    // verify code
    func verifyCode() {
        
        let emailAddress = txtEmailAddress.text!
        let code = txtAuthCode.text!
        
        showLoadingViewWithTitle("")
        
        WebService.verifyCode(emailAddress, code: code) { (status, message) in
            
            self.hideLoadingView()
            
            if status {
                
                self.isVerified = true
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
            } else {
                
                if message == "" {
                    self.showError(Constants.WRONG_CODE)
                } else {
                    self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil, positiveAction: nil, negativeAction: nil, completion: nil)
                }
            }
        }
    }

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SegueInputEmail2Profile" {
            
            let destVC = segue.destinationViewController as! InputProfileContainerViewController
            destVC.emailAddress = txtEmailAddress.text!
        }
    }
}

extension InputEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        self.hideError()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        guard textField == txtAuthCode else { return true }
        
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        
        return newLength <= kVerifyCodeLength
    }
}
