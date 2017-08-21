//
//  NSArray+Extension.h
//  ARDemo
//
//  Created by apple on 2017/7/26.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>


@interface NSArray (Extension)

/**
 求CGFloat数组的平均值
 
 @param array CGFloat数组
 @return 平均值
 */
+ (CGFloat)getAverageFromCGFloatArray:(NSArray *)array;

/*
 求SCNVector3数组的平均值
 
 @param array SCNVector3数组
 @return SCNVector3平均值
 */
+ (SCNVector3)getAverageFromSCNVector3Array:(NSArray *)array;

- (void)keepLastWithElements:(NSInteger)elementsToKeep;
@end
