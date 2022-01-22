//
//  ChangeInterestViewController.swift
//  WonBridge
//
//  Created by Elite on 11/3/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

private let kMaxInterestLength = 40

class ChangeInterestViewController: BaseViewController {
    
    var interest = ""
    @IBOutlet weak var interestField: UITextField!
    
    @IBOutlet weak var lblErrorMsg: UILabel!
    
    @IBOutlet weak var buttonContainerViewTopLayout: NSLayoutConstraint!
    
    @IBOutlet weak var interest1Button: UIButton! { didSet {
        interest1Button.layer.cornerRadius = 4
        interest1Button.layer.masksToBounds = true
        }}
    @IBOutlet weak var interest2Button: UIButton! { didSet {
        interest2Button.layer.cornerRadius = 4
        interest2Button.layer.masksToBounds = true
        }}
    @IBOutlet weak var interest3Button: UIButton! { didSet {
        interest3Button.layer.cornerRadius = 4
        interest3Button.layer.masksToBounds = true
        }}
    @IBOutlet weak var interest4Button: UIButton! { didSet {
        interest4Button.layer.cornerRadius = 4
        interest4Button.layer.masksToBounds = true
        }}
    @IBOutlet weak var interest5Button: UIButton! { didSet {
        interest5Button.layer.cornerRadius = 4
        interest5Button.layer.masksToBounds = true
        }}
    @IBOutlet weak var interest6Button: UIButton! { didSet {
        interest6Button.layer.cornerRadius = 4
        interest6Button.layer.masksToBounds = true
        }}
    
    // global user - me
    var _user: UserEntity?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me!
        
        interestField.delegate = self
        
        interestField.textAlignment = .Center
        interestField.text = _user!._interest
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func interest1Tapped(sender: AnyObject) {
        interestField.text = "K歌舞蹈"
    }
    
    @IBAction func interest2Tapped(sender: AnyObject) {
        interestField.text = "户外运动"
    }
    
    @IBAction func interest3Tapped(sender: AnyObject) {
        interestField.text = "文化创作"
    }
    
    @IBAction func interest4Tapped(sender: AnyObject) {
        interestField.text = "棋牌娱乐"
    }
    
    @IBAction func interest5Tapped(sender: AnyObject) {
        interestField.text = "品酒美食"
    }
    
    @IBAction func interest6Tapped(sender: AnyObject) {
        interestField.text = "专业策划"
    }
    
    @IBAction func deleteTapped(sender: AnyObject) {
        
        interestField.text = ""
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        
        interestField.resignFirstResponder()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func backTapped(sender: AnyObject) {
        
        interestField.resignFirstResponder()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func confirmTapped(sender: AnyObject) {
        
        interestField.resignFirstResponder()
        
        if interestField.text!.isEmpty {
            
            showError("Please input valid interest.")
            return
        }
        
        hideError()
        
        showLoadingViewWithTitle("")
        WebService.setInterest(_user!._idx, name: interestField.text!.trim().stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH)) { (status) in
            
            self.hideLoadingView()
            
            if status {
                
                self._user!._interest = self.interestField.text!.trim()
                self.interest = self.interestField.text!.trim()
                self.performSegueWithIdentifier("unwindInterest2MyPage", sender: self)
                
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

extension ChangeInterestViewController: UITextFieldDelegate {
    
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
        return newLength <= kMaxInterestLength
    }
}
