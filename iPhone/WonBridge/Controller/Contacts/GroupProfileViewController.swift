//
//  GroupProfileViewController.swift
//  WonBridge
//
//  Created by Elite on 10/8/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class GroupProfileViewController: BaseTableViewController {
    
    var group: GroupEntity?
    
    @IBOutlet weak var lblMemberCount: UILabel!
    @IBOutlet weak var lblNickname: UILabel!
    @IBOutlet weak var imvAvatar: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        guard group != nil else { return }
        
        self.title = Constants.TITLE_GROUPPROFILE + "(\(group!.memberCount))"
        
        imvAvatar.setImageWithUrl(NSURL(string: group!.profileUrl)!, placeHolderImage: WBAsset.GroupPlaceHolder.image)
        lblMemberCount.text = Constants.GROUP_MEMBER_COUNT + "(\(group!.memberCount))"
        lblNickname.text = group!.nickname
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
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
