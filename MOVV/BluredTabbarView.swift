//
//  BluredTabbarView.swift
//  MOVV
//
//  Created by Martino Mamic on 07/07/15.
//  Copyright (c) 2015 Martino Mamic. All rights reserved.
//

import UIKit

class BluredTabbarView: UIView {

    
    @IBOutlet var homeButton: UIButton!
    
    @IBOutlet var searchButton: UIButton!
    
    @IBOutlet var cameraButton: UIButton!
    
    @IBOutlet var newsButton: UIButton!
    
    @IBOutlet var profileButton: UIButton!
    
    var selectedIndex = 0
    
    override func awakeFromNib() {
        
    }
    
    func defaultButton() {
        homeButton.setImage(UIImage (named: "homeButton"), forState: .Normal);
        newsButton.setImage(UIImage (named: "searchBarButton"), forState: .Normal);
        searchButton.setImage(UIImage (named: "newsButton"), forState: .Normal);
        profileButton.setImage(UIImage (named: "profileButton"), forState: .Normal);
    }
    
    @IBAction func onHomeButton(sender: AnyObject) {
        self.defaultButton()
        homeButton.setImage(UIImage (named: "homeButtonSelected"), forState: .Normal);
    }
    
    @IBAction func onNewsButton(sender: AnyObject) {
        self.defaultButton()
        newsButton.setImage(UIImage (named: "searchBarButtonSelected"), forState: .Normal);
    }
    
    @IBAction func onSearchBarButton(sender: AnyObject) {
        self.defaultButton()
        searchButton.setImage(UIImage (named: "newsButtonSelected"), forState: .Normal);
    }
    
    @IBAction func onProfileButton(sender: AnyObject) {
        self.defaultButton()
        profileButton.setImage(UIImage (named: "profileButtonSelected"), forState: .Normal);
    }
    
    func setupEdgeInsets(){
        if(self.tag > 375){
            self.cameraButton.imageEdgeInsets = UIEdgeInsetsMake(1, 13, 5, 13)
            self.searchButton.imageEdgeInsets = UIEdgeInsetsMake(searchButton.imageEdgeInsets.top, searchButton.imageEdgeInsets.left + 1, searchButton.imageEdgeInsets.bottom, searchButton.imageEdgeInsets.right + 1)
            self.profileButton.imageEdgeInsets = UIEdgeInsetsMake(profileButton.imageEdgeInsets.top - 2 , profileButton.imageEdgeInsets.left, profileButton.imageEdgeInsets.bottom - 4, profileButton.imageEdgeInsets.right)
            self.newsButton.imageEdgeInsets = UIEdgeInsetsMake(newsButton.imageEdgeInsets.top+3 , newsButton.imageEdgeInsets.left, newsButton.imageEdgeInsets.bottom - 4, newsButton.imageEdgeInsets.right+2)
            self.homeButton.imageEdgeInsets = UIEdgeInsetsMake(homeButton.imageEdgeInsets.top , homeButton.imageEdgeInsets.left-2, homeButton.imageEdgeInsets.bottom - 4, homeButton.imageEdgeInsets.right-2)
        } else if (self.tag == 375){
            self.cameraButton.imageEdgeInsets = UIEdgeInsetsMake(1, 12, 5, 12)
            self.searchButton.imageEdgeInsets = UIEdgeInsetsMake(searchButton.imageEdgeInsets.top, searchButton.imageEdgeInsets.left + 1, searchButton.imageEdgeInsets.bottom  - 4, searchButton.imageEdgeInsets.right + 1)
            self.profileButton.imageEdgeInsets = UIEdgeInsetsMake(profileButton.imageEdgeInsets.top - 2 , profileButton.imageEdgeInsets.left, profileButton.imageEdgeInsets.bottom - 4, profileButton.imageEdgeInsets.right)
            self.newsButton.imageEdgeInsets = UIEdgeInsetsMake(newsButton.imageEdgeInsets.top+3 , newsButton.imageEdgeInsets.left, newsButton.imageEdgeInsets.bottom - 4, newsButton.imageEdgeInsets.right+2)
            self.homeButton.imageEdgeInsets = UIEdgeInsetsMake(homeButton.imageEdgeInsets.top , homeButton.imageEdgeInsets.left-2, homeButton.imageEdgeInsets.bottom - 4, homeButton.imageEdgeInsets.right-2)
        } else {
            self.searchButton.imageEdgeInsets = UIEdgeInsetsMake(searchButton.imageEdgeInsets.top, searchButton.imageEdgeInsets.left - 1, searchButton.imageEdgeInsets.bottom  - 4, searchButton.imageEdgeInsets.right - 1)
            self.profileButton.imageEdgeInsets = UIEdgeInsetsMake(profileButton.imageEdgeInsets.top - 2 , profileButton.imageEdgeInsets.left - 1, profileButton.imageEdgeInsets.bottom - 4, profileButton.imageEdgeInsets.right - 1)
            self.newsButton.imageEdgeInsets = UIEdgeInsetsMake(newsButton.imageEdgeInsets.top+3 , newsButton.imageEdgeInsets.left, newsButton.imageEdgeInsets.bottom - 4, newsButton.imageEdgeInsets.right+2)
            self.homeButton.imageEdgeInsets = UIEdgeInsetsMake(homeButton.imageEdgeInsets.top , homeButton.imageEdgeInsets.left-2, homeButton.imageEdgeInsets.bottom - 4, homeButton.imageEdgeInsets.right-2)
        }

    }
}
