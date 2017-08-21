//
//  SCNVector3Tool.h
//  ARDemo
//
//  Created by apple on 2017/7/21.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
@interface SCNVector3Tool : NSObject


/**
 根据一个vector_float3类型的值返回一个SCNVector3
 
 @param vec vector_float3
 @return SCNVector3
 */
+ (SCNVector3)makeSCNVector3With:(vector_float3)vec;

/**
 计算SCNVector3的空间长度
 
 @param scve SCNVector3
 @return CGFloat类型的长度
 */
+ (CGFloat)lengthWith:(SCNVector3)scve;

/**
 设置SCNVector3长度
 
 @param scve SCNVector3 点
 @param length 长度
 @return scve
 
 */
+ (SCNVector3)setLengthWith:(SCNVector3)scve Length:(CGFloat)length;

/**
 设置SCNVector3最大长度
 
 @param scve SCNVector3 点
 @param maxLength 最大长度
 @return scve
 */
+ (SCNVector3)setMaximumLength:(SCNVector3)scve Length:(CGFloat)maxLength;


/**
 标准化设置
 
 @param scve SCNVector3 点
 @return scve
 */
+ (SCNVector3)normalizeWithSCNVector3:(SCNVector3)scve;
/**
 标准化设置
 
 @param scve SCNVector3 点
 @return scve
 */
+ (SCNVector3)normalizedWithSCNVector3:(SCNVector3)scve;
/**
 根据transfrom变换生成SCNVector3
 
 @param transform 3维变换
 @return SCNVector3值
 */
+ (SCNVector3 )positionFromTransform:(matrix_float4x4)transform;

+ (NSString *)friendlyStringWithSCNVector3:(SCNVector3)scve;

+ (CGFloat )dotWithSCNVector3:(SCNVector3)scve1 SCNVector3_2:(SCNVector3)scve2;

+ (SCNVector3 )crossWithSCNVector3_1:(SCNVector3)scve1 SCNVector3_2:(SCNVector3)scve2;

+ (SCNVector3)makeSCNVector3One;
+ (SCNVector3)makeSCNVector3UniformValue:(CGFloat)value;
@end
