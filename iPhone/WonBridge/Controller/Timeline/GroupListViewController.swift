//
//  GroupListViewController.swift
//  WonBridge
//
//  Created by Tiia on 28/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

// Nearby GroupListViewController
class GroupListViewController: BaseViewController {
    
    // sliding tab title
    var itemInfo = IndicatorInfo(title: Constants.SLIDE_GROUP)
    // title button view hide delegate
    weak var stripDelegate: StripTitleHideDelegate?
    
    // global user - me
    var _user: UserEntity?
    
    // nearby groups
    var itemDataSource = [GroupEntity]()
    var searchItemDataSource = [GroupEntity]()
    
    // refresh control
    var upperRefreshControl = UIRefreshControl()
    var bottomRefreshControl = UIRefreshControl()
    var pageIndex = 1
    
    @IBOutlet weak var searchField: UITextField!
    var isSearch = false
    
    // nearby group list tableview
    @IBOutlet weak var listTableView: UITableView!

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _user = WBAppDelegate.me
        
        initView()
        
        getNearbyGroups(true)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        // add pull to refresh on UITableView
        upperRefreshControl.tintColor = UIColor(netHex: 0x3366AD)
        upperRefreshControl.addTarget(self, action: #selector(refreshNearbyGroups(_:)), forControlEvents: .ValueChanged)
        listTableView.addSubview(upperRefreshControl)
        
        // add bottom refresh control on UITableView
        bottomRefreshControl.triggerVerticalOffset = 90
        bottomRefreshControl.tintColor = UIColor(netHex: 0x3366AD)
        bottomRefreshControl.addTarget(self, action: #selector(refreshNearbyGroups(_:)), forControlEvents: UIControlEvents.ValueChanged)
        listTableView.bottomRefreshControl = bottomRefreshControl
        
        listTableView.tableFooterView = UIView()
        listTableView.rowHeight = 70
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(textFieldDidChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func searchGroup() {
        
        // hide keyboard
        searchField.resignFirstResponder()
        
        let grpName = searchField.text!.encodeString()
        WebService.searchGroup(grpName!) { (status, message, searchList) in
            
            if status {
                self.isSearch = true
                
                self.searchItemDataSource.removeAll()
                self.searchItemDataSource += searchList!
                
                self.listTableView.reloadData()
            } else {
                
                guard message != "" else { return }
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.APP_NAME, negative: nil)
            }
        }
    }
    
    func textFieldDidChanged(textField: UITextField) {
        
        if textField.text!.isEmpty {
            textField.resignFirstResponder()
            
            isSearch = false
            listTableView.reloadData()
        }
    }
    
    func refresh() {
        
        guard !isSearch else { return }
        
        getNearbyGroups(true)
    }
    
    func refreshNearbyGroups(sender: UIRefreshControl) {
        
        if sender == upperRefreshControl {
            getNearbyGroups(true)
        } else {
            getNearbyGroups(false)
        }
    }
    
    func getNearbyGroups(isRefresh: Bool) {
        
        guard _user != nil else  { return }
        
        if isRefresh {
            pageIndex = 1
        } else {
            pageIndex += 1
        }
        
        guard let myLocation = _user!.getUserLocation() else { return }
        let lat: Double = myLocation.latitude.format(".8")
        let long: Double = myLocation.longitude.format(".8")
        let distance = UserDefault.getInt(Constants.PREFKEY_DISTANCE, defaultValue: 10)
        
        WebService.getNearbyGroups(_user!._idx, lat: lat, long: long, distance: distance, pageIndex: pageIndex) { (status, message, list) in
            
            if self.upperRefreshControl.refreshing {
                self.upperRefreshControl.endRefreshing()
            }
            
            if self.bottomRefreshControl.refreshing {
                self.bottomRefreshControl.endRefreshing()
            }
            
            if status {
                
                if isRefresh {
                    self.itemDataSource.removeAll()
                }
                
                if list != nil {
                    self.itemDataSource += list!
                    
                    guard self.listTableView != nil else { return }
                    self.listTableView.reloadData()
                } else {
                    self.pageIndex -= 1
                }
            } else {
                self.pageIndex -= 1
            }
        }
    }
    
    // ROOM#1_11_22_1478243399349:1_11_22:test05#SYSTEM#test05$1_11_22_1478243399349$REQUEST**ROOM#20161106,07:14:36
    // send a group request message to group owner
    func sendGroupRequestMessage(requestGroup: GroupEntity) {
        
        let roomInfo = Constants.KEY_ROOM_MARKER + requestGroup.name + ":" + requestGroup.participants + ":" + _user!._name + Constants.KEY_SEPERATOR
        let requestMsg = _user!._name + "$" + requestGroup.name + "$" + Constants.KEY_REQUEST_MARKER
        let fullMsg = roomInfo + Constants.KEY_SYSTEM_MARKER + requestMsg + Constants.KEY_SEPERATOR + NSDate.utcString()
        
        let ownerIdx = requestGroup.ownerID
        guard ownerIdx > 0 else { return }
        
        WBAppDelegate.xmpp.sendMessage(fullMsg, to: ownerIdx)
    }
    
    // send a request message to server
    // it wil be change group request status
    func sendGroupRequest(requestGroup: GroupEntity, content: String) {
        
        showLoadingViewWithTitle("")
        
        var sendMsg = content
        if sendMsg.length == 0 {
            sendMsg = Constants.DEFAULT_REQUEST_MSG
        }
        
        WebService.sendGroupRequest(_user!._idx, requestGroup: requestGroup, content: sendMsg) { (status) in
            
            self.hideLoadingView()
            
            if status {
                
                requestGroup.isRequested = true
                self.listTableView.reloadData()
                
                self.showRequestCompletion()
            } else {
                
                self.showAlert(Constants.APP_NAME, message: Constants.FAIL_TO_CONNECT, positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
    
    func showRequestCompletion() {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertConfirmViewController") as! CustomAlertConfirmViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        customAlert.showCustomAlert(self, title: Constants.NOTE_GROUP_REQUEST, positive: Constants.ALERT_OK, positiveAction: {
            self.dismissViewControllerAnimated(true, completion: {
            })
        })
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

// MARK: @protocol - UITableViewDataSource and UITableViewDelegate
extension GroupListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rowCount = isSearch ? searchItemDataSource.count : itemDataSource.count
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactGroupCell") as! ContactGroupCell
        let group = isSearch ? searchItemDataSource[indexPath.row] : itemDataSource[indexPath.row]
//        cell.setContent(group, isSearch: true, actionBlock: nil)
        cell.setContent(group, isSearch: true) { (sender) in
            
            let storyboard = UIStoryboard(name: "Custom", bundle: nil)
            let customAlert = storyboard.instantiateViewControllerWithIdentifier("GroupRequestViewController") as! GroupRequestViewController
            customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            
            customAlert.showRequestDialog(self, group: group, confirmAction: { (reqContent) in
                
                self.sendGroupRequestMessage(group)
                self.sendGroupRequest(group, content: reqContent)
                
                }, cancelAction: { _ in
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // hide keyboard
        if searchField.isFirstResponder() {
            searchField.resignFirstResponder()
        }
        
        let group = isSearch ? searchItemDataSource[indexPath.row] : itemDataSource[indexPath.row]
        if _user!.isExistGroup(group) {
            
            guard let chatRoom = _user!.getRoom(group.name) else { return }
            
            // go to chat
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let chatVC = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            
            chatVC.chatRoom = chatRoom
            WBAppDelegate.xmpp.enterChattingRoom(chatRoom)
            
            if chatRoom._recentCount > 0 {
                
                WebService.reduceBadgeCount(_user!._idx, count: chatRoom._recentCount, completion: { (status) in
                })
            }
            
            _user!.notReadCount -= chatRoom._recentCount
            chatRoom._recentCount = 0
            
            // update tabBar badge
            WBAppDelegate.notifyReceiveNewMessage()
            
            // update database
            DBManager.getSharedInstance().updateRoom(chatRoom)
            
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
extension GroupListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // search group with key value
        searchGroup()
        
        return true
    }
}

// MARK: - @protocol UIScrollViewDelegate
extension GroupListViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        self.searchField.resignFirstResponder()
    }
}

// MARK: - @protocol indicator info provider : navigation sliding tab title of this viewcontroller
extension GroupListViewController: IndicatorInfoProvider  {
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}




