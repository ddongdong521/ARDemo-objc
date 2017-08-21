//
//  Plane.m
//  ARDemo
//
//  Created by apple on 2017/8/2.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "Plane.h"
#import "SettingManager.h"
@implementation Plane

- (instancetype)initWithAnchor:(ARPlaneAnchor *)anchor ShowDebugVisualization:(BOOL)showDebugVisualization{
    if (self = [super init]) {
        self.anchor = anchor;
        self.occlusionPlaneVerticalOffset = -0.01;
        [self showDebugVisualization:showDebugVisualization];
    }
    BOOL useOcclusionPlanes = [SettingManager getPopulateSettingWithSetting:SettingUseOcclusionPlanes];
    if (useOcclusionPlanes) {
        [self createOcclusionNode];
    }
    return self;
}
- (void)updateWithAnchor:(ARPlaneAnchor *)anchor{
    self.anchor = anchor;
    if (self.debugVisualization) {
        [self.debugVisualization updateWithAnchor:anchor];
    }
    BOOL useOcclusionPlanes = [SettingManager getPopulateSettingWithSetting:SettingUseOcclusionPlanes];
    if (useOcclusionPlanes) {
    [self updateOcclusionNode];
    }
    
    
}
- (void)showDebugVisualization:(BOOL)show{
    if (show){
        if (self.debugVisualization==nil) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                self.debugVisualization = [[PlaneDebugVisualization alloc]initWithAnchor:self.anchor];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addChildNode:self.debugVisualization];
                });
            });
        }
    }else{
        if (self.debugVisualization) {
            [self.debugVisualization removeFromParentNode];
            self.debugVisualization = nil;
        }
    }
}
- (void)updateOcclusionSetting{
    BOOL useOcclusionPlanes = [SettingManager getPopulateSettingWithSetting:SettingUseOcclusionPlanes];
    if (useOcclusionPlanes) {
        if (self.occlusionNode==nil) {
            [self createOcclusionNode];
        }
    }else{
        if (self.occlusionNode) {
            [self.occlusionNode removeFromParentNode];
            self.occlusionNode = nil;
        }
    }
    
}

- (void)createOcclusionNode{
    SCNPlane *occlusionPlane = [SCNPlane planeWithWidth:self.anchor.extent.x - 0.05 height:self.anchor.extent.z - 0.05];
    SCNMaterial *material = [[SCNMaterial alloc]init];
    material.colorBufferWriteMask = 0;
    material.doubleSided = YES;
    occlusionPlane.materials = @[material];
    
    self.occlusionNode = [[SCNNode alloc]init];
    self.occlusionNode.geometry = occlusionPlane;
    self.occlusionNode.transform = SCNMatrix4MakeRotation(-M_PI_2, 1, 0, 0);
    self.occlusionNode.position = SCNVector3Make(self.anchor.center.x, self.occlusionPlaneVerticalOffset, self.anchor.center.z);
    [self addChildNode:self.occlusionNode];
}
- (void)updateOcclusionNode{
    
    if (!self.occlusionNode||![self.occlusionNode.geometry isKindOfClass:[SCNPlane class]]) {
        return;
    }
    SCNPlane *occlusionPlane = (SCNPlane *)self.occlusionNode.geometry;
    occlusionPlane.width = self.anchor.extent.x - 0.05;
    occlusionPlane.height = self.anchor.extent.z - 0.05;
    
    self.occlusionNode.position = SCNVector3Make(self.anchor.center.x, self.occlusionPlaneVerticalOffset, self.anchor.center.z);
    
    
    if (!self.occlusionNode) {
        return;
    }
    if (![self.geometry isKindOfClass:[SCNPlane class]]) {
        return;
    }
    
}

@end
