//
//  DeviceEngine.m
//  RWDeviceEngine
//
//  Created by 曾云 on 2020/5/28.
//  Copyright © 2020 曾云. All rights reserved.
//

#import "DeviceEngine.h"

#import <sys/sysctl.h>
#import <ifaddrs.h> //ip地址
#import <arpa/inet.h>
#import <sys/param.h>
#import <sys/mount.h>//设备存储大小

#define KeyWindowSafeAreaInsets [UIApplication sharedApplication].keyWindow.rootViewController.view.safeAreaInsets


/* 🐱
 规则
 设备类型_设备名称_第几代_尺寸_宽_高_倍数_年月
 设备类型 IPHONE IPAD IPODTOUCH
 设备名称 4s 6Plus Air Pro 没有用M代替
 第几代  没有使用D代替
 尺寸 35表示3.5英寸 55表示5.5英寸 不清楚用C代替
 宽 320 表示开发尺寸320pt
 高 480 表示开发尺寸480pt
 倍数 2表示2倍图 可以计算出像素尺寸(宽高) 宽*倍数 高*倍数
 年月 最早发布时间 如果不清楚 使用NY
 比如
 IPHONE_4S_D_35_320_480_2_201003
 表示    手机4s 3.5寸 D第几代不清楚 开发尺寸宽320 开发尺寸高480 2倍图 2010年03月发布
 
 */

static NSString *IPHONE_1G_1_35_320_480_1_N = @"iPhone_1G";
static NSString *IPHONE_3G_2_35_320_480_1_N = @"iPhone_3G";
static NSString *IPHONE_3GS_3_35_320_480_1_N = @"iPhone_3GS";
static NSString *IPHONE_4_4_35_320_480_2_Y = @"iPhone_4";
static NSString *IPHONE_4GSM_4_35_320_480_2_Y = @"iPhone_4_CSM";
static NSString *IPHONE_4CDMA_4_35_320_480_2_Y = @"iPhone_4_CDMA";
static NSString *IPHONE_4S_5_35_320_480_2_Y = @"iPhone_4S";
static NSString *IPHONE_5_6_40_320_568_2_Y = @"iPhone_5";
static NSString *IPHONE_5C_7_40_320_568_2_Y = @"iPhone_5C";
static NSString *IPHONE_5S_7_40_320_568_2_Y = @"iPhone_5S";
static NSString *IPHONE_SE_9_40_320_568_2_Y = @"iPhone_SE";
static NSString *IPHONE_SE2_9_47_375_667_2_202004 = @"iPhone_SE_2";
static NSString *IPHONE_6_8_47_375_667_2_Y = @"iPhone_6";
static NSString *IPHONE_6Plus_8_55_414_736_3_Y = @"iPhone_6Plus";
static NSString *IPHONE_6S_9_47_375_667_2_Y = @"iPhone_6S";
static NSString *IPHONE_6SPlus_9_55_414_736_3_Y = @"iPhone_6S_Plus";
static NSString *IPHONE_7_10_47_375_667_2_Y = @"iPhone_7";
static NSString *IPHONE_7Plus_10_55_414_736_3_Y = @"iPhone_7Plus";
static NSString *IPHONE_8_11_47_375_667_2_Y = @"iPhone_8";
static NSString *IPHONE_8Plus_11_55_414_736_3_Y = @"iPhone_8Plus";
static NSString *IPHONE_X_11_58_375_812_3_Y = @"iPhone_X";
static NSString *IPHONE_XS_12_58_375_812_3_Y = @"iPhone_XS";
static NSString *IPHONE_XR_12_61_414_896_2_Y = @"iPhone_XR";
static NSString *IPHONE_XSMAX_12_65_414_896_3_Y = @"iPhone_XS_Max";
static NSString *IPHONE_11_1_61_414_896_2_201909 = @"iPhone_11";
static NSString *IPHONE_11Pro_1_58_375_812_3_201909 = @"iPhone_11_Pro";
static NSString *IPHONE_11ProMax_1_65_414_896_3_201909 = @"iPhone_11_ProMax";
static NSString *IPHONE_12Mini_1_54_360_780_3_202010 = @"iPhone_12_Mini";
static NSString *IPHONE_12_1_61_390_884_3_202010 = @"iPhone_12";
static NSString *IPHONE_12Pro_1_61_390_884_3_202010 = @"iPhone_12_Pro";
static NSString *IPHONE_12ProMax_1_67_428_926_3_202010 = @"iPhone_12_ProMax";

static NSString *IPODTOUCH_M_1_35_320_480_1_NY = @"iPodTouch_1";
static NSString *IPODTOUCH_M_2_35_320_480_1_NY = @"iPodTouch_2";
static NSString *IPODTOUCH_M_3_35_320_480_1_NY = @"iPodTouch_3";
static NSString *IPODTOUCH_M_4_35_320_480_2_NY = @"iPodTouch_4";
static NSString *IPODTOUCH_M_5_40_320_568_2_201406 = @"iPodTouch_5";
static NSString *IPODTOUCH_M_6_49_320_568_2_NY = @"iPodTouch_6";
static NSString *IPODTOUCH_M_7_49_320_568_2_201609 = @"iPodTouch_7";

static NSString *IPAD_MINI_1_79_768_1024_1_201210 = @"iPadMini_1";
static NSString *IPAD_MINI_2_79_768_1024_2_201310 = @"iPadMini_2";
static NSString *IPAD_MINI_3_79_768_1024_2_201410 = @"iPadMini_3";
static NSString *IPAD_MINI_4_79_768_1024_2_201509 = @"iPadMini_4";
static NSString *IPAD_MINI_5_79_768_1024_2_201903 = @"iPadMini_5";

static NSString *IPAD_AIR_1_97_768_1024_2_201310  = @"iPadAir_1";
static NSString *IPAD_AIR_2_97_768_1024_2_201410  = @"iPadAir_2";
static NSString *IPAD_AIR_3_105_834_1112_2_201903 = @"iPadAir_3";
static NSString *IPAD_AIR_4_974_820_1180_2_202009 = @"iPadAir_4";

static NSString *IPAD_PRO_1_97_768_1024_2_201603   = @"iPadPro_9.7_1";
static NSString *IPAD_PRO_1_105_834_1112_2_201706  = @"iPadPro_10.5_1";
static NSString *IPAD_PRO_1_11_834_1194_2_201809   = @"iPadPro_11_1";
static NSString *IPAD_PRO_2_11_834_1194_2_202010   = @"iPadPro_11_2";
static NSString *IPAD_PRO_1_129_1024_1366_2_201509 = @"iPadPro_12.9_1";
static NSString *IPAD_PRO_2_129_1024_1366_2_201706 = @"iPadPro_12.9_2";
static NSString *IPAD_PRO_3_129_1024_1366_2_201809 = @"iPadPro_12.9_3";
static NSString *IPAD_PRO_4_129_1024_1366_2_202010 = @"iPadPro_12.9_4";

