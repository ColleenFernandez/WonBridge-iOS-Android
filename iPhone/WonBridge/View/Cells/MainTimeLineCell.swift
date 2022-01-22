//
//  MainTimeLineCell.swift
//  WonBridge
//
//  Created by July on 2016-09-18.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import RxSwift

private let kExpandButtonHeight: CGFloat = 29
private let kNameCountryViewHeight: CGFloat = 21
private let kInfoViewHeight: CGFloat = 21

// default padding and margin
private let kTimeLineMargin1: CGFloat = 8
private let kTimeLineMargin2: CGFloat = 10
private let kTimeLineMargin3: CGFloat = 12

private let kInfoTextFont: UIFont = UIFont.systemFontOfSize(12)
private let kReplyTextFont: UIFont = UIFont.systemFontOfSize(13)
private let kCommentTextFont: UIFont = UIFont.systemFontOfSize(14)
private let kTimeLineNameFont = UIFont.systemFontOfSize(15, weight: UIFontWeightSemibold)

private let kTimeLineAvatarWidth: CGFloat = 50
private let kTimeLineAvatarHeight: CGFloat = kTimeLineAvatarWidth

private let kTimeLineFlagWidth: CGFloat = 21
private let kNameLabelHeight: CGFloat = 21
private let kCommentLabelHeight: CGFloat = 20

// colleciton view
private let kRowCount: CGFloat = 3.0
private let kMinSpacingForCellLine: CGFloat = 2.0
private let kTimeLineTextMaxWidth = UIScreen.width - kTimeLineMargin2 * 2 - kTimeLineAvatarWidth - kTimeLineMargin2
private let kMainTimeLinePhotCellSize: CGFloat = (kTimeLineTextMaxWidth - kMinSpacingForCellLine*2.0) / kRowCount

let kTimeLineCollectionSize: CGSize = CGSizeMake(kMainTimeLinePhotCellSize, kMainTimeLinePhotCellSize)

private let kReplyTopMargin: CGFloat = 12
private let kReplyOneRowHeight: CGFloat = 16

class MainTimeLineCell: UITableViewCell {
    
    var profileImageTapBlock: ((sender: AnyObject) -> Void)?
    var expandAction : ((Void) -> Void)?
    var textTapAction: ((Void) -> Void)?
    var photoTapAction: ((Void) -> Void)?
    
    var timeLine: TimeLineEntity?
    
    @IBOutlet weak var imvAvatar: UIImageView! { didSet {
        imvAvatar.clipsToBounds = true
        imvAvatar.layer.cornerRadius = 25
        imvAvatar.layer.masksToBounds = true
        }}
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imvCountry: UIImageView!
    @IBOutlet weak var imvFavCountry: UIImageView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var expandButton: UIButton! { didSet {
        expandButton.clipsToBounds = true
        }}
    @IBOutlet weak var listCollectionView: UICollectionView! { didSet {
        listCollectionView.backgroundColor = UIColor.whiteColor()
        listCollectionView.userInteractionEnabled = false
        listCollectionView.scrollEnabled = false
        }}
    @IBOutlet weak var imvIconHere: UIImageView!
    @IBOutlet weak var lblDistance: UILabel!            // distance
    @IBOutlet weak var lblPostedTime: UILabel!          // posted time
    @IBOutlet weak var imvIconLikeUsers: UIImageView!
    @IBOutlet weak var lblLikeCnt: UILabel!
    @IBOutlet weak var imvLeftMessages: UIImageView!
    @IBOutlet weak var lblReplyCnt: UILabel!
    @IBOutlet weak var imvBackComment: UIImageView!
    @IBOutlet weak var imvLikeIcon: UIImageView!
    @IBOutlet weak var lblLikeUsers: UILabel!
    @IBOutlet weak var lblFirstReply: UILabel!
    @IBOutlet weak var lblSecondReply: UILabel!
    @IBOutlet weak var lblSeparator: UILabel!
    
    @IBOutlet weak var replySuperView: UIView! { didSet {
        replySuperView.clipsToBounds = true
        }}
    @IBOutlet weak var likeUserView: UIView! { didSet {
        likeUserView.clipsToBounds = true
        }}
    @IBOutlet weak var replyView: UIView! { didSet {
        replyView.clipsToBounds = true}}
    
