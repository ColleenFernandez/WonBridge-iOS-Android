//
//  NameCell.swift
//  WonBridge
//
//  Created by Elite on 11/2/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class NameCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(name: String) {
        
        lblName.text = name
    }
}
