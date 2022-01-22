//
//  LikeUserGridCell.swift
//  WonBridge
//
//  Created by July on 2016-09-22.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class LikeUserGridCell: UICollectionViewCell {
    
    @IBOutlet weak var imvUser: UIImageView!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code  
    }
    
    func configCell(user: FriendEntity) {
        
        imvUser.setImageWithUrl(NSURL(string: user._photoUrl)!, placeHolderImage: UIImage(named: "img_user"))
    }
    
}
