//  TagsViewController.swift
//
//  MOVV
//
//  Created by Martino Mamic on 08/05/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

protocol TagsViewControllerDelegate {
    func addedTag(tagsArray : Array<String>)
}


class TagsViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var delegate:TagsViewControllerDelegate? = nil
    var viewAppeared : Bool = false
    var tags = Array<String>()
    
    var selectedTags = Array<String>()
    @IBOutlet var viewRecentTags: UIView!
    @IBOutlet var buttonBack: UIButton!
    @IBOutlet var textFieldTags: UITextField!
    @IBOutlet var tagsTable: UITableView!
    var newTag:String?
    var addedNewTag = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        viewAppeared = false
        buttonBack.imageView?.contentMode = UIViewContentMode.ScaleAspectFit;
        textFieldTags.text = "#"
        textFieldTags.becomeFirstResponder()
        textFieldTags.addDoneOnKeyboardWithTarget(self, action: #selector(TagsViewController.doneButtonTapped))
        tags = self.getRecentTags()
        viewRecentTags.hidden = tags.count == 0
        if selectedTags.count > 0{
            textFieldTags.text = selectedTags.joinWithSeparator(" ")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        viewAppeared = true
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    
    
    // MARK: <UITableViewDataSource>
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier("RecentTagsTableViewCell", forIndexPath: indexPath) as! RecentTagsTableViewCell
        cell.labelTags.text = tags[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! RecentTagsTableViewCell
        let prevString = textFieldTags.text?.substringWithRange((textFieldTags.text!.endIndex.advancedBy(-1) ..< textFieldTags.text!.endIndex));
        if prevString == "#" {
            textFieldTags.text?.appendContentsOf(cell.labelTags.text!.substringFromIndex(cell.labelTags.text!.startIndex.advancedBy(1)))
        }else{
            textFieldTags.text?.appendContentsOf((prevString == " ") ? cell.labelTags.text! : (" " + cell.labelTags.text!))
        }
    }
    
    //MARK: - Controls Actions
    @IBAction func onBackButton(sender: AnyObject) {
        self.popToPrevious()
    }
    
    func doneButtonTapped(){
        self.popToPrevious()
    }
    
    func popToPrevious(){
        self.saveRecentTags(self.getTagsList(textFieldTags.text!))
        let tagsUsed = textFieldTags.text!.componentsSeparatedByString(" ")
        let tagsUnion:NSArray = NSMutableSet.init(array: tagsUsed).allObjects
        self.selectedTags.removeAll()
        tagsUnion.enumerateObjectsUsingBlock { (obj, idx, stop) in
            self.selectedTags.append(obj as! String)
        }
        var finalTagList = Array<String>()
        tagsUnion.enumerateObjectsUsingBlock { (obj, idx, stop) in
            if (obj as! String != "#" && obj as! String != ""  && obj as! String != " " && idx < 10){
                finalTagList.append(obj as! String)
            }
        }
        self.delegate?.addedTag(finalTagList)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0{
            return false
        }
        if string == "" {
            let prevString = textField.text?.substringWithRange((textField.text!.endIndex.advancedBy(-1) ..< textField.text!.endIndex));
            if prevString == "#" {
                textField.text = textField.text?.substringWithRange((textField.text!.startIndex ..< textField.text!.endIndex.advancedBy(-2)));
                return false;
            }
        }
        if string == " " {
            let prevString = textField.text?.substringWithRange((textField.text!.endIndex.advancedBy(-1) ..< textField.text!.endIndex));
            if prevString  == "#" {
                return false;
            }
            textField.text!.appendContentsOf(" #")
            return false;
        }
        return true;
    }
    
    //MARK: - Recent Tags
    
    func getTagsList(tags:String) -> Array<String> {
        let tagsUsed = textFieldTags.text!.componentsSeparatedByString(" ")
        let tagsStored = self.getRecentTags()
        let meargedTags = NSMutableArray()
        meargedTags.addObjectsFromArray(tagsUsed)
        meargedTags.addObjectsFromArray(tagsStored)
        let meargedUnionTags = NSMutableSet.init(array: meargedTags as [AnyObject])
        meargedTags.removeAllObjects()
        meargedTags.addObjectsFromArray(meargedUnionTags.allObjects)
        var tagsUsedList = Array<String>()
        meargedTags.enumerateObjectsUsingBlock { (obj, idx, stop) in
            if (obj as! String != "#" && obj as! String != ""  && obj as! String != " " && idx < 10){
                tagsUsedList.append(obj as! String)
            }
        }
        return tagsUsedList
    }
    
    func saveRecentTags(tags:Array<String>) -> Array<String> {
        NSUserDefaults.standardUserDefaults().setValue(tags, forKey: "RecentTags")
        return tags
    }
    
    func getRecentTags() -> Array<String> {
        let recentTags = NSUserDefaults.standardUserDefaults().valueForKey("RecentTags") as? Array<String>
        return recentTags == nil ? Array<String>() : recentTags!
    }
    
}
