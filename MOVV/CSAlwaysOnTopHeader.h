//
//  CSAlwaysOnTopHeader.h
//  CSStickyHeaderFlowLayoutDemo
//
//  Created by James Tang on 6/4/14.
//  Copyright (c) 2014 Jamz Tang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CSAlwaysOnTopHeader : UICollectionReusableView

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *followButtonCenterX;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *followButtonCenterY;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *followButtonBottomSpace;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelBottom;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *avatarCenterXAlignment;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *location;
@property (strong, nonatomic) IBOutlet UIButton *lButton;
@property (strong, nonatomic) IBOutlet UIView *starsView;
@property (strong, nonatomic) IBOutlet UIButton *userPicButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *avatarLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *followButtonTrailingConstraint;
@property (strong, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *avatarCenterY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *avatarCenterX;

@property (strong, nonatomic) IBOutlet UIView *newsView;
@property (strong, nonatomic) IBOutlet UIView *itemsView;
@property (strong, nonatomic) IBOutlet UIView *reviewsView;
@property (strong, nonatomic) IBOutlet UIView *followersView;
@property (strong, nonatomic) IBOutlet UILabel *numberOfFollowers;
@property (strong, nonatomic) IBOutlet UILabel *numberOfReviews;
@property (strong, nonatomic) IBOutlet UILabel *numberOfSelling;

@property (strong, nonatomic) IBOutlet UIButton *starButton1;
@property (strong, nonatomic) IBOutlet UIButton *starButton2;
@property (strong, nonatomic) IBOutlet UIButton *starButton3;
@property (strong, nonatomic) IBOutlet UIButton *starButton4;
@property (strong, nonatomic) IBOutlet UIButton *starButton5;
@property (strong, nonatomic) IBOutlet UIImageView *coverImage;



//@property (weak, nonatomic) IBOutlet UIButton *editAction;
@property (weak, nonatomic) IBOutlet UIButton *editButtonAction;
@property BOOL isReviewActive;

- (void)setRatingStars:(int)rating;

@end
