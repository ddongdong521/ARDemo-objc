//
//  SingleFingerGesture.h
//  ARDemo
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "Gesture.h"

@interface SingleFingerGesture : Gesture

@property (nonatomic,assign)CGPoint initialTouchLocation;
@property (nonatomic,assign)CGPoint latestTouchLocation;
@property (nonatomic,assign)CGFloat translationThreshold;
@property (nonatomic,assign)BOOL translationThresholdPassed;
@property (nonatomic,assign)BOOL hasMovedObject;
@property (nonatomic,assign)BOOL firstTouchWasOnObject;
@property (nonatomic,assign)CGPoint dragOffset;




@end
