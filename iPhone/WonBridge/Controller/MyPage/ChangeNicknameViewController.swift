//
//  ChangeNicknameViewController.swift
//  WonBridge
//
//  Created by Tiia on 16/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import Material

class ChangeNicknameViewController: BaseViewController {
    
    // global user - me
    var _user: UserEntity?

    @IBOutlet weak var txfNickname: TextField!
    
    @IBOutlet weak var lblErrorMsg: UILabel!
    
    @IBOutlet weak var buttonContainerViewTopLayout: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me
        
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        
        txfNickname.textAlignment = .Center
        txfNickname.text = _user!._name
    }
    
    @IBAction func backBtnTapped(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func cancelBtnTapped(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func confirmBtnTapped(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if txfNickname.text!.characters.count < kNickNameMinLength {
            
            showError(Constants.INPUT_NICKNAME)
            
            return
        }
        
        hideError()
        
        showLoadingViewWithTitle("")
        
//        let nickname = txfNickname.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).encodeString()
        
        let nickname = txfNickname.text!.encodeString()
        
        WebService.changeNickname(_user!._idx, nickname: nickname!) { (status, message) in
            
            self.hideLoadingView()
            
            if status {
                
                if message == "" {
                    
                    self._user!._name = self.txfNickname.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    UserDefault.setString(Constants.pref_user_name, value: self._user!._name)                
                    self.performSegueWithIdentifier("SegueChangeNickName2MyPage", sender: self)
                    
                } else {
                    
                    self.showError(message)
                }                
                
            } else {
                
                self.showError(message)
            }
        }
    }
    
    @IBAction func deleteBtnTapped(sender: AnyObject) {
     
        txfNickname.text = ""
    }
    
    func showError(errorMsg: String) {
        
        lblErrorMsg.text = errorMsg
        
        buttonContainerViewTopLayout.constant = 55
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
        
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    
    func hideError() {
        
        buttonContainerViewTopLayout.constant = 20
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
            
            self.view.layoutIfNeeded()
            
            }, completion: nil)
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

extension ChangeNicknameViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        hideError()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        
        return newLength <= kNicknameMaxLength
    }
}


