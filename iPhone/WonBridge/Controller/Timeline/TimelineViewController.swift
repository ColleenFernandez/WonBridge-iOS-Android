//
//  TimelineViewController.swift
//  WonBridge
//
//  Created by Tiia on 28/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import CCBottomRefreshControl

private var kMyPageIndex = 3

protocol TimeLineRefreshDelegate: class {
    
    func refresh()
}

// TimeLineViewController 
class TimeLineViewController: BaseViewController, IndicatorInfoProvider {
    
    // global user - me
    var _user: UserEntity?
    var _nearbyUsers = [FriendEntity]()
    // navigation bar sliding item - title
    var itemInfo = IndicatorInfo(title: Constants.SLIDE_TIMELINE)
    // sliding title of navigation bar hide delegate
    weak var stripDelegate: StripTitleHideDelegate?
    // nearby user refresh delegate    
    weak var nearbyRefreshDelegate: NearbyRefreshDelegate?
    
    var arrTimeLine = [TimeLineEntity]()
    
    var pageIndex = 1
    // refresh control
    var upperRefreshControl = UIRefreshControl()
    var bottomRefreshControl = UIRefreshControl()
    
    var myLocation: CLLocationCoordinate2D?
    
    // timeline tableview and array
    @IBOutlet weak var tblTimeLineList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _user = WBAppDelegate.me
        
        initView()
        
