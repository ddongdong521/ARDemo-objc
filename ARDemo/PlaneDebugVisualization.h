//
//  PlaneDebugVisualization.h
//  ARDemo
//
//  Created by apple on 2017/8/2.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface PlaneDebugVisualization : SCNNode
@property (nonatomic,strong)ARPlaneAnchor *planeAnchor;
@property (nonatomic,strong)SCNPlane *planeGeometry;
@property (nonatomic,strong)SCNNode *planeNode;


- (instancetype)initWithAnchor:(ARPlaneAnchor *)anchor;


- (void)updateWithAnchor:(ARPlaneAnchor *)anchor;
@end