static NSString *IPAD_M_1_97_768_1024_1_201003 = @"iPad_9.7_1";
static NSString *IPAD_M_2_97_768_1024_1_201103 = @"iPad_9.7_2";
static NSString *IPAD_M_3_97_768_1024_2_201203 = @"iPad_9.7_3";
static NSString *IPAD_M_4_97_768_1024_2_201603 = @"iPad_9.7_4";
static NSString *IPAD_M_5_97_768_1024_2_201703 = @"iPad_9.7_5";
static NSString *IPAD_M_6_97_768_1024_2_201803 = @"iPad_9.7_6";
static NSString *IPAD_M_7_98_810_1080_2_201909 = @"iPad_9.7_7";
static NSString *IPAD_M_8_98_810_1080_2_201909 = @"iPad_9.7_8";


static NSString *Simulator_I386 = @"i386";
static NSString *Simulator_X86_64 = @"x86_64";



//设置一个默认的全局使用的Style，
static DeviceEngineOrientationStyle __rw_OrientationStyle = DeviceEngineOrientationStyle_Portrait;
static BOOL __rw_dealWithSeparate = NO;/* 🐱 是否单独处理 */

@interface DeviceEngine ()

@property (nonatomic,assign) DeviceEngineOrientationStyle orientationStyle;/* 定向样式 */

@end




@implementation DeviceEngine

static DeviceEngine *_defaultDeviceEngine = nil;

+ (DeviceEngine *)defaultCustomDevice {
    return [self defaultCustomDeviceOrientationStyle:DeviceEngineOrientationStyle_Portrait];
}

+ (DeviceEngine *)defaultCustomDeviceOrientationStyle:(DeviceEngineOrientationStyle)orientationStyle {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_defaultDeviceEngine == nil) {
            _defaultDeviceEngine = [[self alloc]init];
            _defaultDeviceEngine.orientationStyle = orientationStyle;
        }
    });
    __rw_OrientationStyle = _defaultDeviceEngine.orientationStyle;
    return _defaultDeviceEngine;
}


+(id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_defaultDeviceEngine == nil) {
            _defaultDeviceEngine = [super allocWithZone:zone];;
            _defaultDeviceEngine.orientationStyle = DeviceEngineOrientationStyle_Portrait;
        }
    });
    __rw_OrientationStyle = _defaultDeviceEngine.orientationStyle;
    return _defaultDeviceEngine;
}

-(id)copyWithZone:(struct _NSZone *)zone {
    return self;
}


- (instancetype)init {
    self = [super init];
    if (self) {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)orientationDidChange:(NSNotification *)notification {
    if (self.deviceAutorotateBlock) {
        self.deviceAutorotateBlock();
    }
}



#pragma mark -

/* 🐱 单独处理竖屏 */
+ (DeviceEngine *)dealWithSeparatePortrait {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_defaultDeviceEngine == nil) {
            _defaultDeviceEngine = [self defaultCustomDevice];
        }
    });
    __rw_OrientationStyle = DeviceEngineOrientationStyle_Portrait;
    __rw_dealWithSeparate = YES;
    return _defaultDeviceEngine;
}

/* 🐱 单独处理横屏  */
+ (DeviceEngine *)dealWithSeparateLandscape {
    static dispatch_once_t onceToken;
       dispatch_once(&onceToken, ^{
           if (_defaultDeviceEngine == nil) {
               _defaultDeviceEngine = [self defaultCustomDevice];
           }
       });
       __rw_OrientationStyle = DeviceEngineOrientationStyle_Landscape;
       __rw_dealWithSeparate = YES;
       return _defaultDeviceEngine;
}




- (NSString *)machineModel {
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}

