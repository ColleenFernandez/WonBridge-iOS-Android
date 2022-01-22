//
//  TimeLineDetailViewController.swift
//  WonBridge
//
//  Created by Roch David on 11/09/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMaps
import YYText


private let kReplyCellHeight: CGFloat = 50
private let kTimeLinePhotoCellHeight: CGFloat = 124
private let kLikeUserCellImageWidth: CGFloat = 42
private let kLikeUserTableViewMarginTop: CGFloat = 4
private let kLikeUserCellLeftRightPadding: CGFloat = 2
private let kTableViewWidth: CGFloat = kLikeUserCellImageWidth
private let kTimeLinePhotoViewHeight: CGFloat = 128

class TimeLineDetailViewController: BaseViewController {
    
    var _user: UserEntity?
    var selectedTimeLine: TimeLineEntity?
    
    // like or dislike status
    // true - like: will be pink heart
    // false - dislike: will be gray heart
    var _isLike: Bool = false
    var _likeUsers = [FriendEntity]()
    var _replys = [ReplyEntity]()

    @IBOutlet weak var imvProfilePhoto: UIImageView!
    @IBOutlet weak var imvBgUserProfile: UIImageView!
    @IBOutlet weak var lblLastLoggedTime: UILabel!
    @IBOutlet weak var lblFriendStatus: UILabel!
    @IBOutlet weak var lblPostedTime: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    // 有空出来聚餐啊，好久不见了~~
//    @IBOutlet weak var lblTimeLineText: YYLabel! { didSet {
//        
//        }}
    
    @IBOutlet weak var lblTimeLineText: YYLabel! { didSet {
        lblTimeLineText.highlightTapAction = ({ [weak self] containerView, text, range, rect in
            self!.didTapRichLabelText(self!.lblTimeLineText, textRange: range)
        })
        }
    }
    
    @IBOutlet weak var inputbar: TimeLineInputbar!
    @IBOutlet weak var inputbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLinePhotosRootView: UIView! { didSet {
        timeLinePhotosRootView.clipsToBounds = true
        }}
    
    // timeline photo horizontal scroll tableview
    private lazy var timeLinePhotosTableView: UITableView = {
        
        let tableView = UITableView(frame: CGRectMake(2, 2, kTimeLinePhotoCellHeight, UIScreen.mainScreen().bounds.width - 4))
        tableView.backgroundColor = UIColor.clearColor()
        tableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
        tableView.center =  CGPointMake(self.view.frame.size.width / 2, kTimeLinePhotoViewHeight / 2.0 )
        
        tableView.pagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = kTimeLinePhotoCellHeight
        
        return tableView
    }()
    
    // height for timeline photos
    // will be set zero if no files in selected timeline
    @IBOutlet weak var timeLinePhotosHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeUsersCountLabel: UILabel!
    @IBOutlet weak var replyMessageCountLabel: UILabel!
    @IBOutlet weak var likeActionButton: UIButton!
    @IBOutlet weak var likeUsersCountArrowLabel: UILabel!
    @IBOutlet weak var likeUsersTableRootView: UIView!
    
    private lazy var likeUserTableView: UITableView = {
        
        let tableView = UITableView(frame: CGRectMake(0, kLikeUserTableViewMarginTop, kTableViewWidth, UIScreen.mainScreen().bounds.width - 120))
        
        tableView.backgroundColor = UIColor.clearColor()
        tableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
        tableView.center = CGPointMake((self.view.frame.size.width - 110) / 2, 30 )
        
        tableView.pagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.rowHeight = kTableViewWidth + 2*kLikeUserCellLeftRightPadding
        
        return tableView
    } ()

    @IBOutlet weak var likeUserTableRootViewHeight: NSLayoutConstraint!
    @IBOutlet weak var replyUserTableView: UITableView!
    @IBOutlet weak var replyTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeLineTextLabelHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _user = WBAppDelegate.me
        
