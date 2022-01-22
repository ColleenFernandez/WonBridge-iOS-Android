//
//  DepartureViewControler.swift
//  WonBridge
//
//  Created by Elite on 10/12/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

private let kRowCount: CGFloat = 3

class DepartureViewController: BaseViewController {
    
    var itemInfo = IndicatorInfo(title: Constants.TITLE_DEPARTURE)
    weak var stripDelegate: StripTitleHideDelegate?
    
    var menuItemSize: CGSize = CGSizeZero
    
    var itemDataSource: [(String, UIImage)] = []
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var listCollectionView: UICollectionView! { didSet {
        listCollectionView.backgroundColor = UIColor.whiteColor()
        }}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        
        initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        hideSearch()
    }
    
    func initData() {
        
        itemDataSource.append((Constants.DEPARTURE_SEARCH1, WBAsset.Departure_Item_1.image))
        itemDataSource.append((Constants.DEPARTURE_SEARCH2, WBAsset.Departure_Item_2.image))
        itemDataSource.append((Constants.DEPARTURE_SEARCH3, WBAsset.Departure_Item_3.image))
        itemDataSource.append((Constants.DEPARTURE_SEARCH4, WBAsset.Departure_Item_4.image))
        itemDataSource.append((Constants.DEPARTURE_SEARCH5, WBAsset.Departure_Item_5.image))
        itemDataSource.append((Constants.DEPARTURE_SEARCH6, WBAsset.Departure_Item_6.image))
        itemDataSource.append((Constants.DEPARTURE_SEARCH7, WBAsset.Departure_Item_7.image))
        itemDataSource.append((Constants.DEPARTURE_SEARCH8, WBAsset.Departure_Item_8.image))
    }
    
    func initView() {
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(textFieldDidChanged(_:)), forControlEvents: .EditingChanged)
        
        listTableView.dataSource = self
        listTableView.delegate = self
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        
        let width = self.view.width / kRowCount
        menuItemSize = CGSizeMake(width, width)
    }
    
    func textFieldDidChanged(textField: UITextField) {
        
        if textField.text!.isEmpty {
            textField.resignFirstResponder()
            hideSearch()
        }
    }
    
    func showSearchResult() {
        UIView.transitionWithView(listCollectionView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
            self.listCollectionView.hidden = true
            }, completion: nil)
    }
    
    func hideSearch() {
        UIView.transitionWithView(listCollectionView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
            self.listCollectionView.hidden = false
            }, completion: nil)
    }
    
    @IBAction func searchTapped(sender: AnyObject) {
        
        guard !searchField.text!.isEmpty else { return }
        
        searchField.resignFirstResponder()
        showSearchResult()
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        searchField.text = ""
        
        hideSearch()
    }
}

// MARK: - @protocol UITableViewDataSource, UITableViewDelegate
extension DepartureViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DepartureSearchCell") as! DepartureSearchCell
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TO DO
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DepatureDetailViewController") as! DepatureDetailViewController
        detailVC.hidesBottomBarWhenPushed = true
        stripDelegate?.hideStripTitleOnNavBar()
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - @protocol UICollectionViewDataSource
extension DepartureViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MenuItemCell", forIndexPath: indexPath) as! MenuItemCell
        cell.setContent(itemDataSource[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        showSearchResult()
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return menuItemSize
    }
}

// MARK: - @protocol UITextFieldDelegate
extension DepartureViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if !textField.text!.isEmpty {
            showSearchResult()
        }
        
        return true
    }
}

// MARK: - @protocol Indicator Info Providers
extension DepartureViewController: IndicatorInfoProvider {
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return itemInfo
    }
}
