//
//  TUGSliderViewController.swift
//  WonBridge
//
//  Created by Tiia on 28/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

protocol StripTitleHideDelegate: class {
    
    func hideStripTitleOnNavBar()
}

protocol NearbyRefreshDelegate: class {
    
    // this will be called after user update their filter setting
    // or after user update their location
    func refreshNearby()
}

class TUGSliderViewController: ButtonBarPagerTabStripViewController, StripTitleHideDelegate {
    
    // global user - me
    var _user: UserEntity?
    
    var timeLineVC: TimeLineViewController!
    var userListVC: UserListViewController!
    var groupListVC: GroupListViewController!
   
    override func viewDidLoad() {
        
        // setup style before super view did load is excuted
        settings.style.buttonBarBackgroundColor = UIColor.clearColor()
        settings.style.selectedBarBackgroundColor = UIColor.whiteColor()
        settings.style.selectedBarHeight = 2.0
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me
        
        initView()
        
        // will be called automatically once user location updated
        getNearByUsers()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // show buttonBarView for sliding tab title bar
        self.buttonBarView.hidden = false
    }
    
    func initView() {
        
        var frame = buttonBarView.frame
        frame.origin.x = 20
        frame.size.width = self.view.frame.size.width - 100
        buttonBarView.frame = frame
        
        // remove button bar from superview
        buttonBarView.removeFromSuperview()
        
        navigationController?.navigationBar.addSubview(buttonBarView)
       
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor(white: 1, alpha: 0.6)
            newCell?.label.textColor = UIColor.whiteColor()
        }
    }

    // MARK: - PagerTabStripDataSource
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let storyboard = UIStoryboard(name: "TimeLine", bundle: nil)
        
        timeLineVC = storyboard.instantiateViewControllerWithIdentifier("TimeLineViewController") as! TimeLineViewController
        timeLineVC.stripDelegate = self
        timeLineVC.nearbyRefreshDelegate = self
        
        userListVC = storyboard.instantiateViewControllerWithIdentifier("UserListViewController") as! UserListViewController
        userListVC.stripDelegate = self
        
        groupListVC = storyboard.instantiateViewControllerWithIdentifier("GroupListViewController") as! GroupListViewController
        groupListVC.stripDelegate = self
        
        return [timeLineVC, userListVC, groupListVC]
    }
    
    override func configureCell(cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo, indexPath: NSIndexPath) {
        
        super.configureCell(cell, indicatorInfo: indicatorInfo, indexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
    }
    
    // setting button click event
    @IBAction func settingButtonTapped(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        
        let filterVC = storyboard.instantiateViewControllerWithIdentifier("FilterViewController") as! FilterViewController
        filterVC.modalTransitionStyle = .CoverVertical
        filterVC.modalPresentationStyle = .OverFullScreen
        
        filterVC.nearbyRefreshDelegate = self
        
        self.presentViewController(filterVC, animated: true, completion: nil)
    }
    
    //MARK: - StripTitleHideDelegate
    func hideStripTitleOnNavBar() {
        
        self.buttonBarView.hidden = true
    }
    
    func getNearByUsers() {
        
        guard let location = _user!.getUserLocation() else { return }
        
        let lat: Double = Double(location.latitude).format(".8")
        let long: Double = Double(location.longitude).format(".8")
        
        let distance = UserDefault.getInt(Constants.PREFKEY_DISTANCE, defaultValue: 10)
        let ageStart = UserDefault.getInt(Constants.PREFKEY_AGE_START, defaultValue: 1)
        let ageEnd = UserDefault.getInt(Constants.PREFKEY_AGE_END, defaultValue: 100)
        
        let sex = UserDefault.getInt(Constants.PREFKEY_SEX, defaultValue: 2)       // all (male, female)
        let lastLogin = UserDefault.getInt(Constants.PREFKEY_LASTLOGIN, defaultValue: 7)   // 7 days ago
        let relation = UserDefault.getInt(Constants.PREFKEY_RELATION, defaultValue: 0)     // all of users
        
        WebService.getNearbyUsers(_user!._idx, lat: lat, long: long, distance: distance, ageStart: ageStart, ageEnd: ageEnd, sex: sex, lastLogin: lastLogin, relation: relation, pageIndex: 1) { (status, message, nearbyUsers) in
            
            if (status) {
                // refresh all lists (timeline, userlist, goruplist depending on updated user's location)
                self.timeLineVC.refresh(nearbyUsers)
                self.userListVC.refresh(nearbyUsers)                
            } else {
                debugPrint("error to find nearby users")
            }
            
            self.groupListVC.refresh()
        }
    }
    
    @IBAction func unwindFromChatView(segue: UIStoryboardSegue) {
        
        guard segue.sourceViewController.isKindOfClass(ChatViewController) else { return }
        
//        dispatch_async(dispatch_get_main_queue(), {
//            self.tabBarController?.selectedIndex = 1
//        })
        
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

// MARK: - @delegate NearbyRefreshDelegate
extension TUGSliderViewController: NearbyRefreshDelegate {

    func refreshNearby() {
        // refresh nearby users
        // after then will udpate nearby groups, too
        getNearByUsers()
    }
}




