//
//  MyPageViewController.swift
//  WonBridge
//
//  Created by Roch David on 08/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class SignupCompleteViewController: BaseViewController {
    
    var user: UserEntity?
    
    @IBOutlet weak var imvProfile: UIImageView!

    @IBOutlet weak var lblEmailAddress: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblSex: UILabel!

    @IBOutlet weak var lblPassword: UILabel!
    
    @IBOutlet weak var lblCountry: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        user = WBAppDelegate.me
        
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.title = "注册会员"
     
        imvProfile.setImageWithUrl(NSURL(string: user!._photoUrl)!, placeHolderImage: UIImage(named: "img_user")!)
        
        if user!._email != "" {
            lblEmailAddress.text = user!._email
        } else if user!._phoneNumber != "" {
            lblEmailAddress.text = user!._phoneNumber
        } else if user!._wechatId != "" {
            lblEmailAddress.text = user!._wechatId.substringToIndex(user!._wechatId.startIndex.advancedBy(10)) + "***"
        } else if user!._qqId != "" {
            lblEmailAddress.text = user!._qqId.substringToIndex(user!._qqId.startIndex.advancedBy(10)) + "***"
        }
        
        lblName.text = user!._name
        lblSex.text = user!._gender == .MALE ? Constants.SEX_MALE : Constants.SEX_FEMALE
        
//        let countryName = user!._countryCode != "" ? CommonUtils.getDisplayCountryName(user!._countryCode) : CommonUtils.getDisplayCountryName()
        let countryName = CommonUtils.getDisplayCountryName()
        lblCountry.text = countryName
        
        // for a test
//        lblCountry.text = "China"
        var pwd = ""
        
        let pwdLength = user!._password.characters.count
        
        if pwdLength <= 4 {
            for _ in 0 ..< pwdLength {
                pwd += "*"
            }
        } else {
            pwd = (user!._password as NSString).substringToIndex(4)
            for _ in 0 ..< pwdLength - 4 {
                pwd += "*"
            }
        }
        
        lblPassword.text = pwd
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func confirmBtnTapped(sender: AnyObject) {        
        
        CommonUtils.setUserAutoLogin(true)
        
        user!.saveUserInfo()
        
        // go to login activity
        var viewControllers = self.navigationController?.viewControllers
        
        let loginVC = viewControllers![0] as! LoginViewController
        
        viewControllers?.removeAll()
        
        viewControllers?.append(loginVC)
        
        navigationController?.navigationBarHidden = true
        
        self.navigationController?.setViewControllers(viewControllers!, animated: false)
    }
    
    @IBAction func updateProfileTapped(sender: AnyObject) {
        
        showToast("coming soon")
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
