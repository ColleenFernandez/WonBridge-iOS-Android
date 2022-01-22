//
//  TSChatShareMoreView.swift
//  TSWeChat
//
//  Created by Hilen on 12/24/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxBlocking
import Dollar

private let kTopBottomPadding: CGFloat = 15.0
private let kItemCountOfRow: CGFloat = 3.0
private let kTitleLabelHeight: CGFloat = 28.0

class ChatShareMoreView: UIView {
    
    @IBOutlet weak var listCollectionView: UICollectionView! {didSet {
        listCollectionView.scrollsToTop = false
        }}
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    weak var delegate: ChatShareMoreViewDelegate?
    
    private let itemDataSouce: [(name: String, iconImage: UIImage)] = [
        ("照片", WBAsset.ShareMorePicture.image),
        ("视频", WBAsset.ShareMoreVideo.image),
        ("拍照", WBAsset.ShareMoreCamera.image),
        ("语音通话", WBAsset.ShareMoreVoiceCall.image),
        ("视频通话", WBAsset.ShareMoreVideoCall.image),  //Where is the lucky money icon!  T.T
        ("赠送礼物 ", WBAsset.ShareMoreGift.image)
    ]
    
    var itemSize: CGSize!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.initialize()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.initialize()
    }
    
    func initialize() {
        
    }
    
    override func awakeFromNib() {
        
        let itemHeight = (self.collectionViewHeightConstraint.constant - kTopBottomPadding*2 - 10)/2
        let itemWidth = itemHeight - kTitleLabelHeight
        
        //Calculate the UICollectionViewCell size
        let itemSpacing = (UIScreen.width - itemWidth*3)/(kItemCountOfRow + 1)
        itemSize = CGSizeMake(itemWidth, itemHeight)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: kTopBottomPadding, left: itemSpacing, bottom: kTopBottomPadding, right: itemSpacing)
        layout.itemSize = itemSize
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = itemSpacing
        self.listCollectionView.collectionViewLayout = layout
        
        self.listCollectionView.registerNib(ChatShareMoreCollectionViewCell.NibObject(), forCellWithReuseIdentifier: ChatShareMoreCollectionViewCell.identifier)
        self.listCollectionView.showsHorizontalScrollIndicator = false
        self.listCollectionView.showsVerticalScrollIndicator = false
        self.listCollectionView.bounces = false
    }
}

// MARK: - @protocol UICollectionViewDelegate
extension ChatShareMoreView: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let delegate = self.delegate else {
            return
        }

        switch indexPath.row {            
        case 0:
            delegate.chatShareMoreViewPhotoTaped()
            break
        case 1:
            delegate.chatShareMoreViewVideoTaped()
            break
        case 2:
            delegate.chatShareMoreViewCameraTapped()
            break
        case 3:
            delegate.chatShareMoreViewVoiceCallTapped()
            break
        case 4:
            delegate.chatShareMoreViewVideoCallTapped()
            break
        default:
            delegate.chatShareMoreViewGiftTapped()
            break
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return itemSize
    }
}


// MARK: - @protocol UICollectionViewDataSource
extension ChatShareMoreView: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemDataSouce.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ChatShareMoreCollectionViewCell.identifier, forIndexPath: indexPath) as! ChatShareMoreCollectionViewCell
        let item = self.itemDataSouce.get(indexPath.row)
        cell.itemButton.setImage(item.iconImage, forState: .Normal)
        cell.itemLabel.text = item.name
        return cell
    }
}

 // MARK: - @delgate ChatShareMoreViewDelegate
protocol ChatShareMoreViewDelegate: class {
    
    func chatShareMoreViewPhotoTaped()
    
    func chatShareMoreViewVideoTaped()
    
    func chatShareMoreViewCameraTapped()
    
    func chatShareMoreViewVoiceCallTapped()
    
    func chatShareMoreViewVideoCallTapped()
    
    func chatShareMoreViewGiftTapped()
}





