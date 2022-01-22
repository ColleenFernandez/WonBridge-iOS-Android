//
//  InputProfileViewController.swift
//  WonBridge
//
//  Created by Roch David on 07/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import RxSwift

class InputProfileViewController: BaseTableViewController {
    
    var rootVC: InputProfileContainerViewController?
    
    var emailAddress: String?
    var phoneNumber: String?
    var wechatId: String?
    var qqId: String?
    
//    var isEmail = false
    
    var sex: GenderType = .NONE
    var strPhotoPath = ""
    var idx = 0
    var photoURL = ""
    
    let picker = UIImagePickerController()
    
    @IBOutlet weak var lblEmailAddress: UILabel!
    @IBOutlet weak var btnSex: UIButton!
    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var txtNickname: UITextField!
    @IBOutlet weak var lblSex: UILabel!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmPwdView: UIView!
    
    let disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
        tap.rx_event.subscribeNext { (_) in
            self.view.endEditing(true)
            }.addDisposableTo(disposebag)
        
        initView()
        
        picker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        
        if emailAddress != nil {
            lblEmailAddress.text = emailAddress!
        } else if phoneNumber != nil {
            lblEmailAddress.text = "+" + phoneNumber!
        } else if wechatId != nil {
            lblEmailAddress.text = wechatId!.substringToIndex(wechatId!.startIndex.advancedBy(10)) + "***"            
            passwordView.hidden = true
            confirmPwdView.hidden = true
            
            if let wechatPhotoUrl = UserDefault.getString(Constants.PREFKEY_WECHAT_PHOTOURL) {
                
                loadImageFromUrl(wechatPhotoUrl, completion: { (status, image) in
                    if status {
                        
                        self.strPhotoPath = CommonUtils.saveToFile(image, filePath: Constants.SAVE_ROOT_PATH, fileName: "profile.png")
                        self.imvProfile.contentMode = .ScaleToFill
                        self.imvProfile.image = UIImage(contentsOfFile: self.strPhotoPath)
                    }
                })
            }
            
            if let wechatNickname = UserDefault.getString(Constants.PREFKEY_WECHAT_NICKNAME) {
                txtNickname.text = wechatNickname
            }
            
        } else if qqId != nil {
            lblEmailAddress.text = qqId!.substringToIndex(qqId!.startIndex.advancedBy(10)) + "***"
            passwordView.hidden = true
            confirmPwdView.hidden = true
            
            if let qqPhotoUrl = UserDefault.getString(Constants.PREFKEY_QQ_PHOTOURL) {
                
                loadImageFromUrl(qqPhotoUrl, completion: { (status, image) in
                    if status {
                        
                        self.strPhotoPath = CommonUtils.saveToFile(image, filePath: Constants.SAVE_ROOT_PATH, fileName: "profile.png")
                        self.imvProfile.contentMode = .ScaleToFill
                        self.imvProfile.image = UIImage(contentsOfFile: self.strPhotoPath)
                    }
                })
            }
            
            if let qqNickname = UserDefault.getString(Constants.PREFKEY_QQ_NICKNAME) {
                txtNickname.text = qqNickname
            }
        }
    }

    // sex select action
    @IBAction func selectSexTapped(sender: AnyObject) {
        
        let alert = UIAlertController(title: nil, message: Constants.SEX_SELECTION  , preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let maleAction = UIAlertAction(title: Constants.SEX_MALE, style: UIAlertActionStyle.Default) { (alert) in

            self.lblSex.text = Constants.SEX_MALE
            self.sex = .MALE
        }
        
        let femaleAction = UIAlertAction(title: Constants.SEX_FEMALE, style: UIAlertActionStyle.Default) { (alert) in
            
            self.lblSex.text = Constants.SEX_FEMALE
            self.sex = .FEMALE
        }
        
        let cancelAction = UIAlertAction(title: Constants.ALERT_CANCEL, style: UIAlertActionStyle.Cancel) {(alert) in
        }
        
        alert.addAction(maleAction)
        alert.addAction(femaleAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func confirmTapped(sender: AnyObject) {
        
        if checkValid() {
            
            register()
        }
        
//        rootVC?.gotoLocationVC()
    }
    
    @IBAction func nicknameConflictBtnTapped(sender: AnyObject) {

    }
    
    @IBAction func userProfileImageTapped(sender: AnyObject) {
        
        let alert = UIAlertController(title: nil, message: nil  , preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let takePhotoAction = UIAlertAction(title: Constants.TAKE_PHOTO, style: UIAlertActionStyle.Default) { (alert) in
            
            self.openCamera()
        }
        
        let galleryAction = UIAlertAction(title: Constants.FROM_GALLERY, style: UIAlertActionStyle.Default) { (alert) in
            
            self.openGallery()
        }
        
        let cancelAction = UIAlertAction(title: Constants.ALERT_CANCEL, style: UIAlertActionStyle.Cancel) {(alert) in
        }
        
        alert.addAction(takePhotoAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // open phone camera
    func openCamera() {
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.allowsEditing = true
            picker.modalPresentationStyle = .FullScreen
            
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    // open gallery
    func openGallery() {
        
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.allowsEditing = true
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func loadImageFromUrl(urlString: String, completion: (status: Bool, image: UIImage?) -> Void) {
        
        let imgURL: NSURL = NSURL(string: urlString)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) in
            if error == nil {
                completion(status: true, image: UIImage(data: data!))
            } else {
                completion(status: false, image: nil)
            }
        }
    }
    
    func uploadProfileImage() {
        
        if strPhotoPath.isEmpty {
            
            self.hideLoadingView()
            
            onSuccessRegiser()
            
            return
        }
        
        WebService.addUserImage(idx, photoPath: strPhotoPath) { (status, message, photo_url) in
            
            self.hideLoadingView()
            
            self.photoURL = photo_url
            
            if !status {
                self.showToast(message)
            }
            
            self.onSuccessRegiser()
        }
    }
    
    func onSuccessRegiser() {
        
        let user = UserEntity()
        
        user._idx = self.idx
        user._name = txtNickname.text!
        
        if emailAddress != nil {
            user._email = emailAddress!
        } else if phoneNumber != nil {
            user._phoneNumber = phoneNumber!
        } else if wechatId != nil {
            user._wechatId = wechatId!
        } else if qqId != nil {
            user._qqId = qqId!
        }
        
        user._photoUrl = photoURL
        user._gender = sex
        user._password = txtPassword.text!
        
        WBAppDelegate.me = user
        
        rootVC?.gotoLocationVC()
    }
    
    func checkNickname() {
        
        var nickname = txtNickname.text!.stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH)
        nickname = nickname.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).encodeString()!
        
        showLoadingViewWithTitle("")
        
        WebService.checkNickName(nickname) { (status, message) in
            
            self.hideLoadingView()
            
            self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
        }
    }
    
    func checkValid() -> Bool {
        
        if txtNickname.text!.characters.count < kNickNameMinLength {
            
            self.showAlert(Constants.APP_NAME, message: Constants.INPUT_NICKNAME, positive: Constants.ALERT_OK, negative: nil)
            return false
        }
        
        if sex == .NONE {
            
            self.showAlert(Constants.APP_NAME, message: Constants.INPUT_SEX, positive: Constants.ALERT_OK, negative: nil)
            return false
        }
        
        guard wechatId == nil && qqId == nil else { return true }
        
        if txtPassword.text!.characters.count < kPasswordMinLength {
            
            self.showAlert(Constants.APP_NAME, message: Constants.INPUT_PASSWORD, positive: Constants.ALERT_OK, negative: nil)
            return false
        }
        
        if txtPassword.text != txtConfirmPassword.text {
            
            self.showAlert(Constants.APP_NAME, message: Constants.INPUT_CONFIRM, positive: Constants.ALERT_OK, negative: nil)
            return false
        }
        
        return true
    }
    
    func register() {
        
        showLoadingViewWithTitle("")
        
        var nickname = txtNickname.text!.stringByReplacingOccurrencesOfString("/", withString: Constants.SLASH)
        nickname = nickname.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).encodeString()!
//        let password = wechatId == nil ? txtPassword.text! : Constants.DEFAULT_WECHAT_PWD
        var password = txtPassword.text!
        
        if password.isEmpty {
            
            if wechatId != nil {
                password = Constants.DEFAULT_WECHAT_PWD
            } else if qqId != nil {
                password = Constants.DEFAULT_QQ_PWD
            }
        }
        
        var userAddress = ""
        var baseUrl = ""
        if emailAddress != nil {
            baseUrl = WebService.REQ_REGISTER
            userAddress = emailAddress!
        } else if phoneNumber != nil {
            baseUrl = WebService.REQ_REGISTERWITHPHONE
            userAddress = phoneNumber!
        } else if wechatId != nil {
            baseUrl = WebService.REQ_REGISTERWITHWECHAT
            userAddress = wechatId!
        } else if qqId != nil {
            baseUrl = WebService.REQ_REGISTERWITHQQ
            userAddress = qqId!
        }
        
        let sexuality = sex == .MALE ? 0 : 1
        let registerUrl = baseUrl + "/\(userAddress)/\(nickname)/\(sexuality)/\(password)"
        
        WebService.registerUser(registerUrl) { (status, message, idx) in
            
            if status {
                
                self.idx = idx
                self.uploadProfileImage()
            } else {
                
                self.hideLoadingView()
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
            }
        }
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

// MARK: UITextFieldDelegate
extension InputProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == txtNickname {
            
            txtPassword.becomeFirstResponder()
            
        } else if textField == txtPassword {
            
            txtConfirmPassword.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        guard textField == txtNickname || textField == txtPassword else { return true }
        
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        
        return newLength <= kNicknameMaxLength
    }
}

extension InputProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let chosenImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            strPhotoPath = CommonUtils.saveToFile(chosenImage, filePath: Constants.SAVE_ROOT_PATH, fileName: "profile.png")
            
            dispatch_async(dispatch_get_main_queue(), {
            
                self.imvProfile.contentMode = .ScaleAspectFit
                self.imvProfile.image = UIImage(contentsOfFile: self.strPhotoPath)
            })
        }
        
        dismissViewControllerAnimated(true, completion: nil)        
    }
}













