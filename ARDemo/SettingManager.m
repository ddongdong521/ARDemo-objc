//
//  SettingManager.m
//  ARDemo
//
//  Created by apple on 2017/8/7.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "SettingManager.h"

@implementation SettingManager

+ (void)registerDefaults{
    NSDictionary *defalutsOption = @{[self getStringWithSetting:SettingAmbientLightEstimation]:@(YES),[self getStringWithSetting:SettingDragOnInfinitePlanes]:@(YES),[self getStringWithSetting:SettingSelectedObjectID]:@(-1),};
       [[NSUserDefaults standardUserDefaults] registerDefaults:defalutsOption];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString *)getStringWithSetting:(Setting)setting{
    NSString *string = @"";
    switch (setting) {
        case SettingDebugMode:
            string = @"SettingDebugMode";
            break;
        case SettingShowHitTestAPI:
            string = @"SettingShowHitTestAPI";
            break;
        case SettingUse3DOFFallback:
            string = @"SettingUse3DOFFallback";
            break;
        case SettingUse3DOFTracking:
            string = @"SettingUse3DOFTracking";
            break;
        case SettingSelectedObjectID:
            string = @"SettingSelectedObjectID";
            break;
        case SettingUseOcclusionPlanes:
            string = @"SettingUseOcclusionPlanes";
            break;
        case SettingScaleWithPinchGesture:
            string = @"SettingScaleWithPinchGesture";
            break;
        case SettingDragOnInfinitePlanes:
            string = @"SettingDragOnInfinitePlanes";
            break;
        case SettingAmbientLightEstimation:
            string = @"SettingAmbientLightEstimation";
            break;
            default:
            break;
    }
    return string;
}
+(BOOL)getPopulateSettingWithSetting:(Setting)setting{
    NSString *string = [self getStringWithSetting:setting];
    
    return [[NSUserDefaults standardUserDefaults]boolForKey:string];
}
+(void)setSettingWithSetting:(Setting)setting Value:(BOOL)value{
    NSString *string = [self getStringWithSetting:setting];
    [[NSUserDefaults standardUserDefaults]setBool:value forKey:string];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(void)setSelectedObjectWithInteger:(NSInteger)integer{
    [[NSUserDefaults standardUserDefaults]setInteger:integer forKey:[self getStringWithSetting:SettingSelectedObjectID]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+ (NSInteger)getSelectedObject{
    return [[NSUserDefaults standardUserDefaults]integerForKey:[self getStringWithSetting:SettingSelectedObjectID]];
}
@end
