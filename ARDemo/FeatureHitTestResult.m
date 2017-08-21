//
//  FeatureHitTestResult.m
//  ARDemo
//
//  Created by apple on 2017/7/26.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "FeatureHitTestResult.h"

@implementation FeatureHitTestResult
- (instancetype)initWithPosition:(SCNVector3)position DistanceToRayOrigin:(CGFloat)distanceToRayOrigin FeatureHit:(SCNVector3)featureHit FeatureDistanceToHitResult:(CGFloat)featureDistanceToHitResult{
    if(self = [super init]){
        self.position = position;
        self.featureHit = featureHit;
        self.featureDistanceToHitResult = featureDistanceToHitResult;
        self.distanceToRayOrigin = distanceToRayOrigin;
    }
    return self;
}
@end