        if CommonUtils.isCNLocale() {
            geocodeSearch = BMKGeoCodeSearch()
        } else {
            googleGeocoder = GMSGeocoder()
        }
        
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        if CommonUtils.isCNLocale() {
            geocodeSearch.delegate = self
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        if CommonUtils.isCNLocale() {
            geocodeSearch.delegate = nil
        }
    }
    
    func initView() {

        // remove show timeline list
//        let btnShowList = UIButton()
//        btnShowList.frame = CGRectMake(0, 0, 80, 30)
//        btnShowList.setTitle(Constants.TITLE_SHOWLIST, forState: .Normal)
//        btnShowList.backgroundColor = UIColor(netHex: 0xf7f7f7)
//        btnShowList.setTitleColor(UIColor.blackColor(), forState: .Normal)
//        btnShowList.titleLabel!.font = UIFont.systemFontOfSize(15)
//        btnShowList.layer.cornerRadius = 15
//        btnShowList.layer.masksToBounds = true
//        
//        btnShowList.addTarget(self, action: #selector(showListTapped), forControlEvents: .TouchUpInside)
//        let rightBarButton = UIBarButtonItem(customView: btnShowList)
//        self.navigationItem.rightBarButtonItem = rightBarButton
        
//        imvProfilePhoto.layer.borderColor = UIColor.whiteColor().CGColor
//        imvProfilePhoto.layer.borderWidth = 2
        
        // setup inputbar
        setupInputbar()
        
        guard selectedTimeLine != nil  else {
            return
        }
            
        self.title = selectedTimeLine?.user_name
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // user profile image of selected timeline
        imvProfilePhoto.setImageWithUrl(NSURL(string:selectedTimeLine!.photo_url)!, placeHolderImage: UIImage(named: "img_user")!)
        
        self.timeLinePhotosTableView.registerNib(TimeLinePhotoCell.NibObject(), forCellReuseIdentifier: TimeLinePhotoCell.identifier)
        self.likeUserTableView.registerNib(LikeUserCell.NibObject(), forCellReuseIdentifier: LikeUserCell.identifier)
        
        timeLinePhotosRootView.addSubview(timeLinePhotosTableView)
        likeUsersTableRootView.addSubview(likeUserTableView)
        
        replyUserTableView.dataSource = self
        replyUserTableView.rowHeight = kReplyCellHeight
        
        if selectedTimeLine!.user_id == _user!._idx {
            likeActionButton.setBackgroundImage(nil, forState: .Normal)
            likeActionButton.setImage(nil, forState: .Normal)
            likeActionButton.setTitle(Constants.TITLE_DEL, forState: .Normal)
        }
        
        updateUI()
        
        setTimeLineImages()
        
        getTimeLineDetail()
    }
    
    // update ui
    // this is for showing timeline deatil in case of coming from timeline list...
    func updateUI() {
        
        let attributedString = WBTimeLineTextParser.parseText(selectedTimeLine!.content, font: UIFont.systemFontOfSize(16), color: UIColor(netHex: 0x5B5B5B))
        
        //初始化排版布局对象
        let modifier = WBYYTextLinePositionModifier(font: UIFont.systemFontOfSize(16))
        
        //初始化 YYTextContainer
        let textContainer: YYTextContainer = YYTextContainer()
        textContainer.size = CGSize(width: self.view.width - 40, height: CGFloat.max)
        textContainer.linePositionModifier = modifier
        textContainer.maximumNumberOfRows = 0
        
        //设置 layout
        let textLayout = YYTextLayout(container: textContainer, text: attributedString!)
        
        //计算高度
        let stringHeight = modifier.heightForLineCount(Int(textLayout!.rowCount))
        timeLineTextLabelHeightConstraint.constant = stringHeight
        
        // age, logged time, current status
//        lblTimeLineText.text = selectedTimeLine!.content
        lblTimeLineText.attributedText = attributedString
        // post timeline date
        // time was set utc timezone , it will be need to change local timezone
        lblPostedTime.text = selectedTimeLine!.postedTime.displayLocalTime()
        // timeline - address
        getAddress(selectedTimeLine!.location, completion: { (address) in
            self.lblAddress.text = address
        })
    }
    
