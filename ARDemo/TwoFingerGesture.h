//
//  TwoFingerGesture.h
//  ARDemo
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "Gesture.h"

@interface TwoFingerGesture : Gesture
@property (nonatomic, strong) UITouch *firstTouch;
@property (nonatomic, strong) UITouch *secondTouch;

@property (nonatomic, assign)CGFloat translationThreshold;
@property (nonatomic, assign)CGFloat translationThresholdHarder;
@property (nonatomic, assign)BOOL translationThresholdPassed;;
@property (nonatomic, assign)BOOL allowTranslation;;
@property (nonatomic, assign)CGPoint dragOffset;
@property (nonatomic, assign)CGPoint initialMidPoint;

@property (nonatomic, assign)CGFloat rotationThreshold;
@property (nonatomic, assign)CGFloat rotationThresholdHarder;
@property (nonatomic, assign)BOOL rotationThresholdPassed;
@property (nonatomic, assign)BOOL allowRotation;
@property (nonatomic, assign)CGFloat initialFingerAngle;
@property (nonatomic, assign)CGFloat initialObjectAngle;

@property (nonatomic, assign)CGFloat scaleThreshold;
@property (nonatomic, assign)CGFloat scaleThresholdHarder;
@property (nonatomic, assign)BOOL scaleThresholdPassed;
@property (nonatomic, assign)BOOL allowScaling;
@property (nonatomic, assign)CGFloat initialDistanceBetweenFingers;
@property (nonatomic, assign)CGFloat baseDistanceBetweenFingers;
@property (nonatomic, assign)CGFloat objectBaseScale;




@end
