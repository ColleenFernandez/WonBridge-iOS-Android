//
//  SelectCountryViewController.swift
//  WonBridge
//
//  Created by July on 2016-09-29.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import SwiftyJSON

let FROM_INPUTPHONE =   "From_InputPhoneViewController"
let FROM_RECOVERPWD =   "From_RecoverPwdViewController"
let FROM_LOCATIONVC =   "From_LocationViewController"
let FROM_MYPROFILEVC =  "From_MyPageViewController"

class SelectCountryViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var from = ""
    
    var countries = [CountryModel]()
    
    @IBOutlet weak var listTableView: UITableView!
    
    var selectedCountry: CountryModel?
    
    let currentLocale = NSLocale.currentLocale()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if from == FROM_LOCATIONVC || from == FROM_MYPROFILEVC {
            navigationController?.navigationBarHidden = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if from == FROM_LOCATIONVC || from == FROM_MYPROFILEVC {
            navigationController?.navigationBarHidden = false
        }
    }
    
    func initData() {
        
        guard let JsonData = NSData.dataFromJSONFile("countries") else { return }
        
        let jsonObj = JSON(data: JsonData)
        
        guard let jsonArray = jsonObj.array else { return }        
        
        for index in 0 ..< jsonArray.count {
        
            let country = CountryModel()
            country.dialCode = jsonArray[index]["dial_code"].string!.stringByReplacingOccurrencesOfString("+", withString: "")
            let countryCode = jsonArray[index]["code"].string!
            country.code = countryCode
            country.name = currentLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
            
            countries.append(country)
        }
        
        listTableView.reloadData()
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return countries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CountryCell") as! CountryCell
        cell.setContent(countries[indexPath.row])        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedCountry = countries[indexPath.row]
        
        if from == FROM_RECOVERPWD {
            performSegueWithIdentifier("unwindToRecover", sender: self)
        } else if from == FROM_LOCATIONVC {
            performSegueWithIdentifier("unwind2LocationVC", sender: self)
        } else if from == FROM_MYPROFILEVC {
            
            showLoadingViewWithTitle("")
            WebService.setFavCountry(WBAppDelegate.me!._idx, name: selectedCountry!.code, completion: { (status) in
            
                self.hideLoadingView()
                if status {
                    
                    self.performSegueWithIdentifier("unwindCountry2MyProfile", sender: self)
                } else {
                    
                    self.showAlert(Constants.APP_NAME, message: Constants.FAIL_TO_CONNECT, positive: Constants.ALERT_OK, negative: nil)
                }
            })
            
        } else {
            performSegueWithIdentifier("unwind2InputPhone", sender: self)
        }
    }
}
