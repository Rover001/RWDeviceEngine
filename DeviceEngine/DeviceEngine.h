//
//  DeviceEngine.h
//  RWDeviceEngine
//
//  Created by 曾云 on 2020/5/28.
//  Copyright © 2020 曾云. All rights reserved.
//

#import <UIKit/UIKit.h>



#define CustomDeviceEngine [DeviceEngine defaultCustomDevice]

NS_ASSUME_NONNULL_BEGIN


/*  软件主要定向样式
 默认是竖屏  导航栏 状态栏 、、、都会竖屏样式返回值
 */
typedef NS_ENUM(NSInteger,DeviceEngineOrientationStyle) {
    DeviceEngineOrientationStyle_Portrait = 0,  /**< 🐱 竖屏  默认 */
    DeviceEngineOrientationStyle_Landscape = 1, /**< 🐱 横屏 */
    DeviceEngineOrientationStyle_Auto = 2       /**< 🐱  横竖屏自动切换 */
};

/* 🐱

 DeviceEngine OtherType中的值都是根据系统的手机来计算的
 
 比如：iPhone11ProMax 在横屏下 系统导航栏是32.0f； 如果你的导航栏需求不是32.0f；这样的话就不能满足需求，怎么办？

 */

@interface DeviceEngine : NSObject
#pragma mark - 设置App定向样式
/* 🐱
IOS_13以下 在  '- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions' 方法中 设定App定向样式
 
IOS_13以上 '- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0))' 方法中 设定App定向样式

 设置App定向样式：
 1.[DeviceEngine defaultCustomDevice];
 2.[DeviceEngine defaultCustomDeviceOrientationStyle:DeviceEngineOrientationStyle];

 */

/// 默认为 CustomDeviceOrientationStyle_Portrait
+ (DeviceEngine *)defaultCustomDevice;

/// @param orientationStyle 软件主要定向样式
+ (DeviceEngine *)defaultCustomDeviceOrientationStyle:(DeviceEngineOrientationStyle)orientationStyle;


@property (nonatomic,readonly) DeviceEngineOrientationStyle orientationStyle;/* 定向样式 */

#pragma mark - 特殊需求
/* 🐱 特殊需求 OtherType中返回值都是根据系统计算的
 比如：
 1.整个工程大多数页面都是竖屏的，但是里面会存在一个或者几个页面需要横屏处理，怎么办？
 2.整个工程大多数页面都是横屏的，但是里面会存在一个或者几个页面需要竖屏处理，怎么办？
 
 请使用一下两个方法：  获取其他类型属性的值
 竖屏：+ (CustomDevice *)dealWithSeparatePortrait;
 横屏：+ (CustomDevice *)dealWithSeparateLandscape;
 
 */

/* 🐱 单独处理竖屏 */
+ (DeviceEngine *)dealWithSeparatePortrait;

/* 🐱 单独处理横屏  */
+ (DeviceEngine *)dealWithSeparateLandscape;



/**<🐱 屏幕旋转回调 在viewWillAppear里面使用 */
@property (nonatomic,strong)void(^deviceAutorotateBlock)(void);


#pragma mark - DeviceType  设备分类
- (BOOL)isSimulator;/*🐱 是否是模拟器 */
- (BOOL)isiPad;/*🐱 是否是iPad */
- (BOOL)isiPhone;/*🐱 是否是手机 */
- (BOOL)isiPodTouch;/*🐱 是否是iPodTouch */
- (BOOL)isAppleTV;/*🐱 是否是电视TV */
- (BOOL)isCarolay;
#pragma mark - 用于真机判断

#pragma mark -- iPhoneAll iphone类型
- (BOOL)iPhone;
- (BOOL)iPhone3G;
- (BOOL)iPhone3GS;
- (BOOL)iPhone4;
- (BOOL)iPhone4S;
- (BOOL)iPhone5;
- (BOOL)iPhone5C;
- (BOOL)iPhone5S;
- (BOOL)iPhoneSE;
- (BOOL)iPhoneSE2;
- (BOOL)iPhone6;
- (BOOL)iPhone6Plus;
- (BOOL)iPhone6S;
- (BOOL)iPhone6SPlus;
- (BOOL)iPhone7;
- (BOOL)iPhone7Plus;
- (BOOL)iPhone8;
- (BOOL)iPhone8Plus;
- (BOOL)iPhoneX;
- (BOOL)iPhoneXR;
- (BOOL)iPhoneXS;
- (BOOL)iPhoneXSMAX;
- (BOOL)iPhone11;
- (BOOL)iPhone11Pro;
- (BOOL)iPhone11ProMax;
- (BOOL)iPhone12Mini;/* 🐱 5.4_360*780(1080*2688)_@3x_202010 */
- (BOOL)iPhone12;/* 🐱 6.1_390*844(1170*2532)_@3x_202010 */
- (BOOL)iPhone12Pro;/* 🐱 6.1_390*844(1170*2532)_@3x_202010 */
- (BOOL)iPhone12ProMax;/* 🐱 6.7_428*926(1284*2778)_@3x_202010 */
 