- (NSString *)machineModelName {
    static dispatch_once_t one;
    static NSString *name;
    dispatch_once(&one, ^{
        NSString *model = [self machineModel];
        if ([model isEqualToString:@"iPhone1,1"])
            name = IPHONE_1G_1_35_320_480_1_N;
        else if ([model isEqualToString:@"iPhone1,2"])
            name = IPHONE_3G_2_35_320_480_1_N;
        else if ([model isEqualToString:@"iPhone2,1"])
            name = IPHONE_3GS_3_35_320_480_1_N;
        else if ([model isEqualToString:@"iPhone3,1"])
            name = IPHONE_4GSM_4_35_320_480_2_Y;
        else if ([model isEqualToString:@"iPhone3,2"])
            name = IPHONE_4_4_35_320_480_2_Y;
        else if ([model isEqualToString:@"iPhone3,3"])
            name = IPHONE_4CDMA_4_35_320_480_2_Y;
        else if ([model isEqualToString:@"iPhone4,1"])
            name = IPHONE_4S_5_35_320_480_2_Y;
        else if ([model isEqualToString:@"iPhone5,1"])
            name = IPHONE_5_6_40_320_568_2_Y;
        else if ([model isEqualToString:@"iPhone5,2"])
            name = IPHONE_5_6_40_320_568_2_Y;
        else if ([model isEqualToString:@"iPhone5,3"])
            name = IPHONE_5C_7_40_320_568_2_Y;
        else if ([model isEqualToString:@"iPhone5,4"])
            name = IPHONE_5C_7_40_320_568_2_Y;
        else if ([model isEqualToString:@"iPhone6,1"])
            name = IPHONE_5S_7_40_320_568_2_Y;
        else if ([model isEqualToString:@"iPhone6,2"])
            name = IPHONE_5S_7_40_320_568_2_Y;
        else if ([model isEqualToString:@"iPhone7,1"])
            name = IPHONE_6Plus_8_55_414_736_3_Y;
        else if ([model isEqualToString:@"iPhone7,2"])
            name = IPHONE_6_8_47_375_667_2_Y;
        else if ([model isEqualToString:@"iPhone8,1"])
            name = IPHONE_6S_9_47_375_667_2_Y;
        else if ([model isEqualToString:@"iPhone8,2"])
            name = IPHONE_6SPlus_9_55_414_736_3_Y;
        else if ([model isEqualToString:@"iPhone8,4"])
            name = IPHONE_SE_9_40_320_568_2_Y;
        else if ([model isEqualToString:@"iPhone9,1"])
            name = IPHONE_7_10_47_375_667_2_Y;
        else if ([model isEqualToString:@"iPhone9,2"])
            name = IPHONE_7Plus_10_55_414_736_3_Y;
        else if ([model isEqualToString:@"iPhone10,1"])
            name = IPHONE_8_11_47_375_667_2_Y;
        else if ([model isEqualToString:@"iPhone10,4"])
            name = IPHONE_8_11_47_375_667_2_Y;
        else if ([model isEqualToString:@"iPhone10,2"])
            name = IPHONE_8Plus_11_55_414_736_3_Y;
        else if ([model isEqualToString:@"iPhone10,5"])
            name = IPHONE_8Plus_11_55_414_736_3_Y;
        else if ([model isEqualToString:@"iPhone10,3"])
            name = IPHONE_X_11_58_375_812_3_Y;
        else if ([model isEqualToString:@"iPhone10,6"])
            name = IPHONE_X_11_58_375_812_3_Y;
        else if ([model isEqualToString:@"iPhone11,8"])
            name = IPHONE_XR_12_61_414_896_2_Y;
        else if ([model isEqualToString:@"iPhone11,2"])
            name = IPHONE_XS_12_58_375_812_3_Y;
        else if ([model isEqualToString:@"iPhone11,6"])
            name = IPHONE_XSMAX_12_65_414_896_3_Y;
        else if ([model isEqualToString:@"iPhone11,4"])
            name = IPHONE_XSMAX_12_65_414_896_3_Y;
        else if ([model isEqualToString:@"iPhone12,1"])
            name = IPHONE_11_1_61_414_896_2_201909;
        else if ([model isEqualToString:@"iPhone11,3"])
            name = IPHONE_11Pro_1_58_375_812_3_201909;
        else if ([model isEqualToString:@"iPhone11,5"])
            name = IPHONE_11ProMax_1_65_414_896_3_201909;
        else if ([model isEqualToString:@"iPhone12,8"])
            name = IPHONE_SE2_9_47_375_667_2_202004;
        else if ([model isEqualToString:@"iPhone13,1"])
            name = IPHONE_12Mini_1_54_360_780_3_202010;
        else if ([model isEqualToString:@"iPhone13,2"])
            name = IPHONE_12_1_61_390_884_3_202010;
        else if ([model isEqualToString:@"iPhone13,3"])
            name = IPHONE_12Pro_1_61_390_884_3_202010;
        else if ([model isEqualToString:@"iPhone13,4"])
            name = IPHONE_12ProMax_1_67_428_926_3_202010;
        
        
        else if ([model isEqualToString:@"iPod1,1"])
            name = IPODTOUCH_M_1_35_320_480_1_NY;
        else if ([model isEqualToString:@"iPod2,1"])
            name = IPODTOUCH_M_2_35_320_480_1_NY;
        else if ([model isEqualToString:@"iPod3,1"])
            name = IPODTOUCH_M_3_35_320_480_1_NY;
        else if ([model isEqualToString:@"iPod4,1"])
            name = IPODTOUCH_M_4_35_320_480_2_NY;
        else if ([model isEqualToString:@"iPod5,1"])
            name = IPODTOUCH_M_5_40_320_568_2_201406;
        else if ([model isEqualToString:@"iPod7,1"])
            name = IPODTOUCH_M_6_49_320_568_2_NY;
        else if ([model isEqualToString:@"iPod9,1"])
            name = IPODTOUCH_M_7_49_320_568_2_201609;
        
        else if ([model isEqualToString:@"iPad1,1"])
            name = IPAD_M_1_97_768_1024_1_201003;
        else if ([model isEqualToString:@"iPad2,1"] |
                 [model isEqualToString:@"iPad2,2"] ||
                 [model isEqualToString:@"iPad2,3"] ||
                 [model isEqualToString:@"iPad2,4"])
            name = IPAD_M_2_97_768_1024_1_201103;
        else if ([model isEqualToString:@"iPad3,1"] ||
                 [model isEqualToString:@"iPad3,2"] ||
                 [model isEqualToString:@"iPad3,3"])
            name = IPAD_M_3_97_768_1024_2_201203;
        else if ([model isEqualToString:@"iPad3,4"] ||
                 [model isEqualToString:@"iPad3,5"] ||
                 [model isEqualToString:@"iPad3,6"])
            name = IPAD_M_4_97_768_1024_2_201603;
        else if ([model isEqualToString:@"iPad6,11"] ||
                 [model isEqualToString:@"iPad6,12"])
            name = IPAD_M_5_97_768_1024_2_201703;
        else if ([model isEqualToString:@"iPad7,5"] ||
                 [model isEqualToString:@"iPad7,6"])
            name = IPAD_M_6_97_768_1024_2_201803;
        else if ([model isEqualToString:@"iPad7,12"] ||
                 [model isEqualToString:@"iPad7,11"])
            name = IPAD_M_7_98_810_1080_2_201909;
        else if ([model isEqualToString:@"iPad11,6"] ||
             [model isEqualToString:@"iPad11,7"])
            name = IPAD_M_8_98_810_1080_2_201909;
        
        
        else if ([model isEqualToString:@"iPad4,1"] ||
                 [model isEqualToString:@"iPad4,2"] ||
                 [model isEqualToString:@"iPad4,3"])
            name = IPAD_AIR_1_97_768_1024_2_201310;
        else if ([model isEqualToString:@"iPad5,3"] ||
                 [model isEqualToString:@"iPad5,4"])
            name = IPAD_AIR_2_97_768_1024_2_201410;
        else if ([model isEqualToString:@"iPad11,3"] ||
                 [model isEqualToString:@"iPad11,4"])
            name = IPAD_AIR_3_105_834_1112_2_201903;
        else if ([model isEqualToString:@"iPad13,1"] ||
             [model isEqualToString:@"iPad13,2"])
            name = IPAD_AIR_4_974_820_1180_2_202009;
        
        
        else if ([model isEqualToString:@"iPad6,3"] ||
                 [model isEqualToString:@"iPad6,4"])
            name = IPAD_PRO_1_97_768_1024_2_201603;
        else if ([model isEqualToString:@"iPad6,7"] ||
                 [model isEqualToString:@"iPad6,8"])
            name = IPAD_PRO_1_129_1024_1366_2_201509;
        else if ([model isEqualToString:@"iPad7,1"] ||
                 [model isEqualToString:@"iPad7,2"])
            name = IPAD_PRO_2_129_1024_1366_2_201706;
        else if ([model isEqualToString:@"iPad7,3"] ||
                 [model isEqualToString:@"iPad7,4"])
            name = IPAD_PRO_1_105_834_1112_2_201706;
        else if ([model isEqualToString:@"iPad8,1"] ||
                 [model isEqualToString:@"iPad8,2"] ||
                 [model isEqualToString:@"iPad8,3"] ||
                 [model isEqualToString:@"iPad8,4"])
            name = IPAD_PRO_1_11_834_1194_2_201809;
        else if ([model isEqualToString:@"iPad8,9"] ||
                 [model isEqualToString:@"iPad8,10"])
            name = IPAD_PRO_2_11_834_1194_2_202010;
        
        else if ([model isEqualToString:@"iPad8,5"] ||
                 [model isEqualToString:@"iPad8,6"] ||
                 [model isEqualToString:@"iPad8,7"] ||
                 [model isEqualToString:@"iPad8,8"])
            name = IPAD_PRO_3_129_1024_1366_2_201809;
        else if ([model isEqualToString:@"iPad8,11"] ||
                 [model isEqualToString:@"iPad8,12"])
            name = IPAD_PRO_4_129_1024_1366_2_202010;
        
        else if ([model isEqualToString:@"iPad2,5"] ||
                 [model isEqualToString:@"iPad2,6"] ||
                 [model isEqualToString:@"iPad2,7"])
            name = IPAD_MINI_1_79_768_1024_1_201210;
        else if ([model isEqualToString:@"iPad4,4"] ||
                 [model isEqualToString:@"iPad4,5"] ||
                 [model isEqualToString:@"iPad4,6"])
            name = IPAD_MINI_2_79_768_1024_2_201310;
        else if ([model isEqualToString:@"iPad4,7"] ||
                 [model isEqualToString:@"iPad4,8"] ||
                 [model isEqualToString:@"iPad4,9"])
            name = IPAD_MINI_3_79_768_1024_2_201410;
        else if ([model isEqualToString:@"iPad5,1"] ||
                 [model isEqualToString:@"iPad5,2"])
            name = IPAD_MINI_4_79_768_1024_2_201509;
        else if ([model isEqualToString:@"iPad11,1"] ||
                 [model isEqualToString:@"iPad11,2"])
            name = IPAD_MINI_5_79_768_1024_2_201903;
        
        else if ([model isEqualToString:@"i386"])
            name = Simulator_I386;
        else if ([model isEqualToString:@"x86_64"])
            name = Simulator_X86_64;
        else name = model;
    });
    return name;
}

