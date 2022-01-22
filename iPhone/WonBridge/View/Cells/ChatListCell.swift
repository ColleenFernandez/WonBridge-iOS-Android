//
//  ChatListCell.swift
//  WonBridge
//
//  Created by Tiia on 01/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

private let kSwipeWidth: CGFloat = 180

class ChatListCell: UITableViewCell {
    
    @IBOutlet weak var imvAvatar: UIImageView! { didSet {
        imvAvatar.layer.cornerRadius = 25
        imvAvatar.layer.masksToBounds = true
        }}
    
    // group chat list avatar view
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var imvAvatar1: UIImageView!
    @IBOutlet weak var imvAvatar2: UIImageView!
    @IBOutlet weak var imvAvatar3: UIImageView!
    @IBOutlet weak var imvAvatar4: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var vBadge: UIView!
    @IBOutlet weak var lblUnreadCount: UILabel!
    @IBOutlet weak var imvCountry: UIImageView!
    @IBOutlet weak var imvFavCountry: UIImageView!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var firstX: CGFloat = CGFloat(0)
    
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var bgView: UIView!
    
    var readAction: ((sender: UIButton) -> Void)?
    var deleteAction: ((sender: UIButton) -> Void)?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .None
        
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        
        lblContent.textColor = UIColor(colorNamed: WBColor.chatListCotentGray)
        
