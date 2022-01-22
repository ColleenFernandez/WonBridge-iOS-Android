//
//  SelectSchoolViewController.swift
//  WonBridge
//
//  Created by Elite on 11/2/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import SwiftyJSON

let FROM_LOCATION2SCHOOL  =     "From_Location_School"
let FROM_CHANGESCHOOL      =    "From_ChangeSchool"

class SelectSchoolViewController: BaseViewController {
    
    var from = FROM_LOCATION2SCHOOL
    
    var isSearch = false
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var listTableView: UITableView!
    
    var selectedSchool: String = ""
    
    var schools = [String]()
    
    var searchItemDataSource = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initData()
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(textFieldDidChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        listTableView.dataSource = self
        listTableView.delegate = self
        
        listTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initData() {
        
        guard let JsonData = NSData.dataFromJSONFile("china_university") else { return }
        
        let jsonObj = JSON(data: JsonData)
        
        guard let jsonArray = jsonObj.array else { return }
        
        for index in 0 ..< jsonArray.count {
            
            if let jsonSchoolArray = jsonArray[index]["school"].array {
                
                for schoolIndex in 0 ..< jsonSchoolArray.count {
                    schools.append(jsonSchoolArray[schoolIndex]["name"].string!)
                }
            }
        }
    }
    
    func textFieldDidChanged(textField: UITextField) {
        
        if textField.text!.isEmpty {
            textField.resignFirstResponder()
            
            isSearch = false
            listTableView.reloadData()
        } else {
            
            searchSchool(textField.text!)
        }
    }
    
    func searchSchool(name: String) {
        
        searchItemDataSource.removeAll()
        for school in schools {
            if school.rangeOfString(name, options: .RegularExpressionSearch) != nil {
                searchItemDataSource.append(school)
            }
        }
        
        isSearch = true
        listTableView.reloadData()
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
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

extension SelectSchoolViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearch {
            return searchItemDataSource.count
        } else {
            return schools.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NameCell") as! NameCell
        
        let name = isSearch ? searchItemDataSource[indexPath.row] : schools[indexPath.row]
        cell.setContent(name)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if isSearch {
            selectedSchool = searchItemDataSource[indexPath.row]
        } else {
            selectedSchool = schools[indexPath.row]
        }
        
        if from == FROM_CHANGESCHOOL {
            self.performSegueWithIdentifier("unwind2ChangeSchool", sender: self)
        } else {
            self.performSegueWithIdentifier("unwindSchool2Locaiton", sender: self)
        }
    }
}

// MARK: - @protocol UITextFieldDelegate
extension SelectSchoolViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // search group with key value
        
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: - @protocol UIScrollViewDelegate
extension SelectSchoolViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        self.searchField.resignFirstResponder()
    }
}