    // setup inputbar
    func setupInputbar() {
        
        // Customize Inputbar
        inputbar.translucent = false
        // remove default border on top
        inputbar.clipsToBounds = true
        // add top border
        let upperBorder = CALayer()
        upperBorder.backgroundColor = UIColor.whiteColor().CGColor
        upperBorder.frame = CGRectMake(0, 0, self.inputbar.frame.size.width, 1.0)
        inputbar.layer.addSublayer(upperBorder)
        
        inputbar.sendButtonImage = UIImage(named: "button_send_chat")!
        
        inputbar.normalImage = "button_send_chat"
        inputbar.selectedImage = "button_send_press_chat"
        
        inputbar.tDelegate = self
        
        self.keyboardControl()
        
        // disable inputbar if user open his or her timeline detail page
        if selectedTimeLine!.user_id == _user!._idx {
            inputbar.textView.userInteractionEnabled = false
        }
    }
    
    func getTimeLineDetail() {
        
        WebService.getTimeLineDetail(selectedTimeLine!.id, userId: _user!._idx) { (status, userLastLogin, isFriend, isLike, likeUsers, replys) in
            
            if (status) {
                
                self._likeUsers.removeAll()
                self._replys.removeAll()
                
                self.selectedTimeLine!.userLastLogin = userLastLogin
                self.selectedTimeLine!.isFriend = isFriend
                
                self._isLike = isLike
                self._likeUsers = likeUsers
                self._replys = replys
                
                self.updateTimeLineInfo()
            }
        }
    }
    
    func setTimeLineImages() {
        
        self.timeLinePhotosTableView.reloadData()
        
        if selectedTimeLine!.file_url.count > 0 {
            timeLinePhotosHeightConstraint.constant = kTimeLinePhotoViewHeight
        } else {
            timeLinePhotosHeightConstraint.constant = 0
        }
        
        self.view.layoutIfNeeded()
    }
    
    func updateTimeLineInfo() {
        
        // user information of this timeline
        // user last login
        lblLastLoggedTime.text = selectedTimeLine!.userLastLogin.displayLocalTime()
        
        if selectedTimeLine!.isFriend {
            lblFriendStatus.text = Constants.STATE_FRIEND
        } else {
            lblFriendStatus.text = ""
        }
    
        updateLikeUserView()
        updateReplyView()
    }
    
    func updateLikeUserView() {
        
        if _user!._idx != selectedTimeLine?.user_id {
            
            if (_isLike) {
                
                likeActionButton.setImage(WBAsset.Button_LikeTimeLine.image, forState: .Normal)
            } else {
                
                likeActionButton.setImage(WBAsset.Button_DislikeTimeLine.image, forState: .Normal)
            }
        }
        
        likeUsersCountLabel.text = "\(_likeUsers.count)"        
        
        if _likeUsers.count > 0 {
            
            likeUsersCountArrowLabel.text = "(\(_likeUsers.count)) >"
            likeUsersCountArrowLabel.hidden = false
            likeUserTableRootViewHeight.constant = 60
            
            self.view.layoutIfNeeded()
            likeUserTableView.reloadData()
            
        } else {
            
            likeUserTableRootViewHeight.constant = 0
            likeUsersCountArrowLabel.hidden = true
            self.view.layoutIfNeeded()
            
            likeUserTableView.reloadData()
        }
    }
    
    func updateReplyView() {
        
        replyMessageCountLabel.text = "\(_replys.count)"
        replyTableViewHeightConstraint.constant = CGFloat(60 * _replys.count)
        self.view.layoutIfNeeded()
        
        replyUserTableView.reloadData()
    }
    
