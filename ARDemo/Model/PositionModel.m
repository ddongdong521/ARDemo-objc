//
//  PositionModel.m
//  ARDemo
//
//  Created by apple on 2017/8/17.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "PositionModel.h"

@implementation PositionModel

+ (instancetype)modelWithPosition:(SCNVector3 )positon PlaneAnchor:(ARPlaneAnchor *)planeAnchor HitAPlane:(BOOL)hitPlane{
    PositionModel *model = [[self alloc]init];
    model.position = positon;
    model.planeAnchor = planeAnchor;
    model.hitAPlane = hitPlane;
    return model;
}
@end