#pragma mark -- iPodTouchAll touch类型
- (BOOL)iPodTouch;
- (BOOL)iPodTouch2;
- (BOOL)iPodTouch3;
- (BOOL)iPodTouch4;
- (BOOL)iPodTouch5;
- (BOOL)iPodTouch6;
- (BOOL)iPodTouch7;

#pragma mark -- iPadAll ipad类型
- (BOOL)iPad;
- (BOOL)iPad2;
- (BOOL)iPad3;
- (BOOL)iPad4;
- (BOOL)iPad5;
- (BOOL)iPad6;
- (BOOL)iPad7;
- (BOOL)iPad8;
- (BOOL)iPadAir;
- (BOOL)iPadAir2;
- (BOOL)iPadAir3;
- (BOOL)iPadAir4;
- (BOOL)iPadPro129;
- (BOOL)iPadPro129_2;
- (BOOL)iPadPro129_3;
- (BOOL)iPadPro129_4;
- (BOOL)iPadPro97;
- (BOOL)iPadPro105;
- (BOOL)iPadPro11;
- (BOOL)iPadPro11_2;
- (BOOL)iPadMini;
- (BOOL)iPadMini2;
- (BOOL)iPadMini3;
- (BOOL)iPadMini4;
- (BOOL)iPadMini5;


#pragma mark - 真机 模拟器都可以使用

#pragma mark -- SizeType 开发尺寸分类

/**<🐱
 iPhone_320_480 开发尺寸,包含设备类型 （iphone类型）
 - (BOOL)iPhone;
 - (BOOL)iPhone3G;
 - (BOOL)iPhone3GS;
 - (BOOL)iPhone4;
 - (BOOL)iPhone4S;
 - (BOOL)iPodTouch;
 - (BOOL)iPodTouch2;
 - (BOOL)iPodTouch3;
 - (BOOL)iPodTouch4;
 
 统一名称：- (BOOL)isiPhone4s;
 
 */
- (BOOL)iPhone_320_480;

/**<🐱
 iPhone_320_568 开发尺寸,包含设备类型 （iphone类型）
 - (BOOL)iPhone5;
 - (BOOL)iPhone5C;
 - (BOOL)iPhone5S;
 - (BOOL)iPhoneSE;
 - (BOOL)iPodTouch5;
 - (BOOL)iPodTouch6;
 - (BOOL)iPodTouch7;
 
  统一名称：- (BOOL)isiPhone5;
 */

- (BOOL)iPhone_320_568;

/**<🐱
 iPhone_375_667 开发尺寸,包含设备类型 （iphone类型）
 - (BOOL)iPhone6;
 - (BOOL)iPhone6S;
 - (BOOL)iPhone7;
 - (BOOL)iPhone8;
 - (BOOL)iPhoneSE2;
 
  统一名称：- (BOOL)isiPhone6;
 */

- (BOOL)iPhone_375_667;

/**<🐱
 iPhone_414_736 开发尺寸,包含设备类型 （iphone类型）
 - (BOOL)iPhone6Plus;
 - (BOOL)iPhone6SPlus;
 - (BOOL)iPhone7Plus;
 - (BOOL)iPhone8Plus;
 
  统一名称：- (BOOL)isiPhonePlus;
 */

- (BOOL)iPhone_414_736;

/**<🐱
 iPhone_375_812 开发尺寸,包含设备类型 （iphone类型）
 - (BOOL)iPhoneX;
 - (BOOL)iPhoneXS;
 - (BOOL)iPhone11Pro;
 
  统一名称：- (BOOL)isiPhoneX;
 */

- (BOOL)iPhone_375_812;

/**<🐱
 iPhone_414_896 开发尺寸,包含设备类型 （iphone类型）
 - (BOOL)iPhoneXR;
 - (BOOL)iPhoneXSMAX;
 - (BOOL)iPhone11;
 - (BOOL)iPhone11ProMax;
 
  统一名称：- (BOOL)isiPhoneXPlus;
 */
- (BOOL)iPhone_414_896;


/**<🐱
iPhone_360_780 开发尺寸,包含设备类型 （iphone类型）
- (BOOL)iPhone12Mini;
 统一名称：- (BOOL)isiPhone12Mini;
*/
- (BOOL)iPhone_360_780;

/**<🐱
iPhone_360_780 开发尺寸,包含设备类型 （iphone类型）
- (BOOL)iPhone12;
- (BOOL)iPhone12Pro;
 统一名称：- (BOOL)isiPhone12Pro;
*/
- (BOOL)iPhone_390_884;

/**<🐱
iPhone_428_926 开发尺寸,包含设备类型 （iphone类型）
- (BOOL)iPhone12ProMax;
 统一名称：- (BOOL)isiPhone12ProMax;
*/
- (BOOL)iPhone_428_926;


- (BOOL)isiPhone4s;
- (BOOL)isiPhone5;
- (BOOL)isiPhone6;
- (BOOL)isiPhonePlus;
- (BOOL)isiPhoneX DEPRECATED_MSG_ATTRIBUTE("Please use isiPhoneFullScreen");
- (BOOL)isiPhoneXPlus DEPRECATED_MSG_ATTRIBUTE("Please use isiPhoneFullScreenPlus");
- (BOOL)isiPhoneFullScreen;
- (BOOL)isiPhoneFullScreenPlus;
- (BOOL)isiPhone12Mini;
- (BOOL)isiPhone12Pro;
- (BOOL)isiPhone12ProMax;

