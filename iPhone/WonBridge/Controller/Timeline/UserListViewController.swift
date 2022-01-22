//
//  UserlistViewController.swift
//  WonBridge
//
//  Created by Saville Briard on 22/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

// Nearby UserListViewController
class UserListViewController: BaseViewController {
    
    var itemInfo = IndicatorInfo(title: Constants.SLIDE_USER)
    
    weak var stripDelegate: StripTitleHideDelegate?
    
    // global user - me
    var _user: UserEntity?
    
    // nearby users
    var _nearbyUsers = [FriendEntity]()
    
    // refresh control
    var upperRefreshControl = UIRefreshControl()
    var bottomRefreshControl = UIRefreshControl()
    var pageIndex = 1
    
    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        _user = WBAppDelegate.me
        
        initView()
    }
    
    func initView() {
        
        // add pull to refresh on UICollectionView
        upperRefreshControl.tintColor = UIColor(netHex: 0x3366AD)
        upperRefreshControl.addTarget(self, action: #selector(refreshNearbyUsers(_:)), forControlEvents: .ValueChanged)
        listTableView.addSubview(upperRefreshControl)
        
        // add bottom refresh control on UITableView
        bottomRefreshControl.triggerVerticalOffset = 90
        bottomRefreshControl.tintColor = UIColor(netHex: 0x3366AD)
        bottomRefreshControl.addTarget(self, action: #selector(refreshNearbyUsers(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        listTableView.bottomRefreshControl = bottomRefreshControl
        listTableView.rowHeight = 70
        listTableView.tableFooterView = UIView()
    }
    
    func refreshNearbyUsers(sender: UIRefreshControl) {
        
        if sender == upperRefreshControl {
            getNearbyUsers(true)
        } else {
            getNearbyUsers(false)
        }
    }
    
    // this will be called after filter was changed (location, intereting filter such as filter, distance, age, last logged in, etc)
    func refresh(nearbyUsers: [FriendEntity]) {
        
        self._nearbyUsers.removeAll()
        
        self._nearbyUsers = nearbyUsers
        
        sortNearbyUsers()
        
        guard listTableView != nil else { return }
        listTableView.reloadData()
    }
    
    func sortNearbyUsers() {
        _nearbyUsers = _nearbyUsers.sort {
            $0.distance < $1.distance
        }
    }
    
    func getNearbyUsers(isRefresh: Bool) {
        
        if (isRefresh) {
            pageIndex = 1
        } else {
            pageIndex += 1
        }
        
        guard let myLocation = self._user!.getUserLocation() else { return }
        
        let lat: Double = myLocation.latitude.format(".8")
        let long: Double = myLocation.longitude.format(".8")
        
        let distance = UserDefault.getInt(Constants.PREFKEY_DISTANCE, defaultValue: 10)
        let ageStart = UserDefault.getInt(Constants.PREFKEY_AGE_START, defaultValue: 1)
        let ageEnd = UserDefault.getInt(Constants.PREFKEY_AGE_END, defaultValue: 100)
        
        let sex = UserDefault.getInt(Constants.PREFKEY_SEX, defaultValue: 2)       // all (male, female)
        let lastLogin = UserDefault.getInt(Constants.PREFKEY_LASTLOGIN, defaultValue: 7)   // 7 days ago
        let relation = UserDefault.getInt(Constants.PREFKEY_RELATION, defaultValue: 0)     // all of users
        
        WebService.getNearbyUsers(_user!._idx, lat: lat, long: long, distance: distance, ageStart: ageStart, ageEnd: ageEnd, sex: sex, lastLogin: lastLogin, relation: relation, pageIndex: pageIndex   ) { (status, message, nearbyUsers) in
            
            if self.upperRefreshControl.refreshing {
                self.upperRefreshControl.endRefreshing()
            }
            
            if self.bottomRefreshControl.refreshing {
                self.bottomRefreshControl.endRefreshing()
            }
            
            if (status) {
                
                if isRefresh {
                    self._nearbyUsers.removeAll()
                }
                
                if nearbyUsers.count > 0 {
                    self._nearbyUsers += nearbyUsers
                    self.sortNearbyUsers()
                    self.listTableView.reloadData()
                } else {
                    self.pageIndex -= 1
                }
            } else {                
                self.pageIndex -= 1
            }
        }
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "SegueUserList2UserProfile")  {
            
            let userProfileVC = segue.destinationViewController as! UserProfileViewController
            
            userProfileVC._selectedUser = _nearbyUsers[listTableView.indexPathForSelectedRow!.row]
            userProfileVC.from = FROM_USERLIST
            userProfileVC.hidesBottomBarWhenPushed = true
            
            // hide strip title
            stripDelegate?.hideStripTitleOnNavBar()
        }
    }
}

// MARK: @protocol - UITableViewDataSource and UITableViewDelegate
extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return _nearbyUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UserListCell") as! UserListCell
        cell.setContent(_nearbyUsers[indexPath.row])
        return cell
    }
}

// MARK: - @protocol indicator info provider : navigation sliding tab title of this viewcontroller
extension UserListViewController: IndicatorInfoProvider  {
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}



