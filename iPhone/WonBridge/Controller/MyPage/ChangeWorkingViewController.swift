//
//  ChangeWorkingViewController.swift
//  WonBridge
//
//  Created by Elite on 11/3/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

private let kMaxWorkingLength = 40

class ChangeWorkingViewController: BaseViewController {
    
    var working = ""
    @IBOutlet weak var workingField: UITextField!
    
    @IBOutlet weak var lblErrorMsg: UILabel!
    
    @IBOutlet weak var buttonContainerViewTopLayout: NSLayoutConstraint!
    
    @IBOutlet weak var working1Button: UIButton! { didSet {
        working1Button.layer.cornerRadius = 4
        working1Button.layer.masksToBounds = true
        }}
    @IBOutlet weak var working2Button: UIButton! { didSet {
        working2Button.layer.cornerRadius = 4
        working2Button.layer.masksToBounds = true
        }}
    @IBOutlet weak var working3Button: UIButton! { didSet {
        working3Button.layer.cornerRadius = 4
        working3Button.layer.masksToBounds = true
        }}
    @IBOutlet weak var working4Button: UIButton! { didSet {
        working4Button.layer.cornerRadius = 4
        working4Button.layer.masksToBounds = true
        }}
    @IBOutlet weak var working5Button: UIButton! { didSet {
        working5Button.layer.cornerRadius = 4
        working5Button.layer.masksToBounds = true
        }}
    @IBOutlet weak var working6Button: UIButton! { didSet {
        working6Button.layer.cornerRadius = 4
        working6Button.layer.masksToBounds = true
        }}
    
    // global user - me
    var _user: UserEntity?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me!
        
        workingField.delegate = self
        
        workingField.textAlignment = .Center
        workingField.text = _user!._working
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func working1Tapped(sender: AnyObject) {
        workingField.text = "留学生"
    }
    
    @IBAction func working2Tapped(sender: AnyObject) {
        workingField.text = "移民中"
    }
    
    @IBAction func working3Tapped(sender: AnyObject) {
        workingField.text = "跨境游"
    }
    
    @IBAction func working4Tapped(sender: AnyObject) {
        workingField.text = "海外打工"
    }
    
    @IBAction func working5Tapped(sender: AnyObject) {
        workingField.text = "侨居父母"
    }
    
    @IBAction func working6Tapped(sender: AnyObject) {
        workingField.text = "跨境投资"
    }
    
    @IBAction func deleteTapped(sender: AnyObject) {
        
        workingField.text = ""
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        
        workingField.resignFirstResponder()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func backTapped(sender: AnyObject) {
        
        workingField.resignFirstResponder()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func confirmTapped(sender: AnyObject) {
        
        workingField.resignFirstResponder()
        
        if workingField.text!.isEmpty {
            
            showError("Please input valid occupation.")
            return
        }
        
        hideError()
        
        showLoadingViewWithTitle("")
        WebService.setWorking(_user!._idx, name: workingField.text!.trim().stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH)) { (status) in
            
            self.hideLoadingView()
            
            if status {
                
                self._user!._working = self.workingField.text!.trim()
                self.working = self.workingField.text!.trim()
                self.performSegueWithIdentifier("unwindWorking2MyPage", sender: self)
                
            } else {
                
                self.showAlert(Constants.APP_NAME, message: Constants.FAIL_TO_CONNECT, positive: Constants.ALERT_OK, negative: nil)
            }
        }
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


extension ChangeWorkingViewController: UITextFieldDelegate {
    
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
        return newLength <= kMaxWorkingLength
    }
}
