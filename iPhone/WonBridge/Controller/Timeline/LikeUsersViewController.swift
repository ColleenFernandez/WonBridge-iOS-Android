//
//  LikeUsersViewController.swift
//  WonBridge
//
//  Created by July on 2016-09-20.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class LikeUsersViewController: BaseViewController {
    
    var _user: UserEntity?
    
    // Global User - Me
    var _selectedTimeLine: TimeLineEntity?
    
    var _likeUsers = [FriendEntity]()
    
    var collectionViewCellW: CGFloat!
    var collectionViewCellH: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me
        
        initView() 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initView() {
        
        self.title = _selectedTimeLine!.user_name + ": " + Constants.TITLE_LIKE_USERS
        
        // define collectioviewcell width and height according to root view size
        collectionViewCellW = (self.view.frame.size.width - 20) / 3
        collectionViewCellH = collectionViewCellW - 4
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
}

extension LikeUsersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK - UICollectionViewDataSource and Delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return _likeUsers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LikeUserGridCell", forIndexPath: indexPath) as! LikeUserGridCell
        
        cell.configCell(_likeUsers[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(collectionViewCellW, collectionViewCellH)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard _likeUsers[indexPath.row]._idx != _user!._idx else { return }
        
        let userProfileVC = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        
        userProfileVC.from = FROM_TIMELINEDETAIL
        userProfileVC._selectedUser = _likeUsers[indexPath.row]
        
        var viewControllers = navigationController?.viewControllers
        
        viewControllers?.removeLast()
        viewControllers?.append(userProfileVC)
        
        navigationController?.setViewControllers(viewControllers!, animated: true)
    }
}


