//
//  MessageViewController.swift
//  WonBridge
//
//  Created by Saville Briard on 22/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

protocol RefreshBadgeDelegate {
    
    func updateBadgeCount()
}

class ChatSliderViewController: ButtonBarPagerTabStripViewController, StripTitleHideDelegate {
    
    var _user: UserEntity?
    
    var arrBadgeView: [M13BadgeView] = []
    
     override func viewDidLoad() {
        
        // setup style before super view did load is excuted
        settings.style.buttonBarBackgroundColor = UIColor.clearColor()
        settings.style.selectedBarBackgroundColor = UIColor.whiteColor()
        settings.style.selectedBarHeight = 2.0

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me
        
        initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView(){
        
        var frame = buttonBarView.frame
        frame.origin.x = 20
        frame.size.width = self.view.frame.size.width - 40
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
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        buttonBarView.hidden = false
        
        refreshBadgeCount()
        
        WBAppDelegate.refreshBadgeDelegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        WBAppDelegate.refreshBadgeDelegate = nil
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        
        let chatListVC = storyboard.instantiateViewControllerWithIdentifier("ChatListViewController") as! ChatListViewController
        chatListVC.stripDelegate = self
        
        let grpChatListVC = storyboard.instantiateViewControllerWithIdentifier("GroupChatListViewController") as! GroupChatListViewController
        grpChatListVC.stripDelegate = self
        
        
        let partnerListVC = storyboard.instantiateViewControllerWithIdentifier("FriendListViewController") as! FriendListViewController
//        grpChatListVC.stripDelegate = self
        
        return [chatListVC, grpChatListVC, partnerListVC]
    }
    
    override func configureCell(cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo, indexPath: NSIndexPath) {
        
        super.configureCell(cell, indicatorInfo: indicatorInfo, indexPath: indexPath)
        
        if indexPath.row == 0 || indexPath.row == 1 {

            let badgeView = M13BadgeView(frame: CGRectMake(0, 0, 24.0, 18.0))
            badgeView.text = "0"
            badgeView.hidesWhenZero = true
            badgeView.font = UIFont.systemFontOfSize(12.0)
            cell.badgeSuperView.addSubview(badgeView)
            
            badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight
            badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentTop
            
            arrBadgeView.append(badgeView)
        }
        
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func hideStripTitleOnNavBar() {
        
        buttonBarView.hidden = true
    }
    
    func refreshBadgeCount() {

        for index in 0 ..< arrBadgeView.count {
         
            let badgeView = arrBadgeView[index]
            
            if (index == 0) {
                badgeView.text = "\(_user!.getChatUnReadMsgCount())"
            } else {                
                badgeView.text = "\(_user!.getGrpChatUnreadCount())"
            }
        }
    }
}

extension ChatSliderViewController: RefreshBadgeDelegate {
    
    func updateBadgeCount() {
        
        refreshBadgeCount()
    }
}






