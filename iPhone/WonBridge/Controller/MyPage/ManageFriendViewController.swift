//
//  ManageFriendViewController.swift
//  WonBridge
//
//  Created by Tiia on 16/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class ManageFriendViewController: BaseViewController {
    
    var _user: UserEntity?
    
    @IBOutlet weak var noFriendView: UIView!
    
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var listCollectionView: UICollectionView!
    
    var collectionViewCellW: CGFloat!
    var collectionViewCellH: CGFloat!
    
    var blockUserList: [FriendEntity] = []
    var selectedUserList: [FriendEntity] = []
    
    var unblocking: Bool = false
    
    @IBOutlet weak var btnUnBlock: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _user = WBAppDelegate.me
        
        initView()
    }
    
    func initView() {
        
        // define collectioviewcell width and height according to root view size
        collectionViewCellW = (self.view.frame.size.width - 20) / 3
        collectionViewCellH = collectionViewCellW * 1.5
        
        for blockedUser in _user!._blockList {
            blockUserList.append(blockedUser)
        }
        updateUI(blockUserList.count == 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // status: true  - no friend
    //       : false - user has friends
    func updateUI(status: Bool) {
        
        if (status) {
            noticeView.hidden = true
            listCollectionView.hidden = true
            noFriendView.hidden = false
            
            btnUnBlock.title = ""
            
        } else {
            noticeView.hidden = false
            listCollectionView.hidden = false
            noFriendView.hidden = true
            
            btnUnBlock.title = Constants.MENU_UNBLOCK
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
    
    func selectUser(indexPath: NSIndexPath) {
        
        if let _selectedUser: FriendEntity? = blockUserList[indexPath.row] {
            
            // reverse selected state in model
            _selectedUser!._isSelected = !_selectedUser!._isSelected
            
            // update checked state
            let cell = listCollectionView.cellForItemAtIndexPath(indexPath) as! UserGridCell
            cell.setCheck((_selectedUser?._isSelected)!)
            
            if (_selectedUser!._isSelected) {
                // add a friend to selected list
                selectedUserList.append(blockUserList[indexPath.row])
            } else {
                // remove a friend from selected list
                selectedUserList.removeAtIndex(selectedUserList.indexOf(blockUserList[indexPath.row])!)
            }
        }
        
        updateConfirmButtonTitle()
    }
    
    func updateConfirmButtonTitle() {
        
        // disable animation to remove blink when to change button title
        UIView.setAnimationsEnabled(false)
        
        // update confirm button title according to selected friends count
        if (selectedUserList.count == 0) {
            btnUnBlock.title = Constants.MENU_UNBLOCK
        } else {
            btnUnBlock.title = Constants.MENU_UNBLOCK + "(\(selectedUserList.count))"
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    @IBAction func unblockButtonTapped(sender: AnyObject) {
        
        guard selectedUserList.count > 0 && !unblocking else { return }
        
        unblockUsers()
    }
    
    func unblockUsers() {
        
        unblocking = true
        
        var unblockIdList = [String]()
        
        for blockedUser in selectedUserList {
            
            unblockIdList.append("\(blockedUser._idx)")
        }
        
        WebService.unblockUsers(_user!._idx, unblockIdList: unblockIdList) { (status, message) in
            
            self.unblocking = false
            
            if status {
                
                // diselect friends
                for _friend in self.selectedUserList {
                    _friend._isSelected = false
                    
                    self._user!.removeblockUser(_friend)
                }
                
                self.selectedUserList.removeAll()
                self.updateConfirmButtonTitle()
                
                self.blockUserList.removeAll()
                self.blockUserList = self._user!._blockList
                
                self.listCollectionView.reloadData()
                
                self.updateUI(self.blockUserList.count == 0)
            }
        }
    }
}

 // MARK - UICollectionViewDataSource and Delegate
extension ManageFriendViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return blockUserList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserGridCell", forIndexPath: indexPath) as! UserGridCell
        cell.setUser(blockUserList[indexPath.row])
        
        // show check box for select user
        cell.setCheckVisibility(true)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(collectionViewCellW, collectionViewCellH)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        selectUser(indexPath)
    }
}