    func gotoUserProfile(friend: FriendEntity) {
        
        let userProfileVC = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        userProfileVC.from = FROM_TIMELINEDETAIL
        userProfileVC._selectedUser = friend
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    // go to user timeline list
    @IBAction func userProfilePhotoTapped(sender: AnyObject) {
        
        guard _user != nil else { return }
        
        guard selectedTimeLine != nil else { return }
        
        guard _user!._idx != selectedTimeLine!.user_id else { return }
        
        guard let selectedUser = _user!.getFriend(selectedTimeLine!.user_id) else {
            let timeLineUser = FriendEntity()
            timeLineUser._idx = selectedTimeLine!.user_id
            timeLineUser._name = selectedTimeLine!.user_name
            timeLineUser._photoUrl = selectedTimeLine!.photo_url
            gotoUserProfile(timeLineUser)
            
            return
        }
        
        gotoUserProfile(selectedUser)
    }

    @IBAction func backButtonTapped(sender: AnyObject) {
        
        if selectedTimeLine!.user_id == _user!._idx {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.performSegueWithIdentifier("unwind2TimeLine", sender: self)
        }
    }
    
    // show user timeline list
    func showListTapped() {
        
        let viewControllers = navigationController?.viewControllers
        
        guard viewControllers != nil && viewControllers!.count >= 2 else { return }
        let beforeVC = viewControllers![viewControllers!.count - 2]
        
        if beforeVC.isKindOfClass(TimeLineListViewController) {
            navigationController?.popViewControllerAnimated(true)
        } else {
            self.performSegueWithIdentifier("SegueTimeLineDeatil2List", sender: self)
        }
    }
    
    func deleteTimeLine() {
        
        showLoadingViewWithTitle("")
        
        WebService.deleteTimeLine(selectedTimeLine!.id) { (status, message) in
            
            self.hideLoadingView()
            if status {
                self.gotoLastVC()
            } else {
                self.showAlert(Constants.APP_NAME, message: Constants.FAIL_TO_CONNECT, positive: Constants.ALERT_OK, negative: nil)
            }
        }
    }
    
    // TimeLineViewController or TimeLineList( MY )
    func gotoLastVC() {
        
        let viewControllers = navigationController?.viewControllers        
        guard viewControllers != nil && viewControllers!.count >= 2 else {
            return
        }
        
        let lastVC = viewControllers![viewControllers!.count - 2]        
        if lastVC.isKindOfClass(TimeLineListViewController) {
            // goto TimeLineListViewController (my timeline list)
            self.performSegueWithIdentifier("unwind2TimeLineList", sender: self)
        } else {
            // goto TimeLineViewController
            self.performSegueWithIdentifier("unwind2TimeLine", sender: self)
        }
    }
    
    func showDeleteConfirmDialog() {
        
        let storyboard = UIStoryboard(name: "Custom", bundle: nil)
        
        let customAlert = storyboard.instantiateViewControllerWithIdentifier("CustomAlertViewController") as! CustomAlertViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        customAlert.statusBarHidden = prefersStatusBarHidden()
        
        customAlert.showCustomAlert(self, title: Constants.TITLE_CONFIRM_DELETE, positive: Constants.ALERT_OK, negative: Constants.ALERT_CANCEL, positiveAction: { _ in
            self.deleteTimeLine()
        }) {}
    }
    
    // like or dislike action
    @IBAction func actionButtonTapped(sender: AnyObject) {
        
        if selectedTimeLine!.user_id == _user!._idx {
            // this will do a action for deleting my timeline.
            showDeleteConfirmDialog()
            
        } else {
            
            // like or dislike timeline posted by other users
            WebService.likeTimeLine(selectedTimeLine!.id, userId: _user!._idx, like: !_isLike) { (status) in
                
                if (status) {
                    
                    self._isLike = !self._isLike
                    
                    let me = FriendEntity()
                    me._idx = self._user!._idx
                    me._name = self._user!._name
                    me._photoUrl = self._user!._photoUrl
                    
                    if self._isLike && !self._likeUsers.contains(me) {
                        
                        self._likeUsers.append(me)
                        
                    } else if !self._isLike {
                        
                        for index in 0 ..< self._likeUsers.count {
                            
                            if self._likeUsers[index]._idx == me._idx {
                                
                                self._likeUsers.removeAtIndex(index)
                                break
                            }
                        }
                    }
                    
                    self.updateLikeUserView()
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SegueTimeLineDeatil2List" {
            
            let timeLineListVC = segue.destinationViewController as! TimeLineListViewController
            
            timeLineListVC.selectedTimeLine = self.selectedTimeLine
            
        } else if segue.identifier == "SegueTimeLineDetail2LikeUsers" {
            
            let likeUsersVC = segue.destinationViewController as! LikeUsersViewController
            
            likeUsersVC._likeUsers = self._likeUsers
            likeUsersVC._selectedTimeLine = self.selectedTimeLine
        }
    }
    
    @IBOutlet weak var superScrolView: UIScrollView!
    
    func scrollToBottom() {
        
        guard (superScrolView.contentSize.height - superScrolView.bounds.size.height) > 0 else { return }
        
        let bottomOffSet = CGPointMake(0, self.superScrolView.contentSize.height - self.superScrolView.bounds.size.height)
        
        self.superScrolView.setContentOffset(bottomOffSet, animated: true)
    }
    
    @IBAction func prepareForUnwindToTimeLineDetail(segue: UIStoryboardSegue) {
        
        if segue.identifier == "unwind2TimeLineDetail" {
            let sourceVC = segue.sourceViewController as! TimeLineListViewController
            
            self.selectedTimeLine = sourceVC.selectedTimeLine
            
            updateUI()
            setTimeLineImages()
            
            getTimeLineDetail()
        }
    }
    
}

// MARK: UITableViewDataSource
extension TimeLineDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == timeLinePhotosTableView {
            
            guard selectedTimeLine != nil else  { return  0 }
            return selectedTimeLine!.file_url.count
        } else if tableView == likeUserTableView {
            
            return _likeUsers.count
        } else {
            
            return _replys.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == timeLinePhotosTableView {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(TimeLinePhotoCell.identifier, forIndexPath: indexPath)  as! TimeLinePhotoCell
            cell.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2.0))
            cell.selectionStyle = .None
            cell.backgroundColor = UIColor.clearColor()
            cell.configCell(selectedTimeLine!.file_url[indexPath.row], bFile: false, deleteAction: nil)
            cell.hideDelButton()
            
            return cell
            
        } else if tableView == likeUserTableView {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(LikeUserCell.identifier) as! LikeUserCell
            cell.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2.0))
            cell.selectionStyle = .None
            cell.backgroundColor = UIColor.clearColor()
            cell.configCell(_likeUsers[indexPath.row])
            
