//
//  ContactPartnerViewController.swift
//  WonBridge
//
//  Created by Roch David on 15/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import RxSwift

private let kContactPartnerListCellHeight: CGFloat = 70

class ContactPartnerViewController: BaseViewController {
    
    var itemInfo = IndicatorInfo(title: Constants.SLIDE_PARTNER)
    weak var stripDelegate: StripTitleHideDelegate?
    
    var _user: UserEntity?
    
    var itemDataSource = [FriendEntity]()
    var searchItemDataSource = [FriendEntity]()
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var listTableView: UITableView!
    
    @IBOutlet weak var partnerView: UIView!
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
        
        partnerView.hidden = false
    }
    
    func initView() {
        
        listTableView.tableFooterView = UIView()
        listTableView.rowHeight = kContactPartnerListCellHeight
    
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        partnerView.addGestureRecognizer(tap)
        tap.rx_event.subscribeNext { _ in
            self.showPartnerView(false)
            }.addDisposableTo(disposeBag)
        
        searchField.addTarget(self, action: #selector(textFeildDidChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func searchPartner() {
        
        searchField.resignFirstResponder()
    }
    
    func showPartnerView(visible: Bool) {
        
        if visible {
            partnerView.hidden = visible
        } else {
            UIView.transitionWithView(partnerView, duration: 0.4, options: .TransitionCrossDissolve, animations: {
                self.partnerView.hidden = true
                }, completion: nil)
        }
    }
    
    func textFeildDidChanged(textField: UITextField) {
        
        if textField.text!.isEmpty {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func searchButtonTapped(sender: AnyObject) {
        
        searchPartner()
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

// MARK: - Indicator Info Providers
extension ContactPartnerViewController: IndicatorInfoProvider {
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

// MARK: - @protocol UITableViewDataSource, UITableViewDelegate
extension ContactPartnerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactPartnerCell") as! ContactPartnerCell
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TO DO
    }
}

extension ContactPartnerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        searchPartner()
        return true
    }
}

// MARK: - @protocol UIScrollViewDelegate
extension ContactPartnerViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}






