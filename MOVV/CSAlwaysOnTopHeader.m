//
//  CSAlwaysOnTopHeader.m
//  CSStickyHeaderFlowLayoutDemo
//
//  Created by James Tang on 6/4/14.
//  Copyright (c) 2014 Jamz Tang. All rights reserved.
//




#import "CSAlwaysOnTopHeader.h"
#import "CSStickyHeaderFlowLayoutAttributes.h"
#import "MOVVV-Swift.h"

static CGFloat followButtonHeight = 0;
static CGFloat titleLabelHeight = 0;

@implementation CSAlwaysOnTopHeader

-(void)awakeFromNib{
    [super awakeFromNib];

    if(self.tag == 0){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeView) name:@"changeView" object:nil];
        followButtonHeight = CGRectGetHeight(self.bounds)*0.25;
        titleLabelHeight = CGRectGetHeight(self.bounds)* 0.41;
        
        self.isReviewActive = false;
        if(CGRectGetWidth(self.bounds) == 320){
            self.avatarCenterY.constant = 35;
            
        }
    
    }
    self.userPicButton.layer.borderColor = [UIColor colorWithRed:0.224 green:0.647 blue:0.208 alpha:1.0].CGColor;
    
    self.userPicButton.layer.borderWidth = 2;
    self.userPicButton.clipsToBounds = true;
    self.userInteractionEnabled = true;
}

- (void)applyLayoutAttributes:(CSStickyHeaderFlowLayoutAttributes *)layoutAttributes {
    if(self.tag == 0){
        [UIView beginAnimations:@"" context:nil];
        if(layoutAttributes.progressiveness < 0.9){
            self.username.alpha = 0;
            
            self.location.alpha = 0;
            self.lButton.alpha = 0;

            
        } else {
            self.username.alpha = 1;
            
            self.location.alpha = 1;
            self.lButton.alpha = 1;

            
        }
        CGAffineTransform scale = CGAffineTransformMakeScale(MAX(0.5, layoutAttributes.progressiveness),MAX(0.5, layoutAttributes.progressiveness));
        self.userPicButton.transform = scale;
        CGFloat buttonTrail = CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.followButton.bounds) + CGRectGetMinY(self.followButton.bounds)) -10;
        
        self.followButtonCenterX.constant = MIN(0, -(1 -layoutAttributes.progressiveness)*buttonTrail);
        self.followButtonBottomSpace.constant = MAX(followButtonHeight * layoutAttributes.progressiveness, 10);
        self.titleLabelBottom.constant = MAX(titleLabelHeight * layoutAttributes.progressiveness, 10);
        self.avatarCenterX.constant = -self.followButtonCenterX.constant;
        self.avatarCenterY.constant = MAX(CGRectGetWidth(self.userPicButton.frame) * 0.75,layoutAttributes.progressiveness*90);
        
        [UIView commitAnimations];
    }
}


-(void)didMoveToSuperview {
    if(CGRectGetWidth(self.bounds) == 320){
        self.userPicButton.layer.cornerRadius = 320 * 0.11;
    } else if(CGRectGetWidth(self.bounds) >  375){
        self.userPicButton.layer.cornerRadius = 414 * 0.11;
    } else {
        self.userPicButton.layer.cornerRadius = 414 * 0.10;
    }
    
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)changeView{
//    if(self.isReviewActive){
//        self.isReviewActive = false;
//        self.reviewsView.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
//        self.newsView.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    } else {
//        self.isReviewActive = true;
//        self.reviewsView.backgroundColor = [UIColor groupTableViewBackgroundColor];
//        self.newsView.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
//    }
}

- (void)setRatingStars:(int)rating
{
    for (int i = 0; i < rating; i++)
    {
        UIButton *button = (UIButton *)[self viewWithTag: 100 + i];
        [button setBackgroundImage:[UIImage imageNamed:@"starFilled.png"] forState:UIControlStateNormal];
    }
}
@end
