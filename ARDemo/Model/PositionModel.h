//
//  PositionModel.h
//  ARDemo
//
//  Created by apple on 2017/8/17.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>

@interface PositionModel : NSObject

@property (nonatomic,assign) SCNVector3 position;
@property (nonatomic,strong) ARPlaneAnchor *planeAnchor;
@property (nonatomic,assign) BOOL hitAPlane;

+ (instancetype)modelWithPosition:(SCNVector3 )positon PlaneAnchor:(ARPlaneAnchor *)planeAnchor HitAPlane:(BOOL)hitPlane;

@end
