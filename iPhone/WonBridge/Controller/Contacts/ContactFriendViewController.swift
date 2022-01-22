//
//  ContactFriendViewController.swift
//  WonBridge
//
//  Created by Roch David on 15/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import RxSwift

private let kContactFriendCellHeight: CGFloat = 70

class ContactFriendViewController: BaseViewController {
    
    var itemInfo = IndicatorInfo(title: Constants.SLIDE_FRIEND)
    
    weak var stripDelegate: StripTitleHideDelegate?
    
    // global user - me
    var _user: UserEntity?
    
    @IBOutlet weak var tblFriends: UITableView!
    var itemDataSource = [FriendEntity]()
    var searchItemDataSource = [FriendEntity]()
    
    // refresh control
    var bottomRefreshControl = UIRefreshControl()
    var pageIndex = 1
    
    // 
    @IBOutlet weak var newFriendView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    var isSearch = false
    
    let disposeBag = DisposeBag()

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
        
        // remove tableview separator of empty cell
        tblFriends.tableFooterView = UIView(frame: CGRectZero)
        tblFriends.rowHeight = kContactFriendCellHeight
        
        // add bottom refresh control on UITableView
        bottomRefreshControl.triggerVerticalOffset = 90
        bottomRefreshControl.tintColor = UIColor(netHex: 0x3366AD)
        bottomRefreshControl.addTarget(self, action: #selector(refreshFriendList(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        tblFriends.bottomRefreshControl = bottomRefreshControl
        
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        newFriendView.addGestureRecognizer(tap)
        tap.rx_event.subscribeNext { _ in
           self.showNewFriendView(false)
        }.addDisposableTo(disposeBag)
        
        searchTextField.addTarget(self, action: #selector(textFeildDidChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        newFriendView.hidden = false        
        initFriendList()
    }
    
    func showNewFriendView(visible: Bool) {
        
        if visible {
            self.newFriendView.hidden = visible
        } else {
            UIView.transitionWithView(newFriendView, duration: 0.4, options: .TransitionCrossDissolve, animations: {
                self.newFriendView.hidden = true
                }, completion: nil)
        }
    }
    
    func initFriendList() {
        
        isSearch = false
     
        itemDataSource.removeAll()
        for friend in _user!._frList {
            if !_user!.isBlockedFriend(friend._idx) {
                itemDataSource.append(friend)
            }
        }
        
        itemDataSource.sortInPlace({ return $0._name < $1._name })        
        tblFriends.reloadData()
    }
    
    func refreshFriendList(sender: UIRefreshControl) {
        
        guard !isSearch else { return }
        
        getFriendList()
    }
    
    func getFriendList() {
        
        pageIndex += 1
        
        WebService.getFriends(_user!._idx, pageIndex: pageIndex) { (status, message, friendList) in
            
            if self.bottomRefreshControl.refreshing {
                
                self.bottomRefreshControl.endRefreshing()
            }
            
            if (status) {
                
                guard friendList.count > 0 else {
                    self.pageIndex -= 1
                    return
                }
                
                for friend in friendList {
                    self._user!.addFriend(friend)
                }
                self.initFriendList()
            }
        }
    }
    
    func searchFriend() {
        
        // hide keyboard
        searchTextField.resignFirstResponder()
        
        guard !searchTextField.text!.isEmpty else { return }
        
        let name = searchTextField.text!.stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH).encodeString()
        WebService.searchFriend(_user!._idx, name: name!) { (status, message, searchUser) in
            
            if status {
                
                self.isSearch = true
                
                self.searchItemDataSource.removeAll()
                self.searchItemDataSource.append(searchUser!)
                
                self.tblFriends.reloadData()
                
            } else {
                
                guard message != "" else { return }
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
    
    @IBAction func searchButtonTapped() {
        
        searchFriend()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textFeildDidChanged(textField: UITextField) {
        
        if textField.text!.isEmpty {
            textField.resignFirstResponder()
            initFriendList()
        }
    }
}

// MARK: - @protocol Indicator Info Providers
extension ContactFriendViewController: IndicatorInfoProvider {
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return itemInfo
    }
}

// MARK: - @protocol UITableViewDataSource, UITableViewDelegate
extension ContactFriendViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rowCount = isSearch ? searchItemDataSource.count : itemDataSource.count
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactFriendCell") as! ContactFriendCell
        let friend = isSearch ? searchItemDataSource[indexPath.row] : itemDataSource[indexPath.row]
        cell.configureCell(friend) { (sender) in
            // TO DO
        }
        cell.showActionButton(isSearch, friend: friend)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let storyboard = UIStoryboard(name: "TimeLine", bundle: nil)
        let userProfileVC = storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        userProfileVC.from = FROM_CONTACT_FRIENDLIST
        
        let friend = isSearch ? searchItemDataSource[indexPath.row] : itemDataSource[indexPath.row]
        userProfileVC._selectedUser = friend
        
        navigationController?.pushViewController(userProfileVC, animated: true)
        
        stripDelegate?.hideStripTitleOnNavBar()
    }
}

// MARK: - @protocol UITextFieldDelegate
extension ContactFriendViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        searchFriend()
        
        // search with field
        return true
    }
}

// MARK: - @protocol UIScrolViewDelegate
extension ContactFriendViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}