- (BOOL)iPhone_FullScreen;/*🐱 手机是否是全面屏 isiPhoneFullScreen isiPhoneFullScreenPlus */
- (BOOL)iPhone_Plus;/*🐱 手机是否是Plus机型 isiPhonePlus  isiPhoneFullScreenPlus */

/**<🐱
 ipad_768_1024 开发尺寸,包含设备类型 （ipad类型）
 - (BOOL)iPad;
 - (BOOL)iPad2;
 - (BOOL)iPad3;
 - (BOOL)iPad4;
 - (BOOL)iPad5;
 - (BOOL)iPad6;
 - (BOOL)iPadAir;
 - (BOOL)iPadAir2;
 - (BOOL)iPadPro97;
 - (BOOL)iPadMini;
 - (BOOL)iPadMini2;
 - (BOOL)iPadMini3;
 - (BOOL)iPadMini4;
 - (BOOL)iPadMini5;
 
 统一名称：- (BOOL)isiPadMini;
 */
- (BOOL)ipad_768_1024;

/**<🐱
 ipad_834_1112 开发尺寸,包含设备类型 （ipad类型）
 - (BOOL)iPadAir3;
 - (BOOL)iPadPro105;
 
 统一名称：- (BOOL)isiPadPro105;
 */
- (BOOL)ipad_834_1112;

/**<🐱
 ipad_834_1194 开发尺寸,包含设备类型 （ipad类型）
 - (BOOL)iPadPro11;
 - (BOOL)iPadPro11_2;
 
 统一名称：- (BOOL)isiPadPro11;
 */
- (BOOL)ipad_834_1194;

/**<🐱
 ipad_820_1180 开发尺寸,包含设备类型 （ipad类型）
 - (BOOL)iPadAir4;

 */
- (BOOL)ipad_820_1180;

/**<🐱
 ipad_1024_1136 开发尺寸,包含设备类型 （ipad类型）
 - (BOOL)iPadPro129;
 - (BOOL)iPadPro129_2;
 - (BOOL)iPadPro129_3;
 - (BOOL)iPadPro129_4;
 
 统一名称：- (BOOL)isiPadPro129;
 */
- (BOOL)ipad_1024_1136;


- (BOOL)isiPadMini;
- (BOOL)isiPadPro105;
- (BOOL)isiPadPro11;
- (BOOL)isiPadPro129;

/**<🐱
 ipad是否是全面屏
 iPadAir4
 isiPadPro11
 iPadPro129_3
 iPadPro129_4
 
 统一名称：- (BOOL)iPad_FullScreen;
 */
- (BOOL)iPad_FullScreen;

#pragma mark -- PixelType 开发像素分类
#pragma mark - OtherType  其他类型 比如 导航栏高度。。。

- (UIDeviceOrientation)deviceOrientation;/**<🐱 设备硬件旋转方向 */
- (BOOL)deviceIsPortrait;/**< 🐱 设备是否是竖屏 */
- (BOOL)deviceIsLandscape;/**< 🐱 设备是否是横屏 */
- (UIInterfaceOrientation)interfaceOrientation;/**<🐱 程序界面的当前旋转方向 */
- (BOOL)interfaceIsPortrait;/**<🐱 程序是否是竖屏 */
- (BOOL)interfaceIsLandscape;/**<🐱 程序是否是横屏 */


- (CGFloat)deviceHeight;/**<🐱 设备高度 */
- (CGFloat)deviceWidth;/**<🐱 设备宽度 */
- (CGFloat)deviceScale;/**<🐱  */


- (CGFloat)deviceStatusBarHeight;/**<🐱 状态栏高度 */
- (BOOL)devicieStatusBarIsHidden;/**<🐱 状态栏是否隐藏 */

- (CGFloat)deviceNavigationBarHeight;/**<🐱  导航栏的高度  */
- (CGFloat)deviceTabBarHeight;/**<🐱 TabBar 高度 */

/* 🐱 默认0.0f  IOS_11*/
- (CGFloat)deviceSafeAreaTopHeight;/**<🐱 顶部安全区域高度 */
- (CGFloat)deviceSafeAreaBottomHeight;/**<🐱 底部的安全区域高度 */
- (CGFloat)deviceSafeAreaLeftHeight;/**<🐱 左边安全区域宽度 */
- (CGFloat)deviceSafeAreaRightHeight;/**<🐱 右边的安全区域宽度 */
- (CGFloat)deviceSafeAreaHeight;/**<🐱 安全区域高度 */
- (CGFloat)deviceSafeAreaWidth;/**<🐱 安全区域宽度 */

- (NSString *)deviceAvailableStoreSize;/**<🐱 设备可用存储大小 MB */
- (NSString *)deviceIPAdress;/**<🐱 设备的IP地址 */


@end

NS_ASSUME_NONNULL_END
