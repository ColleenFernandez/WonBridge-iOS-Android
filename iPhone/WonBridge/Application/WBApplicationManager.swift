//
//  WBApplicationManager.swift
//  WonBridge
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import Foundation

class WBApplicationManager: NSObject {

    static func applicationConfigInit() {
        
        self.setup()
        
        self.initNavigationBar()
        
        self.initNotifications()
        
        WBProgressHUD.wb_initHUD()
    }
    
    /**
     Custom NavigationBar
     */
    static func initNavigationBar() {
        
        UINavigationBar.appearance().barTintColor = UIColor(netHex: 0x3366AD)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().translucent = false
        
        let attributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(19.0),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attributes
    }
    
    /**
     Register remote notification
     */
    static func initNotifications() {
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        LNNotificationCenter.defaultCenter().registerApplicationWithIdentifier("123", name: Constants.APP_NAME, icon: WBAsset.WonBridge.image, defaultSettings: LNNotificationAppSettings.defaultNotificationAppSettings())
    }
    
    static func setup() {
        
        CommonUtils.createUploadFolder()        
        CommonUtils.createDownloadFolder()
    }
}
