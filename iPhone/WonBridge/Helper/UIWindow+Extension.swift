//
//  UIWindow+Extension.swift
//  WonBridge
//
//  Created by July on 2016-10-06.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

// extension UIWindow
extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(rootViewController)
        }
        
        return nil
    }
    
    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        
        if vc.isKindOfClass(UINavigationController.self) {
            
            // Return modal view controller if it exists. Otherwise the top view controller.
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom(navigationController.visibleViewController!)
            
        } else if vc.isKindOfClass(UITabBarController.self) {
            
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(tabBarController.selectedViewController!)
            
        } else {
            
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(presentedViewController.presentedViewController!)
            } else {
                return vc;
            }
        }
    }
}
