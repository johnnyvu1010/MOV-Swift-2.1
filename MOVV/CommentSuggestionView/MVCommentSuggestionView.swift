//
//  MVCommentSuggestionView.swift
//  MOVV
//
//  Created by Raushan Kumar on 26/08/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

protocol MVCommentSuggestionViewDelegate : NSObjectProtocol{
    func userSelected(user: MVUser)
}

class MVCommentSuggestionView: UIView,UITableViewDelegate
{

    @IBOutlet var commentTableView : UITableView!
    @IBOutlet var tableHeightConstraint : NSLayoutConstraint!
    var userArr = NSMutableArray()
    var currentSearchStr : String!
    var item : MVProduct!
    weak var delegate : MVCommentSuggestionViewDelegate!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        commentTableView.separatorStyle = .None
        self.hidden = true
        setUpView()
    }
    
    func setUpView() {
        commentTableView.registerNib(UINib(nibName: "MVCommentSuggestionCell", bundle: nil), forCellReuseIdentifier: "MVCommentSuggestionCell")
    }
    
    func showTableWithUserNamePrefix(namePrefix :  String!)
    {
        userArr.removeAllObjects()
        currentSearchStr = ""
        if namePrefix.characters.count == 0 || !namePrefix.containsString("@") || namePrefix.indexOfCharacter("@") != 0
        {
            self.hidden = true
        }
        else
        {
            currentSearchStr = namePrefix
            currentSearchStr.removeAtIndex(namePrefix.startIndex)
            self.hidden = false
            getUsers()
            
        }
        tableHeightConstraint.constant = (CGFloat(userArr.count * 50) > 200) ? 200 : CGFloat(userArr.count * 50)
        commentTableView.reloadData()
    }
    //MARK: Table View Delegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCellWithIdentifier("MVCommentSuggestionCell") as? MVCommentSuggestionCell
        {
            if let user = userArr.objectAtIndex(indexPath.row) as? MVUser
            {
                cell.fillDetailsWithUser(user)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let user = userArr.objectAtIndex(indexPath.row) as? MVUser
        {
             delegate.userSelected(user)
        }
       
    }
    
    
    func getUsers()
    {
        let parameters :  NSDictionary! = ["user_id":"\(MVParameters.sharedInstance.currentMVUser.id)" ,"product_id":"\(item.id)","q":"\(currentSearchStr)" ]
        MVSyncManager.getDataFromServerUsingGET(parameters, request: "suggest-users/", successBlock: { response in
            if let responseObj = response as? [String:AnyObject]
            {
                if let arr = responseObj["users"] as? [NSDictionary]
                {
                    self.userArr.removeAllObjects()
                    for dict in arr{
                        self.userArr.addObject(MVUser(dictionary: dict))
                    }
                    self.tableHeightConstraint.constant = (CGFloat(self.userArr.count * 50) > self.frame.size.height) ? self.frame.size.height : CGFloat(self.userArr.count * 50)
                    self.commentTableView.reloadData()
                    
                }
            }
            
        }) { failure in
            print(failure)
        }
    }

}
