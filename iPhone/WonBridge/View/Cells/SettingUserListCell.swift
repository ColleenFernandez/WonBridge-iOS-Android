//
//  SettingUserListCell.swift
//  WonBridge
//
//  Created by Roch David on 07/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class SettingUserListCell: UITableViewCell {

    @IBOutlet weak var imvAvatar: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(participant: FriendEntity) {
        
        imvAvatar.setImageWithUrl(NSURL(string: participant._photoUrl)!, placeHolderImage: UIImage(named: "img_member_set02")!)
        
        lblUserName.text = participant._name
    }

}
