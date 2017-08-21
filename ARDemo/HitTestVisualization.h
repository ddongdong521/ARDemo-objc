//
//  HitTestVisualization.h
//  ARDemo
//
//  Created by apple on 2017/8/3.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>
#import "LineOverlayView.h"

@interface HitTestVisualization : NSObject

@property (nonatomic,assign)CGFloat minHitDistance;
@property (nonatomic,assign)CGFloat maxHitDistance;
@property (nonatomic,assign)NSInteger xAxisSamples;
@property (nonatomic,assign)NSInteger yAxisSamples;
@property (nonatomic,assign)CGFloat fieldOfViewWidth;
@property (nonatomic,assign)CGFloat fieldOfViewHeight;

@property (nonatomic,strong)SCNNode *hitTestPointParentNode;
@property (nonatomic,strong)NSMutableArray <SCNNode *>*hitTestPoints;
@property (nonatomic,strong)NSMutableArray <SCNNode *>*hitTestFeaturePoints;
@property (nonatomic,strong)ARSCNView *sceneView;
@property (nonatomic,strong)LineOverlayView *overlayView;

- (instancetype)initWithSceneView:(ARSCNView *)sceneView;
- (void)setupHitTestResultPoints;
- (void)render;
- (CGPoint)screenPointForPoint:(SCNVector3)point;

@end
