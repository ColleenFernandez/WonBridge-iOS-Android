//
//  GroupMember.swift
//  WonBridge
//
//  Created by July on 2016-09-30.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

let kPlusMemberName = "+"
let kMinusMemberName = "-"

class GroupMemberCell: UICollectionViewCell {
    
    @IBOutlet weak var imvAvatar: UIImageView!  // user profile image
    @IBOutlet weak var lblName: UILabel!        // user name
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setContent(model: FriendEntity) {
        
        if model._name == kPlusMemberName {
            lblName.hidden = true
            imvAvatar.image = WBAsset.InviteUser.image
        } else if model._name == kMinusMemberName {
            lblName.hidden = true
            imvAvatar.image = WBAsset.BanishUser.image
        } else {
            imvAvatar.setImageWithUrl(NSURL(string: model._photoUrl)!, placeHolderImage: WBAsset.UserPlaceHolder.image)
            lblName.text = model._name
            lblName.hidden = false
        }
    }
}
