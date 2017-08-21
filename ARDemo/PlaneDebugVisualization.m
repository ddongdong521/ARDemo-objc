//
//  PlaneDebugVisualization.m
//  ARDemo
//
//  Created by apple on 2017/8/2.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "PlaneDebugVisualization.h"
#import "SimpleGeometriesTool.h"
#import <UIKit/UIKit.h>
@implementation PlaneDebugVisualization
- (instancetype)initWithAnchor:(ARPlaneAnchor *)anchor{
    if (self = [super init]) {
        self.planeAnchor = anchor;
        UIImage *grid = [UIImage imageNamed:@"Models.scnassets/plane_grid.png"];
        self.planeGeometry = [SimpleGeometriesTool createPlaneWithSize:CGSizeMake(anchor.extent.x, anchor.extent.z) Contents:grid];
        self.planeNode = [SCNNode nodeWithGeometry:self.planeGeometry];
        self.planeNode.transform = SCNMatrix4MakeRotation(-M_PI_2, 1, 0, 0);
        SCNNode *originVisualizationNode = [SimpleGeometriesTool createAxesNodeWithQuiverLength:0.1 QuiverThickness:1.0];
        [self addChildNode: originVisualizationNode];
        [self addChildNode: self.planeNode];
        self.position = SCNVector3Make(anchor.center.x, -0.002, anchor.center.z);
        [self adjustScale];
    }
    return self;
}
- (void)updateWithAnchor:(ARPlaneAnchor *)anchor{
    self.planeAnchor = anchor;
    self.planeGeometry.width = anchor.extent.x;
    self.planeGeometry.height = anchor.extent.z;
    self.position = SCNVector3Make(anchor.center.x, -0.002, anchor.center.z);
    [self adjustScale];
}

- (void)adjustScale{
    CGFloat scaledWidth = self.planeGeometry.width / 2.4;
    CGFloat scaledHeight = self.planeGeometry.height / 2.4;
    CGFloat offsetWidth = -0.5 * (scaledWidth - 1);
    CGFloat offsetHeight = -0.5 * (scaledHeight - 1);
    
    SCNMaterial *material = [self.planeGeometry.materials firstObject];
    SCNMatrix4 transform = SCNMatrix4MakeScale(scaledWidth, scaledHeight, 1);
    transform = SCNMatrix4Translate(transform, offsetWidth, offsetHeight, 0);
    material.diffuse.contentsTransform = transform;
    
}

@end
