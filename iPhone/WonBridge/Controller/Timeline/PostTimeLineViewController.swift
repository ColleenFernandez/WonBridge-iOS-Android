//
//  PostTimeLineViewController.swift
//  WonBridge
//
//  Created by Roch David on 11/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import Photos
import Synchronized

private let kTimeLinePostMsgMaxLength           =       10000
private let kTimeLinePostImageCount             =       9
let kPickerCellInterval: CGFloat = 2
let kImagePickerRowCount: CGFloat = 4

class PostTimeLineViewController: BaseViewController {
    
    var _user: UserEntity?
    let picker = UIImagePickerController()
    var _assets = [AnyObject]()
    var _photos = [WBMediaModel]()
    
    weak var refreshDelegate: TimeLineRefreshDelegate?

    @IBOutlet weak var lblTextCount: UILabel!
    @IBOutlet weak var txvTimeLine: PlaceholderTextView!
    @IBOutlet weak var vSuperTableView: UIView!
    @IBOutlet weak var btnSave: UIButton!
    
    var isPosted: Bool = false
    
    private lazy var tblTimeLinePhoto: UITableView = {
    
        let tableView = UITableView(frame: CGRectMake(2, 2, 124, UIScreen.mainScreen().bounds.width - 4))
        tableView.backgroundColor = UIColor.clearColor()
        tableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
        tableView.center =  CGPointMake(self.view.frame.size.width / 2, self.vSuperTableView.frame.size.height / 2);
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .None
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 124
        return tableView
    }()
    
    // timeline image file path array
    // will have 4 items in maximum
    var arrTimeLineImage = [(String, String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self._user = WBAppDelegate.me
        initUI()
        
        loadAssets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        
        self.tblTimeLinePhoto.registerNib(TimeLinePhotoCell.NibObject(), forCellReuseIdentifier: TimeLinePhotoCell.identifier)
        
        lblTextCount.text = "\(kTimeLinePostMsgMaxLength)"
        txvTimeLine.delegate = self        
        vSuperTableView.addSubview(tblTimeLinePhoto)
    }
    
    // MARK: - Load Assets
    func loadAssets() {
        
        guard NSClassFromString("PHAsset") != nil else { return }
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.Authorized {
                    self.performLoadAssets()
                }
            })
        } else if status == PHAuthorizationStatus.Authorized {
            self.performLoadAssets()
        }
    }
    
    func performLoadAssets() {
        
        // initialize array
        self._assets.removeAll()
        
        guard NSClassFromString("PHAsset") != nil else  { return }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.Image.rawValue)
            let fetchResults = PHAsset.fetchAssetsWithOptions(fetchOptions)
            
            fetchResults.enumerateObjectsUsingBlock({ (obj, idx, stop) in
                self._assets.append(obj)
            })
            
