//
//  NavigationController.swift
//  WonBridge
//
//  Created by Tiia on 30/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // hide 1px bottom line of navigation bar
        let image = UIImage()
        
        navigationBar.shadowImage = image
        navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
        navigationBar.backgroundColor = UIColor(colorLiteralRed: 52/255, green: 102/255, blue: 173/255, alpha: 1)

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