            return cell
            
        } else {            
            
            let cell = tableView.dequeueReusableCellWithIdentifier("TimeLineReplyCell") as! TimeLineReplyCell
            cell.configureCell(_replys[indexPath.row])
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard tableView == timeLinePhotosTableView else { return }
        
//        photoVC.imageUrls = selectedTimeLine!.file_url
        
        var photos = [IDMPhoto]()
        for url in selectedTimeLine!.file_url {
            photos.append(IDMPhoto(URL: NSURL(string: url)!))
        }
        
        let broswer = IDMPhotoBrowser(photos: photos)
        broswer.delegate = self
        broswer.displayToolbar = false
        broswer.setInitialPageIndex(UInt(indexPath.row))
        broswer.doneButtonImage = WBAsset.BackButton.image
        
        // show
        self.presentViewController(broswer, animated: true, completion: nil)
    }
    
    private func didTapRichLabelText(label: YYLabel, textRange: NSRange) {
        //解析 userinfo 的文字
        let attributedString = label.textLayout!.text
        if textRange.location >= attributedString.length {
            return
        }
        guard let hightlight: YYTextHighlight = attributedString.yy_attribute(YYTextHighlightAttributeName, atIndex: UInt(textRange.location)) as? YYTextHighlight else {
            return
        }
        guard let info = hightlight.userInfo where info.count > 0 else {
            return
        }
        
        if let URL: String = info[kChatTextKeyURL] as? String {
            UIApplication.sharedApplication().openURL(NSURL(string: URL)!)
        }
    }
}

extension TimeLineDetailViewController: IDMPhotoBrowserDelegate {
    
    // all delegate methods are optional
    
}






