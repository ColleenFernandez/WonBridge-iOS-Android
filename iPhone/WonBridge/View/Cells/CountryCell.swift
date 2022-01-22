//
//  CountryCell.swift
//  WonBridge
//
//  Created by July on 2016-09-29.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class CountryCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lbCode: UILabel!
    
    func setContent(model: CountryModel) {
        
        lblName.text = model.name
        lbCode.text = model.code
    }
}
