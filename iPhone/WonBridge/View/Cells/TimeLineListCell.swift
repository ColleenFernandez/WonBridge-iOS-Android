//
//  TimeLineListCell.swift
//  WonBridge
//
//  Created by Tiia on 31/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class TimeLineListCell: UITableViewCell {
    
    @IBOutlet weak var imvUser: UIImageView!
    @IBOutlet weak var lblComment: UILabel!
    
    @IBOutlet weak var lblPostedTime: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var lblMessageCount: UILabel!
    
    @IBOutlet weak var layoutTrailingofComment: NSLayoutConstraint!
    
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
    
    func setUserImageVisibility(visible: Bool) {
        
        if (visible) {
            
            imvUser.hidden = false
            layoutTrailingofComment.constant = 64
        } else {
            
            imvUser.hidden = true
            layoutTrailingofComment.constant = 18
        }
        
        self.layoutIfNeeded()
    }
    
    func configureCell(timeline: TimeLineEntity) {
        
        if timeline.file_url.count > 0 {
        
            imvUser.setImageWithUrl(NSURL(string: timeline.file_url[0])!, placeHolderImage: UIImage.imageWithColor(UIColor(netHex: 0x5f99fb), size: imvUser.bounds.size))
        } else {
            
            self.setUserImageVisibility(false)
        }
        
        lblComment.text = timeline.content
        lblPostedTime.text = timeline.postedTime.displayLocalTime()
        let globalUser = WBAppDelegate.me
        lblDistance.text = globalUser.getDistance(timeline.location)        
        lblLikeCount.text = "\(timeline.likeCount)"
        lblMessageCount.text = "\(timeline.replyCount)"        
    }
}
