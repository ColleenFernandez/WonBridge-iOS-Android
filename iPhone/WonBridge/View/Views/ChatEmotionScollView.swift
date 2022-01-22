//
//  TSChatEmotionScollView.swift
//  TSWeChat
//
//  Created by Hilen on 1/6/16.
//  Copyright © 2016 Hilen. All rights reserved.
//

import Foundation

class ChatEmotionScollView: UICollectionView {
    private var touchBeganTime: NSTimeInterval = 0
    private var touchMoved: Bool = false
    private var magnifierImageView: UIImageView!
    private var magnifierContentImageView: UIImageView!
    private var backspaceTimer: NSTimer!
    private weak var currentMagnifierCell: ChatEmotionCell?
    
    var emotionScrollDelegate: ChatEmotionScollViewDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.initialize()
    }
    
    func initialize() {
        self.magnifierImageView = UIImageView(image: WBAsset.Emoticon_keyboard_magnifier.image)
        self.magnifierContentImageView = UIImageView()
        self.magnifierContentImageView.size = CGSizeMake(40, 40)
        self.magnifierContentImageView.centerX = self.magnifierImageView.width / 2
        self.magnifierImageView.addSubview(self.magnifierContentImageView)
        self.magnifierImageView.hidden = true
        self.addSubview(self.magnifierImageView)
    }
    
    override func awakeFromNib() {
        self.clipsToBounds = false
        self.showsHorizontalScrollIndicator = false
        self.userInteractionEnabled = true
        self.canCancelContentTouches = false
        self.multipleTouchEnabled = false
        self.scrollsToTop = false
    }
    
    deinit {
        self.endBackspaceTimer()
    }
    
    /**
     按住删除不动，触发 timer
     */
    func startBackspaceTimer() {
        self.endBackspaceTimer()
        self.backspaceTimer = NSTimer.every(0.1, {[weak self] in
            if self!.currentMagnifierCell!.isDelete {
                UIDevice.currentDevice().playInputClick()
                self!.emotionScrollDelegate?.emoticonScrollViewDidTapCell(self!.currentMagnifierCell!)
            }
        })
        NSRunLoop.mainRunLoop().addTimer(self.backspaceTimer, forMode: NSRunLoopCommonModes)
    }
    
    /**
     停止 timmer
     */
    func endBackspaceTimer() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(ChatEmotionScollView.startBackspaceTimer), object: nil)
        if self.backspaceTimer != nil {
            self.backspaceTimer.invalidate()
            self.backspaceTimer = nil
        }
    }
    
    /**
     根据 touch point 获取 Cell
     
     - parameter touches: touches
     
     - returns: 表情 Cell
     */
    func cellForTouches(touches: Set<UITouch>) -> ChatEmotionCell? {
        let touch =  touches.first as UITouch!
        let point = touch.locationInView(self)
        let indexPath = self.indexPathForItemAtPoint(point)
        guard let newIndexPath = indexPath else {
            return nil
        }
        let cell: ChatEmotionCell = self.cellForItemAtIndexPath(newIndexPath) as! ChatEmotionCell
        return cell
    }
    
    /**
     隐藏放大镜
     */
    func hideMagnifierView() {
        self.magnifierImageView.hidden = true
    }
    
    /**
     显示放大镜
     
     - parameter cell: 将要显示的 cell
     */
    func showMagnifierForCell(cell: ChatEmotionCell) {
    }
}

// MARK: - @extension TSChatEmotionScollView
extension ChatEmotionScollView {
    /**
     touch 响应链 touchesBegan
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchMoved = false
        //        let cell = self.cellForTouches(touches)
        guard let cell = self.cellForTouches(touches) else {
            return
        }
        self.currentMagnifierCell = cell
        self.showMagnifierForCell(self.currentMagnifierCell!)
        if !cell.isDelete && cell.emotionImageView.image != nil {
            UIDevice.currentDevice().playInputClick()
        }
        
        if cell.isDelete {
            self.endBackspaceTimer()
            self.performSelector(#selector(ChatEmotionScollView.startBackspaceTimer), withObject: nil, afterDelay: 0.5)
        }
    }
    
    /**
     touch 响应链 touchesMoved
     */
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchMoved = true
        if self.currentMagnifierCell != nil && self.currentMagnifierCell!.isDelete {
            return
        }
        
        guard let cell = self.cellForTouches(touches) else {
            return
        }
        if cell != self.currentMagnifierCell {
            if !self.currentMagnifierCell!.isDelete && !cell.isDelete {
                self.currentMagnifierCell = cell
            }
            self.showMagnifierForCell(cell)
        }
    }
    
    /**
     touch 响应链 touchesEnded
     */
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let cell = self.cellForTouches(touches) else {
            self.endBackspaceTimer()
            return
        }
        let checkCell = !self.currentMagnifierCell!.isDelete && cell.emotionImageView.image != nil
        let checkMove = !self.touchMoved && cell.isDelete
        if checkCell || checkMove {
            self.emotionScrollDelegate?.emoticonScrollViewDidTapCell(self.currentMagnifierCell!)
        }
        self.endBackspaceTimer()
        self.hideMagnifierView()
    }
    
    /**
     touch 响应链 touchesCancelled
     */
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.hideMagnifierView()
        self.endBackspaceTimer()
    }
}

/**
 *  仅供 TSChatEmotionInputView  使用
 */
// MARK: - @delgate ChatEmotionScollViewDelegate
protocol ChatEmotionScollViewDelegate {
    /**
     点击表情 Cell 或者 delete Cell
     
     - parameter cell: 表情 cell
     */
    func emoticonScrollViewDidTapCell(cell: ChatEmotionCell)
}





