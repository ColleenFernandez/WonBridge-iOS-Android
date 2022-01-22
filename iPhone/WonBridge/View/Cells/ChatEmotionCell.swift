//
//  TSChatEmotionCell.swift
//  TSWeChat
//
//  Created by Hilen on 12/22/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import UIKit

class ChatEmotionCell: UICollectionViewCell {
    
    @IBOutlet weak var emotionImageView: UIImageView!
    internal var isDelete: Bool = false
    var emotionModel: EmotionModel? = nil

    override func prepareForReuse() {
        super.prepareForReuse()
        self.emotionImageView.image = nil
        self.emotionModel = nil
    }
    
    func setCellContnet(model: EmotionModel? = nil) {
        guard let model = model else {
            self.emotionImageView.image = nil
            return
        }
        self.emotionModel = model
        self.isDelete = false
        if let path = WBConfig.ExpressionBundle!.pathForResource(model.imageString, ofType:"png") {
            self.emotionImageView.image = UIImage(contentsOfFile: path)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}


/**
 *  表情的 Model
 */

let EMOJI_PREFIX = "[emoji_"
let EMOJI_SUFFIX = "]"

struct EmotionModel {
    var imageString : String!
    var text : String!
    var idx: Int!
    
    init(fromDictionary dictionary: NSDictionary, index: Int){
        let imageText = dictionary["image"] as! String
        imageString = "\(imageText)@3x"
        text = EMOJI_PREFIX + "\(index)" + EMOJI_SUFFIX
    }
}



