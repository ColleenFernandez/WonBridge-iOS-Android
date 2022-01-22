//
//  TimeLineListViewController.swift
//  WonBridge
//
//  Created by Roch David on 11/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class TimeLineListViewController: BaseViewController {
    
    var selectedTimeLine: TimeLineEntity?
    var selectedUser: FriendEntity?
    
    var _user: UserEntity?
    
    // refresh control
    var upperRefreshControl = UIRefreshControl()
    var bottomRefreshControl = UIRefreshControl()
    
    var pageIndex = 1
    
    var arrTimeLine = [TimeLineEntity]()
    
    @IBOutlet weak var tblTimeLineList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _user = WBAppDelegate.me
        
        initView()
        
        getTimeLineList(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    func initView() {
        
        tblTimeLineList.tableFooterView = UIView()
        
        // add pull to refresh on UITableView
        upperRefreshControl.tintColor = UIColor(netHex: 0x3366AD)
        upperRefreshControl.addTarget(self, action: #selector(refreshTimeLineList(_:)), forControlEvents: .ValueChanged)
        tblTimeLineList.addSubview(upperRefreshControl)
        
        // add bottom refresh control on UITableView
        bottomRefreshControl.triggerVerticalOffset = 90
        bottomRefreshControl.tintColor = UIColor(netHex: 0x3366AD)
        bottomRefreshControl.addTarget(self, action: #selector(refreshTimeLineList(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        tblTimeLineList.bottomRefreshControl = bottomRefreshControl
        tblTimeLineList.dataSource = self
        tblTimeLineList.estimatedRowHeight = 100
        tblTimeLineList.rowHeight = UITableViewAutomaticDimension
        
        if selectedUser != nil {
            self.title = selectedUser!._name + " " + Constants.TITLE_TIMELINELIST_SUFFIX
        } else {
            self.title = _user!._name + " " + Constants.TITLE_TIMELINELIST_SUFFIX
        }
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func refreshTimeLineList(sender: UIRefreshControl) {
        
        if sender == upperRefreshControl {
            getTimeLineList(true)
        } else {
            getTimeLineList(true)
        }
    }
    
    func getTimeLineList(isRefresh: Bool) {
        
        if (isRefresh) {
            pageIndex = 1
        }

        let userId = selectedUser != nil ? selectedUser!._idx : _user!._idx
        WebService.getUserTimeLineDetail(userId, pageIndex: pageIndex) { (status, message, timeLineList) in
            
            if self.upperRefreshControl.refreshing {
                self.upperRefreshControl.endRefreshing()
            }
            
            if self.bottomRefreshControl.refreshing {
                self.bottomRefreshControl.endRefreshing()
            }
            
            if status {
                
                if timeLineList.count > 0 {
                    
                    if (isRefresh) {
                        self.arrTimeLine.removeAll()
                    }
                    
                    self.arrTimeLine += timeLineList
                    self.pageIndex += 1
                    self.tblTimeLineList.reloadData()
                }
                
            } else {
                self.showToast(message)
            }
        }
    }
    
    func gotoFullTextView(timeLine: TimeLineEntity) {
        
        let fullTextVC = storyboard?.instantiateViewControllerWithIdentifier("FullTextViewController") as! FullTextViewController
        fullTextVC.timeline = timeLine
        
        self.navigationController?.pushViewController(fullTextVC, animated: true)
    }
    
    func gotoUserProfile(friend: FriendEntity) {
       
        let userProfileVC = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        
        userProfileVC.from = FROM_TIMELINE
        userProfileVC._selectedUser = friend
        
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    // go to timeline detail
    func gotoTimeLineDetail(timeLine: TimeLineEntity) {
        
        let timeLineDetailVC = storyboard?.instantiateViewControllerWithIdentifier("TimeLineDetailViewController") as! TimeLineDetailViewController
        timeLineDetailVC.selectedTimeLine = timeLine
        
        navigationController?.pushViewController(timeLineDetailVC, animated: true)
    }
    
    @IBAction func prepareForUnwindToTimeLineList(segue: UIStoryboardSegue) {
        
        if segue.identifier == "unwind2TimeLineList" {
            let sourceVC = segue.sourceViewController as! TimeLineDetailViewController
            // delete timeline and reload data
            let deletedTimeLine = sourceVC.selectedTimeLine!
            
            for timeLine in arrTimeLine {
                if timeLine.id == deletedTimeLine.id {
                    arrTimeLine.removeObject(timeLine)
                    break
                }
            }
            
            tblTimeLineList.reloadData()
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

extension TimeLineListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrTimeLine.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MainTimeLineCell") as! MainTimeLineCell
        
        cell.setContent(arrTimeLine[indexPath.row], expandAction: { _ in
            tableView.reloadData()
            if indexPath.row == self.arrTimeLine.count - 1 {
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
            }
            }, textTapAction: { _ in
                
                let timeLine = self.arrTimeLine[indexPath.row]
                
                // if timeline content length is over 100 then it will be direct to full text
                // otherwise it will be direct to detail page
                if timeLine.content.length >= 100 {
                    
                    self.gotoFullTextView(timeLine)
                } else {
                    
                    guard timeLine.id != 0 else { return }
                    self.gotoTimeLineDetail(timeLine)
                }
                
            }, photoTapAction: { _ in
                // for showing wonbridge timeline image 
            }, block: { (sender) in
                
                if self.selectedUser != nil {
                    
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    let timeLine = self.arrTimeLine[indexPath.row]
                    guard timeLine.user_id != self._user!._idx else {
                        return
                    }
                    
                    guard let selectedUser = self._user!.getFriend(timeLine.user_id) else  {
                        
                        // timeLine user is not a friend, so will make a temp user with timeLine then will go to user profile page
                        let timeLineUser = FriendEntity()
                        timeLineUser._idx = timeLine.user_id
                        timeLineUser._name = timeLine.user_name
                        timeLineUser._photoUrl = timeLine.photo_url
                        
                        self.gotoUserProfile(timeLineUser)
                        return
                    }
                    
                    self.gotoUserProfile(selectedUser)
                    
                }
                
                
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var viewControllers = navigationController?.viewControllers
        
        guard viewControllers != nil && viewControllers?.count >= 2 else {
            return
        }
        
        let lastVC = viewControllers![viewControllers!.count - 2]
        
        if lastVC.isKindOfClass(TimeLineDetailViewController) {
            
            selectedTimeLine = arrTimeLine[indexPath.row]
            performSegueWithIdentifier("unwind2TimeLineDetail", sender: self)
        } else {
            // navigation stack: My Page -> TimeLineList
            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("TimeLineDetailViewController") as! TimeLineDetailViewController
            detailVC.selectedTimeLine = arrTimeLine[indexPath.row]            
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell.isKindOfClass(MainTimeLineCell) {
            let timeLineCell = cell as! MainTimeLineCell
            timeLineCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        }
    }
}

extension TimeLineListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrTimeLine[collectionView.tag].file_url.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TimeLinePhotoCollectionViewCell", forIndexPath: indexPath) as! TimeLinePhotoCollectionViewCell
        let timeLine = arrTimeLine[collectionView.tag]
        cell.setContent(timeLine.file_url[indexPath.row])
        
        return cell
    }
    
    //Use for size
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return kTimeLineCollectionSize
    }
}







