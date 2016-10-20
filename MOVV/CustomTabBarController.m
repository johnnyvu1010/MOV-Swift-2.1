//
//  MYBaseTabBarController.m
//  customTabBar
//
//  Created by Poslovanje Kvadrat on 02.07.2015..
//  Copyright (c) 2015. GaussDevelopment. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "CustomTabBarController.h"
#import "MOVVV-Swift.h"

@interface CustomTabBarController () <UIAlertViewDelegate>
@property (strong, nonatomic) BluredTabbarView *tabbarView;
@property CGRect tabbarFrame;
@property NSTimer* timer;
@end

@implementation CustomTabBarController

- (id)init {
    self = [super init];
    return self;
}

// MARK: Lifecycle
-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTabbar) name:@"showTabbar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTabbar) name:@"hideTabbar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkOrientation) name:@"checkParentOrientation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playGifView) name:@"previewDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchGifPlay) name:@"searchGifPlay" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    if([MVHelper sharedInstance].cameraPresented == false ){
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        [self shouldAutorotate];
    }
    // when user installs the app for first time.
    if(self.insNew == true){
        [self onBoardingShow];
//        _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onBoardingShow) userInfo:nil repeats:NO];
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if(_tabbarView == nil){
        self.tabBar.alpha = 0.001;
        _tabbarView = [[[NSBundle mainBundle] loadNibNamed:@"BluredTabBar" owner:nil options:nil] firstObject];
        _tabbarView.frame = CGRectMake(0.0, self.view.frame.size.height - self.view.frame.size.height/11, self.view.frame.size.width, self.view.frame.size.height/11);
        _tabbarFrame = _tabbarView.frame;
        _tabbarView.tag = CGRectGetWidth(self.view.frame);
        [_tabbarView setupEdgeInsets];
        [self.view addSubview:_tabbarView];
        

        _btn1 = (UIButton *)[_tabbarView viewWithTag:1];
        [_btn1 addTarget:self action:@selector(processBtn:) forControlEvents:UIControlEventTouchUpInside];
        _btn2 = (UIButton *)[_tabbarView viewWithTag:2];
        [_btn2 addTarget:self action:@selector(processBtn:) forControlEvents:UIControlEventTouchUpInside];
        _btn3 = (UIButton *)[_tabbarView viewWithTag:3];
        [_btn3 addTarget:self action:@selector(processBtn:) forControlEvents:UIControlEventTouchUpInside];
        _btn4 = (UIButton *)[_tabbarView viewWithTag:4];
        [_btn4 addTarget:self action:@selector(processBtn:) forControlEvents:UIControlEventTouchUpInside];
        _btn5 = (UIButton *)[_tabbarView viewWithTag:5];
        [_btn5 addTarget:self action:@selector(processBtn:) forControlEvents:UIControlEventTouchUpInside];
        _lastSender = _btn1;
        [self setSelectedViewController:self.viewControllers[0]];
        
        UIVisualEffectView *blur;
        
        for (UIView *view in self.tabbarView.subviews){
            if([view isKindOfClass:[UIVisualEffectView class]]){
                blur = (UIVisualEffectView*)view;
            }
        }
        if(blur.layer.mask == nil){
            CALayer *maskLayer = [CALayer layer];
            maskLayer.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(_tabbarView.frame), CGRectGetHeight(_tabbarView.frame));
            maskLayer.contents = (__bridge id)([UIImage imageNamed:@"tabbar_mask"].CGImage);
            blur.layer.mask = maskLayer;
        } else {
            blur.layer.mask.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(_tabbarView.frame), CGRectGetHeight(_tabbarView.frame));
        }
        [self addIndicatorView];
    } else {
        _tabbarView.frame = _tabbarFrame;
    }
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: Actions
-(void)processBtn:(UIButton *)sender {
    _lastSender = sender;
    long selectedIndex = sender.tag - 1;
    UIViewController *selectedController = [self.viewControllers objectAtIndex:selectedIndex];
    
    for (int i = 1; i < 5; i++) {
        if (i != 3) {
        }
    }

    [self setSelectedViewController:selectedController];
}

