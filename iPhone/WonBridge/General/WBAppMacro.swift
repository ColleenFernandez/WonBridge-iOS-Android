//
//  WBAppMacro.swift
//  WonBridge
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

// delegate
let WBAppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

let kSandDocumentPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!


let TIMELINE_MAX_CNT                    =               30
let kNicknameMaxLength                  =               15
let kNickNameMinLength                  =               2
let kPasswordMinLength                  =               4

// Toast Duration Constants
let TOAST_SHORT                         =               1.5
let TOAST_LONG                          =               3.0

//let SERVICE_PHONE_NUMBER                =               "156-4331-9561"

let SERVICE_PHONE_NUMBER                =               "400-012-9288"

let SERVICE_EMAIL_ADDRESS               =               "service@wonbridge.com"

let XMPP_SERVER_URL                     =               "52.78.120.201"
let XMPP_HOSTPORT                       =               5222
let XMPP_RESOURCE                       =               "WonBridge"

let RTC_SERVER                          =               "http://52.78.101.116:8080"

let DEVICE_TYPE                         =               1

class WBConfig {
    
    static let ExpressionBundle = NSBundle(URL: NSBundle.mainBundle().URLForResource("Expression", withExtension: "bundle")!)
    static let ExpressionBundleName = "Expression.bundle"
    static let ExpressionPlist = NSBundle.mainBundle().pathForResource("Expression", ofType: "plist")
}