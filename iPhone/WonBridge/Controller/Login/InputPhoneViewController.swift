//
//  InputPhoneViewController.swift
//  WonBridge
//
//  Created by July on 2016-09-29.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import SwiftyJSON

private let kVerifyCodeLength = 6

class InputPhoneViewController: BaseViewController {

    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var verifyCodeField: UITextField!
    
    @IBOutlet weak var countryButton: UIButton!
    
    var selectedCountry: CountryModel?
    
    var isVerified = false
    
    @IBOutlet weak var lblCountryCode: UILabel!
    
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var btnSendCode: UIButton!
    
    @IBOutlet weak var errorMsgLabel: UILabel! //35, 70
    
    @IBOutlet weak var btnViewTopLayoutConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    func initView() {
        
        var dialCode = "+86"
        let myCountryCode = CommonUtils.getCountryCode() as? String
        
        if myCountryCode != nil {
            guard let JsonData = NSData.dataFromJSONFile("countries") else { return }
            let jsonObj = JSON(data: JsonData)
            guard let jsonArray = jsonObj.array else { return }
            
            for index in 0 ..< jsonArray.count {
                let countryCode = jsonArray[index]["code"].string!
                if countryCode == myCountryCode! {
                    dialCode = jsonArray[index]["dial_code"].string!.stringByReplacingOccurrencesOfString(" ", withString: "")
                }
            }
        }
        
        let countryName = CommonUtils.getDisplayCountryName()
        lblCountryCode.text = "\(dialCode)"
        countryButton.setTitle(countryName, forState: .Normal)
        
        btnNext.layer.borderColor = UIColor(netHex: 0x5f99fb).CGColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        if phoneField.text!.isEmpty {
            showError(Constants.INPUT_PHONE)
            return
        }
        
        self.view.endEditing(true)
        
        let countryCode = lblCountryCode.text?.stringByReplacingOccurrencesOfString("+", withString: "")
        let phoneNumber = countryCode! + phoneField.text!
        
        showLoadingViewWithTitle("")
        
        WebService.getAuthCode(phoneNumber) { (status, message) in
            
            self.hideLoadingView()
            if status {
                UIView.setAnimationsEnabled(false)
                self.btnSendCode.setTitle(Constants.RESEND_CODE, forState: UIControlState.Normal)
                UIView.setAnimationsEnabled(true)
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil, positiveAction: nil, negativeAction: nil, completion: nil)
            } else {
                
                if message == "" {
                    self.showError(Constants.EXIST_PHONE)
                } else {
                    self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil, positiveAction: nil, negativeAction: nil, completion: nil)
                }
            }
        }
    }
    
    @IBAction func confirmButtonTapped(sender: AnyObject) {
        if phoneField.text!.isEmpty {
            showError(Constants.INPUT_PHONE)
            return
        }
        
        if verifyCodeField.text!.isEmpty {
            showError(Constants.VERIFY_CODE)
            return
        }
        
        hideError()
        self.view.endEditing(false)
        
        let countryCode = lblCountryCode.text?.stringByReplacingOccurrencesOfString("+", withString: "")
        let phoneNumber = countryCode! + phoneField.text!
        let verifyCode = verifyCodeField.text!
        
        showLoadingViewWithTitle("")
        
        WebService.verifyCode(phoneNumber, code: verifyCode) { (status, message) in
            self.hideLoadingView()
            
            if status {
                self.isVerified = true
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
            } else {
                if message == "" {
                    self.showError(Constants.WRONG_CODE)
                } else {
                    self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
                }
            }
        }
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        
        if !isVerified {
            showAlert(Constants.APP_NAME, message: Constants.VERIFY_EMAIL, positive: Constants.ALERT_OK, negative: nil)
            return
        }
        
        // go to input profile
        performSegueWithIdentifier("SegueInputPhone2Profile", sender: self)
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
    
    @IBAction func unwindToInputPhone(segue: UIStoryboardSegue) {
        
        if segue.identifier == "unwind2InputPhone" {
            
            let selectCountryVC = segue.sourceViewController as! SelectCountryViewController
            
            guard let _selectedCountry = selectCountryVC.selectedCountry else { return }
            
            self.selectedCountry = _selectedCountry
            
            UIView.setAnimationsEnabled(false)
            countryButton.setTitle(self.selectedCountry!.name, forState: .Normal)
            lblCountryCode.text = "+" + self.selectedCountry!.dialCode
            UIView.setAnimationsEnabled(true)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SegueInputPhone2SelectCountry" {
            let destVC = segue.destinationViewController as! SelectCountryViewController
            destVC.from = FROM_INPUTPHONE
        } else if segue.identifier == "SegueInputPhone2Profile" {
            let destVC = segue.destinationViewController as! InputProfileContainerViewController
            destVC.phoneNumber = lblCountryCode.text!.stringByReplacingOccurrencesOfString("+", withString: "") + phoneField.text!
        }
    }
}

// MARK: - @protocol UITextField Delegate
extension InputPhoneViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        self.hideError()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        guard textField == verifyCodeField else { return true }
        
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        
        return newLength <= kVerifyCodeLength
    }
}





