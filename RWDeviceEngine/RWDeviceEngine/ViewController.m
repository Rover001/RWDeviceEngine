//
//  ViewController.m
//  RWDeviceEngine
//
//  Created by 曾云 on 2020/5/28.
//  Copyright © 2020 曾云. All rights reserved.
//

#import "ViewController.h"


#import "DeviceEngine.h"



#define isCustomDeviceEngine 1

#define DeviceEngine_Portrait [DeviceEngine dealWithSeparatePortrait]
#define DeviceEngine_Landscape [DeviceEngine dealWithSeparateLandscape]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [UIApplication sharedApplication].keyWindow.rootViewController.view.safeAreaInsets
    
    NSLog(@"rootViewController:%@",[UIApplication sharedApplication].keyWindow.rootViewController);
    if (@available(iOS 11.0, *)) {
        NSLog(@"rootViewController:%f %f",[UIApplication sharedApplication].keyWindow.rootViewController.view.safeAreaInsets.bottom,DeviceEngine_Portrait.deviceSafeAreaBottomHeight);
    } else {
        // Fallback on earlier versions
    }
    
    
    NSLog(@"%f %f",[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    
    if (!isCustomDeviceEngine) {
        NSLog(@"isSimulator = %d isiPhone = %d isPad = %d ",CustomDeviceEngine.isSimulator,CustomDeviceEngine.isiPhone,CustomDeviceEngine.isiPad);
           NSLog(@"statusBarHeight=%f  navigationBarHeight = %f",[UIApplication sharedApplication].statusBarFrame.size.height,self.navigationController.navigationBar.bounds.size.height);
           NSLog(@"deviceStatusBarHeight=%f  deviceNavigationBarHeight = %f deviceSafeAreaWidth = %f deviceSafeAreaHeight =%f",CustomDeviceEngine.deviceStatusBarHeight,CustomDeviceEngine.deviceNavigationBarHeight,CustomDeviceEngine.deviceSafeAreaWidth,CustomDeviceEngine.deviceSafeAreaHeight);
           NSLog(@"iPad_FullScreen = %d",CustomDeviceEngine.iPad_FullScreen);
    } else {
        
        NSLog(@"orientationStyle :%ld",DeviceEngine_Portrait.orientationStyle);
        
        NSLog(@"isSimulator = %d isiPhone = %d isPad = %d ",DeviceEngine_Portrait.isSimulator,DeviceEngine_Portrait.isiPhone,CustomDeviceEngine.isiPad);
        NSLog(@"statusBarHeight=%f  navigationBarHeight = %f",[UIApplication sharedApplication].statusBarFrame.size.height,self.navigationController.navigationBar.bounds.size.height);
        NSLog(@"deviceStatusBarHeight=%f  deviceNavigationBarHeight = %f deviceSafeAreaWidth = %f deviceSafeAreaHeight =%f",DeviceEngine_Portrait.deviceStatusBarHeight,DeviceEngine_Portrait.deviceNavigationBarHeight,DeviceEngine_Portrait.deviceSafeAreaWidth,DeviceEngine_Portrait.deviceSafeAreaHeight);
         
        NSLog(@"iPad_FullScreen = %d",CustomDeviceEngine.iPad_FullScreen);
    }
    
//    CustomDeviceEngine.deviceAutorotateBlock = ^{
//        NSLog(@"ViewController = deviceAutorotateBlock");
//        [self orientationDidChange:nil];
//    };
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DeviceEngine_Portrait.deviceAutorotateBlock = ^{
     NSLog(@"ViewController = deviceAutorotateBlock");
        [self orientationDidChange:nil];
    };
}

- (void)orientationDidChange:(NSNotification *)notification {
   
     NSLog(@"height：%f width：%f",[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width);
    NSLog(@"======================================");
    
    NSLog(@"deviceStatusBarHeight=%f  deviceNavigationBarHeight = %f deviceSafeAreaWidth = %f deviceSafeAreaHeight =%f",CustomDeviceEngine.deviceStatusBarHeight,CustomDeviceEngine.deviceNavigationBarHeight,CustomDeviceEngine.deviceSafeAreaWidth,CustomDeviceEngine.deviceSafeAreaHeight);
    
    NSLog(@"======================================");
    NSLog(@"orientationStyle :%ld",DeviceEngine_Portrait.orientationStyle);
//    NSLog(@"statusBarHeight=%f  navigationBarHeight = %f",[UIApplication sharedApplication].statusBarFrame.size.height,self.navigationController.navigationBar.bounds.size.height);
//       NSLog(@"deviceStatusBarHeight=%f  deviceNavigationBarHeight = %f deviceSafeAreaWidth = %f deviceSafeAreaHeight =%f",DeviceEngine_Landscape.deviceStatusBarHeight,DeviceEngine_Landscape.deviceNavigationBarHeight,DeviceEngine_Landscape.deviceSafeAreaWidth,DeviceEngine_Landscape.deviceSafeAreaHeight);
    
//    if (!isCustomDeviceEngine) {
//       NSLog(@"statusBarHeight=%f  navigationBarHeight = %f",[UIApplication sharedApplication].statusBarFrame.size.height,self.navigationController.navigationBar.bounds.size.height);
//       NSLog(@"deviceStatusBarHeight=%f  deviceNavigationBarHeight = %f deviceSafeAreaWidth = %f deviceSafeAreaHeight =%f",CustomDeviceEngine.deviceStatusBarHeight,CustomDeviceEngine.deviceNavigationBarHeight,CustomDeviceEngine.deviceSafeAreaWidth,CustomDeviceEngine.deviceSafeAreaHeight);
//    } else {
//        NSLog(@"orientationStyle :%ld",DeviceEngine_Portrait.orientationStyle);
//        NSLog(@"statusBarHeight=%f  navigationBarHeight = %f",[UIApplication sharedApplication].statusBarFrame.size.height,self.navigationController.navigationBar.bounds.size.height);
//           NSLog(@"deviceStatusBarHeight=%f  deviceNavigationBarHeight = %f deviceSafeAreaWidth = %f deviceSafeAreaHeight =%f",DeviceEngine_Landscape.deviceStatusBarHeight,DeviceEngine_Landscape.deviceNavigationBarHeight,DeviceEngine_Landscape.deviceSafeAreaWidth,DeviceEngine_Landscape.deviceSafeAreaHeight);
//    }
    
    if (@available(iOS 11.0, *)) {
            ;
           NSLog(@"safeAreaInsetsBottom=%f = %f",self.view.safeAreaInsets.top,[UIApplication sharedApplication].keyWindow.rootViewController.view.safeAreaInsets.bottom);
 NSLog(@"deviceSafeAreaBottomHeight=%f",DeviceEngine_Landscape.deviceSafeAreaBottomHeight);
       }
}
@end
