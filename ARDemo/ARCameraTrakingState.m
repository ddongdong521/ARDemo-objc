//
//  ARCameraTrakingState.m
//  ARDemo
//
//  Created by apple on 2017/8/4.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "ARCameraTrakingState.h"

@implementation ARCameraTrakingState
+ (instancetype)cameraTrakingStateWithCamera:(ARCamera *)camera{
    ARCameraTrakingState *states = [[ARCameraTrakingState alloc]init];
    states.camera = camera;
    return states;
}

- (NSString *)presentationString{
    switch (self.camera.trackingState) {
        case ARTrackingStateNotAvailable:
            return @"TRACKING UNAVAILABLE";
            break;
        case ARTrackingStateNormal:
            return @"TRACKING NORMAL";
            break;
        case ARTrackingStateLimited:
            switch (self.camera.trackingStateReason) {
                case ARTrackingStateReasonExcessiveMotion:
                    return @"TRACKING LIMITED\nToo much camera movement";
                    break;
                case ARTrackingStateReasonInsufficientFeatures:
                    return @"TRACKING LIMITED\nNot enough surface detail";
                default:
                    break;
            }
        default:
            break;
    }
    return nil;
}

@end
