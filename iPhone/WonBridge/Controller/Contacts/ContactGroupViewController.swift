//
//  ContactGroupViewController.swift
//  WonBridge
//
//  Created by Roch David on 15/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//


import UIKit
import RxSwift

private let kGroupContactListCellHeight: CGFloat = 70

class ContactGroupViewController: BaseViewController {
    
    var itemInfo = IndicatorInfo(title: Constants.SLIDE_GROUP)
    
    weak var stripDelegate: StripTitleHideDelegate?
    
    // global user - me
    var _user: UserEntity?
    
    @IBOutlet weak var listTableView: UITableView!
    
    var arrContacts = [GroupEntity]()
    
    var itemDataSource = [GroupEntity]()
    var searchItemDataSource = [GroupEntity]()
    
    @IBOutlet weak var newGroupView: UIView!
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        newGroupView.hidden = false
        loadGroup()
    }
    
    func initView() {
        
        // remove tableview separator of empty cell
        listTableView.tableFooterView = UIView(frame: CGRectZero)
        listTableView.rowHeight = kGroupContactListCellHeight
        
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        newGroupView.addGestureRecognizer(tap)
        tap.rx_event.subscribeNext { _ in
            self.showNewGroupView(false)
            }.addDisposableTo(disposeBag)
        
        searchTextField.addTarget(self, action: #selector(textFeildDidChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func showNewGroupView(visible: Bool) {
        
        if visible {
            self.newGroupView.hidden = visible
        } else {
            UIView.transitionWithView(newGroupView, duration: 0.4, options: .TransitionCrossDissolve, animations: {
                self.newGroupView.hidden = true
                }, completion: nil)
        }
    }
    
    func initGroupList() {
        
        isSearch = false
        
        itemDataSource.removeAll()
        for group in _user!._groupList {
            itemDataSource.append(group)
        }
        
//        itemDataSource.sortInPlace({ return $0.name < $1.name })
        listTableView.reloadData()
    }
    
    func loadGroup() {
        
        WebService.loadGroup(_user!._idx) { (status, message, list) in
            
            if status {
                
                guard list?.count != 0 else { return }
                
                self._user!._groupList.removeAll()
                self._user!._groupList.insertContentsOf(list!, at: 0)
                
                self.initGroupList()
            }
        }
    }
    
    func searchGroup() {
        
        // hideKeyboard
        searchTextField.resignFirstResponder()
        
        guard !searchTextField.text!.isEmpty else { return }
        
        let name = searchTextField.text!.stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH).encodeString()
        WebService.searchGroup(name!) { (status, message, searchList) in
            
            if status {
                self.isSearch = true
                
                self.searchItemDataSource.removeAll()
                self.searchItemDataSource += searchList!
                
                self.listTableView.reloadData()
                
            } else {
                
                guard message != "" else { return }
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
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
    
    func textFeildDidChanged(textField: UITextField) {
        
        if textField.text!.isEmpty {
            textField.resignFirstResponder()
            initGroupList()
        }
    }
    
    @IBAction func searchButtonTapped(sender: AnyObject) {
        searchGroup()
    }
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        
//        showToast("Coming soon.")
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let selectFriendVC = storyboard.instantiateViewControllerWithIdentifier("SelectFriendViewController") as! SelectFriendViewController
        
        stripDelegate!.hideStripTitleOnNavBar()
        navigationController?.pushViewController(selectFriendVC, animated: true)
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
}

// MARK: - Indicator Info Providers
extension ContactGroupViewController: IndicatorInfoProvider {
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return itemInfo
    }
}

// MARK: - @protocol UITableViewDataSource , UITableViewDelegate
extension ContactGroupViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rowCount = isSearch ? searchItemDataSource.count : itemDataSource.count
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactGroupCell") as! ContactGroupCell
        let group = isSearch ? searchItemDataSource[indexPath.row] : itemDataSource[indexPath.row]        
        cell.setContent(group, isSearch: self.isSearch, actionBlock: nil)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let group = isSearch ? searchItemDataSource[indexPath.row] : itemDataSource[indexPath.row]
        if _user!.isExistGroup(group) {
            // go to chat
            guard let chatRoom = _user!.getRoom(group.name) else { return }
            
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let chatVC = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            chatVC.chatRoom = chatRoom
            WBAppDelegate.xmpp.enterChattingRoom(chatRoom)
            
            if chatRoom._recentCount > 0 {
                
                WebService.reduceBadgeCount(_user!._idx, count: chatRoom._recentCount, completion: { (status) in
                })
                
//                var badgeCount = UIApplication.sharedApplication().applicationIconBadgeNumber - chatRoom._recentCount
//                badgeCount = badgeCount >= 0 ? badgeCount : 0
//                UIApplication.sharedApplication().applicationIconBadgeNumber = badgeCount
                
                _user!.notReadCount -= chatRoom._recentCount
                chatRoom._recentCount = 0
                
                // update tabbar badge
                WBAppDelegate.notifyReceiveNewMessage()
                
                // update database
                DBManager.getSharedInstance().updateRoom(chatRoom)
            }
            
            stripDelegate?.hideStripTitleOnNavBar()
            navigationController?.pushViewController(chatVC, animated: true)
        } else {
            // go to group profile
            let storyboard = UIStoryboard(name: "Contact", bundle: nil)
            let groupProfileVC = storyboard.instantiateViewControllerWithIdentifier("GroupProfileViewController") as! GroupProfileViewController
            groupProfileVC.group = group
            
            stripDelegate?.hideStripTitleOnNavBar()
            navigationController?.pushViewController(groupProfileVC, animated: true)
        }
    }
}

// MARK: - @protocol UITextFieldDelegate
extension ContactGroupViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // search with field
        searchGroup()
        
        return true
    }
}

// MARK: - @protocol UIScrollViewDelegate
extension ContactGroupViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}


