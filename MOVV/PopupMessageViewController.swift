
//
//  PopupMessageViewController.swift
//  MOVV
//
//  Created by My Star on 6/8/16.
//  Copyright © 2016 Martino Mamic. All rights reserved.
//

import Foundation
protocol PopupMessageViewControllerDelegate {
    func backWindow()
}

class PopupMessageViewController: UIViewController{
    
    @IBOutlet var messageView: UIView!
    
    @IBOutlet weak var secondView: UIView!
    
    
    var delegate : PopupMessageViewControllerDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let xConstraint = NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: self.secondView, attribute: .CenterX, multiplier: 1, constant: 500)
//
//           self.secondView.addConstraint(xConstraint)
        
        
        messageView.layer.cornerRadius = 10
        secondView.layer.cornerRadius = 10
//        secondView.hidden = true
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func goSecondClick(sender: AnyObject) {
        UIView.animateWithDuration(1.0, delay: 0.0,
                                   usingSpringWithDamping: 0.25,
                                   initialSpringVelocity: 0.0,
                                   options: [],
                                   animations: {
                                    self.messageView.layer.position.x -= 500.0
//                                    self.messageView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
            }, completion: nil)
        
        UIView.animateWithDuration(1.0, delay: 0.0,
                                   usingSpringWithDamping: 0.25,
                                   initialSpringVelocity: 0.0,
                                   options: [],
                                   animations: {
                                    self.secondView.hidden = false
                                    self.secondView.layer.position.x -= 400.0
//                                    self.secondView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
            }, completion: nil)
        
    }
    
    @IBAction func onNextButtonClick(sender: AnyObject) {
        self.delegate?.backWindow()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}