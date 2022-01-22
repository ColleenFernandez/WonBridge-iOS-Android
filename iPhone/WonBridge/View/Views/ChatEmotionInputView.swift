//
//  TSChatEmotionInputView.swift
//  TSWeChat
//
//  Created by Hilen on 12/16/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import UIKit
import Dollar
import RxSwift

private let kPageIndicaterHeight: CGFloat = 40
private let kOneGroupCount = 18
private let kNumberOfOneRow: CGFloat = 6

class ChatEmotionInputView: UIView {
    @IBOutlet private weak var emotionPageControl: UIPageControl!

    @IBOutlet private weak var listCollectionView: ChatEmotionScollView!
    private var groupDataSouce = [[EmotionModel]]()  //大数组包含小数组
    private var emotionsDataSouce = [EmotionModel]()  //Model 数组
    internal var delegate: ChatEmotionInputViewDelegate?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.initialize()
    }
        
    func initialize() {

    }
    
    override func awakeFromNib() {
        self.userInteractionEnabled = true
        
        //calculate width and height
        let itemHeight = (self.height - kPageIndicaterHeight - 10*4) / 3.0
        let itemWidth = itemHeight
        
        let padding = (UIScreen.width - kNumberOfOneRow * itemWidth) / (kNumberOfOneRow + 1)
        
        //init FlowLayout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.itemSize = CGSizeMake(itemWidth, itemHeight)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsetsMake(padding, padding, 0, padding)
        
        //init listCollectionView
        self.listCollectionView.collectionViewLayout = layout
        self.listCollectionView.registerNib(ChatEmotionCell.NibObject(), forCellWithReuseIdentifier: ChatEmotionCell.identifier)
        self.listCollectionView.pagingEnabled = true
        self.listCollectionView.emotionScrollDelegate = self

        //init dataSource
        guard let emojiArray = NSArray(contentsOfFile: WBConfig.ExpressionPlist!) else {
            return
        }
        
        for data in emojiArray {
            let index = emojiArray.indexOfObject(data)
            let model = EmotionModel.init(fromDictionary: data as! NSDictionary, index: index)
            self.emotionsDataSouce.append(model)
        }
        self.groupDataSouce = $.chunk(self.emotionsDataSouce, size: kOneGroupCount)  //将数组切割成 每23个 一组
        self.listCollectionView.reloadData()
        self.emotionPageControl.numberOfPages = self.groupDataSouce.count
    }
    
    //transpose line/row
    private func emoticonForIndexPath(indexPath: NSIndexPath) -> EmotionModel? {
        let page = indexPath.section
        var index = page * kOneGroupCount + indexPath.row
        
        let ip = index / kOneGroupCount  //重新计算的所在 page
        let ii = index % kOneGroupCount  //重新计算的所在 index
        let reIndex = (ii % 3) * Int(kNumberOfOneRow) + (ii / 3)  //最终在数据源里的 Index
        
        index = reIndex + ip * kOneGroupCount
        if index < self.emotionsDataSouce.count {
            return self.emotionsDataSouce[index]
        } else {
            return nil
        }
    }
}

// MARK: - @protocol UICollectionViewDelegate
extension ChatEmotionInputView: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

// MARK: - @protocol UICollectionViewDataSource
extension ChatEmotionInputView: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.groupDataSouce.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kOneGroupCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ChatEmotionCell.identifier, forIndexPath: indexPath) as! ChatEmotionCell
        cell.setCellContnet(self.emoticonForIndexPath(indexPath))
        return cell
    }
}

// MARK: - @protocol UIScrollViewDelegate
extension ChatEmotionInputView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth: CGFloat = self.listCollectionView.frame.sizeWidth
        self.emotionPageControl.currentPage = Int(self.listCollectionView.contentOffset.x / pageWidth)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.listCollectionView.hideMagnifierView()
        self.listCollectionView.endBackspaceTimer()
    }
}

// MARK: - @protocol UIInputViewAudioFeedback
extension ChatEmotionInputView: UIInputViewAudioFeedback {
    internal var enableInputClicksWhenVisible: Bool {
        get { return true }
    }
}


// MARK: - @protocol ChatEmotionScollViewDelegate
extension ChatEmotionInputView: ChatEmotionScollViewDelegate {
    func emoticonScrollViewDidTapCell(cell: ChatEmotionCell) {
        guard let delegate = self.delegate else {
            return
        }
     
        delegate.chatEmoticonInputViewDidTapCell(cell)
    }
}

/**
 *  表情键盘的代理方法
 */
 // MARK: - @delegate ChatEmotionInputViewDelegate
protocol ChatEmotionInputViewDelegate {
    /**
     点击表情 Cell
     
     - parameter cell: 表情 cell
     */
    func chatEmoticonInputViewDidTapCell(cell: ChatEmotionCell)
}