        getNearbyTimeLine(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    func initView() {
        
        tblTimeLineList.tableFooterView = UIView()
        tblTimeLineList.estimatedRowHeight = 310
        tblTimeLineList.rowHeight = UITableViewAutomaticDimension
        
        // add pull to refresh on UITableView
        upperRefreshControl.tintColor = UIColor(netHex: 0x3366AD)
        upperRefreshControl.addTarget(self, action: #selector(refreshTimeLineList(_:)), forControlEvents: .ValueChanged)
        tblTimeLineList.addSubview(upperRefreshControl)
        
        // add bottom refresh control on UITableView
        bottomRefreshControl.triggerVerticalOffset = 90
        bottomRefreshControl.tintColor = UIColor(netHex: 0x3366AD)
        bottomRefreshControl.addTarget(self, action: #selector(refreshTimeLineList(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        tblTimeLineList.bottomRefreshControl = bottomRefreshControl
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        if let pushNotification = UserDefault.getString("push_notification") {
//            showToast(pushNotification)
//        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // refresh nearby users
    // will be called from slider viewcontroller
    func refresh(neabyUsers: [FriendEntity]) {
        
        self._nearbyUsers.removeAll()
        self._nearbyUsers = neabyUsers
        
        getNearbyTimeLine(true)
    }
    
    func refreshTimeLineList(sender: UIRefreshControl) {
        
        if sender == upperRefreshControl {
            getNearbyTimeLine(true)
        } else {
            getNearbyTimeLine(false)
        }
    }
    
    func getNearbyTimeLine(isRefresh: Bool) {
        
        if (isRefresh) {
            pageIndex = 1
        }
        
        guard let myLocation = _user!.getUserLocation() else { return }
        
        let distance = UserDefault.getInt(Constants.PREFKEY_DISTANCE, defaultValue: 10)
        let ageStart = UserDefault.getInt(Constants.PREFKEY_AGE_START, defaultValue: 1)
        let ageEnd = UserDefault.getInt(Constants.PREFKEY_AGE_END, defaultValue: 100)
        
        let sex = UserDefault.getInt(Constants.PREFKEY_SEX, defaultValue: 2)       // all (male, female)
        let lastLogin = UserDefault.getInt(Constants.PREFKEY_LASTLOGIN, defaultValue: 7)   // 7 days ago
        let relation = UserDefault.getInt(Constants.PREFKEY_RELATION, defaultValue: 0)     // all of users
        
        let lat: Double = myLocation.latitude.format(".8")
        let long: Double =  myLocation.longitude.format(".8")
        
        WebService.getNearbyTimeLineDetail(_user!._idx, lat: lat, long: long, distance: distance, ageStart: ageStart, ageEnd: ageEnd, sex: sex, lastLogin: lastLogin, relation: relation, pageIndex: pageIndex) { (status, message, nearbyTimeLine) in
            
            if self.upperRefreshControl.refreshing {
                self.upperRefreshControl.endRefreshing()
            }
            
            if self.bottomRefreshControl.refreshing {                
                self.bottomRefreshControl.endRefreshing()
            }
            
            if (status) {
                
                if (isRefresh) {
                    self.arrTimeLine.removeAll()
                }
                
                if nearbyTimeLine.count > 0 {
                    
                    self.pageIndex += 1
                    self.arrTimeLine += nearbyTimeLine
                    
                    if CommonUtils.wonbridgeTimeLine != nil  && isRefresh {
                        self.arrTimeLine.insert(CommonUtils.wonbridgeTimeLine!, atIndex: 1)
                    }
                    
                    self.tblTimeLineList.reloadData()

                } else if nearbyTimeLine.count == 0 {
                    
                    if CommonUtils.wonbridgeTimeLine != nil && isRefresh {
                        self.arrTimeLine.append(CommonUtils.wonbridgeTimeLine!)
                    }
                    
                    self.tblTimeLineList.reloadData()
                }
            }
        }
    }
    
    // MARK: - Indicator Info Providers
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return itemInfo
    }
    
    func gotoUserProfile(user: FriendEntity) {
        
        // hide sliding title navigation bar
        stripDelegate?.hideStripTitleOnNavBar()
        
        let userProfileVC = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        userProfileVC.from = FROM_TIMELINE
        userProfileVC._selectedUser = user
        
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func syncMyLocationToServer() {
        
        guard let myLocation = _user!.getUserLocation() else { return }
        
        let lat: Double = myLocation.latitude.format(".8")
        let long: Double = myLocation.longitude.format(".8")
        
        WebService.setMyLocation(_user!._idx, lat: lat, long: long) { (status) in
            
            if (status) {
                // update nearbyuser and update nearbytimeline
                self.nearbyRefreshDelegate?.refreshNearby()
            }
        }
    }
    
    // MARK: - unwind from timeline detail
    // it will be need to nearbytimeline list.
    // timeline was deleted or updated (likeUsers, replies)
    @IBAction func unwindFromTimeLineDetail(segue: UIStoryboardSegue) {
        
        if segue.identifier == "unwind2TimeLine" {
            
            // will refresh timeline list
            self.getNearbyTimeLine(true)
            
//            let timeLineDetailVC = segue.sourceViewController as! TimeLineDetailViewController
//            if timeLineDetailVC.selectedTimeLine!.user_id == _user!._idx {
//                // will delete selected timeline
//                let deletedTimeLine = timeLineDetailVC.selectedTimeLine
//                for timeLine in arrTimeLine {
//                    if timeLine.id == deletedTimeLine!.id {
//                        self.arrTimeLine.removeObject(timeLine)
//                        break
//                    }
//                }
//                self.tblTimeLineList.reloadData()
//            } else {
//                // will refresh timeline list
//                self.getNearbyTimeLine(true)
//            }
        }
    }
    
    // go to full text view
    func gotoFullTextView(timeLine: TimeLineEntity) {
        
        let fullTextVC = self.storyboard?.instantiateViewControllerWithIdentifier("FullTextViewController") as! FullTextViewController
        fullTextVC.timeline = timeLine
        stripDelegate?.hideStripTitleOnNavBar()
        navigationController!.pushViewController(fullTextVC, animated: true)
    }
    
    // go to timeline detail
    func gotoTimeLineDetail(timeLine: TimeLineEntity) {
        
        stripDelegate?.hideStripTitleOnNavBar()
        
        let timeLineDetailVC = storyboard?.instantiateViewControllerWithIdentifier("TimeLineDetailViewController") as! TimeLineDetailViewController
        timeLineDetailVC.selectedTimeLine = timeLine
        
        navigationController?.pushViewController(timeLineDetailVC, animated: true)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SegueTimeLine2Detail" {
            
            stripDelegate?.hideStripTitleOnNavBar()
            
            let timeLineDetailVC = segue.destinationViewController as! TimeLineDetailViewController
            let selectedIndexPath = tblTimeLineList.indexPathForSelectedRow
            timeLineDetailVC.selectedTimeLine = arrTimeLine[selectedIndexPath!.row - 1]
            
        } else if segue.identifier == "SegueTimeLine2Post" {
            
            let postTimeLineVC = segue.destinationViewController as! PostTimeLineViewController            
            postTimeLineVC.refreshDelegate = self
            
        } else if segue.identifier == "SegueTimeLine2Map" {
            
            let mapVC = segue.destinationViewController as! MapViewController
            mapVC.showProfileDelegate = self
            mapVC._nearbyUsers = self._nearbyUsers
        }
    }
}

// MARK: - UITableViewDataSource, UITaleViewDelegate
extension TimeLineViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTimeLine.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
           let cell = tableView.dequeueReusableCellWithIdentifier("TimeLineMapCell") as! TimeLineMapCell
            cell.setNearByUser(_nearbyUsers)
            cell.setAction({ _ in
                
                self.performSegueWithIdentifier("SegueTimeLine2Map", sender: self)
            })
            cell.mapcellDelegate = self
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MainTimeLineCell") as! MainTimeLineCell
            cell.setContent(arrTimeLine[indexPath.row - 1], expandAction: { _ in
                
                tableView.reloadData()
                if indexPath.row == self.arrTimeLine.count {
                    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
                }
                
                }, textTapAction: { _ in
                    
                    let timeLine = self.arrTimeLine[indexPath.row - 1]
                    
                    // if timeline content length is over 100 then it will be direct to full text 
                    // otherwise it will be direct to detail page
                    if timeLine.content.length >= 100 {
                        
                        self.gotoFullTextView(timeLine)
                    } else {
                        
                        guard timeLine.id != 0 else { return }                        
                        self.gotoTimeLineDetail(timeLine)
                    }
                }, photoTapAction: { _ in
                    
                    let timeLine = self.arrTimeLine[indexPath.row - 1]
                    
                    var photos = [IDMPhoto]()
                    for url in timeLine.file_url {
                        photos.append(IDMPhoto(URL: NSURL(string: url)!))
                    }
                    
                    let broswer = IDMPhotoBrowser(photos: photos)
                    broswer.delegate = self
                    broswer.displayToolbar = false
                    broswer.setInitialPageIndex(UInt(indexPath.row))
                    broswer.doneButtonImage = WBAsset.BackButton.image
                    broswer.setInitialPageIndex(0)
                    
                    // show
                    self.presentViewController(broswer, animated: true, completion: nil)
                    
                }, block: { (sender) in
                    
                    let timeLine = self.arrTimeLine[indexPath.row - 1]                    
                    guard timeLine.id != 0 else { return }
                    
                    guard timeLine.user_id != self._user!._idx else {
                        self.tabBarController?.selectedIndex = kMyPageIndex
                        return
                    }
                    
                    guard let selectedUser = self._user!.getFriend(timeLine.user_id) else {
                        
                        let timeLineUser = FriendEntity()
                        timeLineUser._idx = timeLine.user_id
                        timeLineUser._name = timeLine.user_name
                        timeLineUser._photoUrl = timeLine.photo_url
                        self.gotoUserProfile(timeLineUser)
                        
                        return
                    }
                    
                    self.gotoUserProfile(selectedUser)
            })
            
            return cell
        }
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell.isKindOfClass(MainTimeLineCell) {
            let timeLineCell = cell as! MainTimeLineCell            
            timeLineCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let timeLine = self.arrTimeLine[indexPath.row - 1]
        guard timeLine.id != 0 else {
            return
        }
        
        gotoTimeLineDetail(timeLine)
    }
    
    
}

extension TimeLineViewController: UICollectionViewDataSource, UICollectionViewDelegate {
   
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard collectionView.tag != 0 else { return 0 }
        return arrTimeLine[collectionView.tag - 1].file_url.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TimeLinePhotoCollectionViewCell", forIndexPath: indexPath) as! TimeLinePhotoCollectionViewCell
        let timeLine = arrTimeLine[collectionView.tag - 1]
        cell.setContent(timeLine.file_url[indexPath.row])
        
        return cell
    }
    
//    //Use for size
//    func collectionView(collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        
//        return kTimeLineCollectionSize
//    }
}

extension TimeLineViewController: TimeLineMapCellDelegate {
    
    func showUserProfile(user: AnyObject) {
        
        if user.isKindOfClass(UserAnnotation) {
            self.gotoUserProfile((user as! UserAnnotation).user!)
            
        } else if user.isKindOfClass(UserMapMarker) {
            self.gotoUserProfile((user as! UserMapMarker).user!)
        }
    }
    
    func locationUpdated() {
        self.syncMyLocationToServer()
    }
}

extension TimeLineViewController: TimeLineRefreshDelegate {
    
    func refresh() {
        getNearbyTimeLine(true)
    }
}

// MARK: -  Show User Profile Delegate
// when an user click annotation bubble
extension TimeLineViewController: ShowProfileFromMapDelegate {
    
    func showProfile(user: FriendEntity) {
        dismissViewControllerAnimated(false) {
            self.gotoUserProfile(user)
        }
    }
}

extension TimeLineViewController: IDMPhotoBrowserDelegate {
    
    // all delegate methods are optional
    
}





