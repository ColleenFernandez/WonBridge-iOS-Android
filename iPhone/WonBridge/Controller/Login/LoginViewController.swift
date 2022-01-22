//
//  LoginViewController.swift
//  WonBridge
//
//  Created by Saville Briard on 16/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import RxSwift
import Material
import SwiftyJSON

private let kSplashImageViewTag = 200

class LoginViewController: BaseViewController ,UITextFieldDelegate {
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var _user: UserEntity?
    
    let disposebag = DisposeBag()
    
    var bAutoLogin: Bool = CommonUtils.getUserAutoLogin()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // udpate all chat - no current message
        // this is for loading only old messages
        DBManager.getSharedInstance().updateChatNoCurrent()
        
        self.navigationController?.navigationBarHidden = true
        
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        tap.rx_event.subscribeNext { (_) in
            self.view.endEditing(true)
        }.addDisposableTo(disposebag)
        
        // add wechat delegate
        WXApiManager.sharedManager().delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginSuccessed), name: kLoginSuccessed, object: sdkCall.getinstance())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginFailed), name: kLoginFailed, object: sdkCall.getinstance())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginCancelled), name: kLoginCancelled, object: sdkCall.getinstance())
     
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didGetUserInfo(_:)), name: kGetUserInfoResponse, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        _user = WBAppDelegate.me
        
