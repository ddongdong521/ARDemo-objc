//
//  HitTestVisualization.m
//  ARDemo
//
//  Created by apple on 2017/8/3.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "HitTestVisualization.h"
#import "SimpleGeometriesTool.h"
#import "SCNVector3Tool.h"

@implementation HitTestVisualization
-(void)dealloc{
    [self.hitTestPointParentNode removeFromParentNode];
    [self.overlayView removeFromSuperview];
}
- (instancetype)initWithSceneView:(ARSCNView *)sceneView{
    if (self = [super init]) {
        self.sceneView = sceneView;
        self.minHitDistance = 0.01;
        self.maxHitDistance = 4.5;
        self.xAxisSamples = 6;
        self.yAxisSamples = 6;
        self.fieldOfViewWidth = 0.8;
        self.fieldOfViewHeight = 0.8;
        self.hitTestPointParentNode = [SCNNode node];
        self.overlayView = [[LineOverlayView alloc]init];
        self.overlayView.backgroundColor = [UIColor clearColor];
        self.overlayView.frame = sceneView.frame;
        [sceneView addSubview:self.overlayView];
    }
    return self;
}
- (void)setupHitTestResultPoints{
    if (self.hitTestPointParentNode.parentNode==nil) {
        [self.sceneView.scene.rootNode addChildNode: self.hitTestPointParentNode];
    }
    while (self.hitTestPoints.count < self.xAxisSamples * self.yAxisSamples) {
        [self.hitTestPoints addObject: [SimpleGeometriesTool createCrossNodeWithSize:0.01 Color:[UIColor blueColor] Horizontal:NO Opacity:1.0]];
        [self.hitTestFeaturePoints addObject:[SimpleGeometriesTool createCrossNodeWithSize:0.01 Color:[UIColor yellowColor] Horizontal:YES Opacity:1.0]];
    }
    
}
- (void)render{
    for (SCNNode *node in self.hitTestPointParentNode.childNodes) {
        [node removeFromParentNode];
        node.geometry = nil;
    }
    [self setupHitTestResultPoints];
    CGFloat xAxisOffset = (1 - self.fieldOfViewWidth) / 2;
    CGFloat yAxisOffset = (1 - self.fieldOfViewHeight) / 2;
    
    CGFloat stepX = self.fieldOfViewWidth /(self.xAxisSamples - 1);
    CGFloat stepY = self.fieldOfViewHeight /(self.yAxisSamples - 1);
    CGFloat screenSpaceX = xAxisOffset;
    CGFloat screenSpaceY = yAxisOffset;
    
    for (int i = 0; i < self.xAxisSamples; i++) {
        screenSpaceX = xAxisOffset + (i * stepX);
        for (int j = 0; j < self.yAxisSamples; j++) {
            screenSpaceY = yAxisOffset + (j * stepY);
            SCNNode *hitTestPoint = self.hitTestPoints[(i * self.yAxisSamples) + j];
            NSArray *hitTestResults = [self.sceneView.session.currentFrame hitTest:CGPointMake(screenSpaceX, screenSpaceY) types: ARHitTestResultTypeFeaturePoint];
            if (hitTestResults.count==0) {
                hitTestPoint.hidden = YES;
                continue;
            }
            hitTestPoint.hidden = NO;
            ARHitTestResult *result = hitTestResults[0];
            SCNVector3 hitTestPointPosition = [SCNVector3Tool positionFromTransform:result.worldTransform];
            hitTestPoint.position = hitTestPointPosition;
            [self.hitTestPointParentNode addChildNode: hitTestPoint];
            
            SCNVector3 localPointPosition = [SCNVector3Tool positionFromTransform:result.localTransform];
            SCNVector3 featurePosition = SCNVector3Make(hitTestPointPosition.x - localPointPosition.x, hitTestPointPosition.y - localPointPosition.y, hitTestPointPosition.z - localPointPosition.z);
            SCNNode *hitTestFeaturePoint = self.hitTestFeaturePoints[(i * self.yAxisSamples) + j];
            hitTestFeaturePoint.position = featurePosition;
            [self.hitTestPointParentNode addChildNode:hitTestFeaturePoint];
            [self.overlayView addLineWithStart:[self screenPointForPoint:hitTestPointPosition] End:[self screenPointForPoint:featurePosition]];
            
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.overlayView setNeedsDisplay];
    });
}
- (CGPoint)screenPointForPoint:(SCNVector3)point{
    SCNVector3 projectedPoint = [self.sceneView projectPoint:point];
    return CGPointMake(projectedPoint.x, projectedPoint.y);
}
- (NSMutableArray <SCNNode *>*)hitTestPoints{
    if (!_hitTestPoints) {
        _hitTestPoints = [NSMutableArray array];
    }
    return _hitTestPoints;
}
- (NSMutableArray <SCNNode *>*)hitTestFeaturePoints{
    if (!_hitTestFeaturePoints) {
        _hitTestFeaturePoints = [NSMutableArray array];
    }
    return _hitTestFeaturePoints;
}
@end
