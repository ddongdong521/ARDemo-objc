//
//  Gesture.m
//  ARDemo
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "Gesture.h"
#import "SingleFingerGesture.h"
#import "TwoFingerGesture.h"

@implementation Gesture

- (instancetype)initWithTouches:(NSSet<UITouch *> *)touches SceneView:(ARSCNView *)sceneView VirtualObject:(VirtualObject *)virtualObject{
    if (self = [super init]) {
        self.currentTouches = [NSMutableSet setWithSet:touches];
        self.sceneView = sceneView;
        self.virtualObject = virtualObject;
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.016667 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self refreshCurrentGesture];
        }];
    }
    return self;
}
+ (Gesture *)startGestureFromTouches:(NSSet<UITouch *> *)touches SceneView:(ARSCNView *)sceneView VirtualObject:(VirtualObject *)virtualObject{
    if (touches.count == 1) {
        return [[SingleFingerGesture alloc]initWithTouches:touches SceneView:sceneView VirtualObject:virtualObject];
    }else if (touches.count == 2){
        return [[TwoFingerGesture alloc]initWithTouches:touches SceneView:sceneView VirtualObject:virtualObject];
    }else{
        return nil;
    }
}
- (Gesture *)updateGestureFromTouches:(NSSet<UITouch *> *)touches Type:(TouchEventType)type{
    if (touches.count==0) {
        return  self;
    }
    if (type == TouchEventTypeTouchBegan|| type ==TouchEventTypeTouchMoved) {
        [self.currentTouches unionSet:touches];
    }else if(type ==TouchEventTypeTouchEnded||type ==TouchEventTypeTouchCancelled){
        [self.currentTouches minusSet:touches];
    }
    if ([self isKindOfClass:[SingleFingerGesture class]]) {
        if (self.currentTouches.count == 1) {
            [self updateGesture];
            return self;
        }else{
            [self finishGesture];
            if(self.refreshTimer){
            [self.refreshTimer invalidate];
            self.refreshTimer = nil;
            }
            return [Gesture startGestureFromTouches:self.currentTouches SceneView:self.sceneView VirtualObject:self.virtualObject];
        }
    }else if ([self isKindOfClass:[TwoFingerGesture class]]){
        if (self.currentTouches.count == 2) {
            [self updateGesture];
            return self;
        }else{
            [self finishGesture];
            if (self.refreshTimer) {
                [self.refreshTimer invalidate];
                self.refreshTimer = nil;
            }
            return nil;
        }
    }else{
        return self;
    }
}
- (void)refreshCurrentGesture{
    [self updateGesture];
    
}
- (void)finishGesture{
    
}
- (void)updateGesture{
   
}

@end