- (BOOL)isSimulator {
    return [self.machineModelName isEqualToString:Simulator_I386] ||
    [self.machineModelName isEqualToString:Simulator_X86_64];
}
- (BOOL)isiPad {
    if (@available(iOS 13.0, *)) {
        return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    } else {
         return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    }
}

- (BOOL)isiPhone {
    if (@available(iOS 13.0, *)) {
       return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
   } else {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
   }
}

- (BOOL)isiPodTouch {
    UIUserInterfaceIdiom idiom = UIUserInterfaceIdiomUnspecified;
    if (@available(iOS 13.0, *)) {
        idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    } else {
        idiom = UI_USER_INTERFACE_IDIOM();
    }
    
    if (idiom == UIUserInterfaceIdiomPhone) {
        if ([self iPodTouch] || [self iPodTouch2] || [self iPodTouch3] ||
            [self iPodTouch4] || [self iPodTouch5] || [self iPodTouch6] ||
            [self iPodTouch7]) {
            return YES;
        }
        return NO;
    }
    return NO;
}


- (BOOL)isAppleTV {
    if (@available(iOS 13.0, *)) {
        return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomTV;
    } else {
         return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomTV;
    }
}
- (BOOL)isCarolay {
    
    if (@available(iOS 13.0, *)) {
        return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomCarPlay;
    } else {
         return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomCarPlay;
    }
}

#pragma mark iPhone All

- (BOOL)iPhone {
    return [self.machineModelName isEqualToString:IPHONE_1G_1_35_320_480_1_N];
}

- (BOOL)iPhone3G {
    return [self.machineModelName isEqualToString:IPHONE_3G_2_35_320_480_1_N];
}

- (BOOL)iPhone3GS {
    return [self.machineModelName isEqualToString:IPHONE_3GS_3_35_320_480_1_N];
}

- (BOOL)iPhone4 {
    return
    [self.machineModelName isEqualToString:IPHONE_4_4_35_320_480_2_Y]    ||
    [self.machineModelName isEqualToString:IPHONE_4GSM_4_35_320_480_2_Y] ||
    [self.machineModelName isEqualToString:IPHONE_4CDMA_4_35_320_480_2_Y];
}

- (BOOL)iPhone4S {
    return [self.machineModelName isEqualToString:IPHONE_4S_5_35_320_480_2_Y];
}

- (BOOL)iPhone5 {
    return [self.machineModelName isEqualToString:IPHONE_5_6_40_320_568_2_Y];
}

- (BOOL)iPhone5C {
    return [self.machineModelName isEqualToString:IPHONE_5C_7_40_320_568_2_Y];
}

- (BOOL)iPhone5S {
    return [self.machineModelName isEqualToString:IPHONE_5S_7_40_320_568_2_Y];
}

- (BOOL)iPhoneSE {
    return [self.machineModelName isEqualToString:IPHONE_SE_9_40_320_568_2_Y];
}

- (BOOL)iPhoneSE2 {
    return [self.machineModelName isEqualToString:IPHONE_SE2_9_47_375_667_2_202004];
}

- (BOOL)iPhone6 {
    return [self.machineModelName isEqualToString:IPHONE_6_8_47_375_667_2_Y];
}

- (BOOL)iPhone6Plus {
    return [self.machineModelName isEqualToString:IPHONE_6Plus_8_55_414_736_3_Y];
}

- (BOOL)iPhone6S {
    return [self.machineModelName isEqualToString:IPHONE_6S_9_47_375_667_2_Y];
}

- (BOOL)iPhone6SPlus {
    return [self.machineModelName isEqualToString:IPHONE_6SPlus_9_55_414_736_3_Y];
}

- (BOOL)iPhone7 {
    return [self.machineModelName isEqualToString:IPHONE_7_10_47_375_667_2_Y];
}

- (BOOL)iPhone7Plus {
    return [self.machineModelName isEqualToString:IPHONE_7Plus_10_55_414_736_3_Y];
}

- (BOOL)iPhone8 {
    return [self.machineModelName isEqualToString:IPHONE_8_11_47_375_667_2_Y];
}

- (BOOL)iPhone8Plus {
    return [self.machineModelName isEqualToString:IPHONE_8Plus_11_55_414_736_3_Y];
}

- (BOOL)iPhoneX {
    return [self.machineModelName isEqualToString:IPHONE_X_11_58_375_812_3_Y];
}

- (BOOL)iPhoneXR {
    return [self.machineModelName isEqualToString:IPHONE_XR_12_61_414_896_2_Y];
}

- (BOOL)iPhoneXS {
    return [self.machineModelName isEqualToString:IPHONE_XS_12_58_375_812_3_Y];
}

- (BOOL)iPhoneXSMAX {
    return [self.machineModelName isEqualToString:IPHONE_XSMAX_12_65_414_896_3_Y];
}

- (BOOL)iPhone11 {
    return [self.machineModelName isEqualToString:IPHONE_11_1_61_414_896_2_201909];
}

- (BOOL)iPhone11Pro {
    return [self.machineModelName isEqualToString:IPHONE_11Pro_1_58_375_812_3_201909];
}

- (BOOL)iPhone11ProMax {
    return [self.machineModelName isEqualToString:IPHONE_11ProMax_1_65_414_896_3_201909];
}

- (BOOL)iPhone12Mini {
    return [self.machineModelName isEqualToString:IPHONE_12Mini_1_54_360_780_3_202010];
}
- (BOOL)iPhone12 {
    return [self.machineModelName isEqualToString:IPHONE_12_1_61_390_884_3_202010];
}
- (BOOL)iPhone12Pro {
    return [self.machineModelName isEqualToString:IPHONE_12Pro_1_61_390_884_3_202010];
}
- (BOOL)iPhone12ProMax {
    return [self.machineModelName isEqualToString:IPHONE_12ProMax_1_67_428_926_3_202010];
}

