//
//  CGPointTool.h
//  ARDemo
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
@interface CGPointTool : NSObject

/**
 使用size初始化point
 
 @param size size
 @return point
 */
+ (CGPoint)makePointWithCGSize:(CGSize)size;

/**
 使用vertor初始化point
 
 @param vector vector
 @return point
 */
+ (CGPoint)makePointWithSCNVector3:(SCNVector3)vector;

/**
 计算两点之间的距离
 
 @param point_1 第一个point
 @param point_2 第二个point
 @return distance
 */
+ (CGFloat)distanceFromPoint_1:(CGPoint)point_1 ToPoint_2:(CGPoint)point_2;

/**
 计算一个点距原点的距离
 
 @param point point
 @return length
 */
+ (CGFloat)lengthWithCGPoint:(CGPoint)point;

/**
 计算两点之间的中点
 
 @param point_1 point1
 @param point_2 point2
 @return midPoint
 */
+ (CGPoint)midPointFromPoint_1:(CGPoint)point_1 ToPoint_2:(CGPoint)point_2;

/**
 返回当前点的x，y字符串
 
 @param point point
 @return string
 */
+ (NSString *)firendlyStringWithCGPoint:(CGPoint)point;
@end
