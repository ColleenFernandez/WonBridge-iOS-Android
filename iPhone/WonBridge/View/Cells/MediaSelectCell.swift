//
//  MediaSelectCell.swift
//  WonBridge
//
//  Created by Elite on 10/13/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class MediaSelectCell: UICollectionViewCell {
    
    var mediaModel: WBMediaModel?
    var index: Int!
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var checkIcon: UIImageView!
    
    @IBOutlet weak var markView: UIView! { didSet {
        markView.hidden = true
        }}
    @IBOutlet weak var videoMarkIcon: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.backgroundColor = UIColor(white: 0.12, alpha: 1)
        self.backgroundColor = UIColor(colorNamed: WBColor.colorText2)
        
        // Listen for photo loading notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setProgressFromNotification(_:)), name: PHOTO_PROGRESS_NOTIFICATION, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handlePhotoLoadingDidEndNotification(_:)), name: PHOTO_LOADING_DID_END_NOTIFICATION, object: nil)
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setContent(model: WBMediaModel) {
        
        self.mediaModel = model
        
        if model.isVideo {
            markView.hidden = false
            checkIcon.hidden = true
            
            guard model.asset != nil else {
                durationLabel.text = "00:01"
                return
            }
            
            let duration = model.asset!.duration
            let hours = Int(duration / 3600)
            let mins = Int((duration % 3600) / 60)
            let secs = Int((duration % 3600) % 60)
            durationLabel.text = String(format: "%d:%02d:%02d", hours, mins, secs)
            
        } else {
            markView.hidden = true
            checkIcon.hidden = false
            
            if model.isSelected {
                setChecked(true)
            } else {
                setChecked(false)
            }
        }
    }
    
    func setChecked(status: Bool) {
        
        if status {
            self.checkIcon.image = WBAsset.Selected.image
        } else {
            self.checkIcon.image = WBAsset.Unselected.image
        }
    }
    
    func displayImage() {
        
        guard mediaModel != nil  else { return }
        
        thumbnail.image = mediaModel!.underlyingImage
    }
    
    func setProgressFromNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) { 
            let dict = notification.object as! NSDictionary
            let photoWithProgerss = dict.objectForKey("photo") as! WBMediaModel
            if photoWithProgerss == self.mediaModel {
                //let progerss = dict.valueForKey("progress")!.floatValue
                // set progress
            }
        }
    }
    
    func handlePhotoLoadingDidEndNotification(notification: NSNotification) {
        let photo = notification.object as! WBMediaModel
        if photo == mediaModel {
            if photo.underlyingImage != nil {
                displayImage()
            } else {
                // fail to load
            }
            
            // hide loading indicator
            hideLoadingIndicator()
        }
    }
    
    func hideLoadingIndicator() {
//        loadingIndicator.hidden = true
    }
}
