//
//  RecoverPwdViewController.swift
//  WonBridge
//
//  Created by July on 2016-09-29.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import Material

private let kErrorDeltaH: CGFloat = 40.0

class RecoverPwdViewController: BaseViewController {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var errorMsgLabel: UILabel!
    
    @IBOutlet weak var countryCodeView: UIView!
    @IBOutlet weak var countryButton: UIButton!
    
    @IBOutlet weak var errorLabelTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnViewTopLayoutConstraint: NSLayoutConstraint!
    
    var referbtnViewConstraint: CGFloat = 0
    var referErrorViewContratint: CGFloat = 0
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    var selectedCountry: CountryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryCodeView.hidden = true
        countryCodeView.alpha = 0.0
        confirmButton.hidden = true
        confirmButton.alpha = 0.0
        
        referbtnViewConstraint = btnViewTopLayoutConstraint.constant
        referErrorViewContratint = errorLabelTopLayoutConstraint.constant
        
        showError(Constants.SOCIAL_PASSWORD_WARNING)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showError(errorMsg: String) {
        
        var errorDeltaY: CGFloat = 0
        errorMsgLabel.text = errorMsg
        // counts label lines
        errorDeltaY = errorMsgLabel.lineCounts() == 1 ?  kErrorDeltaH : kErrorDeltaH + 20
        
        btnViewTopLayoutConstraint.constant = referbtnViewConstraint + errorDeltaY
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func hideError() {
       
        btnViewTopLayoutConstraint.constant = referbtnViewConstraint
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        inputTextField.resignFirstResponder()
        
        let code = inputTextField.text!
        
        if code.isValidEmailAddress() {
            sendCode(code, isEmail: true)
        } else if code.isValidPhoneNumber() {
            showPhoneView()
        } else {
            showError(Constants.INPUT_RIGHT_EMAIL_PHONE)
        }
    }
    
    @IBAction func confirmButtonTapped(sender: AnyObject) {
        
        inputTextField.resignFirstResponder()
        
        hideError()
        
        var code = "86"
        if selectedCountry != nil {
            code = selectedCountry!.code
        }
        
        let phone = code + inputTextField.text!
        sendCode(phone, isEmail: false)
    }
    
    func showPhoneView() {
        
        confirmButton.hidden = false
        countryCodeView.hidden = false
        
        referErrorViewContratint += kErrorDeltaH
        referbtnViewConstraint += kErrorDeltaH
        
        errorLabelTopLayoutConstraint.constant = referErrorViewContratint
        btnViewTopLayoutConstraint.constant = referbtnViewConstraint
        UIView.animateWithDuration(0.5, animations: {
            self.confirmButton.alpha = 1.0
            self.countryCodeView.alpha = 1.0
            
            self.sendButton.alpha = 0.0
            
            self.view.layoutIfNeeded()
            }) { (true) in
                self.sendButton.hidden = true
        }
    }
    
    func sendCode(code: String, isEmail: Bool) {
        
        showLoadingViewWithTitle("")
        
        WebService.sendCode(code) { (status, message) in
            
            self.hideLoadingView()
            
            if status {
                self.gotoRecoverConfirm(code, isEmail: isEmail)
            } else {
                guard message == "" else {
                    self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
                    return
                }
                self.showError(Constants.NOT_REGISTERED_USER)
            }
        }
    }
    
    func gotoRecoverConfirm(emailorPhone: String, isEmail: Bool) {
        
        var viewControllers = navigationController?.viewControllers
        viewControllers?.removeLast()

        let confirmVC = self.storyboard!.instantiateViewControllerWithIdentifier("RecoverConfirmViewController") as! RecoverConfirmViewController
        viewControllers?.append(confirmVC)
        
        if isEmail {
            confirmVC.emailAddress = emailorPhone
        } else {
            confirmVC.phoneNumber = emailorPhone
        }

        navigationController?.setViewControllers(viewControllers!, animated: true)
    }
    
    @IBAction func unwindFromCountrySelection(segue: UIStoryboardSegue) {
        
        if segue.identifier == "unwindToRecover" {
            
            let selectCountryVC = segue.sourceViewController as! SelectCountryViewController
            
            guard let _selectedCountry = selectCountryVC.selectedCountry else { return }
            
            self.selectedCountry = _selectedCountry
            
            UIView.setAnimationsEnabled(false)
            countryButton.setTitle(self.selectedCountry!.name, forState: .Normal)
            UIView.setAnimationsEnabled(true)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

     // MARK: - Navigation     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        if segue.identifier == "SegueRecoverPwd2SelectCountry" {
            let destVC = segue.destinationViewController as! SelectCountryViewController
            destVC.from = FROM_RECOVERPWD
        }
     }

}

// MARK: @protocol UITextFieldDelegate
extension RecoverPwdViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        hideError()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