//        UIApplication.sharedApplication().statusBarHidden = true
        bAutoLogin = CommonUtils.getUserAutoLogin()
        
        if bAutoLogin {
            
            // add splash image here
            let splashImageView = UIImageView(frame: CGRectMake(0, 0, self.view.width, self.view.height))
            splashImageView.image = WBAsset.SplashBkg.image
            splashImageView.tag = kSplashImageViewTag
            self.view.addSubview(splashImageView)
            self.view.bringSubviewToFront(splashImageView)
            splashImageView.userInteractionEnabled = true
            
            _user!._email = UserDefault.getString(Constants.pref_user_email, defaultValue: "")!
            _user!._phoneNumber = UserDefault.getString(Constants.pref_user_phonenumber, defaultValue: "")!
            _user!._wechatId = UserDefault.getString(Constants.pref_user_wechatId, defaultValue: "")!
            _user!._password = UserDefault.getString(Constants.pref_user_passsowrd, defaultValue: "")!
            _user!._qqId = UserDefault.getString(Constants.pref_user_qqId, defaultValue: "")!
            
            let userAddress = _user!._email != "" ? _user!._email : _user!._phoneNumber
            if userAddress != "" {
                
                usernameText.text = userAddress
                passwordText.text = _user!._password
                checkDeviceId()
            } else if _user!._wechatId.characters.count > 0 {
                
                doLoginWithWeChat(_user!._wechatId)
            } else if _user!._qqId.characters.count > 0 {
                
                doLoginWithQQ(_user!._qqId)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if(textField == usernameText) {
            passwordText.becomeFirstResponder()
        } else if(textField == passwordText) {
            self.view.endEditing(true)
        }
        
        textField.resignFirstResponder()
        return true
    }

    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        if(checkValid()) {
            checkDeviceId()
        }
    }
    
    
    
    // Forgot Pasword Tapped
    @IBAction func forgotPasswordTapped(sender: AnyObject) {
        
        self.view.endEditing(true)
    }
    
    // Register Button Tapped
    @IBAction func registerButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
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
            
            doLoginWithWeChat(wechatId)
            
        } else {
            
            showAlert(Constants.APP_NAME, message: Constants.INSTALL_WECHAT, positive: Constants.ALERT_OK, negative: nil)
        }
    }
    
    // QQ login action
    @IBAction func qqLoginTapped(sender: AnyObject) {
        
        if TencentOAuth.iphoneQQSupportSSOLogin() {
            
            if let qqId = UserDefault.getString(Constants.PREFKEY_QQ_OPENID) {
                
                doLoginWithQQ(qqId)
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
            
            doLoginWithQQ(openID)
        }
    }
    
    func loginFailed() {
        self.showAlert(Constants.APP_NAME, message: Constants.FAILED_QQ, positive: Constants.ALERT_OK, negative: nil)
    }
    
    func loginCancelled() {
        self.showAlert(Constants.APP_NAME, message: Constants.FAILED_QQ, positive: Constants.ALERT_OK, negative: nil)
    }
    
    // MARK: @qq notification didGetUserInfo
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
        
        doLoginWithQQ(openID)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func showGotoSignupDialog() {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertViewController") as! CustomAlertViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        customAlert.statusBarHidden = prefersStatusBarHidden()
        
        customAlert.showCustomAlert(self, title: Constants.UNREGISTER_IN_SOCIAL, positive: Constants.ALERT_OK, negative: Constants.ALERT_CANCEL, positiveAction: {
            self.gotoSignupPage()
        }) {}
    }
    
    // go to sign up page
    func gotoSignupPage() {
        self.performSegueWithIdentifier("SegueLogin2Signup", sender: self)
    }
    
    // check input valid
    func checkValid() -> Bool {
        
        self.view.endEditing(true)
        
        if usernameText.text!.isEmpty {
            
            showAlert(nil, message: Constants.INPUT_NAME, positive: Constants.ALERT_OK, negative:nil, positiveAction: nil, negativeAction: nil, completion: nil)
            
            return false
            
        } else if passwordText.text!.isEmpty {
            
            showAlert(nil, message: Constants.INPUT_PASSWORD, positive: Constants.ALERT_OK, negative: nil, positiveAction: nil, negativeAction: nil, completion: nil)
            
            return false
        }
        
        return true
    }
    
    func checkDeviceId() {
        
        let username = usernameText.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if !bAutoLogin {
            showLoadingViewWithTitle("")
        }
        
        WebService.checkDeviceId(username!) { (status, validId) in
            
            if status {
                
                if validId == 0 {
                    
                    self.doLogin()
                } else if validId == 1 {
                    
                    if !self.bAutoLogin {
                        self.hideLoadingView()
                    }
                    
                    self.removeSplash()
                    
                    // unregistered user
                    self.showAlert(Constants.APP_NAME, message: Constants.UNREGISTERED_USER, positive: Constants.ALERT_OK, negative: nil)
                    
                } else {
                    
                    if !self.bAutoLogin {
                        self.hideLoadingView()
                    }
                    self.removeSplash()
                    // show logout dialog
                    self.showLogoutDialog()
                }
                
            } else { 
                
                if !self.bAutoLogin {
                    self.hideLoadingView()
                }
                self.showAlert(Constants.APP_NAME, message: Constants.FAIL_TO_CONNECT, positive: Constants.ALERT_OK, negative: nil)
                self.removeSplash()
            }
        }
    }
    
    func showLogoutDialog() {
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertViewController") as! CustomAlertViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        customAlert.statusBarHidden = prefersStatusBarHidden()
        
        customAlert.showCustomAlert(self, title: Constants.WRONG_DEVICE, positive: Constants.ALERT_OK, negative: Constants.ALERT_CANCEL, positiveAction: {
            
                self.doLogin()
            }, negativeAction: {
                
                CommonUtils.setUserAutoLogin(false)
                WBAppDelegate.xmpp.disconnect()
                
                // exit applicaiton
                exit(0)
        })
    }
    
    func doLogin(){
       
        if !bAutoLogin {
            showLoadingViewWithTitle("")
        }
        
        let username = usernameText.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let password = passwordText.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        WebService.login(username, password: password, success: { (status, message, user) in
            
            user._password = password!
            
            self._user!.setUserInfo(user)
            CommonUtils.setUserAutoLogin(true)
            
            // clear db if you're logging in with different account.
            if self._user!.checkNewUser() {
                print("You're logging in with different account.\nThis will be clear DB.")
            }
            
            self._user!.saveUserInfo()
            
            CommonUtils.isSocialLogin = false
            
            self.getFriends()
            
            }) { (resultCode, message) in
                
                if !self.bAutoLogin {
                    self.hideLoadingView()
                }
                
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
                
                self.removeSplash()
        }
    }
    
    func doLoginWithWeChat(wechatId: String) {
        
        if !bAutoLogin {
            showLoadingViewWithTitle("")
        }
        
        WebService.loginWithWechat(wechatId, success: { (status, message, user) in
            
            self._user!.setUserInfo(user)
            CommonUtils.setUserAutoLogin(true)
            
            // clear db if you're logging in with different account.
            if let oldWeChatID = UserDefault.getString(Constants.pref_user_wechatId) {
                if oldWeChatID != self._user!._wechatId {
                    
                    DBManager.getSharedInstance().clearDB()
                }
            }
            
            self._user!.saveUserInfo()
            CommonUtils.isSocialLogin = true
            
            self.getFriends()
            
        }) { (resultCode, message) in
            
            if !self.bAutoLogin {
                self.hideLoadingView()
            }
            
            if resultCode == WebService.CODE_UNREGISTERED {
                self.showGotoSignupDialog()
            } else {
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
            }
            
            self.removeSplash()
        }
    }
    
    func doLoginWithQQ(qqId: String) {
       
        if !bAutoLogin {
            showLoadingViewWithTitle("")
        }
        
        WebService.loginWithQQ(qqId, success: { (status, message, user) in
            
            self._user!.setUserInfo(user)
            CommonUtils.setUserAutoLogin(true)
            
            // clear db if you're logging in with different account.
            if let oldQQId = UserDefault.getString(Constants.pref_user_qqId) {
                if oldQQId != self._user!._qqId {
                    
                    DBManager.getSharedInstance().clearDB()
                }
            }
            
            self._user!.saveUserInfo()
            CommonUtils.isSocialLogin = true
            
            self.getFriends()
            
            }) { (resultCode, message) in
                
                if !self.bAutoLogin {
                    self.hideLoadingView()
                }
                
                if resultCode == WebService.CODE_UNREGISTERED {
                    self.showGotoSignupDialog()
                } else {
                    self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
                }
             
                self.removeSplash()
        }
    }
    
    func removeSplash() {
        
        guard let splashImageView = self.view.viewWithTag(kSplashImageViewTag) else { return }
        splashImageView.removeFromSuperview()
        self.bAutoLogin = false
    }
    
    func getFriends() {
        
        WebService.getFriends(_user!._idx, pageIndex: 1) { (status, message, friendList) in
            
            if status {
                
                for _friend in friendList {
                    self._user!._frList.append(_friend)
                }
            }

            self.getBlockList()
        }
    }
    
    func getBlockList() {
        
        WebService.getBlockUsers(_user!._idx) { (status, message, blockList) in
            
            if status {
                for blockUser in blockList {
                    self._user!._blockList.append(blockUser)
                }
            }
            
            self.getNotiData()
        }
    }
    
    func getNotiData() {
        
        WebService.getNoteData { (status, noti) in
            
            if status {
                
                CommonUtils.wonbridgeTimeLine = noti
            }
            
            self.loadGroupList()
        }
    }
    
    func loadGroupList() {
        
        WebService.loadGroup(_user!._idx) { (status, message, list) in
            
            if (status) {
                for group in list! {
                    self._user!._groupList.append(group)
                }
            }
            
            self.loadRoomList()
        }
    }
    
    // load room list from db
    func loadRoomList() {
    
        // clear unread message count
        _user!.notReadCount = 0
        
        // clear user's room list
//        if _user!._roomList.count != 0 {
            _user!._roomList.removeAll()
//        }
        
        let arrRoom = DBManager.getSharedInstance().loadRoom()
        
        var _nReqCount = arrRoom.count
        if (_nReqCount == 0) {
            
            if (WBAppDelegate.xmpp.connect(_user!._idx, p_strPwd: _user!._password)) {
                
                registerDeviceToken()
            } else {
                
                if !self.bAutoLogin {
                    self.hideLoadingView()
                }
                
                guard let splashImageView = self.view.viewWithTag(kSplashImageViewTag) else { return }
                splashImageView.removeFromSuperview()
                self.bAutoLogin = false
                
                showToast(Constants.FAIL_TO_CONNECT)
            }
            
        } else {
            
            for index in 0 ..< arrRoom.count {
                
                let _room: RoomEntity = arrRoom[index]
                
                _user!.notReadCount += _room._recentCount
                
                let _participantsName = _room.participantsWithLeaveMembers()
                WebService.getRoomInfo(_user!._idx, participantName: _participantsName, completion: { (status, participants) in
                    
                    if (status) {
                        
                        _room._participantList = participants
                        _room.makeRoomDisplayName()
                        
                        if !self._user!._roomList.contains(_room) {
                            self._user!._roomList.append(_room)
                        }
                    }
                    
                    _nReqCount -= 1
                    
                    if (_nReqCount <= 0) {
                        
                        if (WBAppDelegate.xmpp.connect(self._user!._idx, p_strPwd: self._user!._password)) {
                            
                            self.registerDeviceToken()
                            
                        } else {
                            
                            if !self.bAutoLogin {
                                self.hideLoadingView()
                            }
                            
                            guard let splashImageView = self.view.viewWithTag(kSplashImageViewTag) else { return }
                            splashImageView.removeFromSuperview()
                            self.bAutoLogin = false
                            
                            self.showToast(Constants.FAIL_TO_CONNECT)
                        }
                    }
                })
            }
        }        
    }
    
    // go to main
    func registerDeviceToken() {
        
        guard let deviceToken = UserDefault.getString("device_token") else {
            
            gotoMain()
            return
        }
        
        WebService.registerDeviceToken(deviceToken, userId: _user!._idx) { (status) in
            
            if !self.bAutoLogin {
                self.hideLoadingView()
            }
         
            if status {
//                print("device token registered successfully.")
            }
            
            self.gotoMain()
        }
    }
    
    func gotoMain() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tabbar = storyboard.instantiateViewControllerWithIdentifier("MainTabbar")
        UIApplication.sharedApplication().keyWindow?.rootViewController = tabbar
        
        WBAppDelegate.notifyReceiveNewMessage()
    }
    
    func buildAccessTokenLink(code: String) -> String {
        return Constants.WECHAT_ACCESSTOKEN_PREFIX + "appid=\(Constants.WECHAT_APP_ID)&secret=\(Constants.WECHAT_SECRET)&code=\(code)&grant_type=authorization_code"
    }
    
    func buildUserInfoLink(openID: String, accessToken: String) -> String {
        return Constants.WECHAT_USERINFO_PREFIX + "access_token=\(accessToken)&openid=\(openID)"
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

            self.doLoginWithWeChat(openId)
        }
    }
}

// MARK:- @protocol WXApiManagerDelegate
extension LoginViewController: WXApiManagerDelegate {
    
    func managerDidRecvAuthResponse(response: SendAuthResp) {

        if response.code != nil {
            getAccessToken(buildAccessTokenLink(response.code))
        } else {
            self.showAlert(Constants.APP_NAME, message: Constants.FAILED_WECHAT, positive: Constants.ALERT_OK, negative: nil)
        }
    }
}






