//
//  ARSCNView+Extension.m
//  ARDemo
//
//  Created by apple on 2017/7/21.
//  Copyright © 2017年 Jaydon. All rights reserved.
//

#import "ARSCNView+Extension.h"
#import "SCNVector3Tool.h"
#import "SceneKitTool.h"


@implementation ARSCNView (Extension)


- (HitTestRay)hitTestRayFromScreenPos:(CGPoint)point{
    SCNVector3 cameraPos = [SCNVector3Tool positionFromTransform:self.session.currentFrame.camera.transform];
    SCNVector3 positionVec = SCNVector3Make(point.x, point.y, 1.0);
    SCNVector3 screenPosOnFarClippingPlane = [self unprojectPoint:positionVec];
    
    SCNVector3 rayDirection = SCNVector3Make(screenPosOnFarClippingPlane.x - cameraPos.x, screenPosOnFarClippingPlane.y - cameraPos.y, screenPosOnFarClippingPlane.z - cameraPos.z);
    rayDirection = [SCNVector3Tool normalizedWithSCNVector3:rayDirection];
    HitTestRay testRay = {cameraPos,rayDirection};
    return testRay;
}

- (SCNVector3)hitTestWithInfiniteHorizontalPlane:(CGPoint)point PointOnPlane:(SCNVector3)pointOnPlane{
    HitTestRay ray = [self hitTestRayFromScreenPos:point];
    if (ray.direction.y > -0.03) {
        return SCNVector3Zero;
    }
    return [SceneKitTool rayIntersectionWithHorizontalPlane:ray.origin Direction:ray.direction PlaneY:pointOnPlane.y];
}
- (NSMutableArray <FeatureHitTestResult *>*)hitTestWithFeatures:(CGPoint)point ConeOpeningAngleInDegrees:(CGFloat)coneOpeningAngleInDegrees MinDistance:(CGFloat)minDistance MaxDistance:(CGFloat)maxDistance MaxResults:(NSInteger)maxResults{
    NSMutableArray <FeatureHitTestResult *>*results = [NSMutableArray array];
    
    CGFloat maxAngleInDeg = MIN(coneOpeningAngleInDegrees, 360);
    CGFloat maxAngle = (maxAngleInDeg / 180) * M_PI;
    ARPointCloud *features = self.session.currentFrame.rawFeaturePoints;
    HitTestRay ray = [self hitTestRayFromScreenPos:point];
    const vector_float3 *points = features.points;
    for (int i = 0; i<features.count; i++) {
       const vector_float3 * feature = points + i;
        SCNVector3 featurePos = [SCNVector3Tool makeSCNVector3With: *feature];
        SCNVector3 originToFeature = SCNVector3Make(featurePos.x - ray.origin.x , featurePos.y - ray.origin.y, featurePos.z - ray.origin.z);
        SCNVector3 crossProduct = [SCNVector3Tool crossWithSCNVector3_1:originToFeature SCNVector3_2:ray.direction];
        CGFloat featureDistanceFromResult = [SCNVector3Tool lengthWith:crossProduct];
        SCNVector3 origin = ray.origin;
        SCNVector3 direction = ray.direction;
        CGFloat  dot = [SCNVector3Tool dotWithSCNVector3:ray.direction SCNVector3_2:originToFeature];
        
        SCNVector3 hitTestResult = SCNVector3Make(origin.x +(direction.x * dot) , origin.y +(direction.y * dot), origin.z +(direction.z * dot));
        SCNVector3 pointDistance = SCNVector3Make(hitTestResult.x - origin.x, hitTestResult.y - origin.y, hitTestResult.z - origin.z);
        CGFloat distance = [SCNVector3Tool lengthWith:pointDistance];
        if (distance < minDistance || distance > maxDistance ){
            continue;
        }
        SCNVector3 originToFeatureNormalized = [SCNVector3Tool normalizedWithSCNVector3:originToFeature];
        CGFloat angleBetweenRayAndFeature = acos([SCNVector3Tool dotWithSCNVector3:direction SCNVector3_2:originToFeatureNormalized]);
        if (angleBetweenRayAndFeature > maxAngle ){
            continue;
        }
        FeatureHitTestResult *result = [[FeatureHitTestResult alloc]initWithPosition:hitTestResult DistanceToRayOrigin:distance FeatureHit:featurePos FeatureDistanceToHitResult:featureDistanceFromResult];
        [results addObject:result];
        
    }
    [results sortUsingComparator:^NSComparisonResult(FeatureHitTestResult* obj1, FeatureHitTestResult *obj2) {
        return obj1.distanceToRayOrigin < obj2.distanceToRayOrigin;
    }];
    
    NSMutableArray <FeatureHitTestResult *> *cappedResults = [NSMutableArray array];
    int i = 0 ;
    while (i < maxResults&&i < results.count) {
        [cappedResults addObject:results[i]];
        i ++;
    }
    
    return cappedResults;
}
- (FeatureHitTestResult *)hitTestFromOrigin:(SCNVector3)origin Direction:(SCNVector3)direction{
    ARPointCloud *features = self.session.currentFrame.rawFeaturePoints;
    const vector_float3 *points = features.points;
    SCNVector3 closestFeaturePoint = origin;
    CGFloat minDistance = MAXFLOAT;
    for (int i = 0;i < features.count; i++) {
        const vector_float3 * feature = points + i;
        SCNVector3 featurePos = [SCNVector3Tool makeSCNVector3With:*feature];
        SCNVector3 originVector = SCNVector3Make(origin.x - featurePos.x, origin.y - featurePos.y, origin.z - featurePos.z);
        SCNVector3 crossProduct = [SCNVector3Tool crossWithSCNVector3_1:originVector SCNVector3_2:direction];
        CGFloat featureDistanceFromResult = [SCNVector3Tool lengthWith:crossProduct];
        if (featureDistanceFromResult < minDistance) {
            closestFeaturePoint = featurePos;
            minDistance = featureDistanceFromResult;
        }
    }
    
    SCNVector3 originToFeature = SCNVector3Make(closestFeaturePoint.x - origin.x, closestFeaturePoint.y - origin.y, closestFeaturePoint.z - origin.z);
    SCNVector3 hitTestResult = SCNVector3Make(origin.x + (direction.x * [SCNVector3Tool dotWithSCNVector3:direction SCNVector3_2:originToFeature]), origin.y + (direction.y * [SCNVector3Tool dotWithSCNVector3:direction SCNVector3_2:originToFeature]), origin.z + (direction.z * [SCNVector3Tool dotWithSCNVector3:direction SCNVector3_2:originToFeature]));
    SCNVector3 distanceResult = SCNVector3Make(hitTestResult.x - origin.x, hitTestResult.y - origin.y, hitTestResult.z - origin.z);
    CGFloat hitTestResultDistance = [SCNVector3Tool lengthWith:distanceResult];
    return [[FeatureHitTestResult alloc]initWithPosition:hitTestResult DistanceToRayOrigin:hitTestResultDistance FeatureHit:closestFeaturePoint FeatureDistanceToHitResult:minDistance];
}
- (NSArray<FeatureHitTestResult *>*)hitTestWithFeatures:(CGPoint)point{
    NSMutableArray <FeatureHitTestResult *> *results = [NSMutableArray array];
    HitTestRay ray = [self hitTestRayFromScreenPos:point];
    SCNVector3 dir = ray.direction;
    SCNVector3 ori = ray.origin;
    if ((dir.x == 0 && dir.y == 0 && dir.z == 0)&& (ori.x == 0 && ori.y == 0 && ori.z == 0)){
        return results;
    }
    FeatureHitTestResult *result = [self hitTestFromOrigin:ray.origin Direction:ray.origin];
    [results addObject:result];
    return results;
}
@end
