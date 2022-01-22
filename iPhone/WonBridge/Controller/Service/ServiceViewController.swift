//
//  ServiceViewController.swift
//  WonBridge
//
//  Created by Elite on 10/12/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

private let kSlideTitleLeftPadding: CGFloat = 40

class ServiceViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        // setup style before super view did load is excuted
        settings.style.buttonBarBackgroundColor = UIColor.clearColor()
        settings.style.selectedBarBackgroundColor = UIColor.whiteColor()
        settings.style.selectedBarHeight = 2.0
        
        super.viewDidLoad()
        
        initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // show buttonBarView for sldiing tab title bar
        self.buttonBarView.hidden = false
    }
    
    func initView() {
      
        var frame = buttonBarView.frame
        frame.origin.x = kSlideTitleLeftPadding
        frame.size.width = self.view.frame.size.width - kSlideTitleLeftPadding*2
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
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let storyboard = UIStoryboard(name: "Service", bundle: nil)
        
        let serveVC = storyboard.instantiateViewControllerWithIdentifier("ServeViewController") as! ServeViewController
        serveVC.stripDelegate = self
        
        let departureVC = storyboard.instantiateViewControllerWithIdentifier("DepartureViewController") as! DepartureViewController
        departureVC.stripDelegate = self
        
        return [serveVC, departureVC]
    }
    
    override func configureCell(cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo, indexPath: NSIndexPath) {
        
        super.configureCell(cell, indicatorInfo: indicatorInfo, indexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
    }
}

// MARK: - @protocol StripTitleHideDelegate
extension ServiceViewController: StripTitleHideDelegate {
    
    func hideStripTitleOnNavBar() {
        self.buttonBarView.hidden = true
    }
}
