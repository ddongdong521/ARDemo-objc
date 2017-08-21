//
//  TwoFingerGesture.m
//  ARDemo
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "TwoFingerGesture.h"
#import "CGPointTool.h"
#import "SCNVector3Tool.h"
#import "SCNNode+Extension.h"
#import "Candle.h"
#import "SettingManager.h"
@implementation TwoFingerGesture
- (instancetype)initWithTouches:(NSSet<UITouch *> *)touches SceneView:(ARSCNView *)sceneView VirtualObject:(VirtualObject *)virtualObject{
    if(self = [super initWithTouches:touches SceneView:sceneView VirtualObject:virtualObject]){
        self.firstTouch = [[UITouch alloc]init];
        self.secondTouch = [[UITouch alloc]init];
        self.translationThreshold = 40;
        self.translationThresholdHarder = 70;
        self.initialMidPoint = CGPointMake(0, 0);
        
        self.rotationThreshold = M_PI/15;
        self.rotationThresholdHarder = M_PI/10;
        self.initialFingerAngle = 0;
        self.initialObjectAngle = 0;
        
        self.scaleThreshold = 50;
        self.scaleThresholdHarder = 90;
        
        self.initialDistanceBetweenFingers = 0;
        self.baseDistanceBetweenFingers = 0;
        self.objectBaseScale = 1.0;
        
        self.firstTouch = self.currentTouches.allObjects[0];
        self.secondTouch = self.currentTouches.allObjects[1];
        
        CGPoint loc1 = [self.firstTouch locationInView:sceneView];
        CGPoint loc2 = [self.secondTouch locationInView:sceneView];
        CGPoint mp = CGPointMake((loc1.x+loc2.x)/2, (loc1.y+loc2.y)/2);
        self.initialMidPoint = mp;
        self.objectBaseScale = virtualObject.scale.x;
        
        BOOL firstTouchWasOnObject = NO;
        
        CGPoint oc1 = CGPointMake(loc1.x, loc2.y);
        CGPoint oc2 = CGPointMake(loc2.x, loc1.y);
        
         CGPoint dp1 = CGPointMake((oc1.x + loc1.x)/2, (oc1.y + loc1.y)/2);
         CGPoint dp2 = CGPointMake((oc1.x + loc2.x)/2, (oc1.y + loc2.y)/2);
         CGPoint dp3 = CGPointMake((oc2.x + loc1.x)/2, (oc2.y + loc1.y)/2);
         CGPoint dp4 = CGPointMake((oc2.x + loc2.x)/2, (oc2.y + loc2.y)/2);
         CGPoint dp5 = CGPointMake((mp.x + loc1.x)/2, (mp.y + loc1.y)/2);
         CGPoint dp6 = CGPointMake((mp.x + loc2.x)/2, (mp.y + loc2.y)/2);
         CGPoint dp7 = CGPointMake((mp.x + oc1.x)/2, (mp.y + oc2.y)/2);
         CGPoint dp8 = CGPointMake((mp.x + oc2.x)/2, (mp.y + oc2.y)/2);
        NSMutableDictionary *hitTestOptions = [NSMutableDictionary dictionary];
        hitTestOptions[SCNHitTestOptionBoundingBoxOnly] = @(YES);
        
        NSMutableArray <SCNHitTestResult *> *hitTestResults = [NSMutableArray array];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:loc1 options:hitTestOptions]];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:loc2 options:hitTestOptions]];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:oc1 options:hitTestOptions]];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:oc1 options:hitTestOptions]];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:dp1 options:hitTestOptions]];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:dp2 options:hitTestOptions]];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:dp3 options:hitTestOptions]];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:dp4 options:hitTestOptions]];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:dp5 options:hitTestOptions]];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:dp6 options:hitTestOptions]];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:dp7 options:hitTestOptions]];
        [hitTestResults addObjectsFromArray:[sceneView hitTest:dp8 options:hitTestOptions]];
           [hitTestResults addObjectsFromArray:[sceneView hitTest:mp options:hitTestOptions]];
        for (SCNHitTestResult *result in hitTestResults) {
            if ([VirtualObject isNodePartOfVirtualObject:result.node]) {
                firstTouchWasOnObject = YES;
                break;
            }
        }
        
        self.allowTranslation = firstTouchWasOnObject;
        self.allowRotation = firstTouchWasOnObject;
        BOOL scaleGestureEnabled = [SettingManager getPopulateSettingWithSetting:SettingScaleWithPinchGesture];
        self.allowScaling = scaleGestureEnabled&&(firstTouchWasOnObject || self.objectBaseScale < 0.1);
        
        CGPoint loc2ToLoc1 = CGPointMake(loc1.x - loc2.x, loc1.y - loc2.y);
        self.initialDistanceBetweenFingers = [CGPointTool lengthWithCGPoint:loc2ToLoc1];
        CGPoint midPointToLoc1 = CGPointMake(loc2ToLoc1.x/2, loc2ToLoc1.y/2);
        self.initialFingerAngle = atan2(midPointToLoc1.x, midPointToLoc1.y);
        self.initialObjectAngle = virtualObject.eulerAngles.y;
        
    }
    return self;
}
- (void)updateGesture{
    UITouch *newTouch1 = self.currentTouches.allObjects[0];
    UITouch *newTouch2 = self.currentTouches.allObjects[1];
    if (newTouch1.hash == self.firstTouch.hash) {
        self.firstTouch = newTouch1 ;
        self.secondTouch = newTouch2 ;
    }else{
        self.firstTouch = newTouch2;
        self.secondTouch = newTouch1;
    }
    
    CGPoint loc1 = [self.firstTouch locationInView:self.sceneView];
    CGPoint loc2 = [self.secondTouch locationInView:self.sceneView];
    if (self.allowTranslation) {
        [self updateTranslationWithMidPoint:[CGPointTool midPointFromPoint_1:loc1 ToPoint_2:loc2]];
    }
     CGPoint spanBetweenTouches = CGPointMake(loc1.x - loc2.x, loc1.y - loc2.y);
    if (self.allowRotation) {
        [self updateRotationWithSpan:spanBetweenTouches];
    }
    if (self.allowScaling) {
        [self updateScalingWithSpan:spanBetweenTouches];
    }
    
}
- (void)updateTranslationWithMidPoint:(CGPoint)midPoint{
    if (!self.translationThresholdPassed) {
        CGPoint initialLocationTocurrentLocation = CGPointMake(midPoint.x - self.initialMidPoint.x, midPoint.y - self.initialMidPoint.y);
        CGFloat distanceFromStartLocation = [CGPointTool lengthWithCGPoint:initialLocationTocurrentLocation];
        CGFloat threshold = self.translationThreshold;
        if (self.rotationThresholdPassed || self.scaleThresholdPassed) {
            threshold = self.translationThresholdHarder;
        }
        if (distanceFromStartLocation >= threshold) {
            self.translationThresholdPassed = YES;
            
            CGPoint currentObjectLocation = [CGPointTool makePointWithSCNVector3:[self.sceneView projectPoint:self.virtualObject.position]];
            self.dragOffset = CGPointMake(midPoint.x - currentObjectLocation.x, midPoint.y - currentObjectLocation.y);
        }
        if (self.translationThresholdPassed) {
            CGPoint offsetPos = CGPointMake(midPoint.x - self.dragOffset.x, midPoint.y - self.dragOffset.y);
            [self.virtualObject translateBasedOnScreenPos:offsetPos Instantly:NO InfinitePlane:YES];
        }
    }
}
- (void)updateRotationWithSpan:(CGPoint)span{
    CGPoint midpointToFirstTouch = CGPointMake(span.x /2, span.y /2);
    CGFloat currentAngle = atan2(midpointToFirstTouch.x, midpointToFirstTouch.y);
    
    CGFloat currentAngleToInitialFingerAngle = self.initialFingerAngle - currentAngle ;
    
    if (!self.rotationThresholdPassed) {
        CGFloat threshold = self.rotationThreshold;
        
        if (self.translationThresholdPassed || self.scaleThresholdPassed) {
            threshold = self.rotationThresholdHarder;
        }
        
        if(fabs(currentAngleToInitialFingerAngle) >threshold){
            
            self.rotationThresholdPassed = YES;
            if (currentAngleToInitialFingerAngle > 0) {
               self.initialObjectAngle += threshold;
            } else {
               self.initialObjectAngle -= threshold;
            }
        }
    }
    if (self.rotationThresholdPassed) {
        SCNVector3 temp = self.virtualObject.eulerAngles;
        temp.y = self.initialObjectAngle - currentAngleToInitialFingerAngle;
        self.virtualObject.eulerAngles = temp;
    }
    
}
- (void)updateScalingWithSpan:(CGPoint)span{
    CGFloat distanceBetweenFingers = [CGPointTool lengthWithCGPoint:span];
    if (!self.scaleThresholdPassed){
        
        CGFloat fingerSpread = fabs(distanceBetweenFingers - self.initialDistanceBetweenFingers);
        
        CGFloat threshold = self.scaleThreshold;
        
        if (self.translationThresholdPassed || self.rotationThresholdPassed ){
            threshold = self.scaleThresholdHarder;
        }
        
        if (fingerSpread > threshold) {
            self.scaleThresholdPassed = YES;
            self.baseDistanceBetweenFingers = distanceBetweenFingers;
        }
    }
    
    if (self.scaleThresholdPassed) {
        if (self.baseDistanceBetweenFingers != 0) {
            CGFloat relativeScale = distanceBetweenFingers / self.baseDistanceBetweenFingers;
            CGFloat newScale = self.objectBaseScale * relativeScale;
            
            self.virtualObject.scale = [SCNVector3Tool makeSCNVector3UniformValue:newScale];
            if( [self.virtualObject reactsToScale]){
                Candle *candle = (Candle *)self.virtualObject;
                [candle reactToScale];
            }
        }
    }
    
}
- (void)finishGesture{
    
}
@end
