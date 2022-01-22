//
//  LikeUserCell.swift
//  WonBridge
//
//  Created by July on 2016-09-20.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class LikeUserCell: UITableViewCell {
    
    @IBOutlet weak var imvUser: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(user: FriendEntity) {
        
        imvUser.setImageWithUrl(NSURL(string: user._photoUrl)!, placeHolderImage: UIImage(named: "img_user"))
    }
}
