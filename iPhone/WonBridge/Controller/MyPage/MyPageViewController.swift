//
//  MyPageViewController.swift
//  WonBridge
//
//  Created by Roch David on 15/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class MyPageViewController: BaseTableViewController {
    
    // global user - me
    var _user: UserEntity?
    
    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var lblEmailAddress: UILabel!
    @IBOutlet weak var lblNickName: UILabel!
    @IBOutlet weak var lblSex: UILabel!
    @IBOutlet weak var lblAppId: UILabel!
    
    @IBOutlet weak var locationShareSwitch: UISwitch!
    
    @IBOutlet weak var timeLineShareSwitch: UISwitch!
    
    let picker = UIImagePickerController()
    
    var strPhotoPath = ""
    
    @IBOutlet weak var lblSchool: UILabel!
    @IBOutlet weak var lblVillage: UILabel!
    @IBOutlet weak var lblFavCountry: UILabel!
    @IBOutlet weak var lblWorking: UILabel!
    @IBOutlet weak var lblInterest: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _user = WBAppDelegate.me
        
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        imvProfile.setImageWithUrl(NSURL(string: _user!._photoUrl)!, placeHolderImage: WBAsset.UserPlaceHolder.image)
        lblEmailAddress.text = _user!._email
        lblNickName.text = _user!._name
//        lblSex.text = _user!.
        lblAppId.text = "ab12456"
        
        lblSchool.text = _user!._school != "" ? _user!._school : Constants.NO_INPUT
        lblVillage.text = _user!._village != "" ? _user!._village : Constants.NO_INPUT
        lblFavCountry.text = _user!._favCountry != "" ? CommonUtils.getDisplayCountryName(_user!._favCountry) : Constants.NO_INPUT
        lblWorking.text = _user!._working != "" ? _user!._working : Constants.NO_INPUT
        lblInterest.text = _user!._interest != "" ? _user!._interest : Constants.NO_INPUT
        
        locationShareSwitch.setOn(_user!._isPublicLocation, animated: false)
        timeLineShareSwitch.setOn((_user!._isPublicTimeLine), animated: false)
    }
    @IBAction func profileChangeBtnTapped(sender: UIButton) {
        
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
        
        picker.delegate = self
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.allowsEditing = true
            picker.modalPresentationStyle = .FullScreen
            
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.allowsEditing = true
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    // MARK: - Unwind Segue
    @IBAction func unwind2MyProfile(segue: UIStoryboardSegue) {
        
        if segue.identifier == "SegueChangeNickName2MyPage" {
            
            let changeNickNameVC = segue.sourceViewController as! ChangeNicknameViewController
            lblNickName.text = changeNickNameVC.txfNickname.text
        } else if segue.identifier == "unwindCountry2MyProfile" {
            
            let sourceVC = segue.sourceViewController as! SelectCountryViewController
            lblFavCountry.text = sourceVC.selectedCountry!.name
            
        } else if segue.identifier == "unwindInterest2MyPage" {
            
            let sourceVC = segue.sourceViewController as! ChangeInterestViewController
            lblInterest.text = sourceVC.interest
            
        } else if segue.identifier == "unwindWorking2MyPage" {
            
            let sourceVC = segue.sourceViewController as! ChangeWorkingViewController
            lblWorking.text = sourceVC.working
            
        } else if segue.identifier == "unwindSchoo2MyPage" {
            
            let sourceVC = segue.sourceViewController as! ChangeSchoolViewController
            lblSchool.text = sourceVC.school
            
        } else if segue.identifier == "unwindVailllage2MyPage" {
            
            let sourceVC = segue.sourceViewController as! ChangeVillageViewController
            lblVillage.text = sourceVC.village
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
    
    // - share location change action
    @IBAction func shareLocationBtnTapped(sender: AnyObject) {
    
        let isPublic = _user!._isPublicLocation ? 0 : 1
        
        showLoadingViewWithTitle("")
        
        WebService.shareLocation(_user!._idx, shareStatus: isPublic) { (status, message) in
            
            self.hideLoadingView()
            
            if status {
                
                self.locationShareSwitch.setOn(isPublic == 1, animated: true)
                
                self._user!._isPublicLocation = (isPublic == 1)
                
            } else {
                
                self.showToast(message)
            }
        }        
    }
    
    // - share timeline change action
    @IBAction func shareTimeLineBtnTapped(sender: AnyObject) {
        
        let isPublic = _user!._isPublicTimeLine ? 0 : 1
        
        showLoadingViewWithTitle("")
        
        WebService.shareLocation(_user!._idx, shareStatus: isPublic) { (status, message) in
            
            self.hideLoadingView()
            
            if status {
                
                self.timeLineShareSwitch.setOn(isPublic == 1, animated: true)
                
                self._user!._isPublicTimeLine = (isPublic == 1)
                
            } else {
                
                self.showToast(message)
            }
        }
    }
    
    func uploadProfile() {
        
        if strPhotoPath == "" {
            
            return
        }
        
        showLoadingViewWithTitle("")
        
        WebService.addUserImage(_user!._idx, photoPath: strPhotoPath) { (status, message, photo_url) in
            
            self.hideLoadingView()
            
            if photo_url != "" {
                
                self._user!._photoUrl = photo_url
            }
            
            self.imvProfile.setImageWithUrl(NSURL(string: self._user!._photoUrl)!)
            
            if (status) {
                
                self.showToast(Constants.PHOTO_UPLOAD_SUCCESS)
                
            } else {
                
                self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 10 {
                
                let storyboard = UIStoryboard(name: "TimeLine", bundle: nil)
                let timeLineListVC = storyboard.instantiateViewControllerWithIdentifier("TimeLineListViewController") as! TimeLineListViewController
                timeLineListVC.hidesBottomBarWhenPushed = true
                
                navigationController?.pushViewController(timeLineListVC, animated: true)
            } else if indexPath.row == 6 {
                
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let selectCountryVC = storyboard.instantiateViewControllerWithIdentifier("SelectCountryViewController") as! SelectCountryViewController
                selectCountryVC.from = FROM_MYPROFILEVC
                selectCountryVC.hidesBottomBarWhenPushed = true
                
                navigationController?.pushViewController(selectCountryVC, animated: true)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
}

extension MyPageViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let chosenImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            strPhotoPath = CommonUtils.saveToFile(UIImage.fixImageOrientation(chosenImage), filePath: Constants.SAVE_ROOT_PATH, fileName: "profile.png")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.imvProfile.contentMode = .ScaleAspectFit
                self.imvProfile.image = UIImage(contentsOfFile: self.strPhotoPath)
            })
            
            dismissViewControllerAnimated(true, completion: nil)            
            uploadProfile()
        }
    }
}




