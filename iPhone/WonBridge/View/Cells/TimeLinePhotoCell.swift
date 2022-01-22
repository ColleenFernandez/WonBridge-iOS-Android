//
//  TimeLinePhotoCellTableViewCell.swift
//  WonBridge
//
//  Created by Roch David on 11/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class TimeLinePhotoCell: UITableViewCell {

    @IBOutlet weak var imvPhoto: UIImageView!
    
    @IBOutlet weak var imvDelButton: UIImageView!
    
    @IBOutlet weak var btnDelete: UIButton!
    
    var deleteAction: ((sender: UIButton) -> Void)?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(strImgPath: String, bFile: Bool, deleteAction: ((sender: UIButton) -> Void)?) {
        
        self.imvPhoto.contentMode = .ScaleAspectFill
        self.imvPhoto.clipsToBounds = true
        
        if strImgPath != "" {
            if bFile {
                let path = ImageFilesManager.cachePathForKey(strImgPath)
                self.imvPhoto.image = UIImage(contentsOfFile: path!)
            } else {                
                self.imvPhoto.setImageWithUrl(NSURL(string: strImgPath)!, placeHolderImage: UIImage.imageWithColor(UIColor(netHex: 0x5f99fb), size: self.bounds.size))
            }
            
        }
        
        btnDelete.userInteractionEnabled = true
        btnDelete.addTarget(self, action: #selector(deleteBtnTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.deleteAction = deleteAction
    }
    
    func hideDelButton() {
        imvDelButton.hidden = true
        btnDelete.hidden = true
    }

    func deleteBtnTapped(sender: AnyObject) {
        
        if deleteAction != nil {
        
            deleteAction!(sender: sender as! UIButton)
        }
    }
}
