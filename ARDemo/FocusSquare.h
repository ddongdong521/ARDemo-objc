//
//  FocusSquare.h
//  ARDemo
//
//  Created by apple on 2017/7/31.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface FocusSquare : SCNNode
@property (nonatomic,assign)SCNVector3 lastPosition;

- (void)hide;
- (void)unhide;
- (void)updateForPosition:(SCNVector3)position PlaneAnchor:(ARPlaneAnchor *)planeAnchor Camera:(ARCamera *)camera;
@end
