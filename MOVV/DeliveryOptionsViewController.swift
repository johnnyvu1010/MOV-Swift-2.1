//
//  DeliveryOptionsViewController.swift
//  MOVV
//
//  Created by Vineet Choudhary on 01/07/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import UIKit

protocol DeliveryOptionDelegate {
    func selectedOption(option:String)
}

class DeliveryOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate:DeliveryOptionDelegate!
    var selectedOption:NSString!
    @IBOutlet var tableViewDeliveryOption: UITableView!
    @IBOutlet var buttonBack: UIButton!
    @IBOutlet var viewError: UIView!
    
    var titleList = ["0 - 0.5 lbs",
                     "0 - 3 lbs",
                     "3 - 10 lbs",
                     "10 - 20 lbs",
                     "",
                     "> 70 lbs"]
    var subtitleList = ["Accessories, hats & beauty products",
                        "Purses, shoes, clothing & small electronics",
                        "Coats, bags, boots & game consoles",
                        "Musical instruments & large electronics",
                        "",
                        "Meet in person, too large to ship"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDelegate+Datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DeliveryOptionTableViewCell", forIndexPath: indexPath) as! DeliveryOptionTableViewCell
        cell.labelTitle.text = titleList[indexPath.row]
        cell.labelSubtitle.text = subtitleList[indexPath.row]
        cell.imageViewCheck.hidden = !(cell.labelTitle.text == selectedOption && cell.labelTitle.text?.length > 0)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if titleList[indexPath.row].length > 0{
            self.showErrorAlert(indexPath.row == titleList.count-1)
            selectedOption = titleList[indexPath.row]
            tableViewDeliveryOption.reloadData()
            self.buttonBackTapped(self.buttonBack)
        }
    }
    
    //MARK: Controls Actions
    @IBAction func buttonBackTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
        self.delegate.selectedOption(selectedOption as String)
    }
    
    func showErrorAlert(show:Bool) {
        if show && viewError.hidden {
            viewError.alpha = 0;
            viewError.hidden = false
            UIView.animateWithDuration(0.5) {
                self.viewError.alpha = 1
            }
        }else if !show && !viewError.hidden{
            UIView.animateWithDuration(0.5, animations: {
                self.viewError.alpha = 0
                }, completion: { (complete) in
                    if complete{
                        self.viewError.hidden = true
                    }
            })
        }
    }
}
