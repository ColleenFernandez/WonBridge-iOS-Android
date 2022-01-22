//
//  AppDelegate.swift
//  WonBridge
//
//  Created by Saville Briard on 16/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import JLToast
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var me: UserEntity!
    
    var xmpp: XmppEndPoint!
    
    var gTabBar: UITabBar?
    
//    var refreshBadgeDelegate: RefreshBadgeDelegate?
    
    var mapManager: BMKMapManager! = BMKMapManager()
    
    // Baidu Location Service
    var locService: BMKLocationService!
    
    var locManager: CLLocationManager!
    
    // ios app can present only one viewcontroller at once
    // when user may get calling request from partner
    // if user may have other presenting viewcontroller (like FilterVC)
    // then we have to dismiss this viewcontroller, then we can show call request viewcontroller
    // Application delegate will save the presentingviewcontroller for processing incoming call
    var presentVC: BaseViewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        WBApplicationManager.applicationConfigInit()
        
        me = UserEntity()        
        me.loadUserInfo()
        
        xmpp = XmppEndPoint(p_strHostName: XMPP_SERVER_URL, p_nHostPort: XMPP_HOSTPORT)
        
        if CommonUtils.isCNLocale() {
            let ret = mapManager.start(Constants.BAIDU_MAP_KEY, generalDelegate: nil)
            if ret {
                debugPrint("百度引擎设置成功！")
            }
        } else {
            GMSServices.provideAPIKey(Constants.GOOGLE_MAP_KEY)
        }
        
        // add statements to register your id on wechat while starting the app
        print(WXApi.registerApp(Constants.WECHAT_APP_ID, withDescription: "demo 2.0"))
        
        // Enable SSL globally for WebRTC in our app
        RTCPeerConnectionFactory.initializeSSL()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // regiter device token to
        
        ///
        // Disconnect xmpp
        // leave from joined room
        ///
        if xmpp.xmppStream != nil {
            
            if xmpp.xmppJoinRoom != nil && xmpp.xmppJoinRoom.isJoined {
                xmpp.xmppRoomJIDPaused = xmpp.xmppJoinRoom.myRoomJID
                xmpp.leaveRoomInBg()
            } else  {
                xmpp.xmppRoomJIDPaused = nil
            }
            
            if xmpp.isXmppConnected {
                xmpp.disconnect()
            }
            
            xmpp.teardownStream()
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // recover xmpp connect
        // it will be run in case to become active from background state
        // recover xmpp connect and connect to xmpp server
        if (xmpp.xmppStream == nil) {
            
            xmpp.setupStream()
            
            if (me!.isValid()) {
                if (xmpp.connect(me._idx, p_strPwd: me._password) == false) {
                    print("failed to connect to xmpp")
                }
            }
        }
        
        startLocationService()
        
        if me!.isValid() {
            
            let username = me!._email != "" ? me!._email : me!._phoneNumber
            WebService.checkDeviceId(username, completion: { (status, validId) in
                if status && validId != 0 {
                    
                    if let topViewController = self.window!.visibleViewController() {
                        // user is chatting with WonBridge Admin or other user
                        if !topViewController.isKindOfClass(ChatViewController) {
                            
                            self.autoLogout()
                        }
                    }
                }
            })
        }
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {

        let wechatSignIn = WXApi.handleOpenURL(url, delegate: WXApiManager.sharedManager())
        let qqSignIn = TencentOAuth.HandleOpenURL(url)
        
        return wechatSignIn || qqSignIn
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        let wechatSignIn = WXApi.handleOpenURL(url, delegate: WXApiManager.sharedManager())
        let qqSignIn = TencentOAuth.HandleOpenURL(url)

        return wechatSignIn || qqSignIn
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
//        print("DEVICE TOKEN = \(deviceToken)")
        
        var _deviceToken = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet.init(charactersInString: "<>"))
        _deviceToken = _deviceToken.stringByReplacingOccurrencesOfString(" ", withString: "")

        UserDefault.setString("device_token", value: _deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        print("user info: \(userInfo)")
        
        // process online message from push notification
        let push_data = JSON(userInfo)
        // do not process notification without alertbody
        guard let notiMsg = push_data["aps"]["alert"].string else {
            return
        }
        
        // do not process empty notification
        guard !notiMsg.isEmpty else { return }
        
        if application.applicationState == UIApplicationState.Active {
            
            // check topic of notification
            if let noti_topic = push_data["topic"].string {
                
                // process online message push notification
                if noti_topic == "online" {
                
                    if let topViewController = window!.visibleViewController() {
                        // user is chatting with WonBridge Admin or other user
                        if topViewController.isKindOfClass(ChatViewController) {
                            
                            let chatVC = topViewController as! ChatViewController
                            guard chatVC.isOnlineService else {
                                scheduleLocalPushNotification(notiMsg)
                                return
                            }
                            
                            // add push notification to chat
                            let content = push_data["content"].string!
                            
                            let fullMsg = chatVC.getRoomInfoString() + content + Constants.KEY_SEPERATOR + NSDate.utcString()
                            let chatItem = ChatEntity(message: fullMsg, sender: "\(0)", imageModel: nil)
                            chatVC.addMessage(chatItem)
                            
                            WBSystemSoundPlayer.playSoundWithType(.Chat)
//                            AudioPlayInstance.playSoundWithType(.Chat)
                            
                        } else {
                            // show local notification
                            // it will be only need to show push notification from admin
                            // do not process push notification message
                            scheduleLocalPushNotification(notiMsg)
                        }
                    }
                    
                } else if noti_topic == "logout" {
                    
                    autoLogout()
                    scheduleLocalPushNotification(notiMsg)
                } else if noti_topic == "rename" {
                    
                    let newRoom = push_data["content"].string
                    let roomName = push_data["content"].string
                    
                    guard newRoom != nil && roomName != nil else { return }
                    guard let existGroup = me!.getGroup(roomName!) else { return }
                    
                    existGroup.nickname = newRoom!
                    
                    if let topViewController = window!.visibleViewController() {
                        if topViewController.isKindOfClass(ChatTabListViewController) {
                            
                            let chatListVC = topViewController as! ChatTabListViewController
                            chatListVC.initChatList()
                        }
                    }
                }
            }
        } else if application.applicationState == UIApplicationState.Background {
            
            // TO DO
        } else if application.applicationState == UIApplicationState.Inactive {
            
            // TO DO
            // check topic of notification
            if let noti_topic = push_data["topic"].string {
                
                // process online message push notification
                if noti_topic == "online" {
                    
                    if let topViewController = window!.visibleViewController() {
                        // user is chatting with WonBridge Admin or other user
                        if topViewController.isKindOfClass(ChatViewController) {
                            
                            let chatVC = topViewController as! ChatViewController
                            guard chatVC.isOnlineService else {
                                return
                            }
                            
                            // add push notification to chat
                            let content = push_data["content"].string!
                            
                            let fullMsg = chatVC.getRoomInfoString() + content + Constants.KEY_SEPERATOR + NSDate.utcString()
                            let chatItem = ChatEntity(message: fullMsg, sender: "\(0)", imageModel: nil)
                            chatVC.addMessage(chatItem)
                            
                            WBSystemSoundPlayer.playSoundWithType(.Chat)
//                            AudioPlayInstance.playSoundWithType(.Chat)
                        }
                    }
                    
                } else if noti_topic == "logout" {
                    
                    autoLogout()
                    
                } else if noti_topic == "rename" {
                    
                    let newRoom = push_data["content"].string
                    let roomName = push_data["content"].string
                    
                    guard newRoom != nil && roomName != nil else { return }
                    guard let existGroup = me!.getGroup(roomName!) else { return }
                    
                    existGroup.nickname = newRoom!
                    
                    if let topViewController = window!.visibleViewController() {
                        if topViewController.isKindOfClass(ChatTabListViewController) {
                            
                            let chatListVC = topViewController as! ChatTabListViewController
                            chatListVC.initChatList()
                        }
                    }
                }
            }
        }
        
        completionHandler(.NoData)
    }
    
    func scheduleLocalPushNotification(alertBody: String) {

        let notification = UILocalNotification()
        notification.alertBody = alertBody
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        let _notification = LNNotification(message: notification.alertBody)
        CommonUtils.playSound()
        CommonUtils.vibrate()
        LNNotificationCenter.defaultCenter().presentNotification(_notification, forApplicationIdentifier: "123")
    }
    
    func autoLogout() {

        // should set auto-login preference avalue to false
        CommonUtils.setUserAutoLogin(false)
        // will close all xmpp connection
        xmpp.disconnect()
        
        // direct to login view
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginNAV = storyboard.instantiateViewControllerWithIdentifier("LoginNAV") as! NavigationController
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginNAV
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        RTCPeerConnectionFactory.deinitializeSSL()
        
        // if want then you can add logout here
    }
    
    // set badge number of tabbar
    func notifyReceiveNewMessage() {
        
        if me.notReadCount <= 0 {
            gTabBar?.setBadgeStyle(.StyleNone, value: 0, atIndex: 1)
        } else {
            gTabBar?.setBadgeStyle(.StyleNumber, value: me.notReadCount, atIndex: 1)
        }
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = me.notReadCount
        
//        refreshBadgeDelegate?.updateBadgeCount()
        
        WebService.setBadgeCount(me!._idx, count: me!.notReadCount)
    }
    
    /**
     *      present CallViewController
     *      completion: for processing call log ( senderId - message sender Idx, myId - my Id, message - log message)
     */
    func gotoCallVC(roomNumber: String, partnerName: String, partnerId: Int, videoEnable: Bool, isSender: Bool) {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        
        let callVC = storyboard.instantiateViewControllerWithIdentifier("CallViewController") as! CallViewController
        
        callVC.roomId = "videocall_" + roomNumber
        callVC.partnerName = partnerName
        callVC.videoEnable = videoEnable
        callVC.partnerId = partnerId
        
        callVC.isCaller = isSender

        self.window?.rootViewController?.presentViewController(callVC, animated: true, completion: nil)
        
        xmpp.sendVideoAcceptMessage(partnerId)
    }
    
    func showCallRequest(fromUserIdx: Int, fromUserName: String, roomName: String, videoEnable: Bool) {
        
        let storybard = UIStoryboard(name: "Custom", bundle: nil)
        
        let requestVC = storybard.instantiateViewControllerWithIdentifier("CallRequestViewController") as! CallRequestViewController
        
        requestVC.callerId = fromUserIdx
        requestVC.callerName = fromUserName
        requestVC.rooomId = roomName
        requestVC.videoEnable = videoEnable
        
        if presentVC != nil  {
            presentVC!.dismissViewControllerAnimated(false, completion: {
                self.window?.rootViewController?.presentViewController(requestVC, animated: true, completion: nil)
                return
            })
        }
        
        self.window?.rootViewController?.presentViewController(requestVC, animated: true, completion: nil)        
    }
    
    func startLocationService() {
        
        if CommonUtils.isCNLocale() {
            
            if locService == nil {
                locService = BMKLocationService()
            }
            
            locService.distanceFilter = 200
            locService.desiredAccuracy = kCLLocationAccuracyHundredMeters
            
            locService.delegate = self
            
            // start location service
            locService.startUserLocationService()
            
        } else {
            
            if locManager == nil {                
                locManager = CLLocationManager()
            }
            
            locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locManager.distanceFilter = 200
            
            locManager.requestWhenInUseAuthorization()
            
            locManager.delegate = self
            
            locManager.startUpdatingLocation()
        }
    }
    
    func stopLocationService() {
        
        if CommonUtils.isCNLocale() {
            
            locService.delegate = nil
            locService.stopUserLocationService()
            
        } else {
        
            locManager.delegate = nil
            locManager.stopUpdatingLocation()
        }
    }
}

extension AppDelegate: BMKLocationServiceDelegate {

    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        
        if userLocation != nil {
            
            var onceToken: dispatch_once_t = 0
            dispatch_once(&onceToken) {
                
                self.me.location = CLLocationCoordinate2D(latitude: userLocation.location.coordinate.latitude, longitude: userLocation.location.coordinate.longitude)
                
                self.me.saveUserLocation()
                
                self.stopLocationService()
            }
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last
        
        guard newLocation != nil else { return }
        
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            
            self.me.location = CLLocationCoordinate2D(latitude: newLocation!.coordinate.latitude, longitude: newLocation!.coordinate.longitude)
            self.me.saveUserLocation()
            self.stopLocationService()
        }
    }
}











