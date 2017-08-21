//
//  ARSCNView+Extension.h
//  ARDemo
//
//  Created by apple on 2017/7/21.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <ARKit/ARKit.h>
#import "FeatureHitTestResult.h"

struct HitTestRay {
    SCNVector3 origin;
    SCNVector3 direction;
};
typedef struct HitTestRay HitTestRay;


@interface ARSCNView (Extension)


- (HitTestRay)hitTestRayFromScreenPos:(CGPoint)point;


- (SCNVector3)hitTestWithInfiniteHorizontalPlane:(CGPoint)point PointOnPlane:(SCNVector3)pointOnPlane;


- (NSMutableArray <FeatureHitTestResult *>*)hitTestWithFeatures:(CGPoint)point ConeOpeningAngleInDegrees:(CGFloat)coneOpeningAngleInDegrees MinDistance:(CGFloat)minDistance MaxDistance:(CGFloat)maxDistance MaxResults:(NSInteger)maxResults;


- (FeatureHitTestResult *)hitTestFromOrigin:(SCNVector3)origin Direction:(SCNVector3)direction;

- (NSArray<FeatureHitTestResult *>*)hitTestWithFeatures:(CGPoint)point;

@end

