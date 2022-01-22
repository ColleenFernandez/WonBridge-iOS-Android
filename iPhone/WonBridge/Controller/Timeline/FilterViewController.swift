//
//  FilterViewController.swift
//  WonBridge
//
//  Created by Tiia on 17/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class FilterViewController: BaseViewController {
    
    @IBOutlet weak var distanceSlider: CustomSlider!
    @IBOutlet weak var lblFilterDistance: UILabel!
    
    @IBOutlet weak var ageSlider: RangeSlider!
    @IBOutlet weak var lblFilterAge: UILabel!
    
    weak var nearbyRefreshDelegate: NearbyRefreshDelegate?
    
    var arrSexBtn = [UIButton]()
    var arrRegTime = [UIButton]()
    var arrRelation = [UIButton]()
    
    @IBOutlet weak var btnSexAll: UIButton!
    
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var imvMale: UIImageView!        // icon_man_set
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var imvFemale: UIImageView!      // icon_woman_set
    
    @IBOutlet weak var btnCurrent: RoundButton!
    @IBOutlet weak var btnBefore1: RoundButton!
    @IBOutlet weak var btnBefore3: RoundButton!
    @IBOutlet weak var btnBefore7: RoundButton!
    
    @IBOutlet weak var btnRelTotal: UIButton!
    @IBOutlet weak var btnRelFriend: UIButton!

    var filterDistance: Int!        // default - 10
    var filterStartAge: Int!        // default - 1
    var filterEndAge: Int!          // default - 100
    var filterSex: Int!             // 0: man, 1: woman, 2: all (default - all: 2)
    var filterLastLogin: Int!       // 0: online, 1: 1 day ago, 3: 3 days ago, 7: 7 days ago (default - 7 days ago)
    var filterRelation: Int!        // 0: all, 1: friend ( default - all: 0)

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initData()
        
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initData() {
        
        arrSexBtn.append(btnMale)
        arrSexBtn.append(btnFemale)
        arrSexBtn.append(btnSexAll)
        
        arrRegTime.append(btnCurrent)
        arrRegTime.append(btnBefore1)
        arrRegTime.append(btnBefore3)
        arrRegTime.append(btnBefore7)
        
        arrRelation.append(btnRelTotal)
        arrRelation.append(btnRelFriend)
        
        filterDistance = UserDefault.getInt(Constants.PREFKEY_DISTANCE, defaultValue: 10)
        
        filterStartAge = UserDefault.getInt(Constants.PREFKEY_AGE_START, defaultValue: 1)
        filterEndAge = UserDefault.getInt(Constants.PREFKEY_AGE_END, defaultValue: 100)
        
        filterSex = UserDefault.getInt(Constants.PREFKEY_SEX, defaultValue: 2)
        
        filterLastLogin = UserDefault.getInt(Constants.PREFKEY_LASTLOGIN, defaultValue: 7)
        
        filterRelation = UserDefault.getInt(Constants.PREFKEY_RELATION, defaultValue: 0)
    }
    
    func initView() {
        
        distanceSlider.value = Float(filterDistance)
        
        lblFilterDistance.text = "\(filterDistance)km"
        
        ageSlider.lowerValue = Double(filterStartAge)
        ageSlider.upperValue = Double(filterEndAge)
        
        lblFilterAge.text = "\(filterStartAge)" + Constants.UNIT_AGE + "~" + "\(filterEndAge)" + Constants.UNIT_AGE
        
        updateSexSelection(filterSex)
        
        updateRelationSelection(filterRelation)
        
        var selectedIndex = 0
        if filterLastLogin != 0 {
            selectedIndex = filterLastLogin == 3 ? 2 : 3
        }
        
        updateLastRegTimeSelection(selectedIndex)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        ageSlider.updateLayerFrames()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        WBAppDelegate.presentVC = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        WBAppDelegate.presentVC = nil
    }
    
    @IBAction func selectSex(sender: AnyObject) {
        
        let selectedIndex = (sender as! UIButton).tag - 200
        
        filterSex = selectedIndex
        
        updateSexSelection(selectedIndex)
    }
    
    func updateSexSelection(selectedIndex: Int) {
        
        for index in 0 ..< arrSexBtn.count {
            
            if selectedIndex == index {
                
                arrSexBtn[index].backgroundColor = UIColor(netHex: 0x3366AD)
                arrSexBtn[index].setTitleColor(UIColor.whiteColor(), forState: .Normal)
                
                if index == 0 {
                    
                    lblMale.textColor = UIColor.whiteColor()
                    
                    imvMale.image = imvMale.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    imvMale.tintColor = UIColor.whiteColor()
                    
                } else if index == 1 {
                    
                    lblFemale.textColor = UIColor.whiteColor()
                    
                    imvFemale.image = imvFemale.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    imvFemale.tintColor = UIColor.whiteColor()
                }
                
            } else {
                
                arrSexBtn[index].backgroundColor = UIColor(netHex: 0xD1D1D1)
                arrSexBtn[index].setTitleColor(UIColor(netHex: 0xAAAAAA), forState: .Normal)
                
                if index == 0 {
                    
                    lblMale.textColor = UIColor(netHex: 0xAAAAAA)
                    
                    imvMale.image = imvMale.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    imvMale.tintColor = UIColor(netHex: 0xAAAAAA)
                    
                } else if index == 1 {
                    
                    lblFemale.textColor = UIColor(netHex: 0xAAAAAA)
                    
                    imvFemale.image = imvFemale.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    imvFemale.tintColor = UIColor(netHex: 0xAAAAAA)
                }
            }
        }
    }
    
    @IBAction func selectLastRegTime(sender: AnyObject) {
        
        let selectedIndex = (sender as! UIButton).tag - 210
        
        filterLastLogin = (selectedIndex == 0 ? selectedIndex : (Int(pow(Double(2), Double(selectedIndex))) - 1))
        
        updateLastRegTimeSelection(selectedIndex)
    }
    
    func updateLastRegTimeSelection(selectedIndex: Int) {
        
        for index in  0 ..< arrRegTime.count {
            
            if index ==  selectedIndex {
                
                arrRegTime[index].backgroundColor = UIColor(netHex: 0x3366AD)
                arrRegTime[index].setTitleColor(UIColor.whiteColor(), forState: .Normal)
                
            } else {
                
                arrRegTime[index].backgroundColor = UIColor(netHex: 0xD1D1D1)
                arrRegTime[index].setTitleColor(UIColor(netHex: 0xAAAAAA), forState: .Normal)
            }
        }
    }
    
    @IBAction func selectRelation(sender: AnyObject) {
        
        let selectedIndex = (sender as! UIButton).tag - 220
        
        filterRelation = selectedIndex
        
        updateRelationSelection(selectedIndex)
    }
    
    func updateRelationSelection(selectedIndex: Int) {
        
        for index in  0 ..< arrRelation.count {
            
            if index ==  selectedIndex {
                
                arrRelation[index].backgroundColor = UIColor(netHex: 0x3366AD)
                arrRelation[index].setTitleColor(UIColor.whiteColor(), forState: .Normal)
                
            } else {
                
                arrRelation[index].backgroundColor = UIColor(netHex: 0xD1D1D1)
                arrRelation[index].setTitleColor(UIColor(netHex: 0xAAAAAA), forState: .Normal)
            }
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
    
    @IBAction func cancelBtnTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func confirmBtnTapped(sender: AnyObject) {
        
        // save setting value        
        UserDefault.setInt(Constants.PREFKEY_DISTANCE, value: filterDistance)
        UserDefault.setInt(Constants.PREFKEY_AGE_START, value: filterStartAge)
        UserDefault.setInt(Constants.PREFKEY_AGE_END, value: filterEndAge)
        UserDefault.setInt(Constants.PREFKEY_SEX, value: filterSex)
        UserDefault.setInt(Constants.PREFKEY_LASTLOGIN, value: filterLastLogin)
        UserDefault.setInt(Constants.PREFKEY_RELATION, value: filterRelation)
        
        dismissViewControllerAnimated(true) {
            self.nearbyRefreshDelegate?.refreshNearby()
        }
    }
    
    @IBAction func filterDistanceChanged(sender: CustomSlider) {
        
        filterDistance = Int(sender.value)
        lblFilterDistance.text = "\(filterDistance)km"
    }

    @IBAction func filterAgeChanged(sender: RangeSlider) {
        
        filterStartAge = Int(sender.lowerValue)
        filterEndAge = Int(sender.upperValue)
        
        lblFilterAge.text = "\(filterStartAge)" + Constants.UNIT_AGE + "~" + "\(filterEndAge)" + Constants.UNIT_AGE
    }
}


