//
//  ContactPartnerCell.swift
//  WonBridge
//
//  Created by Elite on 10/12/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class ContactPartnerCell: UITableViewCell {
    
    @IBOutlet weak var actionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        actionButton.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
