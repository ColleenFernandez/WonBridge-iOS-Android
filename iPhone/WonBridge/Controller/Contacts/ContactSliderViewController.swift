//
//  ContactSliderViewController.swift
//  WonBridge
//
//  Created by Roch David on 15/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class ContactSliderViewController: ButtonBarPagerTabStripViewController, StripTitleHideDelegate {

    override func viewDidLoad() {
        
        // setup style before super view did load is excuted
        settings.style.buttonBarBackgroundColor = UIColor.clearColor()
        settings.style.selectedBarBackgroundColor = UIColor.whiteColor()
        settings.style.selectedBarHeight = 2.0
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        // show buttonBarView for sliding tab title bar
        self.buttonBarView.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonBarView.hidden = false
    }
    
    func initView() {
        
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
    
    // MARK: - PagerTabStripDataSource
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let storyboard = UIStoryboard(name: "Contact", bundle: nil)
        
        let friendVC = storyboard.instantiateViewControllerWithIdentifier("ContactFriendViewController") as! ContactFriendViewController
        friendVC.stripDelegate = self
        
        let grpVC = storyboard.instantiateViewControllerWithIdentifier("ContactGroupViewController") as! ContactGroupViewController
        grpVC.stripDelegate = self
        
        let partnerVC = storyboard.instantiateViewControllerWithIdentifier("ContactPartnerViewController") as! ContactPartnerViewController
        
        return [friendVC, grpVC, partnerVC]
    }
    
    override func configureCell(cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo, indexPath: NSIndexPath) {
        
        super.configureCell(cell, indicatorInfo: indicatorInfo, indexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - StripTitleHideDelegate
    
    func hideStripTitleOnNavBar() {
        
        self.buttonBarView.hidden = true
    }

}
