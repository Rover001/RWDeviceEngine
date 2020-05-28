//
//  main.m
//  RWDeviceEngine
//
//  Created by 曾云 on 2020/5/28.
//  Copyright © 2020 曾云. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DeviceEngine.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        [DeviceEngine defaultCustomDeviceOrientationStyle:DeviceEngineOrientationStyle_Portrait];
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
