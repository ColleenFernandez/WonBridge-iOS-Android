//
//  WBImagePickerController.swift
//  WonBridge
//
//  Created by Elite on 10/16/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

import UIKit
import Photos
import AssetsLibrary

private let kCollectionViewInterval: CGFloat = 2
private let kRowCount: CGFloat = 4.0


class WBImagePickerController: BaseViewController {
    
    // The maximum count of assets which the user will be able to select
    var maxSelectableCount = 9
    
    var itemSize = CGSizeZero
    
    var itemDataSource = [WBMediaModel]()
    
    var selectedCount = 0
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var listCollectionView: UICollectionView! { didSet {
        listCollectionView.backgroundColor = UIColor.whiteColor()
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        listCollectionView.allowsMultipleSelection = true
        }}
    
    var didSelectAssets: ((models: [WBMediaModel]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.        
        listCollectionView.registerNib(MediaSelectCell.NibObject(), forCellWithReuseIdentifier: MediaSelectCell.identifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = kCollectionViewInterval
        layout.minimumLineSpacing = kCollectionViewInterval
        
        let itemWidth = (UIScreen.width - kCollectionViewInterval * CGFloat(kRowCount - 1)) / kRowCount
        itemSize = CGSizeMake(itemWidth, itemWidth)
        layout.itemSize = itemSize
        
        listCollectionView.collectionViewLayout = layout
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // Cancel outstanding loading
        let visibleCells = self.listCollectionView.visibleCells()
        if visibleCells.count > 0 {
            for cell in visibleCells {
                let _cell = cell as! MediaSelectCell
                guard _cell.mediaModel != nil else { continue }
                _cell.mediaModel!.cancelAnyRequest()
            }
        }
        
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        
        // Release an cashed data, images, etc that aren't in use
        releaseAllUnderlyingPhotos(true)
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        releaseAllUnderlyingPhotos(false)
    }
    
    func releaseAllUnderlyingPhotos(preserveCurrent: Bool) {
        
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func selectButtonTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true) {}
        
        guard didSelectAssets != nil  else { return }

        var selectedAssets = [WBMediaModel]()
        for asset in self.itemDataSource {
            if asset.isSelected {
                asset.isSelected = false
                selectedAssets.append(asset)
            }
        }

        didSelectAssets!(models: selectedAssets)
    } 
    
    func updateTitle() {
        
        // update navigation title
        // disable animation to remove blink when to change button title
        UIView.setAnimationsEnabled(false)
        // update confirm button title according to selected friends count
        if (selectedCount == 0) {
            confirmButton.setTitle(Constants.TITLE_CONFIRM, forState: .Normal)
        } else {
            confirmButton.setTitle(Constants.TITLE_CONFIRM + "(\(selectedCount))", forState: .Normal)
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func imageForMedia(model: WBMediaModel?) -> UIImage? {
        
        if model != nil {
            // get image or obtain in background
            if model!.underlyingImage != nil {
                return model!.underlyingImage
            } else {
                model!.loadUnderlyingImageAndNotify()
            }
        }
        
        return nil
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

extension WBImagePickerController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MediaSelectCell.identifier, forIndexPath: indexPath) as! MediaSelectCell
        let mediaModel = itemDataSource[indexPath.row]
        cell.mediaModel = mediaModel
        cell.index = indexPath.row
        if let _ = imageForMedia(mediaModel) {
            cell.displayImage()
        } else {
            mediaModel.loadUnderlyingImageAndNotify()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        selectedCount += 1
        
        guard selectedCount < maxSelectableCount else {
            showAlert(Constants.APP_NAME, message: Constants.SELECTABLE_MAX_COUNT, positive: Constants.ALERT_OK, negative: nil)
            return
        }
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MediaSelectCell
        let mediaModel = itemDataSource[indexPath.row]
        mediaModel.isSelected = true
        cell.setChecked(true)
        
        updateTitle()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MediaSelectCell
        let mediaModel = itemDataSource[indexPath.row]
        mediaModel.isSelected = false
        cell.setChecked(false)
        
        selectedCount -= 1
        
        updateTitle()
    }
}
