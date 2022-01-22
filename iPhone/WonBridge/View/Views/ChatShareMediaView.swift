//
//  ChatMediaCollectionView.swift
//  WonBridge
//
//  Created by July on 2016-09-26.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

let kLeftRightTopPadding: CGFloat = 2.0
let kVideoItemCountOfRow: CGFloat = 3.0
let kPhotoItemCountOfRow: CGFloat = 4.0

let kMaxSeletableCount: Int = 9

class ChatShareMediaView: UIView {
    
//    var _assets = [AnyObject]()
    var _photos = [WBMediaModel]()
    var _videos = [WBMediaModel]()
    
    var _selectedPhotos = [WBMediaModel]()
    var _isPhotoView: Bool = true
    
    var kItemCountOfRow = kPhotoItemCountOfRow
    var itemSize: CGSize!
    
    var videoCellTapDelegate: ChatShareMediaViewDelegate?
    
    var selectedCount = 0
    
    @IBOutlet weak var listCollectionView: UICollectionView! { didSet {
        listCollectionView.scrollsToTop = false
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        listCollectionView.backgroundColor = UIColor.clearColor()
        listCollectionView.showsVerticalScrollIndicator = false
        listCollectionView.showsHorizontalScrollIndicator = false
        listCollectionView.bounces = false
        listCollectionView.allowsMultipleSelection = true
        }}

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize() {
        
    }
    
    override func awakeFromNib() {        
        
        self.listCollectionView.registerNib(MediaSelectCell.NibObject(), forCellWithReuseIdentifier: MediaSelectCell.identifier)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: kLeftRightTopPadding, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = kLeftRightTopPadding
        layout.minimumInteritemSpacing = kLeftRightTopPadding
        self.listCollectionView.collectionViewLayout = layout
        
        let itemSizeW = (UIScreen.width - kLeftRightTopPadding*(kItemCountOfRow + 1)) / kItemCountOfRow
        itemSize = CGSizeMake(itemSizeW, itemSizeW)
    }
    
    func reloadList(assetList: [WBMediaModel]) {
        
        if _isPhotoView {
            _photos.removeAll()
            _photos.appendContentsOf(assetList)
        } else {
            _videos.removeAll()
            _videos.appendContentsOf(assetList)
        }
        
        _selectedPhotos.removeAll()
        selectedCount = 0
        
        if _isPhotoView {
            kItemCountOfRow = kPhotoItemCountOfRow
        } else {
            kItemCountOfRow = kVideoItemCountOfRow
        }
        
        let itemSizeW = (UIScreen.width - kLeftRightTopPadding*(kItemCountOfRow + 1)) / kItemCountOfRow
        itemSize = CGSizeMake(itemSizeW, itemSizeW)
        
        self.listCollectionView.reloadData()
    }
    
    func reloadList() {
        
        _selectedPhotos.removeAll()
        selectedCount = 0
        
        if _isPhotoView {
            for photo in _photos {
                photo.isSelected = false
            }
        }
        
        self.listCollectionView.reloadData()
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
}

// MARK: - @protocol UICollectionViewDataSource, UICollectionViewDelegate
extension ChatShareMediaView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if _isPhotoView {
            return _photos.count
        } else {
            return _videos.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MediaSelectCell.identifier, forIndexPath: indexPath) as! MediaSelectCell
        
        let mediaModel: WBMediaModel = _isPhotoView ? _photos[indexPath.row] : _videos[indexPath.row]
        cell.setContent(mediaModel)
        
        cell.index = indexPath.row
        if let _ = imageForMedia(mediaModel) {
            cell.displayImage()
        } else {
            mediaModel.loadUnderlyingImageAndNotify()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard _isPhotoView else {
            // do process a selected video
            if videoCellTapDelegate != nil {
                videoCellTapDelegate!.videoCellTapped(_videos[indexPath.row])
            }
            
            return
        }
        
        guard selectedCount < kMaxSeletableCount else {
            
            if self.parentViewController != nil && self.parentViewController!.isKindOfClass(ChatViewController) {
                
                let chatVC = parentViewController as! ChatViewController
                
                chatVC.showAlert(Constants.APP_NAME, message: Constants.SELECTABLE_MAX_COUNT, positive: Constants.ALERT_OK, negative: nil)
            }
            
            return
        }
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MediaSelectCell
        let mediaModel = _isPhotoView ? _photos[indexPath.row] : _videos[indexPath.row]
        _selectedPhotos.append(mediaModel)
        mediaModel.isSelected = true
        selectedCount += 1
        cell.setChecked(true)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MediaSelectCell
        let mediaModel = _isPhotoView ? _photos[indexPath.row] : _videos[indexPath.row]
        mediaModel.isSelected = false
        cell.setChecked(false)
        _selectedPhotos.remove(mediaModel)        
        selectedCount -= 1
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return itemSize
    }
}

protocol ChatShareMediaViewDelegate: class {
    /**
     - parameter asset - selected asset
     */
    func videoCellTapped(asset: WBMediaModel)
}









