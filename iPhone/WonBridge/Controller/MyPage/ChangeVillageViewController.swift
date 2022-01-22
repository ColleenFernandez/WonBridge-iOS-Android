//
//  ChangeVillageViewController.swift
//  WonBridge
//
//  Created by Elite on 11/3/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

private let kMaxVillageLength = 40

class ChangeVillageViewController: BaseViewController {
    
    var village = ""
    
    @IBOutlet weak var vaillageField: UITextField!
    
    @IBOutlet weak var lblErrorMsg: UILabel!
    
    @IBOutlet weak var buttonContainerViewTopLayout: NSLayoutConstraint!
    
    // global user - me
    var _user: UserEntity?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me!
        
        vaillageField.delegate = self
        
        vaillageField.textAlignment = .Center
        vaillageField.text = _user!._village
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        vaillageField.resignFirstResponder()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        
        vaillageField.resignFirstResponder()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func confirmTapped(sender: AnyObject) {
        
        vaillageField.resignFirstResponder()
        
        if vaillageField.text!.isEmpty {
            
            showError("Please input valid vaillage name.")
            return
        }
        
        hideError()
        
        showLoadingViewWithTitle("")
        
        WebService.setVillage(_user!._idx, name: vaillageField.text!.trim().stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH)) { (status) in
            
            self.hideLoadingView()
            
            if status {
                
                self._user!._village = self.vaillageField.text!.trim()
                self.village = self.vaillageField.text!.trim()
                self.performSegueWithIdentifier("unwindVailllage2MyPage", sender: self)
                
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
    
    @IBAction func selectVillageButtonTapped(sender: AnyObject) {
        
        vaillageField.resignFirstResponder()
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let destVC = storyboard.instantiateViewControllerWithIdentifier("SelectVillageViewController") as! SelectVillageViewController
        destVC.from = FROM_CHANGEVILLAGE
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    @IBAction func unwindToChangeVillage(segue: UIStoryboardSegue) {
        
        if segue.identifier == "unwind2ChangeVillage" {
            
            let sourceVC = segue.sourceViewController as! SelectVillageViewController
            village = sourceVC.selectedProvince + " " + sourceVC.selectedCity
            
            vaillageField.text = village
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
extension ChangeVillageViewController: UITextFieldDelegate {
    
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
        return newLength <= kMaxVillageLength
    }
}
