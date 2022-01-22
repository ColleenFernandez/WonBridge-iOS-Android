//
//  UserListCell.swift
//  WonBridge
//
//  Created by July on 2016-09-29.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class UserListCell: UITableViewCell {

    @IBOutlet weak var imvAvatar: UIImageView! { didSet {
        imvAvatar.layer.cornerRadius = 23
        imvAvatar.layer.masksToBounds = true
        }}
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLastLogin: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var imvGender: UIImageView!
    @IBOutlet weak var imvCountry: UIImageView!
    @IBOutlet weak var imvFavCountry: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setContent(model: FriendEntity) {
     
        imvAvatar.setImageWithUrl(NSURL(string: model._photoUrl)!, placeHolderImage: WBAsset.UserPlaceHolder.image)
        lblName.text = model._name
        lblLastLogin.text = model._lastLogin.displayLocalTime()        
        imvGender.image = model._gender == .FEMALE ? WBAsset.Female_Icon.image : WBAsset.Male_Icon.image
        imvCountry.image = UIImage(named: "ic_flag_flat_\(model._countryCode.trim().lowercaseString)")
        
        if model._favCountry.length > 0 {
            imvFavCountry.hidden = false
            imvFavCountry.image = UIImage(named: "ic_flag_flat_\(model._favCountry.trim().lowercaseString)")
        } else {
            imvFavCountry.hidden = true
        }
        
        guard model.location != nil else {
            lblDistance.text = ""
            return
        }
        
//        let globalUser = WBAppDelegate.me
//        lblDistance.text = globalUser.getDistance(model.location)
        lblDistance.text = "\(model.distance)km"
    }
}
