//
//  LocationViewController.swift
//  WonBridge
//
//  Created by Roch David on 07/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class LocationViewController: BaseTableViewController {
    
    @IBOutlet weak var countryButton: UIButton!
    
    @IBOutlet weak var schoolField: UITextField!
    @IBOutlet weak var hometownField: UITextField!
    @IBOutlet weak var favCountryField: UITextField! { didSet {
        favCountryField.userInteractionEnabled = false
        }}
    @IBOutlet weak var occupationField: UITextField!
    @IBOutlet weak var interestField: UITextField!
    
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
    
    var selectedCountry: CountryModel?
    
    var _user: UserEntity? = WBAppDelegate.me!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }
    
    func initView() {
        
//        let countryName = CommonUtils.getDisplayCountryName()
//        if countryName != nil {
//            countryButton.setTitle(countryName, forState: .Normal)
//        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.tableView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = false
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.title = "找回账户信息"
    }
    
    func tableViewTapped(sender: UITapGestureRecognizer) {

        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmButtonTapped(sender: AnyObject) {
        
        setCountryCode()
    }
    
    @IBAction func skipButtonTapped(sender: AnyObject) {
       
        setCountryCode()
    }    

    @IBAction func otherSelectionBtnTapped(sender: AnyObject) {
        
        showToast("coming soon")
    }
    
    func setCountryCode() {
        
        self.showLoadingViewWithTitle("")
        
        let countryCode = CommonUtils.getCountryCode() as? String
        guard countryCode != nil else {
//            self.gotoMyPage()
            self.setSchool()
            return
        }
        
        WebService.setCountryCode(_user!._idx, countryCode: countryCode!) { (status, message) in
            if status {
//                print("You did set your country.")
            }
//            self.gotoMyPage()
            
            self.setSchool()
        }
    }
    
    func setSchool() {
        
        if schoolField.text!.isEmpty {
            
            setVillage()
            return
        }
        
        WebService.setSchool(_user!._idx, name:schoolField.text!.trim().stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH)) { (status) in
            
            self.setVillage()
        }
    }
    
    func setVillage() {
        
        if hometownField.text!.isEmpty {
            
            setFavCountry()
            return
        }
        
        WebService.setVillage(_user!._idx, name: hometownField.text!.trim().stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH)) { (status) in
            self.setFavCountry()
        }
    }
    
    func setFavCountry() {
        
        if favCountryField.text!.isEmpty {
            setWorking()
            return
        }
        
        WebService.setFavCountry(_user!._idx, name: selectedCountry!.code) { (status) in
            self.setWorking()
        }
    }
    
    func setWorking() {
        
        if occupationField.text!.isEmpty {
            setInterest()
            return
        }
        
        WebService.setWorking(_user!._idx, name: occupationField.text!.trim().stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH)) { (status) in
            self.setInterest()
        }
    }
    
    func setInterest() {
        
        if interestField.text!.isEmpty {
            
            hideLoadingView()
            gotoMyPage()
            return
        }
        
        WebService.setInterest(_user!._idx, name: interestField.text!.trim().stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH)) { (status) in
            
            self.hideLoadingView()
            self.gotoMyPage()
        }
    }
    
    @IBAction func working1Tapped(sender: AnyObject) {
        occupationField.text = "留学生"
    }
    
    @IBAction func working2Tapped(sender: AnyObject) {
        occupationField.text = "移民中"
    }
    
    @IBAction func working3Tapped(sender: AnyObject) {
        occupationField.text = "跨境游"
    }
    
    @IBAction func working4Tapped(sender: AnyObject) {
        occupationField.text = "海外打工"
    }
    
    @IBAction func working5Tapped(sender: AnyObject) {
        occupationField.text = "侨居父母"
    }
    
    @IBAction func working6Tapped(sender: AnyObject) {
        occupationField.text = "跨境投资"
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

    
    func gotoMyPage() {
        
        performSegueWithIdentifier("SegueLocation2MyPage", sender: self)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func unwindToLocationVC(segue: UIStoryboardSegue) {
        
        if segue.identifier == "unwindSchool2Locaiton" {
            
            let schoolVC = segue.sourceViewController as! SelectSchoolViewController
            
            guard schoolVC.selectedSchool != "" else { return }
            
            schoolField.text = schoolVC.selectedSchool
            
        } else if segue.identifier == "unwind2LocationVC" {
            let selectedCountryVC = segue.sourceViewController as! SelectCountryViewController
            
            selectedCountry = selectedCountryVC.selectedCountry
            
            guard selectedCountry != nil else { return }
            
            favCountryField.text = selectedCountry!.name
            
        } else if segue.identifier == "unwindVilllage2Location" {
            
            let selectVillageVC = segue.sourceViewController as! SelectVillageViewController
            hometownField.text = selectVillageVC.selectedProvince + " " + selectVillageVC.selectedCity
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "segueLocation2Country" {
            let selectCountryVC = segue.destinationViewController as! SelectCountryViewController
            selectCountryVC.from = FROM_LOCATIONVC
        }
    }
    

}
