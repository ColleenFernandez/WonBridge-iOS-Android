//
//  TimeLineReplyCell.swift
//  WonBridge
//
//  Created by July on 2016-09-20.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class TimeLineReplyCell: UITableViewCell {
    
    @IBOutlet weak var imvUser: UIImageView!
    @IBOutlet weak var lblReply: UILabel!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code

    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(reply: ReplyEntity) {
        
        imvUser.setImageWithUrl(NSURL(string: reply._userProfile)!, placeHolderImage: UIImage(named: "img_user"))
        lblReply.text = reply._content
    }
}
