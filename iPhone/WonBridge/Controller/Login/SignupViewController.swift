//
//  SignupViewController.swift
//  WonBridge
//
//  Created by Roch David on 07/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignupViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // add wechat delegate
        WXApiManager.sharedManager().delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginSuccessed), name: kLoginSuccessed, object: sdkCall.getinstance())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginFailed), name: kLoginFailed, object: sdkCall.getinstance())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginCancelled), name: kLoginCancelled, object: sdkCall.getinstance())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didGetUserInfo(_:)), name: kGetUserInfoResponse, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // wechat login action
    @IBAction func wechatLoginTapped(sender: AnyObject) {
        
        // send auth request
        if WXApi.isWXAppSupportApi() {
            
            guard let wechatId = UserDefault.getString(Constants.PREF_WECHAT_OPENID) else {
                
                let request = SendAuthReq()
                request.scope = "snsapi_userinfo"
                request.state = "wechat_sdk_access"
                WXApi.sendReq(request)
                
                return
            }
            
            gotoInputProfileView(wechatId, isWeChat: true)
            
        } else {
            
            showAlert(Constants.APP_NAME, message: Constants.INSTALL_WECHAT, positive: Constants.ALERT_OK, negative: nil)
        }
    }
    
    // QQ login action
    @IBAction func qqLoginTapped(sender: AnyObject) {
        
        if TencentOAuth.iphoneQQSupportSSOLogin() {
            
            if let qqId = UserDefault.getString(Constants.PREFKEY_QQ_OPENID) {
                
                gotoInputProfileView(qqId, isWeChat: false)
                
            } else {
                
                let permissions = [kOPEN_PERMISSION_GET_USER_INFO,
                                   kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                   kOPEN_PERMISSION_ADD_ALBUM,
                                   kOPEN_PERMISSION_ADD_ONE_BLOG,
                                   kOPEN_PERMISSION_ADD_SHARE,
                                   kOPEN_PERMISSION_ADD_TOPIC,
                                   kOPEN_PERMISSION_CHECK_PAGE_FANS,
                                   kOPEN_PERMISSION_GET_INFO,
                                   kOPEN_PERMISSION_GET_OTHER_INFO,
                                   kOPEN_PERMISSION_LIST_ALBUM,
                                   kOPEN_PERMISSION_UPLOAD_PIC,
                                   kOPEN_PERMISSION_GET_VIP_INFO,
                                   kOPEN_PERMISSION_GET_VIP_RICH_INFO]
                
                sdkCall.getinstance().oauth.authorize(permissions, inSafari: false)
            }
        } else {
            
            showAlert(Constants.APP_NAME, message: Constants.INSTALL_QQ, positive: Constants.ALERT_OK, negative: nil)
        }
    }
    
    // MARK: QQ Login Processing
    func loginSuccessed() {
        
        if !sdkCall.getinstance().oauth.getUserInfo() {
            
            let openID = sdkCall.getinstance().oauth.openId
            UserDefault.setString(Constants.PREFKEY_QQ_OPENID, value: openID)
            
            gotoInputProfileView(openID, isWeChat: false)
        }
    }
    
    func loginFailed() {
        self.showAlert(Constants.APP_NAME, message: Constants.FAILED_QQ, positive: Constants.ALERT_OK, negative: nil)
    }
    
    func loginCancelled() {
        self.showAlert(Constants.APP_NAME, message: Constants.FAILED_QQ, positive: Constants.ALERT_OK, negative: nil)
    }
    
    func didGetUserInfo(notification: NSNotification) {
        
        let userInfo = notification.userInfo! as NSDictionary
        let apiResp = userInfo.objectForKey(kResponse) as! APIResponse
        
        let jsonResult = JSON(data: (apiResp.message as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        var photoUrl = ""
        if let fileUrl = jsonResult["figureurl_qq_2"].string {
            photoUrl = fileUrl
        }
        
        var nickname = ""
        if let _nickname = jsonResult["nickname"].string {
            nickname = _nickname
            
            if nickname.length > 15 {
                nickname = nickname.substringToIndex(nickname.startIndex.advancedBy(kNicknameMaxLength))
            }
        }
        
        let openID = sdkCall.getinstance().oauth.openId
        
        UserDefault.setString(Constants.PREFKEY_QQ_OPENID, value: openID)
        if !photoUrl.isEmpty {
            UserDefault.setString(Constants.PREFKEY_QQ_PHOTOURL, value: photoUrl)
        }
        
        if !nickname.isEmpty {
            UserDefault.setString(Constants.PREFKEY_QQ_NICKNAME, value: nickname)
        }
        
        gotoInputProfileView(openID, isWeChat: false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func gotoInputProfileView(openID: String, isWeChat: Bool) {
        
        let inputProfileVC = self.storyboard?.instantiateViewControllerWithIdentifier("InputProfileContainerViewController") as! InputProfileContainerViewController
        
        if isWeChat {
            inputProfileVC.wechatId = openID
        } else {
            inputProfileVC.qqId = openID
        }
        
        self.navigationController?.pushViewController(inputProfileVC, animated: true)
    }
    
    func getAccessToken(url: String) {
        WebService.getWeChatAccessToken(url) { (status, token) in

            if status {
                
                UserDefault.setString(Constants.PREF_WECHAT_OPENID, value: token.1)
                self.getUserInfo(token.0, openId: token.1)
                
            } else {
                self.showAlert(Constants.APP_NAME, message: Constants.FAILED_WECHAT, positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
    
    func getUserInfo(accessToken: String, openId: String) {
        
        let url = buildUserInfoLink(openId, accessToken: accessToken)
        WebService.getWeChatUserInfo(url) { (status, headImageUrl, nickname) in
            
            if (status) {
                if !headImageUrl.isEmpty {
                    UserDefault.setString(Constants.PREFKEY_WECHAT_PHOTOURL, value: headImageUrl)
                }
                
                if !nickname.isEmpty {
                    UserDefault.setString(Constants.PREFKEY_WECHAT_NICKNAME, value: nickname)
                }
            }
            
            self.gotoInputProfileView(openId, isWeChat: true)
        }
    }
    
    func buildAccessTokenLink(code: String) -> String {
        return Constants.WECHAT_ACCESSTOKEN_PREFIX + "appid=\(Constants.WECHAT_APP_ID)&secret=\(Constants.WECHAT_SECRET)&code=\(code)&grant_type=authorization_code"
    }
    
    func buildUserInfoLink(openID: String, accessToken: String) -> String {
        return Constants.WECHAT_USERINFO_PREFIX + "access_token=\(accessToken)&openid=\(openID)"
    }

}

// MARK:- @protocol WXApiManagerDelegate
extension SignupViewController: WXApiManagerDelegate {
    
    func managerDidRecvAuthResponse(response: SendAuthResp) {
        
        if response.code != nil {
            getAccessToken(buildAccessTokenLink(response.code))
        } else {
            self.showAlert(Constants.APP_NAME, message: Constants.FAILED_WECHAT, positive: Constants.ALERT_OK, negative: nil)
        }
    }
}