#pragma mark iPodTouch All

- (BOOL)iPodTouch {
    return [self.machineModelName isEqualToString:IPODTOUCH_M_1_35_320_480_1_NY];
}

- (BOOL)iPodTouch2 {
    return [self.machineModelName isEqualToString:IPODTOUCH_M_2_35_320_480_1_NY];
}

- (BOOL)iPodTouch3 {
    return [self.machineModelName isEqualToString:IPODTOUCH_M_3_35_320_480_1_NY];
}

- (BOOL)iPodTouch4 {
    return [self.machineModelName isEqualToString:IPODTOUCH_M_4_35_320_480_2_NY];
}

- (BOOL)iPodTouch5 {
    return [self.machineModelName isEqualToString:IPODTOUCH_M_5_40_320_568_2_201406];
}

- (BOOL)iPodTouch6 {
    return [self.machineModelName isEqualToString:IPODTOUCH_M_6_49_320_568_2_NY];
}

- (BOOL)iPodTouch7 {
    return [self.machineModelName isEqualToString:IPODTOUCH_M_7_49_320_568_2_201609];
}



#pragma mark iPad All


- (BOOL)iPad {
    return [self.machineModelName isEqualToString:IPAD_M_1_97_768_1024_1_201003];
}

- (BOOL)iPad2 {
    return [self.machineModelName isEqualToString:IPAD_M_2_97_768_1024_1_201103];
}

- (BOOL)iPad3 {
    return [self.machineModelName isEqualToString:IPAD_M_3_97_768_1024_2_201203];
}

- (BOOL)iPad4 {
    return [self.machineModelName isEqualToString:IPAD_M_4_97_768_1024_2_201603];
}

- (BOOL)iPad5 {
    return [self.machineModelName isEqualToString:IPAD_M_5_97_768_1024_2_201703];
}

- (BOOL)iPad6 {
    return [self.machineModelName isEqualToString:IPAD_M_6_97_768_1024_2_201803];
}

-(BOOL) iPad7 {
    return [self.machineModelName isEqualToString:IPAD_M_7_98_810_1080_2_201909];
}

-(BOOL) iPad8 {
    return [self.machineModelName isEqualToString:IPAD_M_8_98_810_1080_2_201909];
}

- (BOOL)iPadAir {
    return [self.machineModelName isEqualToString:IPAD_AIR_1_97_768_1024_2_201310];
}

- (BOOL)iPadAir2 {
    return [self.machineModelName isEqualToString:IPAD_AIR_2_97_768_1024_2_201410];
}

- (BOOL)iPadAir3 {
    return [self.machineModelName isEqualToString:IPAD_AIR_3_105_834_1112_2_201903];
}

- (BOOL)iPadAir4 {
    return [self.machineModelName isEqualToString:IPAD_AIR_4_974_820_1180_2_202009];
}

- (BOOL)iPadPro97 {
    return [self.machineModelName isEqualToString:IPAD_PRO_1_97_768_1024_2_201603];
}

- (BOOL)iPadPro105 {
    return [self.machineModelName isEqualToString:IPAD_PRO_1_105_834_1112_2_201706];
}

- (BOOL)iPadPro11 {
    return [self.machineModelName isEqualToString:IPAD_PRO_1_11_834_1194_2_201809];
}

- (BOOL)iPadPro11_2 {
    return [self.machineModelName isEqualToString:IPAD_PRO_2_11_834_1194_2_202010];
}

- (BOOL)iPadPro129 {
    return [self.machineModelName isEqualToString:IPAD_PRO_1_129_1024_1366_2_201509];
}

- (BOOL)iPadPro129_2 {
    return [self.machineModelName isEqualToString:IPAD_PRO_2_129_1024_1366_2_201706];
}

- (BOOL)iPadPro129_3 {
    return [self.machineModelName isEqualToString:IPAD_PRO_3_129_1024_1366_2_201809];
}

- (BOOL)iPadPro129_4 {
    return [self.machineModelName isEqualToString:IPAD_PRO_4_129_1024_1366_2_202010];
}

- (BOOL)iPadMini {
    return [self.machineModelName isEqualToString:IPAD_MINI_1_79_768_1024_1_201210];
}

- (BOOL)iPadMini2 {
    return [self.machineModelName isEqualToString:IPAD_MINI_2_79_768_1024_2_201310];
}

- (BOOL)iPadMini3 {
    return [self.machineModelName isEqualToString:IPAD_MINI_3_79_768_1024_2_201410];
}

- (BOOL)iPadMini4 {
    return [self.machineModelName isEqualToString:IPAD_MINI_4_79_768_1024_2_201509];
}

- (BOOL)iPadMini5 {
    return [self.machineModelName isEqualToString:IPAD_MINI_5_79_768_1024_2_201903];
}




#pragma mark - 真机 模拟器都可以使用

#pragma mark -- SizeType 开发尺寸分类
/**<🐱
 iPhone_320_480 开发尺寸
 包含设备类型 （iphone类型）
 - (BOOL)iPhone;
 - (BOOL)iPhone3G;
 - (BOOL)iPhone3GS;
 - (BOOL)iPhone4;
 - (BOOL)iPhone4S;
 
 统一名称：- (BOOL)isiPhone4s;
 
 */
- (BOOL)iPhone_320_480 {
    if ([self isSimulator]) {
        if ([self isiPhone] ||[self isiPodTouch]) {
            return [self deviceWidth:320.00 height:480.00];
        }
        return NO;
    }
    
    return [self iPhone] || [self iPhone3G] || [self iPhone3GS] ||
            [self iPhone4] || [self iPhone4S] || [self iPodTouch] ||
            [self iPodTouch2] || [self iPodTouch3] || [self iPodTouch4];
}

/**<🐱
 iPhone_320_568 开发尺寸
 包含设备类型 （iphone类型）
 - (BOOL)iPhone5;
 - (BOOL)iPhone5C;
 - (BOOL)iPhone5S;
 - (BOOL)iPhoneSE;
 
 统一名称：- (BOOL)isiPhone5;
 */

- (BOOL)iPhone_320_568 {
    if ([self isSimulator]) {
        if ([self isiPhone] ||[self isiPodTouch]) {
            return [self deviceWidth:320.00 height:568.00];
        }
        return NO;
    }
    return [self iPhone5] || [self iPhone5C] || [self iPhone5S] || [self iPhoneSE] || [self iPodTouch5] || [self iPodTouch6] || [self iPodTouch7];
}

/**<🐱
 iPhone_375_667 开发尺寸
 包含设备类型 （iphone类型）
 - (BOOL)iPhone6;
 - (BOOL)iPhone6S;
 - (BOOL)iPhone7;
 - (BOOL)iPhone8;
  - (BOOL)iPhoneSE2;
 
 统一名称：- (BOOL)isiPhone6;
 */

