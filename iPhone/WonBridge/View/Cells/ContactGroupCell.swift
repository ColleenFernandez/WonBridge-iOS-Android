//
//  ContactGroupCell.swift
//  WonBridge
//
//  Created by Roch David on 16/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class ContactGroupCell: UITableViewCell {
    
    @IBOutlet weak var imvAvatar: UIImageView!
    
    @IBOutlet weak var groupAvatarView: UIView!
    @IBOutlet weak var imvAvatar1: UIImageView!
    @IBOutlet weak var imvAvatar2: UIImageView!
    @IBOutlet weak var imvAvatar3: UIImageView!
    @IBOutlet weak var imvAvatar4: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCreatedDate: UILabel!
    
    @IBOutlet weak var imvCountry: UIImageView!
    
    // group request or waiting button
    @IBOutlet weak var actionButton: UIButton!
    
    var actionBlock: ((sender: UIButton) -> Void)?
    
    var group: GroupEntity?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .None
        
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        
        // hide action button as a default
        self.actionButton.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(group: GroupEntity, isSearch: Bool, actionBlock: ((sender: UIButton) -> Void)?) {
        
        if group.profileUrl.length > 0 {
            groupAvatarView.hidden = true
            imvAvatar.setImageWithUrl(NSURL(string: group.profileUrl)!, placeHolderImage: WBAsset.GroupPlaceHolder.image)
        } else {
            if group.profileUrls.count > 0 {
                groupAvatarView.hidden = false
                
                var imageViews = [UIImageView]()
                imageViews.append(imvAvatar1)
                imageViews.append(imvAvatar2)
                imageViews.append(imvAvatar3)
                imageViews.append(imvAvatar4)
                
                for index in 0 ..< 4 {
                    
                    if index < group.profileUrls.count {
                        imageViews[index].setImageWithUrl(NSURL(string: group.profileUrls[index])!, placeHolderImage: WBAsset.UserPlaceHolder.image)
                    } else {
                        imageViews[index].image = UIImage.imageWithColor(UIColor(colorNamed: WBColor.Gray), size: CGSizeMake(25, 25))
                    }
                }
                
            } else {
                groupAvatarView.hidden = true
                imvAvatar.setImageWithUrl(NSURL(string: group.profileUrl)!, placeHolderImage: WBAsset.GroupPlaceHolder.image)
            }
        }
        
        
        lblName.text = group.nickname + " (\(group.memberCount))"
        lblCreatedDate.text = Constants.RREFIX_CREATEDDATE + ": " + group.regDate
        
        imvCountry.image = UIImage(named: "ic_flag_flat_\(group.countryCode.trim().lowercaseString)")
        
        showActionButton(isSearch, group: group)
        
        self.actionBlock = actionBlock
    }
        
    func showActionButton(visible: Bool, group: GroupEntity) {
        
        self.group = group
        
        if visible {
            
            if WBAppDelegate.me.isExistGroup(group) {
                actionButton.setTitle(Constants.TITLE_ALREADY_ADDED, forState: .Normal)
                actionButton.backgroundColor = UIColor(colorNamed: WBColor.colorButtonGray)
                actionButton.hidden = true
            } else {
                
                actionButton.hidden = false
                if group.isRequested {
                
                    actionButton.setTitle(Constants.TITLE_REQUEST, forState: .Normal)
                    actionButton.backgroundColor = UIColor(colorNamed: WBColor.colorButtonGray)
                } else {
                
                    actionButton.setTitle(Constants.TITLE_ADD, forState: .Normal)
                    actionButton.backgroundColor = UIColor(colorNamed: WBColor.colorButtonGreen)
                }
            }
            
        } else {
            actionButton.hidden = true
        }
    }
    
    @IBAction func actinButtonTapped(sender: UIButton) {
        
        guard actionButton != nil else { return }
        
        guard group != nil && !group!.isRequested else { return }
        
        actionBlock!(sender: sender)
    }

}
