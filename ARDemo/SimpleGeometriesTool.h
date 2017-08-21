//
//  SimpleGeometriesTool.h
//  ARDemo
//
//  Created by apple on 2017/7/31.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>
@interface SimpleGeometriesTool : NSObject


+ (SCNNode *)createAxesNodeWithQuiverLength:(CGFloat)quiverLength QuiverThickness:(CGFloat)quiverThickness;

+ (SCNNode *)createCrossNodeWithSize:(CGFloat)size Color:(UIColor *)color Horizontal:(BOOL)horizontal Opacity:(CGFloat)opacity;

+ (SCNPlane *)createSquarePlaneWithSize:(CGFloat)size Contents:(id)contents;
+ (SCNPlane *)createPlaneWithSize:(CGSize)size Contents:(id)contents;
@end