//            guard fetchResults.count > 0  else { return }
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func saveButtonTapped(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        guard !isPosted else { return }
        
        isPosted = true
        
        if !checkValid() {
            isPosted = false
            return
        }
        
        guard let myLocation = _user!.getUserLocation() else { return }
        
        let lat: Double = myLocation.latitude.format(".8")
        let long: Double = myLocation.longitude.format(".8")
        
        showLoadingViewWithTitle("")
        
        let postMsg = txvTimeLine.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if arrTimeLineImage.count == 0 {
            
            WebService.postTimeLine(_user!._idx, latitude: lat, longitude: long, postMsg: postMsg.encodeString()!, completion: { (status, message) in
                
                self.hideLoadingView()
                
                if status {
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.refreshDelegate?.refresh()
                } else {
                    self.isPosted = false
                    self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
                }
            })
            
        } else {
            
            var arrPhotoPath = [String]()
            for photoPathTuple in arrTimeLineImage {
                arrPhotoPath.append(photoPathTuple.0)
            }
            
            // post timeline (text and multi image files)
            WebService.postTimeLine(_user!._idx, latitude: lat, longitude: long, postMsg: postMsg, photoPaths: arrPhotoPath) { (status, message) in
                
                self.hideLoadingView()
                
                if (status) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.refreshDelegate?.refresh()
                } else {                    
                    self.showAlert(Constants.APP_NAME, message: message, positive: Constants.ALERT_OK, negative: nil)
                }
            }
        }
    }
    
    func checkValid() -> Bool {
        
        if txvTimeLine.text!.isEmpty && arrTimeLineImage.count == 0 {
            
            if txvTimeLine.text!.isEmpty {
                showAlert(Constants.APP_NAME, message: Constants.INPUT_TIMLLINE_MSG, positive: Constants.ALERT_OK, negative: nil)
            } else {
                showAlert(Constants.APP_NAME, message: Constants.INPUT_TIMELINE_IMG, positive: Constants.ALERT_OK, negative: nil)
            }
            
            return false
        }
        
        return true
    }
    
    @IBAction func cameraButtonTapped(sender: AnyObject) {
        
        guard arrTimeLineImage.count < kTimeLinePostImageCount else {
            showAlert(Constants.APP_NAME, message: "You can select up to \(kTimeLinePostImageCount) images", positive: Constants.APP_NAME, negative: nil)
            return
        }
        
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
//            picker.allowsEditing = true
            picker.modalPresentationStyle = .FullScreen
            
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        
        _photos.removeAll()
        
        synchronized(_assets) { 
            
            let copy = _assets
            guard NSClassFromString("PHAsset") != nil else { return }
            
            // Photos library            
            let itemWidth = (UIScreen.width - kPickerCellInterval * CGFloat(kImagePickerRowCount - 1)) / kImagePickerRowCount
            let thumbSize = CGSizeMake(itemWidth, itemWidth)
            for asset in copy {
                _photos.append(WBMediaModel(asset: asset as! PHAsset, targetSize: thumbSize))
            }
        }
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        let imagePicker = storyboard.instantiateViewControllerWithIdentifier("WBImagePickerController") as! WBImagePickerController
        
        imagePicker.modalTransitionStyle = .CoverVertical
        imagePicker.modalPresentationStyle = .OverFullScreen
        imagePicker.itemDataSource = self._photos
        imagePicker.maxSelectableCount = kTimeLinePostImageCount - arrTimeLineImage.count
        imagePicker.didSelectAssets = { [weak self] (models: [WBMediaModel]) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.showLoadingViewWithTitle("")
            
            var addedCount = 0
            for model in models {
                // save file and add file path to arrTimeLinePhotos
                
                guard model.asset != nil else { return }
                
                if let image = model.asset!.getUIImage() {
                    let selectedImage = UIImage.fixImageOrientation(image)
                    let uploadImageSize = ChatConfig.getChatImageSize(selectedImage.size)
                    
                    guard let uploadImage = selectedImage.resize(uploadImageSize) else {
                        addedCount += 1
                        
                        if addedCount >= models.count {
                            
                            strongSelf.hideLoadingView()
                            
                            strongSelf.tblTimeLinePhoto.reloadData()
                            strongSelf.checkActivation()
                        }
                        
                        break
                    }
                    
                    let uploadFileName = Constants.TIMELINE_IMAGE_PREFIX + "\(NSDate().millisecondesInt)" + ".png"
                    let strImgPath = CommonUtils.saveImageToFile(uploadImage, filePath: Constants.UPLOAD_FILE_PATH, fileName: uploadFileName, resize: false)
                    let storeKey = Constants.TIMELINE_IMAGE_PREFIX + "\(NSDate().millisecondesInt)"
                    
                    ImageFilesManager.storeImage(uploadImage, key: storeKey, completionHandler: {
    
                        strongSelf.arrTimeLineImage.append((strImgPath, storeKey))
                        addedCount += 1
    
                        if addedCount >= models.count {
    
                            strongSelf.hideLoadingView()
    
                            strongSelf.tblTimeLinePhoto.reloadData()
                            strongSelf.checkActivation()
                        }
                    })
                    
                } else {
                    
                    addedCount += 1
                    
                    if addedCount >= models.count {
                        
                        strongSelf.hideLoadingView()
                        
                        strongSelf.tblTimeLinePhoto.reloadData()
                        strongSelf.checkActivation()
                    }
                }
            }
        }

        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func checkActivation() {
        
        if ((arrTimeLineImage.count > 0) || !txvTimeLine.text!.isEmpty) {
            btnSave.setTitleColor(UIColor(netHex: 0x3366AD), forState: UIControlState.Normal)
        } else {
            btnSave.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
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

extension PostTimeLineViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        if let chosenImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            self.showLoadingViewWithTitle("")
            
            let selectedImage = UIImage.fixImageOrientation(chosenImage)
            let uploadImageSize = ChatConfig.getChatImageSize(selectedImage.size)
            guard let uploadImage = selectedImage.resize(uploadImageSize) else { return }
            let uploadFileName = Constants.TIMELINE_IMAGE_PREFIX + "\(NSDate().millisecondesInt)" + ".png"
            let strImgPath = CommonUtils.saveImageToFile(uploadImage, filePath: Constants.UPLOAD_FILE_PATH, fileName: uploadFileName, resize: false)
            let storeKey = Constants.TIMELINE_IMAGE_PREFIX + "\(NSDate().millisecondesInt)"
            
            ImageFilesManager.storeImage(uploadImage, key: storeKey, completionHandler: {
                
                self.arrTimeLineImage.append((strImgPath, storeKey))
                
                self.hideLoadingView()
                
                self.tblTimeLinePhoto.reloadData()
                self.checkActivation()
            })
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PostTimeLineViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrTimeLineImage.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TimeLinePhotoCell.identifier, forIndexPath: indexPath)  as! TimeLinePhotoCell
        cell.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2.0))
        cell.configCell(arrTimeLineImage[indexPath.row].1, bFile: true, deleteAction: { (sender) in
            
            let removeTuple = self.arrTimeLineImage[indexPath.row]
            guard let removeIndex = self.arrTimeLineImage.indexOf({ $0 == removeTuple }) else { return }
            self.arrTimeLineImage.removeAtIndex(removeIndex)
            
            // delete saved file
            CommonUtils.deleteFile(removeTuple.0)
            
            self.tblTimeLinePhoto.reloadData()
            self.checkActivation()
        })
        cell.bringSubviewToFront(cell.btnDelete)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        print("did select row indexPath")
    }
}

extension PostTimeLineViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        
        lblTextCount.text = "\(kTimeLinePostMsgMaxLength - textView.text.characters.count)"
        
        self.checkActivation()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        guard let strText = textView.text else { return true }
        let newLength = strText.characters.count + text.characters.count - range.length
        
        return newLength <= kTimeLinePostMsgMaxLength
    }   
}