-(void)setSelectedViewController:(UIViewController *)selectedViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSUInteger controllerIndex = [self.viewControllers indexOfObject:selectedViewController];
    if (controllerIndex == 3){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchGifPlay" object:self];
    }
    if (controllerIndex == 2) {

        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized) {
            // do your logic
            NSLog(@"You can use Camera!");
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted){
                if (granted) {
                    NSLog(@"You can use MicroPhone");
                    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"videoNavigationController"];
                    MVCameraViewController *viewController = [navController viewControllers].firstObject;
                    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    [self presentViewController:navController animated:true completion:nil];
                }else {
                    NSLog(@"You cannot use MicroPhone");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"MICROPHONE ACCESS DISABLED"
                                                                        message:@"Please turn on Microphone Access in Settings -> MOV -> Microphone"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:@"SETTINGS", nil];
                    [alertView show];
                }
            }];
            
        } else if(authStatus == AVAuthorizationStatusDenied){
            // denied
            NSLog(@"The camera Access was denied!");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CAMERA ACCESS DISABLED"
                                                                message:@"Please turn on Camera Access in Settings -> MOV -> Camera"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:@"SETTINGS", nil];
            [alertView show];
            
        } else if(authStatus == AVAuthorizationStatusRestricted){
            // restricted, normally won't happen
            NSLog(@"The camera Access restricted.");
        } else if(authStatus == AVAuthorizationStatusNotDetermined){
            // not determined?!
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    NSLog(@"Granted access to %@", AVMediaTypeVideo);
                } else {
                    NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                }
            }];
        } else {
            // impossible, unknown authorization status
            NSLog(@"The camera Access impossible.");
        }
        
    } else {
        if (self.selectedViewController != selectedViewController) {
            UINavigationController *navigationController = ((UINavigationController *)selectedViewController);
            if (navigationController.viewControllers.count == 1) {
                navigationController.topViewController.view.userInteractionEnabled = NO;
            }
            self.selectedIndex = controllerIndex;
            [super setSelectedViewController:selectedViewController];
        }
    }
}

// MARK: Layout
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void) playGifView{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self onPlayGif];
    });
}
-(void) onPlayGif{
    [self.timer invalidate];
    self.timer = nil;
    self.isNewTime = true;

    if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PreviewGifViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"previewGif"];
        controller.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:controller animated:YES completion:nil];        
    }

}



// MARK: Screen orientation
-(BOOL) shouldAutorotate {
//    if([MVHelper sharedInstance].cameraPresented){
//        if([MVHelper sharedInstance].cameraRecording){
//            return false;
//        } else {
//            return true;
//        }
    /*} else */
    return [MVHelper sharedInstance].shouldAutorotate;
//    if ([self.presentedViewController isKindOfClass:[UINavigationController class]]) {
//        if ([((UINavigationController *)self.presentedViewController).viewControllers.lastObject isKindOfClass:[ItemDetailViewController class]] || [((UINavigationController *)self.presentedViewController).viewControllers.firstObject isKindOfClass:[MVCameraViewController class]]) {
//            return YES;
//        }
//    }
//    
//    if ([[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait) {
//        return true;
//    } else {
//        return false;
//    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    _tabbarView.frame = _tabbarFrame;
//    if([MVHelper sharedInstance].cameraPresented) {
//        return UIInterfaceOrientationMaskAllButUpsideDown;
/*    } else*/
    if ([MVHelper sharedInstance].shouldAutorotate) {
//        if ([((UINavigationController *)self.presentedViewController).viewControllers.lastObject isKindOfClass:[ItemDetailViewController class]] || [((UINavigationController *)self.presentedViewController).viewControllers.firstObject isKindOfClass:[MVCameraViewController class]]) {
            return UIInterfaceOrientationMaskAllButUpsideDown;
//        }
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

-(void)checkOrientation {
//    if([MVHelper sharedInstance].cameraPresented == false ){
//        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
//        [self shouldAutorotate];
//    }
}

// MARK: Uncategorized
-(void)moveIndicatorView:(CGFloat)indicatorIndex{
    [UIView animateWithDuration:0.3 animations:^{
        _indicatorView.frame = CGRectMake(indicatorIndex * CGRectGetWidth(self.view.frame)/5,_indicatorView.frame.origin.y,CGRectGetWidth(self.view.frame)/5, CGRectGetHeight(self.tabbarView.frame) );
    }];
}

-(void)addIndicatorView {
    
//    int indicatorOffset = 0;
//    if([[UIApplication sharedApplication] keyWindow].frame.size.width > 375){
//        indicatorOffset = 9;
//    } else {
//        indicatorOffset = 8;
//    }
//    _indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0,(CGRectGetHeight(self.view.frame) - self.view.frame.size.height/11) + indicatorOffset, CGRectGetWidth(self.view.frame)/5, self.view.frame.size.height/11)];
//    _indicatorView.backgroundColor = [UIColor colorWithRed:0.224 green:0.647 blue:0.208 alpha:1.0];
//    _indicatorView.alpha = 0.5;
//    [self.view addSubview:_indicatorView];
}

-(void)showTabbar {
    [self.tabBar setHidden:false];
    [self.tabbarView setHidden:false];
    [self.indicatorView setHidden:false];
}

-(void)hideTabbar{
    [self.tabBar setHidden:true];
    [self.tabbarView setHidden:true];
    [self.indicatorView setHidden:true];
}
-(void)onBoardingShow{
//    [_timer invalidate];
//    _timer = nil;
    self.insNew = false;
    self.isNewTime = true;
}

-(void)searchGifPlay{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        searchGifPlayViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"searchGifID"];
        
        controller.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

//MARK: AlertView Delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( 0 == buttonIndex ){ //cancel button
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    } else if ( 1 == buttonIndex ){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
