//
//  MenuItemCell.swift
//  WonBridge
//
//  Created by Elite on 10/12/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class MenuItemCell: UICollectionViewCell {
    
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemIcon: UIImageView!
    
    func setContent(item: (String, UIImage)) {
        itemIcon.image = item.1
        itemName.text = item.0
    }
}
