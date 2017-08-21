//
//  FeatureHitTestResult.h
//  ARDemo
//
//  Created by apple on 2017/7/26.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>
@interface FeatureHitTestResult : NSObject

@property (nonatomic,assign)SCNVector3 position;
@property (nonatomic,assign)CGFloat distanceToRayOrigin;
@property (nonatomic,assign)SCNVector3 featureHit;
@property (nonatomic,assign)CGFloat featureDistanceToHitResult;


- (instancetype)initWithPosition:(SCNVector3)position DistanceToRayOrigin:(CGFloat)distanceToRayOrigin FeatureHit:(SCNVector3)featureHit FeatureDistanceToHitResult:(CGFloat)featureDistanceToHitResult;
@end
