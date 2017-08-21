//
//  SingleFingerGesture.m
//  ARDemo
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "SingleFingerGesture.h"
#import "VirtualObject.h"
#import "CGPointTool.h"

@implementation SingleFingerGesture
- (instancetype)initWithTouches:(NSSet<UITouch *> *)touches SceneView:(ARSCNView *)sceneView VirtualObject:(VirtualObject *)virtualObject{
    self = [super initWithTouches:touches SceneView:sceneView VirtualObject:virtualObject];
    if (self) {
        self.translationThreshold = 30;
        self.translationThresholdPassed = NO;
        self.hasMovedObject = NO;
        self.firstTouchWasOnObject = NO;
        UITouch *touch = self.currentTouches.anyObject;
        self.initialTouchLocation = [touch locationInView:sceneView];
        self.latestTouchLocation = self.initialTouchLocation;
        NSMutableDictionary *hitTestOptions = [NSMutableDictionary dictionary];
        hitTestOptions[SCNHitTestOptionBoundingBoxOnly] =@(YES);
        NSArray <SCNHitTestResult *>*results = [sceneView hitTest:self.initialTouchLocation options:hitTestOptions];
        for (SCNHitTestResult *result in results) {
            if ([VirtualObject isNodePartOfVirtualObject:result.node]) {
                self.firstTouchWasOnObject = YES;
                break;
            }
        }
    }
    return self;
}
- (void)updateGesture{
    UITouch *touch = self.currentTouches.anyObject;
    self.latestTouchLocation = [touch locationInView:self.sceneView];
    if (!self.translationThresholdPassed) {
        CGPoint initialLocationToCurrentLocation = CGPointMake(self.latestTouchLocation.x - self.initialTouchLocation.x, self.latestTouchLocation.y - self.initialTouchLocation.y);
        CGFloat distanceFromStartLocation = [CGPointTool lengthWithCGPoint:initialLocationToCurrentLocation];
        if (distanceFromStartLocation >= self.translationThreshold) {
            self.translationThresholdPassed = YES;
            
            CGPoint currentObjectLocation = [CGPointTool makePointWithSCNVector3:[self.sceneView projectPoint:self.virtualObject.position]];
            self.dragOffset = CGPointMake(self.latestTouchLocation.x - currentObjectLocation.x, self.latestTouchLocation.y - currentObjectLocation.y);
        }
    }
    if(self.translationThresholdPassed&&self.firstTouchWasOnObject){
        CGPoint offsetPos = CGPointMake(self.latestTouchLocation.x - self.dragOffset.x, self.latestTouchLocation.y - self.dragOffset.y);
        [self.virtualObject translateBasedOnScreenPos:offsetPos Instantly:NO InfinitePlane:YES];
        self.hasMovedObject = YES;
    }
}
- (void)finishGesture{
    
    if (self.currentTouches.count > 1) {
        return;
    }
    if (self.hasMovedObject) {
        return;
    }
    BOOL objectHit = NO;
    NSMutableDictionary *hitTestOptions = [NSMutableDictionary dictionary];
    hitTestOptions[SCNHitTestOptionBoundingBoxOnly] =@(YES);
     NSArray <SCNHitTestResult *>*results = [self.sceneView hitTest:self.latestTouchLocation options:hitTestOptions];
    for (SCNHitTestResult *result in results) {
        if ([VirtualObject isNodePartOfVirtualObject:result.node]) {
            objectHit = YES;
        }
    }
    if (!objectHit || [self approxScreenSpaceCoveredByTheObject] > 0.5 ) {
        if (!self.translationThresholdPassed){
            [self.virtualObject translateBasedOnScreenPos:self.latestTouchLocation Instantly:YES InfinitePlane:NO];
        }
    }
    
}
- (CGFloat)approxScreenSpaceCoveredByTheObject{
    NSInteger xAxisSamples = 6;
    NSInteger yAxisSamples = 6;
    CGFloat fieldOfViewWidth = 0.8;
    CGFloat fieldOfViewHeight = 0.8;
    
    CGFloat xAxisOffset = (1 - fieldOfViewWidth) / 2;
    CGFloat yAxisOffset = (1 - fieldOfViewHeight) / 2;
    
    CGFloat stepX = fieldOfViewWidth /(xAxisSamples - 1);
    CGFloat stepY = fieldOfViewWidth /(yAxisSamples - 1);
    
    CGFloat successFulHits = 0;
    CGFloat screenSpaceX = xAxisOffset;
    CGFloat screenSpaceY = yAxisOffset;
    
    NSMutableDictionary *hitTestOptions = [NSMutableDictionary dictionary];
    hitTestOptions[SCNHitTestOptionBoundingBoxOnly] =@(YES);
    for (int i = 0; i < xAxisSamples; i++) {
        screenSpaceX = xAxisOffset + (i * stepX);
        for (int j = 0; j < yAxisSamples; j++) {
            screenSpaceY = yAxisOffset + (j * stepY);
            CGPoint point = CGPointMake(screenSpaceX * self.sceneView.frame.size.width, screenSpaceY * self.sceneView.frame.size.height);
            NSArray <SCNHitTestResult *> *results = [self.sceneView hitTest:point options:hitTestOptions];
            for (SCNHitTestResult *result in results) {
                if ([VirtualObject isNodePartOfVirtualObject:result.node]) {
                    successFulHits += 1;
                    break;
                }
            }
        }
    }
    return successFulHits / (xAxisSamples * yAxisSamples);
}
@end
