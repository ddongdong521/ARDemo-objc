//
//  SCNNode+Extension.m
//  ARDemo
//
//  Created by apple on 2017/7/26.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "SCNNode+Extension.h"
#import <objc/runtime.h>
@implementation SCNNode (Extension)
- (BOOL)reactsToScale{
    Protocol *pro = NSProtocolFromString(@"reactsToScale");
    BOOL canRecat = [self conformsToProtocol:pro];
    if (canRecat) {
        return canRecat;
    }
    if (self.parentNode){
        return [self.parentNode reactsToScale];
    }
    return NO;
}
- (void)setUniformScale:(CGFloat)scale{
    self.scale = SCNVector3Make(scale, scale, scale);
}
- (void)renderOnTop{
    self.renderingOrder = 2;
    if (self.geometry) {
        for (SCNMaterial *material in self.geometry.materials) {
            material.readsFromDepthBuffer = NO;
        }
    }
    for (SCNNode *child in self.childNodes) {
        [child renderOnTop];
    }
    
}
@end
