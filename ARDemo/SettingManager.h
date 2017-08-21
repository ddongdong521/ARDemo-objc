//
//  SettingManager.h
//  ARDemo
//
//  Created by apple on 2017/8/7.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingManager : NSObject

typedef NS_ENUM(NSUInteger,Setting){
    SettingDebugMode = 1,
    SettingScaleWithPinchGesture,
    SettingAmbientLightEstimation,
    SettingDragOnInfinitePlanes,
    SettingShowHitTestAPI,
    SettingUse3DOFTracking,
    SettingUse3DOFFallback,
    SettingUseOcclusionPlanes,
    SettingSelectedObjectID,
};

+ (void)registerDefaults;
+ (NSString *)getStringWithSetting:(Setting)setting;
+(BOOL)getPopulateSettingWithSetting:(Setting)setting;
+(void)setSettingWithSetting:(Setting)setting Value:(BOOL)value;
+(void)setSelectedObjectWithInteger:(NSInteger)integer;
+ (NSInteger)getSelectedObject;
@end