- (BOOL)iPhone_375_667 {
    if ([self isSimulator]) {
        if ([self isiPhone] ||[self isiPodTouch]) {
            return [self deviceWidth:375.00 height:667.00];
        }
        return NO;
    }
    return [self iPhone6] || [self iPhone6S] || [self iPhone7] || [self iPhone8] || [self iPhoneSE2];
}

/**<🐱
 iPhone_414_736 开发尺寸
 包含设备类型 （iphone类型）
 - (BOOL)iPhone6Plus;
 - (BOOL)iPhone6SPlus;
 - (BOOL)iPhone7Plus;
 - (BOOL)iPhone8Plus;
 
 统一名称：- (BOOL)isiPhonePlus;
 */

- (BOOL)iPhone_414_736 {
    if ([self isSimulator]) {
        if ([self isiPhone] ||[self isiPodTouch]) {
            return [self deviceWidth:414.00 height:736.00];
        }
        return NO;
    }
    return [self iPhone6Plus] || [self iPhone6SPlus] ||
        [self iPhone7Plus] || [self iPhone8Plus];
}

/**<🐱
 iPhone_375_812 开发尺寸
 包含设备类型 （iphone类型）
 - (BOOL)iPhoneX;
 - (BOOL)iPhoneXS;
 - (BOOL)iPhone11Pro;
 
 统一名称：- (BOOL)isiPhoneX;
 */

- (BOOL)iPhone_375_812 {
    if ([self isSimulator]) {
        if ([self isiPhone] ||[self isiPodTouch]) {
            return [self deviceWidth:375.00 height:812.00];
        }
        return NO;
    }
    return [self iPhoneX] || [self iPhoneXS] || [self iPhone11Pro];
}

/**<🐱
 iPhone_414_896 开发尺寸
 包含设备类型 （iphone类型）
 - (BOOL)iPhoneXR;
 - (BOOL)iPhoneXSMAX;
 - (BOOL)iPhone11;
 - (BOOL)iPhone11ProMax;
 
 统一名称：- (BOOL)isiPhoneXPlus;
 */
- (BOOL)iPhone_414_896 {
    if ([self isSimulator]) {
        if ([self isiPhone] ||[self isiPodTouch]) {
            return [self deviceWidth:414.00 height:896.00];
        }
        return NO;
    }
    return [self iPhoneXR] || [self iPhoneXSMAX] || [self iPhone11ProMax] || [self iPhone11];
}


/**<🐱
iPhone_360_780 开发尺寸,包含设备类型 （iphone类型）
- (BOOL)iPhone12Mini;
 统一名称：- (BOOL)isiPhone12Mini;
*/
- (BOOL)iPhone_360_780 {
    if ([self isSimulator]) {
        if ([self isiPhone] ||[self isiPodTouch]) {
            return [self deviceWidth:360.00 height:780.00];
        }
        return NO;
    }
    return [self iPhone12Mini];
}

/**<🐱
iPhone_360_780 开发尺寸,包含设备类型 （iphone类型）
- (BOOL)iPhone12;
- (BOOL)iPhone12Pro;
 统一名称：- (BOOL)isiPhone12Pro;
*/
- (BOOL)iPhone_390_884 {
    if ([self isSimulator]) {
        if ([self isiPhone] ||[self isiPodTouch]) {
            return [self deviceWidth:390.00 height:884.00];
        }
        return NO;
    }
    return [self iPhone12] || [self iPhone12Pro];
}

/**<🐱
iPhone_428_926 开发尺寸,包含设备类型 （iphone类型）
- (BOOL)iPhone12ProMax;
 统一名称：- (BOOL)isiPhone12ProMax;
*/
- (BOOL)iPhone_428_926 {
    if ([self isSimulator]) {
        if ([self isiPhone] ||[self isiPodTouch]) {
            return [self deviceWidth:428.00 height:926.00];
        }
        return NO;
    }
    return [self iPhone12ProMax];
}


- (BOOL)isiPhone4s {
    return [self iPhone_320_480];
}
- (BOOL)isiPhone5 {
    return [self iPhone_320_568];
}
- (BOOL)isiPhone6 {
    return [self iPhone_375_667];
}
- (BOOL)isiPhonePlus {
    return [self iPhone_414_736];
}
- (BOOL)isiPhoneX {
    return [self iPhone_375_812];
}

- (BOOL)isiPhoneXPlus {
    return [self iPhone_414_896];
}

- (BOOL)isiPhoneFullScreen {
    return [self iPhone_375_812];
}

- (BOOL)isiPhoneFullScreenPlus {
    return [self iPhone_414_896];
}

- (BOOL)isiPhone12Mini {
    return [self iPhone_360_780];
}
- (BOOL)isiPhone12Pro {
    return [self iPhone_390_884];
}
- (BOOL)isiPhone12ProMax {
    return [self iPhone_428_926];
}

- (BOOL)iPhone_FullScreen {
   return [self isiPhoneFullScreen] || [self isiPhoneFullScreenPlus] || [self isiPhone12Mini] ||
    [self isiPhone12Pro] || [self isiPhone12ProMax];
}

- (BOOL)iPhone_Plus {
    return [self isiPhonePlus] ||[self isiPhoneFullScreenPlus];
}




/**<🐱
 ipad_768_1024 开发尺寸
 包含设备类型 （ipad类型）
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
 
 */
- (BOOL)ipad_768_1024 {
    if ([self isSimulator]) {
        if ([self isiPad]) {
            return [self deviceWidth:768.00 height:1024.00];
        }
        return NO;
    }
    
    return
        [self iPad] || [self iPad2] || [self iPad3] || [self iPad4] ||
        [self iPad5] || [self iPad6] ||
        [self iPadAir] || [self iPadAir2] ||
        [self iPadPro97] ||
        [self iPadMini] || [self iPadMini2] || [self iPadMini3] ||
        [self iPadMini4] || [self iPadMini5];
}

/**<🐱
 ipad_834_1112 开发尺寸
 包含设备类型 （ipad类型）
 - (BOOL)iPadAir3;
 - (BOOL)iPadPro105;
 
 */
- (BOOL)ipad_834_1112 {
    if ([self isSimulator]) {
        if ([self isiPad]) {
            return [self deviceWidth:834.00 height:1112.00];
        }
        return NO;
    }
    
    return [self iPadPro105] ||[self iPadAir3];
}

/**<🐱
 ipad_834_1194 开发尺寸
 包含设备类型 （ipad类型）
 - (BOOL)iPadPro11;
 */
- (BOOL)ipad_834_1194 {
    if ([self isSimulator]) {
        if ([self isiPad]) {
            return [self deviceWidth:834.00 height:1194.00];
        }
        return NO;
    }
    
    return [self iPadPro11];
}

/**<🐱
 ipad_820_1180 开发尺寸,包含设备类型 （ipad类型）
 - (BOOL)iPadAir4;
 
 */
- (BOOL)ipad_820_1180 {
    if ([self isSimulator]) {
        if ([self isiPad]) {
            return [self deviceWidth:820.00 height:1180.00];
        }
        return NO;
    }
    
    return [self iPadAir4];
}

