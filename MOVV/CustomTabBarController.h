//
//  MYBaseTabBarController.h
//  customTabBar
//
//  Created by Poslovanje Kvadrat on 02.07.2015..
//  Copyright (c) 2015. GaussDevelopment. All rights reserved.
//
//#import "SCRecorderViewController.h"
#import <UIKit/UIKit.h>

@protocol TabbarVisibilityDelegate <NSObject>
@optional

    -(void)showTabbar;
    -(void)hideTabbar;

@end

@interface CustomTabBarController : UITabBarController

@property (strong, nonatomic) UIButton *btn1;
@property (strong, nonatomic) UIButton *btn2;
@property (strong, nonatomic) UIButton *btn3;
@property (strong, nonatomic) UIButton *btn4;
@property (strong, nonatomic) UIButton *btn5;
@property (weak, nonatomic) UIButton *lastSender;

@property (nonatomic, weak) id <TabbarVisibilityDelegate> tabbarVisibilityDelegate;

@property BOOL insNew;
@property BOOL isNewTime;

@property (strong, nonatomic) UIImageView *indicatorView;


@end