    @IBOutlet weak var photoGridVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var expandButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var replySuperViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var replyViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var infoViewVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var likeUserViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeUserViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var secondReplyBottomConstraint: NSLayoutConstraint!
    
    
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false

        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumLineSpacing = kMinSpacingForCellLine
        collectionLayout.minimumInteritemSpacing = kMinSpacingForCellLine
        collectionLayout.itemSize = CGSizeMake(kMainTimeLinePhotCellSize, kMainTimeLinePhotCellSize)
        listCollectionView.collectionViewLayout = collectionLayout

        let tap = UITapGestureRecognizer(target: self, action: #selector(commentTapped))
        tap.numberOfTapsRequired = 1
        lblComment.addGestureRecognizer(tap)
        lblComment.userInteractionEnabled = true
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(timeLinePhotoTapped))
        tap1.numberOfTapsRequired = 1
        self.listCollectionView.addGestureRecognizer(tap1)
        
        let strechImage = WBAsset.TimeLine_TextBack.image
        let backImage = strechImage.resizableImageWithCapInsets(UIEdgeInsetsMake(8, 5, 0, 5), resizingMode: .Stretch)
        imvBackComment.image = backImage
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(timeLine: TimeLineEntity, expandAction: ((Void) -> Void)?, textTapAction: ((Void) -> Void)?, photoTapAction: ((Void) -> Void)?, block: (sender: AnyObject) -> Void) {
        
        self.textTapAction = textTapAction
        profileImageTapBlock = block
        self.expandAction = expandAction
        self.photoTapAction = photoTapAction
        
        self.timeLine = timeLine
        
        lblName.text = timeLine.user_name
        imvCountry.image = UIImage(named: "ic_flag_flat_\(timeLine.countryCode.trim().lowercaseString)")
        
        if timeLine.id == 0 {
            listCollectionView.userInteractionEnabled = true
            imvCountry.hidden = true
            imvFavCountry.hidden = true
            imvAvatar.image = WBAsset.WonBridge.image
        } else {
            listCollectionView.userInteractionEnabled = false
            imvCountry.hidden = false
            imvFavCountry.hidden = false
            imvAvatar.setImageWithUrl(NSURL(string: timeLine.photo_url)!, placeHolderImage: WBAsset.UserPlaceHolder.image)
        }
        
        if timeLine.favCountry.length > 0 {
            
            imvFavCountry.hidden = false
            imvFavCountry.image = UIImage(named: "ic_flag_flat_\(timeLine.favCountry.trim().lowercaseString)")
        } else {
            imvFavCountry.hidden = true
        }
        
        // change comment label number of lines
        lblComment.text = timeLine.content
        
        // change comment view height
        if lblComment.lineCounts() > 3 {
            
            if timeLine.isExpanded {
                lblComment.numberOfLines = 0
                expandButton.setTitle(Constants.TITLE_CONTENT_CLOSE, forState: .Normal)
            } else {
                lblComment.numberOfLines = 3
                expandButton.setTitle(Constants.TITLE_CONTENT_ALL, forState: .Normal)
            }
            expandButtonHeightConstraint.constant = kExpandButtonHeight
            photoGridVerticalConstraint.constant = 0
        } else {
            
            lblComment.numberOfLines = 0
            expandButtonHeightConstraint.constant = 0
            
            if timeLine.content != "" {
                photoGridVerticalConstraint.constant = kTimeLineMargin1
            } else {
                photoGridVerticalConstraint.constant = 0
            }
        }

        lblLikeCnt.text = "\(timeLine.likeCount)"
        lblReplyCnt.text = "\(timeLine.replyCount)"

        lblPostedTime.text = timeLine.postedTime.displayLocalTime()

        let globalUser = WBAppDelegate.me
        lblDistance.text = globalUser.getDistance(timeLine.location)
        
        var names = ""
        for name in timeLine.likeUsers {
            names += name + ", "
        }
        if !names.isEmpty {
            names = names.substringToIndex(names.endIndex.advancedBy(-2))
        }
        lblLikeUsers.text = names
        
        lblFirstReply.text = ""
        lblSecondReply.text = ""
  
        // replies will inclue two replies in maximum
        for index in 0 ..< timeLine.replies.count {
        
            let reply = timeLine.replies[index]
            let mutableString = NSMutableAttributedString(string: reply._userName + " : " + reply._content, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(colorNamed: WBColor.colorText2), range: NSRange(location: 0, length: reply._userName.length))
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(colorNamed: WBColor.colorText3), range: NSRange(location: reply._userName.length + 1, length: reply._content.length + 2))
            
            if index == 0 {
                lblFirstReply.attributedText = mutableString
            } else {
                lblSecondReply.attributedText = mutableString
            }
        }
        
