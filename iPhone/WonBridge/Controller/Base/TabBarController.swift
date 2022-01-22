//
//  TabBarController.swift
//  WonBridge
//
//  Created by Tiia on 01/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // change tabBar selection indicator image
        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: self.view.frame.width / numberOfItems, height: tabBar.frame.height)
        
        UITabBar.appearance().selectionIndicatorImage = UIImage.imageWithColor(UIColor(netHex: 0x23272c), size: tabBarItemSize)
        
        WBAppDelegate.gTabBar = self.tabBar
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
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

