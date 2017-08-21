//
//  SceneKitTool.h
//  ARDemo
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface SceneKitTool : NSObject


+ (SCNVector3)rayIntersectionWithHorizontalPlane:(SCNVector3)rayOrigin Direction:(SCNVector3)direction PlaneY:(CGFloat)planeY;


@end
