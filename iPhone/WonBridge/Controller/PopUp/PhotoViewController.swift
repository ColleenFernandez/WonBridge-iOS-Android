//
//  PhotoViewController.swift
//  WonBridge
//
//  Created by July on 2016-10-04.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class PhotoViewController: BaseViewController {
    
    var imageUrl: String?
    
    var autoHideInterface: Bool = true
    var controlVisibilityTimer: NSTimer?
    
    var isBackHidden: Bool = false
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    @IBOutlet weak var backButtonView: UIView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)        
        imageView.userInteractionEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        hideBackViewAfterDelay()
    }
    
    func initView() {
        
        guard imageUrl != nil else { return }
        
        imageView = UIImageView(frame: CGRectMake(0, 0, UIScreen.width, UIScreen.height))
        imageView.setImageWithUrl(NSURL(string: imageUrl!)!)
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.contentSize = imageView.bounds.size
        scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        
        setZoomScale()
        
        self.view.bringSubviewToFront(backButtonView)
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 1.0
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    @IBAction func backButtonTapeed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        
        hideBackView()
    }
    
    func cancelBackHiding() {
        // if a timer exists then cancel and release
        if controlVisibilityTimer != nil {
            controlVisibilityTimer!.invalidate()
            controlVisibilityTimer = nil
        }
    }
    
    func hideBackViewAfterDelay() {
        
        if !autoHideInterface {
            return
        }
     
        if !isBackHidden {
            self.cancelBackHiding()
            controlVisibilityTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(hideBackView), userInfo: nil, repeats: false)
        }
    }
    
    func hideBackView() {
        
        isBackHidden = !isBackHidden
        
        UIView.animateWithDuration(0.2, animations: {
            
            let alpha: CGFloat = self.isBackHidden ? 0 : 1
            self.backButtonView.alpha = alpha
            
            }, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension PhotoViewController: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
}