        readButton.addTarget(self, action: #selector(readButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(move(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        
        self.bgView.addGestureRecognizer(panGestureRecognizer)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(room: RoomEntity, readAction: (sender: UIButton) -> Void, deleteAction: (sender: UIButton) -> Void) {
        
        if room.isSingle() {
            
            // 1:1 chat
            // hide group avatar view
            avatarView.hidden = true
            imvAvatar.hidden = false
            
            var parti = room._participants.componentsSeparatedByString("_")
            var otherIdx = parti[0]
            if Int(otherIdx) == WBAppDelegate.me._idx {
                otherIdx = parti[1]
            }
        
            guard let participant = room.getParticipant(Int(otherIdx)!) else { return }
            imvAvatar.setImageWithUrl(NSURL(string: participant._photoUrl)!, placeHolderImage: WBAsset.UserPlaceHolder.image)
            lblName.text = room._displayName.uppercaseString
            imvCountry.image = UIImage(named: "ic_flag_flat_\(participant._countryCode.trim().lowercaseString)")
            
            if participant._favCountry.length > 0 {
                imvFavCountry.hidden = false
                imvFavCountry.image = UIImage(named: "ic_flag_flat_\(participant._favCountry.trim().lowercaseString)")
            } else {
                imvFavCountry.hidden = true
            }
            
        } else {
            
            // group chat
            // show group avatar view
            
            let group = WBAppDelegate.me.getGroup(room._name)
            if group != nil && group!.getNickname().characters.count > 0 {
                lblName.text = group!.getNickname() + room.getDisplayCount()
            } else {
                lblName.text = room._displayName + room.getDisplayCount()
            }

            if group != nil {
                
                if group!.profileUrl.length > 0 {
                    avatarView.hidden = true
                    imvAvatar.hidden = false
                    
                    imvAvatar.setImageWithUrl(NSURL(string: group!.profileUrl)!, placeHolderImage: WBAsset.GroupPlaceHolder.image)
                } else {
                    
                    if group!.profileUrls.count > 0 {
                        
                        avatarView.hidden = false
                        imvAvatar.hidden = true
                        
                        var imageViews = [UIImageView]()
                        imageViews.append(imvAvatar1)
                        imageViews.append(imvAvatar2)
                        imageViews.append(imvAvatar3)
                        imageViews.append(imvAvatar4)
                        
                        for index in 0 ..< 4 {
                            
                            if index < group!.profileUrls.count {
                                imageViews[index].setImageWithUrl(NSURL(string: group!.profileUrls[index])!, placeHolderImage: WBAsset.UserPlaceHolder.image)
                            } else {
                                imageViews[index].image = UIImage.imageWithColor(UIColor(colorNamed: WBColor.Gray), size: CGSizeMake(25, 25))
                            }
                        }
                        
                    } else {
                        avatarView.hidden = true
                        imvAvatar.hidden = false
                        
                        imvAvatar.setImageWithUrl(NSURL(string: group!.profileUrl)!, placeHolderImage: WBAsset.GroupPlaceHolder.image)
                    }
                }
                
                
                imvCountry.image = UIImage(named: "ic_flag_flat_\(group!.countryCode.trim().lowercaseString)")
            }
            
            imvFavCountry.hidden = true
        }
        
        lblContent.text = room._recentContent
        
        lblTime.text = room.getDisplayTime()
        
        setBadgeCount(room._recentCount)
        
        self.readAction = readAction
        self.deleteAction = deleteAction
    }
    
    func setBadgeCount(count: Int) {
        
        if (count == 0) {
            setBadgeVisibility(false)
        } else {
            setBadgeVisibility(true)
        }
        
        lblUnreadCount.text = "\(count)"
    }
    
    func setBadgeVisibility(visible: Bool) {
        
        if (visible) {
            vBadge.hidden = false
        } else {
            vBadge.hidden = true
        }
    }
    
    func enablePanGesture(enableGesture: Bool) {
        
        if enableGesture {
            bgView.removeGestureRecognizer(panGestureRecognizer)
            
        } else {
            bgView.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    func move(sender: UIPanGestureRecognizer) {
        
        var translatedPoint = sender.translationInView(self.bgView)
        
        if sender.state == UIGestureRecognizerState.Began {
            firstX = sender.view!.center.x
        }
        
        if firstX + translatedPoint.x > self.frame.size.width / 2 {
            translatedPoint = CGPointMake(self.frame.size.width / 2, self.bgView.center.y)
            
        } else if firstX + translatedPoint.x < self.frame.size.width / 2 - kSwipeWidth {
            translatedPoint = CGPointMake(self.frame.size.width / 2 - kSwipeWidth, self.bgView.center.y)
            
        } else {
            translatedPoint = CGPointMake(firstX + translatedPoint.x, self.bgView.center.y)
        }
        
        sender.view?.center = translatedPoint
        if sender.state == UIGestureRecognizerState.Ended || sender.state == UIGestureRecognizerState.Cancelled {
            
            let velocityX = 0.2 * sender.velocityInView(self.bgView).x
            
            var finalX = translatedPoint.x + velocityX
            if finalX < (self.frame.size.width / 2 - kSwipeWidth / 2) {
                finalX = self.frame.size.width / 2 - kSwipeWidth
                
            } else {
                finalX = self.frame.size.width / 2
            }
//            let animationDuration = Swift.abs(velocityX) * 0.002 + 0.2
            
            UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
                sender.view?.center = CGPointMake(finalX, self.bgView.center.y)
            })
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer) {
            
            let g = gestureRecognizer as! UIPanGestureRecognizer
            let point = g.velocityInView(self)
            
            let sPoint = gestureRecognizer.locationInView(self.bgView)
            
            if fabsf(Float(point.x)) > fabsf(Float(point.y)) && sPoint.x > 50 && sPoint.x < UIScreen.mainScreen().bounds.size.width - 50 {
                return true
            }
        }
        
        return false
    }
    
    func readButtonTapped(sender: UIButton) {
        
        UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
            self.bgView.center = CGPointMake(self.frame.size.width / 2, self.bgView.center.y)
        })
        
        if readAction != nil {
            readAction!(sender: sender)
        }
    }
    
    func deleteButtonTapped(sender: UIButton) {
        
        UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
            self.bgView.center = CGPointMake(self.frame.size.width / 2, self.bgView.center.y)
        })
        
        if self.deleteAction != nil {
            self.deleteAction!(sender: sender)
        }
    }
}

extension UIView {
    
    var parentViewController: UIViewController? {
        
        var parentResponder: UIResponder? = self
        
        while parentResponder != nil {
            
            parentResponder = parentResponder!.nextResponder()
            
            if parentResponder is UIViewController {
                 
                return parentResponder as! UIViewController!
            }
        }
        
        return nil
    }
}








