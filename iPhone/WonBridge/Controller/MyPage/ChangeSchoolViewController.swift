//
//  ChangeSchoolViewController.swift
//  WonBridge
//
//  Created by Elite on 11/3/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

private let kMaxSchoolLength = 40

class ChangeSchoolViewController: BaseViewController {
    
    var school = ""
    
    @IBOutlet weak var schoolField: UITextField!
    
    @IBOutlet weak var lblErrorMsg: UILabel!
    
    @IBOutlet weak var buttonContainerViewTopLayout: NSLayoutConstraint!
    
    // global user - me
    var _user: UserEntity?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me!
        
        schoolField.delegate = self
        
        schoolField.textAlignment = .Center
        schoolField.text = _user!._school
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        schoolField.resignFirstResponder()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        
        schoolField.resignFirstResponder()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func confirmTapped(sender: AnyObject) {
        
        schoolField.resignFirstResponder()
        
        if schoolField.text!.isEmpty {
            
            showError("Please input valid school name.")
            return
        }
        
        hideError()
        
        showLoadingViewWithTitle("")
        
        WebService.setSchool(_user!._idx, name: schoolField.text!.trim().stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH)) { (status) in
            
            self.hideLoadingView()
            
            if status {
                
                self._user!._school = self.schoolField.text!.trim()
                self.school = self.schoolField.text!.trim()
                self.performSegueWithIdentifier("unwindSchoo2MyPage", sender: self)
                
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
    
    @IBAction func selectSchoolButtonTapped(sender: AnyObject) {
        
        schoolField.resignFirstResponder()
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let destVC = storyboard.instantiateViewControllerWithIdentifier("SelectSchoolViewController") as! SelectSchoolViewController
        destVC.from = FROM_CHANGESCHOOL
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    @IBAction func unwindToChangeSchool(segue: UIStoryboardSegue) {
        
        if segue.identifier == "unwind2ChangeSchool" {
            
            let selectSchoolVC = segue.sourceViewController as! SelectSchoolViewController
            school = selectSchoolVC.selectedSchool
            
            schoolField.text = school
        }
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

// MARK: @protocol UITextFieldDelegate
extension ChangeSchoolViewController: UITextFieldDelegate {
    
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
        
        return newLength <= kMaxSchoolLength
    }
}
