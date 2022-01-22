//
//  ContactFriendCell.swift
//  WonBridge
//
//  Created by Roch David on 16/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class ContactFriendCell: UITableViewCell {    
    
    // friend profile image
    @IBOutlet weak var imvAvatar: UIImageView! { didSet {
        imvAvatar.layer.cornerRadius = 25
        imvAvatar.layer.masksToBounds = true
        }}
    @IBOutlet weak var lblName: UILabel!            // nickname
    
    @IBOutlet weak var actionButton: UIButton!
    
    var actionBlock: ((sender: UIButton) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .None
        
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        
        actionButton.hidden = true
        
        // round layer
        actionButton.layer.cornerRadius = 4.0
        actionButton.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(friend: FriendEntity, actionBlock: ((sender: UIButton) -> Void)?) {
        
        imvAvatar.setImageWithUrl(NSURL(string: friend._photoUrl)!, placeHolderImage: WBAsset.UserPlaceHolder.image)
        lblName.text = friend._name
        
        self.actionBlock = actionBlock
    }
    
    func showActionButton(visible: Bool, friend: FriendEntity) {
        
        // will be search
        guard visible else {
            actionButton.hidden = true
            return }
        
        if friend._isFriend {
            actionButton.setTitle(Constants.TITLE_ALREADY_ADDED, forState: .Normal)
            actionButton.backgroundColor = UIColor(colorNamed: WBColor.colorButtonGray)
        } else {
            actionButton.setTitle(Constants.TITLE_ADD, forState: .Normal)
            actionButton.backgroundColor = UIColor(colorNamed: WBColor.colorButtonGreen)
        }
        
        actionButton.hidden = false
    }
    
    @IBAction func actionButtonTapped(sender: UIButton) {
        
        actionBlock!(sender: sender)
    }
}
