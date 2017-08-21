//
//  Plane.h
//  ARDemo
//
//  Created by apple on 2017/8/2.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import "FocusSquare.h"
#import "PlaneDebugVisualization.h"

@interface Plane : SCNNode

@property (nonatomic,strong)ARPlaneAnchor *anchor;
@property (nonatomic,strong)SCNNode *occlusionNode;
@property (nonatomic,assign)CGFloat occlusionPlaneVerticalOffset;
@property (nonatomic,strong)PlaneDebugVisualization *debugVisualization;
@property (nonatomic,strong)FocusSquare *focusSquare;


- (instancetype)initWithAnchor:(ARPlaneAnchor *)anchor ShowDebugVisualization:(BOOL)showDebugVisualization;
- (void)updateWithAnchor:(ARPlaneAnchor *)anchor;
- (void)showDebugVisualization:(BOOL)show;
- (void)updateOcclusionSetting;
@end
