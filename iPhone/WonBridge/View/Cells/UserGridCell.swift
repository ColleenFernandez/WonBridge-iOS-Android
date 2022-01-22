//
//  UserListCell.swift
//  WonBridge
//
//  Created by Saville Briard on 22/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class UserGridCell: UICollectionViewCell {
    
    @IBOutlet weak var imvUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblLastLoggedTime: UILabel!
    @IBOutlet weak var imvGender: UIImageView!
    
    @IBOutlet weak var imvCheck: UIImageView!
    
    @IBOutlet weak var btnSelectFriend: UIButton!
    
    var _user: FriendEntity?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
        setCheckVisibility(false)
        
        setCheck(false)
    }
    
    func setUser(user : FriendEntity) {        
        // update checked state
        _user = user
        
        imvUser.setImageWithUrl(NSURL(string: user._photoUrl)!, placeHolderImage: WBAsset.UserPlaceHolder.image)
        
        lblUserName.text = user._name
        
        lblLastLoggedTime.text = user._lastLogin.displayLocalTime()
        
        let globalUser = WBAppDelegate.me
        lblDistance.text = globalUser.getDistance(user.location)        
        
        if(user._gender == .FEMALE)  {
            imvGender.image = WBAsset.Female_Icon.image
        } else{
            imvGender.image = WBAsset.Male_Icon.image
        }
        
        setCheck(user._isSelected)
    }
    
    // hide or show check on cell
    func setCheckVisibility(visible: Bool) {
        
        if (visible) {
            imvCheck.hidden = false
        } else {            
            imvCheck.hidden = true
        }
    }
    
    // set checked state
    func setCheck(state: Bool) {
        
        if (state) {
            imvCheck.image = WBAsset.Selected.image
        } else {
            imvCheck.image = WBAsset.Unselected.image
        }
    }
}