        var replyViewHeight: CGFloat = 0
        var replySuperViewHeight: CGFloat = 0
        if self.timeLine!.likeUsers.count == 0 && self.timeLine!.replies.count == 0 {
            replySuperViewHeight = 0.0
            replyViewHeight = 0.0
            likeUserViewTopConstraint.constant = 0
            likeUserViewBottomConstraint.constant = 0
            secondReplyBottomConstraint.constant = 0
        } else {
            // you have one of like users and reply or replies at least
            replySuperViewHeight += kReplyTopMargin
            if self.timeLine!.likeUsers.count != 0 {
//                replySuperViewHeight += CGFloat(self.lblLikeUsers.lineCounts()) * kReplyOneRowHeight
                replySuperViewHeight += kReplyOneRowHeight
                replySuperViewHeight += kTimeLineMargin1
                likeUserViewTopConstraint.constant = kReplyTopMargin
                likeUserViewBottomConstraint.constant = kTimeLineMargin1
            } else {
                likeUserViewBottomConstraint.constant = 0
            }
            
            if self.timeLine!.replies.count > 1 {
                secondReplyBottomConstraint.constant = kTimeLineMargin1
            } else {
                secondReplyBottomConstraint.constant = 0
            }

            replyViewHeight = CGFloat(self.timeLine!.replies.count) * kReplyOneRowHeight
            replyViewHeight += kTimeLineMargin1 * CGFloat(self.timeLine!.replies.count)
            replySuperViewHeight += replyViewHeight
        }
        
        replyViewHeightConstraint.constant = replyViewHeight
        replySuperViewHeightContraint.constant = replySuperViewHeight
        
        if self.timeLine!.file_url.count == 0 {
            collectionViewHeightConstraint.constant = 0
            infoViewVerticalConstraint.constant = 0
        } else {
            let kCollectionViewLines = ceil(CGFloat(self.timeLine!.file_url.count) / kRowCount)
            let collectionViewHeight = kCollectionViewLines * kMainTimeLinePhotCellSize + kMinSpacingForCellLine * (kCollectionViewLines - 1)
            collectionViewHeightConstraint.constant = collectionViewHeight
            infoViewVerticalConstraint.constant = kTimeLineMargin1
        }
        
        if self.timeLine!.id == 0 {
            infoViewHeightConstraint.constant = 0
        } else {
            infoViewHeightConstraint.constant = kInfoViewHeight
        }
    }

    func commentTapped() {
        
        guard !self.timeLine!.content.isEmpty else { return }
        textTapAction?()
    }
    
    func timeLinePhotoTapped() {
        
        guard self.timeLine!.id == 0 else { return }
        photoTapAction?()
    }
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
        
        listCollectionView.delegate = dataSourceDelegate
        listCollectionView.dataSource = dataSourceDelegate
        listCollectionView.tag = row
        listCollectionView.reloadData()
    }
    
    @IBAction func profileImageTapped(sender: AnyObject) {
        
        if profileImageTapBlock != nil {
            profileImageTapBlock!(sender: sender)
        }
    }
    
    func showAllText() {        
        guard timeLine != nil else { return }
        self.timeLine!.isExpanded = !self.timeLine!.isExpanded
    }
    
    @IBAction func showAllTextTapped(sender: AnyObject) {
        showAllText()
        expandAction?()
    }
}

class TimeLinePhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imvTimeLinePhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
    }
    
    func setContent(fileUrl: String) {
        imvTimeLinePhoto.setImageWithUrl(NSURL(string: fileUrl)!, placeHolderImage: UIImage.imageWithColor(UIColor(colorNamed: WBColor.colorText2), size: kTimeLineCollectionSize))
    }
}