/**<🐱
 ipad_1024_1136 开发尺寸
 包含设备类型 （ipad类型）
 - (BOOL)iPadPro129;
 - (BOOL)iPadPro129_2;
 - (BOOL)iPadPro129_3;
 
 统一名称：- (BOOL)isiPhoneXPlus;
 */
- (BOOL)ipad_1024_1136 {
    if ([self isSimulator]) {
        if ([self isiPad]) {
            return [self deviceWidth:1024.00 height:1136.00];
        }
        return NO;
    }
    
    return [self iPadPro129] ||[self iPadPro129_2] ||[self iPadPro129_3];
}


- (BOOL)isiPadMini {
    return [self ipad_768_1024];
}
- (BOOL)isiPadPro105 {
    return [self ipad_834_1112];
}
- (BOOL)isiPadPro11 {
    return [self ipad_834_1194];
}
- (BOOL)isiPadPro129 {
    return [self ipad_1024_1136];
}

/**<🐱 ipad是否是全面屏 */
- (BOOL)iPad_FullScreen {
    if ([self isSimulator]) {
        if ([self isiPad]) {
            if ([self deviceSafeAreaBottomHeight]) {
                return YES;
            }
            return NO;
        }
        return NO;
    }
    return [self iPadPro129_3] || [self iPadPro129_4] || [self iPadPro11] || [self iPadAir4];
}


- (BOOL)deviceWidth:(CGFloat)width height:(CGFloat)height {
    return ([self deviceWidth] == width && [self deviceHeight] == height) ||
            ([self deviceWidth] == height && [self deviceHeight] == width);
}



#pragma mark -- PixelType 开发像素分类


#pragma mark - OtherType  其他类型 比如 导航栏高度。。。

- (UIDeviceOrientation)deviceOrientation {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    NSLog(@"%ld",(long)[UIDevice currentDevice].orientation);
    if (orientation == UIDeviceOrientationUnknown) {
        return UIDeviceOrientationPortrait;
    }
    return [UIDevice currentDevice].orientation;
}
- (BOOL)deviceIsPortrait {
    return UIDeviceOrientationIsPortrait([self deviceOrientation]);
}

- (BOOL)deviceIsLandscape {
    return UIDeviceOrientationIsLandscape([self deviceOrientation]);
}

- (UIInterfaceOrientation)interfaceOrientation {
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
    
    switch ([self deviceOrientation]) {
        case UIDeviceOrientationPortrait:
            orientation = UIInterfaceOrientationUnknown;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        
        case UIDeviceOrientationLandscapeRight:
            orientation = UIInterfaceOrientationLandscapeLeft;
            break;
        
        case UIDeviceOrientationLandscapeLeft:
            orientation = UIInterfaceOrientationLandscapeRight;
            break;
            
        default:
            break;
    }
    
    return orientation;
}

- (BOOL)interfaceIsPortrait {
    return UIInterfaceOrientationIsPortrait([self interfaceOrientation]);
}

- (BOOL)interfaceIsLandscape {
    return UIInterfaceOrientationIsLandscape([self interfaceOrientation]);
}


- (CGFloat)deviceHeight {
    switch (__rw_OrientationStyle) {
        case DeviceEngineOrientationStyle_Portrait:
            return MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            break;
        case DeviceEngineOrientationStyle_Landscape:
            return MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            break;
            
        case DeviceEngineOrientationStyle_Auto:
            return [UIScreen mainScreen].bounds.size.height;
            break;
            
        default:
            break;
    }
    return [UIScreen mainScreen].bounds.size.height;
}

- (CGFloat)deviceWidth {
    switch (__rw_OrientationStyle) {
        case DeviceEngineOrientationStyle_Portrait:
            return MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            break;
        case DeviceEngineOrientationStyle_Landscape:
            return MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            break;
            
        case DeviceEngineOrientationStyle_Auto:
            return [UIScreen mainScreen].bounds.size.width;
            break;
            
        default:
            break;
    }
    return [UIScreen mainScreen].bounds.size.width;
}

- (CGFloat)deviceScale {
    return [UIScreen mainScreen].scale;
}


/* 🐱
iPhone 状态栏高度
 竖屏状态下 全面屏高度为：44.0f 其余高度为：20.0f
 横屏状态下 高度为：CGFLOAT_MIN

 iPad 状态栏高度
 竖屏状态下
 横屏状态下
 */
