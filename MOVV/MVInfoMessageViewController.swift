//
//  MVInfoMessageViewController.swift
//  MOVV
//
//  Created by Ivan Barisic on 28/08/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

protocol MVInfoMessageViewControllerDelegate {
    func onTouchOKButton()
}

class MVInfoMessageViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var actionDescriptionLabel: UILabel!
    @IBOutlet weak var actionTitleLabel: UILabel!
    @IBOutlet var descriptionLabel: UITextView!
    
    // MARK: Variables
    var messageStatus:MVCameraType!
    var delegate: MVInfoMessageViewControllerDelegate? = nil
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if (self.messageStatus == MVCameraType.Video) {
            self.actionTitleLabel.text = "Record the video"
            self.actionDescriptionLabel.text = "Step 1/2"
            self.descriptionLabel.text = "Lorem ipsum dolor sit amet adipiscing consectetur sit elit."
        } else if (self.messageStatus == MVCameraType.FirstStep) {
            self.actionTitleLabel.text = "Video required!"
            self.actionDescriptionLabel.text = "This is the 1st Step"
        } else if (self.messageStatus == MVCameraType.SecondStep) {
            self.actionTitleLabel.text = "Take preview image!"
            self.actionDescriptionLabel.text = "Step 3/3"
        }

        
    }
    
 
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func onTouchOkButton(sender: AnyObject) {
        if self.delegate != nil {
            self.delegate?.onTouchOKButton()
        } else {
            print("Error delegate MVInfoMessageViewControllerDelegate method onTouchOKButton not initialized")
        }
    }
}
