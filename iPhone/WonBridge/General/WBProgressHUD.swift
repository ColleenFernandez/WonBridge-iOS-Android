//
//  WBProgresHUD.swift
//  WonBridge
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import SVProgressHUD

class WBProgressHUD: NSObject {

    class func wb_initHUD() {
        
        // background and foregroud color will be applied on custom style.
        SVProgressHUD.setFont(UIFont.systemFontOfSize(14))
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
    }
    
    class func wb_show() {
        
        SVProgressHUD.show()
    }
    
    //成功
    class func wb_showSuccessWithStatus(string: String) {
        self.WBProgressHUDShow(.Success, status: string)
    }
    
    //失败 ，NSError
    class func wb_showErrorWithObject(error: NSError) {
        self.WBProgressHUDShow(.ErrorObject, status: nil, error: error)
    }
    
    //失败，String
    class func wb_showErrorWithStatus(string: String) {
        self.WBProgressHUDShow(.ErrorString, status: string)
    }
    
    //转菊花
    class func wb_showWithStatus(string: String) {
        self.WBProgressHUDShow(.Loading, status: string)
    }
    
    //警告
    class func wb_showWarningWithStatus(string: String) {
        self.WBProgressHUDShow(.Info, status: string)
    }
    
    //dismiss消失
    class func wb_dismiss() {
        SVProgressHUD.dismiss()
    }
    
    //私有方法
    private class func WBProgressHUDShow(type: HUDType, status: String? = nil, error: NSError? = nil) {
        switch type {
        case .Success:
            SVProgressHUD.showSuccessWithStatus(status)
            break
        case .ErrorObject:
            guard let newError = error else {
                SVProgressHUD.showErrorWithStatus("Error:出错拉")
                return
            }
            
            if newError.localizedFailureReason == nil {
                SVProgressHUD.showErrorWithStatus("Error:出错拉")
            } else {
                SVProgressHUD.showErrorWithStatus(error!.localizedFailureReason)
            }
            break
        case .ErrorString:
            SVProgressHUD.showErrorWithStatus(status)
            break
        case .Info:
            SVProgressHUD.showInfoWithStatus(status)
            break
        case .Loading:
            SVProgressHUD.showWithStatus(status)
            break
        }
    }
    
    private enum HUDType: Int {
        case Success, ErrorObject, ErrorString, Info, Loading
    }
}