- (CGFloat)deviceStatusBarHeight {
//     NSLog(@"deviceStatusBarHeight:==%f",[[UIApplication sharedApplication] statusBarFrame].size.height);
    switch (__rw_OrientationStyle) {
        case DeviceEngineOrientationStyle_Portrait:
        {
            if ([self isiPhone]) {
                if ([self iPhone_FullScreen]) {
                    return 44.0f;
                }
                return 20.0f;
            } else if ([self isiPad]) {
                return [[UIApplication sharedApplication] statusBarFrame].size.height;
            }
        }
            break;
            
        case DeviceEngineOrientationStyle_Landscape:
        {
            if ([self isiPhone]) {
                return CGFLOAT_MIN;
            } else if ([self isiPad]) {
                return [[UIApplication sharedApplication] statusBarFrame].size.height;
            }
        }
            break;
        case DeviceEngineOrientationStyle_Auto:
        {
           return [[UIApplication sharedApplication] statusBarFrame].size.height;
        }
            break;
            
        default:
            break;
    }
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

- (BOOL)devicieStatusBarIsHidden {
    return [[UIApplication sharedApplication] isStatusBarHidden];
}



- (CGFloat)deviceNavigationBarHeight {
    CGFloat height = CGFLOAT_MIN;
    if ([self isiPhone]) {
//        NSLog(@"iPhone");
        height = [self deviceNavigationBarHeight_iPhone];
    } else if ([self isiPad]) {
//        NSLog(@"Pad");
         height = [self deviceNavigationBarHeight_iPad];
    }
    return height;
}

/* 🐱
竖屏状态下 高度为：44.0f
横屏状态下 Plus手机高度为：44.0f 其余高度为：32.0f
 */
- (CGFloat)deviceNavigationBarHeight_iPhone {
    CGFloat height = 44.0f;
    if ([self isiPhone]) {
        
        switch (__rw_OrientationStyle) {
            case DeviceEngineOrientationStyle_Portrait:
                {
                    height = 44.0f;
                }
                break;
                
            case DeviceEngineOrientationStyle_Landscape:
                {
                    height = 32.0f;
                }
                break;
                
            case DeviceEngineOrientationStyle_Auto:
                {
                    if ([self deviceIsLandscape]) {
//                         NSLog(@"横向、横屏");
                        if ([self iPhone_Plus]) {
                            height = 44.0f;
                        } else {
                            height = 32.0f;
                        }
                    } else if ([self deviceIsPortrait]) {
//                         NSLog(@"纵向、竖屏");
                        height = 44.0f;
                        if ([self deviceOrientation]==UIDeviceOrientationPortraitUpsideDown) {
                            if (![self iPhone_Plus]) {
                                 height = 32.0f;
                            }
                        }
                    }
                }
                break;
                
            default:
                break;
        }
    }
    return height;
}

/* 🐱
竖屏状态下、横屏状态下 --- 不区分横竖屏 默认44.0f
全面屏状态 高度为：50.0f
系统IOS_12以上 高度为：50.0f
*/

- (CGFloat)deviceNavigationBarHeight_iPad {
    CGFloat height = 44.0f;
    if ([self isiPad]) {
        if ([self iPad_FullScreen]) {
            height =  50.0f;
        } else {
            if (@available(iOS 11.0, *)) {
                height =  50.0f;
            }
        }
    }
    return height;
}


- (CGFloat)deviceTabBarHeight {
    CGFloat height = CGFLOAT_MIN;
    if ([self isiPhone]) {
        height = [self deviceTabBarHeight_iPhone];
    } else if ([self isiPad]) {
        height = [self deviceTabBarHeight_iPad];
    }
    return height + [self deviceSafeAreaBottomHeight];
}


- (CGFloat)deviceTabBarHeight_iPhone {
    CGFloat height = 49.0f;
    if ([self isiPhone]) {
//        NSLog(@"iPhone");
        switch (__rw_OrientationStyle) {
            case DeviceEngineOrientationStyle_Portrait:
            {
                height = 49.0f;
            }
                break;
                
            case DeviceEngineOrientationStyle_Landscape:
            {
                if ([self iPhone_Plus]) {
                    height = 49.0f;
                } else {
                    if (@available(iOS 11.0, *)) {
                        height = 32.0f;
                    }
                }
            }
                break;
                
            case DeviceEngineOrientationStyle_Auto:
            {
                if ([self deviceIsLandscape]) {
//                     NSLog(@"横向、横屏");
                     if ([self iPhone_Plus]) {
                         height = 49.0f;
                     } else {
                         if (@available(iOS 11.0, *)) {
                             height = 32.0f;
                         }
                     }
                } else if ([self deviceIsPortrait]) {
//                     NSLog(@"纵向、竖屏");
                    height = 49.0f;
                }
            }
                break;
                
            default:
                break;
        }
    }
    return height;
}

/* 🐱
竖屏状态下、横屏状态下 --- 不区分横竖屏 默认49.0f
全面屏状态 高度为：50.0f
系统IOS_12以上 高度为：50.0f
*/
- (CGFloat)deviceTabBarHeight_iPad {
    CGFloat height = 49.0f;
    if ([self isiPad]) {
        if ([self iPad_FullScreen]) {
            height =  50.0f;
        } else {
            if (@available(iOS 11.0, *)) {
                height =  50.0f;
            }
        }
    }
    return height;
}


- (CGFloat)deviceSafeAreaBottomHeight {
    CGFloat height = CGFLOAT_MIN;
    if ([self isiPhone]) {
        height = [self deviceSafeAreaBottomHeight_iPhone];
    } else if ([self isiPad]) {
        height = [self deviceSafeAreaBottomHeight_iPad];
    }
    return height;
}

- (CGFloat)deviceSafeAreaBottomHeight_iPhone {
    CGFloat height = CGFLOAT_MIN;
    if ([self isiPhone]) {
        if ([self iPhone_FullScreen]) {
//            NSLog(@"iPhone");
            switch (__rw_OrientationStyle) {
                case DeviceEngineOrientationStyle_Portrait:
                {
                    height = 34.0f;
                }
                    break;
                    
                case DeviceEngineOrientationStyle_Landscape:
                {
                    height = 21.0f;
                }
                    break;
                    
                case DeviceEngineOrientationStyle_Auto:
                {
                    if ([self deviceIsLandscape]) {
//                         NSLog(@"横向、横屏");
                          height = 21.0f;
                    } else if ([self deviceIsPortrait]) {
//                         NSLog(@"纵向、竖屏");
                         height = 34.0f;
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    return height;
}

/**<🐱 全面屏底部安全区域高度 20.0f */
- (CGFloat)deviceSafeAreaBottomHeight_iPad {
    CGFloat height = 0.0f;
    if ([self isiPad]) {
        if (@available(iOS 11.0, *)) {
            height = KeyWindowSafeAreaInsets.bottom;
        }
    }
    return height;
}



- (CGFloat)deviceSafeAreaTopHeight {
    CGFloat height = 0.0f;
     if (@available(iOS 11.0, *)) {
         height = KeyWindowSafeAreaInsets.top;
     }
    return height;
}

- (CGFloat)deviceSafeAreaHeight {
    return [self deviceHeight] - [self deviceSafeAreaTopHeight] - [self deviceSafeAreaBottomHeight];
}

- (CGFloat)deviceSafeAreaLeftHeight {
    CGFloat height = 0.0f;
      if (@available(iOS 11.0, *)) {
          height = KeyWindowSafeAreaInsets.left;
      }
   return height;
}

- (CGFloat)deviceSafeAreaRightHeight {
    CGFloat height = 0.0f;
       if (@available(iOS 11.0, *)) {
           height = KeyWindowSafeAreaInsets.right;
       }
    return height;
}

- (CGFloat)deviceSafeAreaWidth {
    return [self deviceWidth] - [self deviceSafeAreaRightHeight] - [self deviceSafeAreaLeftHeight];
}




- (NSString *)deviceAvailableStoreSize {
    struct statfs buf;
  float freespace = 0;
    if(statfs("/", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
//        NSLog(@"手机剩余存储空间为freespace:%.2f GB",freespace/1024/1024/1024);
    }
    
    if(statfs("/var", &buf) >= 0){
        freespace = (unsigned long long)(buf.f_bsize * buf.f_bfree);
//        NSLog(@"手机剩余存储空间为freespace:%.2f GB",freespace/1024/1024/1024);
    }
    
    
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return @"0";
    int64_t space =  [[attrs objectForKey:NSFileSystemSize] longLongValue];
    if (space < 0) space = 0;
//    NSLog(@"手机zong存储空间为space:%qi GB",space/1024/1024/1024);
    
    if (error) return @"0";
    space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = 0;
//    NSLog(@"手机剩余存储空间为space:%qi GB",space/1024/1024/1024);
    
    // 总大小
    float totalsize = 0.0;
    /// 剩余大小
    float freesize = 0.0;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary)
    {
        NSNumber *_free = [dictionary objectForKey:NSFileSystemFreeSize];
        freesize = [_free unsignedLongLongValue]*1.0/(1000);
        
        NSNumber *_total = [dictionary objectForKey:NSFileSystemSize];
        totalsize = [_total unsignedLongLongValue]*1.0/(1000);
    } else
    {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    
    
    return [NSString stringWithFormat:@"%.2f",freesize/1000/1000];
}




- (NSString *)deviceIPAdress {
    NSString *address = @"0.0.0.0";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

@end
